#!/usr/bin/env bash

set -euo pipefail

# TODO: Ensure this is the correct GitHub homepage where releases can be downloaded for websocat.
declare -r GH_REPO="https://github.com/vi/websocat"
declare -r TOOL_NAME="websocat"
declare -r TOOL_TEST="websocat --version"

fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if websocat is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
  git ls-remote --tags --refs "$GH_REPO" |
    grep -o 'refs/tags/.*' | cut -d/ -f3- |
    # v1.10.1 is a tag only
    sed -e '/^v[[:digit:]].*/!d' -e 's/^v//' -e 's/1\.10\.1//'
}

list_all_versions() {
  list_github_tags
}

download_release() {
  local version filename url
  version="$1"
  filename="$2"

  # See the release flavours in the /releases page of websocat
  # shellcheck disable=SC2155
  local uname_s="$(uname -s)"
  # shellcheck disable=SC2155
  local uname_m="$(uname -m)"

  # Give the user a way of overriding the auto-detected platform
  # shellcheck disable=SC2155
  local target="${ASDF_WEBSOCAT_DISTRO:-}"

  if [[ -z "${target}" ]]; then
    # https://doc.rust-lang.org/nightly/rustc/platform-support.html
    case "$uname_m" in
    aarch64)
      case "$uname_s" in
      Android) target="websocat.aarch64-linux-android" ;;
      Darwin)
        # Use x86_64 until native aarch64 binary released
        target="websocat.x86_64-apple-darwin"
        ;;
      Linux) target="websocat.aarch64-unknown-linux-musl" ;;
      *) fail "OS not supported: $uname_s" ;;
      esac
      ;;
    armv7*)
      case "$uname_s" in
      Android) target="websocat.armv7-linux-androideabi" ;;
      *) fail "OS not supported: $uname_s" ;;
      esac
      ;;
    arm64)
      case "$uname_s" in
      Darwin) target="websocat.aarch64-apple-darwin" ;;
      *) fail "OS not supported: $uname_s" ;;
      esac
      ;;
    arm*)
      case "$uname_s" in
      Linux) target="websocat.arm-unknown-linux-musleabi" ;;
      *) fail "OS not supported: $uname_s" ;;
      esac
      ;;
    i?86)
      case "$uname_s" in
      CYGWIN* | MINGW32_NT* | MSYS* | Windows*)
        target="websocat.i686-pc-windows-gnu.exe"
        ;;
      *) fail "OS not supported: $uname_s" ;;
      esac
      ;;
    x86_64)
      case "$uname_s" in
      Darwin) target="websocat.x86_64-apple-darwin" ;;
      FreeBSD) target="websocat.x86_64-unknown-freebsd" ;;
      Linux) target="websocat.x86_64-unknown-linux-musl" ;;
      CYGWIN* | MINGW32_NT* | MSYS* | Windows*)
        target="websocat.x86_64-pc-windows-gnu.exe"
        ;;
      *) fail "OS not supported: $uname_s" ;;
      esac
      ;;
    *) fail "Architecture not supported: $uname_m" ;;
    esac
  fi
  url="$GH_REPO/releases/download/v${version}/${target}"

  echo "* Downloading $TOOL_NAME release $version..."
  curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="${3%/bin}/bin"

  if [ "$install_type" != "version" ]; then
    fail "asdf-$TOOL_NAME supports release installs only"
  fi

  (
    mkdir -p "$install_path"
    cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"

    # TODO: Assert websocat executable exists.
    local tool_cmd
    tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
    test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

    echo "$TOOL_NAME $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error ocurred while installing $TOOL_NAME $version."
  )
}
