#!/usr/bin/env bash
# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0
#
# Generates the semantic-convention Dart enums and their audit-test
# fixtures from the OpenTelemetry semantic-conventions registry using OTel
# Weaver, into three trees:
#
#   lib/src/stable/      conventions the registry calls `stable`
#   lib/src/incubating/  every convention, types suffixed `Incubating`
#   test/semconv/        generated audit of the incubating tree
#
# The incubating tree is a superset and re-declares the stable
# conventions, so code does not break when one graduates. The audit runs
# against it for that reason: it covers the whole surface.
#
# Usage:
#   tool/semconv/generate.sh            # regenerate in place
#   tool/semconv/generate.sh --check    # verify checked-in output is fresh
#
# The registry version is pinned below and fetched automatically, so no
# checkout is needed. To try an unreleased registry, point SEMCONV_REPO at a
# local one; its schema version must still match the pin.
set -euo pipefail

# Pinned registry version. Bump deliberately: it rewrites every generated
# file. Latest tag: `git tag -l --sort=version:refname | tail -1` in
# https://github.com/open-telemetry/semantic-conventions
SEMCONV_VERSION=1.44.0
SEMCONV_TAG="v$SEMCONV_VERSION"
SEMCONV_GIT_URL=https://github.com/open-telemetry/semantic-conventions.git

# Pinned to the same image digest the semantic-conventions repo pins
# (see its dependencies.Dockerfile).
WEAVER_IMAGE="docker.io/otel/weaver:v0.24.2@sha256:d1fb16d279f39810c340fbbf1cf9e5e995a3a9cefa531938e9012437e3bc00c1"

SEMCONV_REPO="${SEMCONV_REPO:-}"
PKG_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TEMPLATES_SRC="$PKG_ROOT/tool/semconv/templates"
# Weaver reads an assembled copy, not the committed tree: see the assembly
# step below.
TEMPLATES_DIR="$PKG_ROOT/tool/semconv/.templates"
STABLE_OUT="$PKG_ROOT/lib/src/stable"
INCUBATING_OUT="$PKG_ROOT/lib/src/incubating"
TEST_OUT="$PKG_ROOT/test/semconv"
MODE="${1:-generate}" # generate | --check
if [ "$MODE" != "generate" ] && [ "$MODE" != "--check" ]; then
  echo "Usage: $0 [--check]" >&2
  exit 2
fi

# Scratch directories. Both must live inside the repo, because paths
# outside Docker Desktop's shared file systems cannot be bind-mounted.
# They are removed on every exit, including a failure, so the working tree
# is left as it was found and nothing needs to be gitignored.
REGISTRY_DIR="$PKG_ROOT/tool/semconv/semantic-conventions"
CHECK_ROOT="$PKG_ROOT/tool/semconv/.check-out"
# Only set when this script created the clone, so that a registry passed in
# through SEMCONV_REPO is never deleted.
FETCHED_REGISTRY=
cleanup() {
  [ -z "$FETCHED_REGISTRY" ] || rm -rf "$FETCHED_REGISTRY"
  rm -rf "$CHECK_ROOT" "$TEMPLATES_DIR"
  return 0
}
trap cleanup EXIT

# Fetch the pinned registry, unless a local one was given. Shallow, and
# re-fetched each run so a stale directory cannot change the output.
if [ -n "$SEMCONV_REPO" ]; then
  REGISTRY_SRC="$SEMCONV_REPO"
else
  rm -rf "$REGISTRY_DIR"
  mkdir -p "$REGISTRY_DIR"
  FETCHED_REGISTRY="$REGISTRY_DIR"
  git -C "$REGISTRY_DIR" init -q
  git -C "$REGISTRY_DIR" remote add origin "$SEMCONV_GIT_URL"
  git -C "$REGISTRY_DIR" fetch -q --depth=1 origin "$SEMCONV_TAG"
  git -C "$REGISTRY_DIR" reset -q --hard FETCH_HEAD
  REGISTRY_SRC="$REGISTRY_DIR"
fi

if [ ! -f "$REGISTRY_SRC/model/manifest.yaml" ]; then
  echo "not a semantic-conventions registry: $REGISTRY_SRC" >&2
  exit 2
fi

# The registry must be the version this package pins, or the output would
# not match what is committed. `schema_url` ends in the version.
REGISTRY_VERSION="$(sed -n 's|^schema_url:.*/||p' "$REGISTRY_SRC/model/manifest.yaml" | tr -d '[:space:]')"
if [ "$REGISTRY_VERSION" != "$SEMCONV_VERSION" ]; then
  echo "registry is $REGISTRY_VERSION but this package pins $SEMCONV_VERSION" >&2
  exit 2
