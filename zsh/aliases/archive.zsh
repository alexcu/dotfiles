#! /usr/bin/env zsh

#
# Archive creation and extraction dispatchers
#

# Homebrew's sevenzip ships the 7zz binary; older p7zip shipped 7z/7za.
function _archive_7z_bin() {
    local candidate
    for candidate in 7zz 7z 7za; do
        if command -v "$candidate" >/dev/null 2>&1; then
            echo "$candidate"
            return 0
        fi
    done
    echo "archive: 7-Zip not found (brew install sevenzip)" >&2
    return 1
}

# Shared usage for archive and unarchive.
function _archive_usage() {
    cat >&2 <<'EOF'
Usage: archive NAME[.suffix] PATH...   create an archive
       unarchive ARCHIVE [DEST]        extract an archive (DEST defaults to .)

The output suffix picks the compressor; no suffix defaults to .tar.zst.

  .tar.zst   everyday default: fast, strong, keeps Unix metadata (zstd -19, all cores)
  .7z        smallest output: LZMA2 Ultra, solid; slowest to create
  .tar.xz    strong Unix compression; slower than zstd (xz -9 -e, all cores)
  .tar.gz    widest compatibility; larger output

Reach for .tar.zst unless you specifically need smaller (.7z), xz (.tar.xz),
or maximum portability (.tar.gz).
EOF
}

# Create an archive; the output suffix selects the compressor (default .tar.zst).
function archive() {
    emulate -L zsh -o pipefail

    if [[ $# -eq 0 ]]; then
        _archive_usage
        return 1
    fi
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        _archive_usage
        return 0
    fi

    local name="$1"
    shift

    if [[ $# -eq 0 ]]; then
        echo "archive: no input paths given (try 'archive --help')" >&2
        return 1
    fi

    local out format
    case "$name" in
        *.7z)      out="$name";           format=7z ;;
        *.tar.xz)  out="$name";           format=xz ;;
        *.tar.zst) out="$name";           format=zst ;;
        *.tar.gz)  out="$name";           format=gz ;;
        *)         out="${name}.tar.zst"; format=zst ;;
    esac

    if [[ -e "$out" ]]; then
        echo "archive: '$out' already exists, refusing to overwrite" >&2
        return 1
    fi

    local input
    for input in "$@"; do
        if [[ ! -e "$input" ]]; then
            echo "archive: input '$input' does not exist" >&2
            return 1
        fi
    done

    case "$format" in
        7z)
            local sevenzip
            sevenzip="$(_archive_7z_bin)" || return 1
            "$sevenzip" a -t7z -m0=lzma2 -mx=9 -ms=on -- "$out" "$@"
            ;;
        xz)  tar -c -f - -- "$@" | xz -9 -e -T0 > "$out" ;;
        zst) tar -c -f - -- "$@" | zstd -19 -T0 -o "$out" ;;
        gz)  tar -c -f - -- "$@" | gzip > "$out" ;;
    esac

    local status=$?
    if [[ $status -ne 0 ]]; then
        rm -f -- "$out"
        echo "archive: failed to create '$out'" >&2
        return $status
    fi

    echo "archive: created '$out'"
}

# Extract an archive into DEST (default: current directory), chosen by suffix.
function unarchive() {
    emulate -L zsh -o pipefail

    if [[ $# -eq 0 ]]; then
        _archive_usage
        return 1
    fi
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        _archive_usage
        return 0
    fi

    local src="$1"
    local dest="${2:-.}"

    if [[ ! -f "$src" ]]; then
        echo "unarchive: '$src' not found" >&2
        return 1
    fi

    if [[ ! -d "$dest" ]]; then
        mkdir -p -- "$dest" || return 1
    fi

    case "$src" in
        *.7z)
            local sevenzip
            sevenzip="$(_archive_7z_bin)" || return 1
            "$sevenzip" x -o"$dest" -- "$src"
            ;;
        *.tar.xz|*.txz)   xz -dc -- "$src"   | tar -x -f - -C "$dest" ;;
        *.tar.zst|*.tzst) zstd -dc -- "$src" | tar -x -f - -C "$dest" ;;
        *.tar.gz|*.tgz)   gzip -dc -- "$src" | tar -x -f - -C "$dest" ;;
        *.tar)            tar -x -f "$src" -C "$dest" ;;
        *)
            echo "unarchive: unrecognised archive type for '$src'" >&2
            return 1
            ;;
    esac

    local status=$?
    if [[ $status -ne 0 ]]; then
        echo "unarchive: failed to extract '$src'" >&2
        return $status
    fi

    echo "unarchive: extracted '$src' into '$dest'"
}
