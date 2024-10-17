#!/bin/sh
# Function to parse gpg list keys output & only export
# public keys that are not expired (by gathered fingerprints)
# creates file ./publickeys.asc
export_public_gpgkeys() {
    EXPORTED_KEYS_FILE="$1"

    rm -f "$EXPORTED_KEYS_FILE"

    if ! output="$(gpg --list-keys --with-colons | grep -v '^(pub|fpr):')"; then
        printf '%s\n' "Retrieving gpg keys failed." >&2
        exit 1
    fi

    fingerprints=""

    make_tmpfile="mktmp"
    if ! command -v "$make_tmpfile" 1>/dev/null 2>&1; then
        make_tmpfile="mktemp" # Mac OS
        if ! command -v "$make_tmpfile" 1>/dev/null 2>&1; then
            error "ERROR: unable to find command to create temporary file."
            exit 1
        fi
    fi
    tmp="$($make_tmpfile)"
    printf '%s\n' "$output" > "$tmp"
    find_pub=true
    while IFS= read -r line <&3 || [ -n "$line" ]; do
    {
        if [ "$find_pub" = "true" ]; then
            if printf '%s\n' "$line" | grep -q "^pub:[^en]:"; then
                # pub:e:* means expired, pub:n:* means not trusted
                find_pub=false
                continue
            fi
        else
            if printf '%s\n' "$line" | grep -q "^fpr:"; then
                if ! fpr="$(printf '%s\n' "$line" | sed -r 's/^fpr::*([A-F0-9]*):$/\1/')"; then
                    printf '%s\n' "Failed to parse fingerprint in '$line'."
                    continue
                fi
                printf '%s\n' "Adding fingerprint: $fpr"
                if [ -n "$fingerprints" ]; then
                    fingerprints="$fingerprints\n"
                fi
                fingerprints="${fingerprints}${fpr}"
                find_pub=true
                continue
            fi
        fi
    } 3<&-
    done 3< "$tmp"
    rm -f "$tmp"

    # collapse newlines to spaces
    fingerprints="$(printf '%b\n' "$fingerprints" | tr '\n' ' ')"
    
    # Only export necessary elements of public keys
    export_filter="drop-subkey='secret == 0 || expired == 0 || revoked == 0 || disabled == 0'"

    # export the cleanest public keys possible selected by their fingerprint strings
    if ! gpg --export --armor --output "$EXPORTED_KEYS_FILE" --export-filter "$export_filter" --export-options export-clean $fingerprints; then
        printf >&2 '%s\n' "Failed to export public keys to $EXPORTED_KEYS_FILE"
        exit 1
    fi
    printf '%s\n' "Exported public keys to file $EXPORTED_KEYS_FILE"
}

export_public_gpgkeys "publickeys.asc"