fi

# --short=8 explicitly: the default abbreviation length scales with the
# object count, so a shallow clone would otherwise write a shorter hash
# than a full one and make --check report stale.
REGISTRY_COMMIT="$(git -C "$REGISTRY_SRC" rev-parse --short=8 HEAD 2>/dev/null || echo unknown)"
# From the pin rather than `git describe`, which a shallow fetch cannot
# always resolve.
REGISTRY_DESCRIBE="$SEMCONV_TAG"

# Weaver resolves a target's `pattern:` and `{% import %}` inside that
# target's own directory, so a shared template has to be present in each
# one. Rather than commit copies that can drift apart, registry/dart holds
# the single copy and the other targets are assembled here:
#
#   dart_incubating  every template; only its weaver.yaml differs, in the
#                    type suffix and the stability filters
#   dart_test        macros.j2 only; its own templates emit the audits
rm -rf "$TEMPLATES_DIR"
mkdir -p "$TEMPLATES_DIR"
cp -R "$TEMPLATES_SRC/." "$TEMPLATES_DIR/"
cp "$TEMPLATES_SRC/registry/dart/"*.j2 "$TEMPLATES_DIR/registry/dart_incubating/"
cp "$TEMPLATES_SRC/registry/dart/macros.j2" "$TEMPLATES_DIR/registry/dart_test/"

# Match host uid/gid inside the container on Linux so generated files aren't
# root-owned. (Unnecessary on macOS Docker Desktop, which maps ownership.)
DOCKER_USER_ARG=()
[ "$(uname)" = "Linux" ] && DOCKER_USER_ARG=(-u "$(id -u):$(id -g)")

run_weaver() { # $1 = target name (templates/registry/<target>), $2 = output dir
  local target="$1" out="$2"
  mkdir -p "$out"
  # ${arr[@]+...} keeps `set -u` happy on bash 3.2 when the array is empty.
  docker run --rm ${DOCKER_USER_ARG[@]+"${DOCKER_USER_ARG[@]}"} --network=none \
    --mount "type=bind,source=$TEMPLATES_DIR,target=/home/weaver/templates,readonly" \
    --mount "type=bind,source=$REGISTRY_SRC/model,target=/home/weaver/source,readonly" \
    --mount "type=bind,source=$out,target=/home/weaver/target" \
    "$WEAVER_IMAGE" registry generate \
    --registry=/home/weaver/source \
    --templates=/home/weaver/templates \
    --param "semconv_version=$SEMCONV_VERSION" \
    --param "registry_commit=$REGISTRY_COMMIT" \
    --param "registry_describe=$REGISTRY_DESCRIBE" \
    "$target" \
    /home/weaver/target
}

generate_into() { # $1 = stable out, $2 = incubating out, $3 = test out
  local stable_out="$1" incubating_out="$2" test_out="$3"
  rm -rf "$stable_out" "$incubating_out" "$test_out"
  run_weaver dart "$stable_out"
  run_weaver dart_incubating "$incubating_out"
  run_weaver dart_test "$test_out"
  (cd "$PKG_ROOT" &&
    dart format "$stable_out" "$incubating_out" "$test_out" >/dev/null)
}

if [ "$MODE" = "--check" ]; then
  rm -rf "$CHECK_ROOT"
  mkdir -p "$CHECK_ROOT/stable" "$CHECK_ROOT/incubating" "$CHECK_ROOT/test"
  generate_into "$CHECK_ROOT/stable" "$CHECK_ROOT/incubating" \
    "$CHECK_ROOT/test"
  status=0
  diff -ru "$STABLE_OUT" "$CHECK_ROOT/stable" || status=1
  diff -ru "$INCUBATING_OUT" "$CHECK_ROOT/incubating" || status=1
  diff -ru "$TEST_OUT" "$CHECK_ROOT/test" || status=1
  if [ "$status" -ne 0 ]; then
    echo "ERROR: generated semconv code is stale; run tool/semconv/generate.sh" >&2
    exit 1
  fi
  echo "semconv generated code is up to date (registry $REGISTRY_DESCRIBE @ $REGISTRY_COMMIT)"
else
  generate_into "$STABLE_OUT" "$INCUBATING_OUT" "$TEST_OUT"
  echo "generated semconv code from registry $REGISTRY_DESCRIBE @ $REGISTRY_COMMIT (schema $SEMCONV_VERSION)"
fi
