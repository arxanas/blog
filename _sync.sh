#!/bin/bash
set -euo pipefail

# Trailing slash means to rename this folder, not move it into 'blog/'.
readonly SOURCE='_site/'  

readonly DEST='waleedkhan.name:home/blog'

# For Google Analytics.
# https://michaelsoolee.com/google-analytics-jekyll/
export JEKYLL_ENV='production'

main() {
    # In case I want a friend to preview one of my drafts, I can just build the
    # website with the drafts and have them look at it. Since realistically, no
    # one else is actually reading my blog.
    if [[ "$#" -lt 1 ]]; then
        echo "You must specify one of 'drafts' or 'posts'"
        exit 1
    fi

    local mode="$1"
    case "$mode" in
        'drafts')
            jekyll build --drafts
            ;;
        'posts')
            jekyll build
            ;;
        *)
            echo "Invalid mode $mode"
            exit 1
            ;;
    esac

    rsync -avz --delete "$SOURCE" "$DEST"
}

main "$@"
