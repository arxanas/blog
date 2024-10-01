#!/bin/bash
set -euo pipefail

readonly DRAFT_DIRS=('_i18n/en/_drafts' '_i18n/pl/_drafts')
readonly POST_DIRS=('_i18n/en/_posts' '_i18n/pl/_posts')

main() {
    local assets
    assets=$(find 'assets' -type f)

    local ret=0
    for i in $assets; do
        local asset_name
        asset_name=$(basename "$i")
        if [[ "$asset_name" == 'mathjax.js' ]]; then
          continue
        fi
        if ! grep -Rq "$asset_name" "${DRAFT_DIRS[@]}" && \
           ! grep -Rq "$asset_name" "${POST_DIRS[@]}"; then
            echo "unused asset: $i"
            ret=1
        fi
    done

    return "$ret"
}

main
