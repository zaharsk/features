#!/usr/bin/env bash
set -euo pipefail

ARCH="$(uname -m)"
DEST=/usr/local/bin
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"

err() {
    echo "(!) $*" >&2
}

REPO_OWNER=cocogitto
REPO_NAME=cocogitto

COG_VERSION="${VERSION}"
COG_COMPLETIONS="${COMPLETIONS}"

if [ "$COG_VERSION" == "latest" ]; then
    RELEASE_INFO="$(curl -fsSL https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest)"
    COG_VERSION="$(echo "${RELEASE_INFO}" | jq -er .tag_name)"
else
    RELEASE_INFO="$(curl -fsSL https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/tags/${COG_VERSION})"
fi

DOWNLOAD_URL="$(echo $RELEASE_INFO |
    jq -er --arg arch "$ARCH" --arg os "$OS" \
        '.assets[] | select(.name | contains($arch) and contains($os)) | .browser_download_url')"

FILE_NAME="${DOWNLOAD_URL#https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${COG_VERSION}/}"

FILE_NAME="${FILE_NAME#cocogitto-${COG_VERSION}-}"
FOLDER_NAME="${FILE_NAME%.tar.gz}"

TMP_DIR="$(mktemp -d)"

curl -fsSL -o "${TMP_DIR}/${FILE_NAME}" "${DOWNLOAD_URL}"

tar -tzf "${TMP_DIR}/${FILE_NAME}"
tar -xf "${TMP_DIR}/${FILE_NAME}" -C "${TMP_DIR}"

install -m 755 \
    "${TMP_DIR}/${FOLDER_NAME}/cog" \
    "${DEST}/cog"

rm -rf "${TMP_DIR}"

if [ "$COG_COMPLETIONS" == "true" ]; then
    cog generate-completions bash >/usr/share/bash-completion/completions/cog
fi

case "${COMPLETIONS}" in
none)
    ;;
bash)
    cog generate-completions bash >/usr/share/bash-completion/completions/cog
    ;;
zsh)
    cog generate-completions zsh >/usr/share/zsh/vendor-completions/_cog
    ;;
fish)
    cog generate-completions fish >/usr/share/fish/vendor_completions.d/cog.fish
    ;;
*)
    err "Unsupported completions shell: ${COMPLETIONS}"
    exit 1
    ;;
esac
