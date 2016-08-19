#!/bin/bash
set -euo pipefail

readonly DRAFTS_DIR='_drafts'
readonly POSTS_DIR='_posts'

main() {
    local assets
    assets=$(find 'assets' -type f)

    local ret=0
    for i in $assets; do
        local asset_name
        asset_name=$(basename "$i")
        if ! grep -Rq "$asset_name" "$DRAFTS_DIR" && \
           ! grep -Rq "$asset_name" "$POSTS_DIR"; then
            echo "unused asset: $i"
            ret=1
        fi
    done

    return "$ret"
}

main
