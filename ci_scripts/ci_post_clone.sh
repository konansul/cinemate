#!/bin/sh

set -e

REPO="$CI_PRIMARY_REPOSITORY_PATH"

if [ -z "$TMDB_API_KEY" ]; then
    echo "error: TMDB_API_KEY is not set in the Xcode Cloud workflow environment"
    exit 1
fi

cat > "$REPO/Cinemate/Config/Secrets.swift" <<EOF
import Foundation

enum Secrets {
    static let tmdbAPIKey = "$TMDB_API_KEY"
}
EOF

echo "ci_post_clone: generated Secrets.swift"

if [ -z "$GOOGLE_SERVICE_INFO_PLIST_BASE64" ]; then
    echo "ci_post_clone: GOOGLE_SERVICE_INFO_PLIST_BASE64 is not set, skipping GoogleService-Info.plist"
    exit 0
fi

echo "$GOOGLE_SERVICE_INFO_PLIST_BASE64" | base64 --decode > "$REPO/Cinemate/GoogleService-Info.plist"

if ! plutil -lint "$REPO/Cinemate/GoogleService-Info.plist" > /dev/null; then
    echo "error: decoded GoogleService-Info.plist is not a valid property list"
    exit 1
fi

echo "ci_post_clone: generated GoogleService-Info.plist"
