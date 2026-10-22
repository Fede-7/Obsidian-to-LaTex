#!/usr/bin/env bash
set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
template="$script_dir/md-to-tex.template"
lua_filter="$script_dir/obsidian_to_latex.lua"

# Path da .env (se presente), altrimenti i valori predefiniti.
if [ -f "$project_dir/.env" ]; then
  set -a
  . "$project_dir/.env"
  set +a
fi
resolve_path() {
  case "$1" in
    /*) printf '%s' "$1" ;;
    *)  printf '%s' "$project_dir/$1" ;;
  esac
}
default_input=$(resolve_path "${MD_SOURCE_DIR:-chapters_md}")
default_output=$(resolve_path "${CHAPTERS_DIR:-chapters}")

usage() {
    printf 'Uso: %s [FILE.md [FILE.tex]]\n' "$(basename "$0")"
    printf '     %s DIRECTORY [OUTPUT_DIRECTORY]\n' "$(basename "$0")"
}

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    usage >&2
    exit 2
fi

convert_file() {
    local input=$1
    local output=$2

    # Risolvi il symlink per ottenere il percorso reale del file in Obsidian
    local real_input
    real_input=$(realpath -e -- "$input")
    mkdir -p "$(dirname -- "$output")"

    # ===== PANDOC CONVERSION =====
    # Pre-elaborazione: in Obsidian una tabella dentro un callout puo' seguire
    # direttamente la riga di testo/titolo; per Pandoc serve una riga vuota
    # (">") prima della tabella, altrimenti la tabella diventa testo.
    perl -0pe 's/^(>[ \t]*[^|\s>][^\n]*\n)(?=>[ \t]*\|)/$1>\n/mg' "$real_input" | pandoc \
        --from=markdown+wikilinks_title_after_pipe-implicit_figures \
        --to=latex \
        --template="$template" \
        --lua-filter="$lua_filter" \
        --top-level-division=chapter \
        --syntax-highlighting=idiomatic \
        --table-of-contents \
        --toc-depth=2 \
        --output="$output"


    # ===== POST-PROCESSING =====
    
    # Rimuovi wrapper \pandocbounded{...}
    sed -i 's/\\pandocbounded{\(.*\)}/\1/g' "$output"
    perl -i -0pe 's/\\pandocbounded\{(.*?)\}/\1/gs' "$output" 2>/dev/null || true
    
    # Converti longtable a xltabular
    sed -i 's|\\begin{longtable}|\\begin{xltabular}{\\linewidth}|g' "$output"
    sed -i 's|\\end{longtable}|\\end{xltabular}|g' "$output"

    # Pandoc usa colonne l per alcune tabelle. In xltabular sono colonne
    # a larghezza naturale e possono lasciare la tabella troppo stretta.
    # La classe definisce Y come colonna X allineata a sinistra.
    perl -i -0pe 's/(?<=\@\{\})(l+)(?=\@\{\})/"Y" x length($1)/ge' "$output"
    
    # Rimuovi \usepackage dal corpo
    sed -i 's|\\usepackage[[:space:]]*{[^}]*}||g' "$output"
    sed -i 's|\\usepackage\[[^\]]*\]||g' "$output"
    
    # Pulisci linee vuote multiple
    sed -i '/^[[:space:]]*$/N;/^\n$/!P;D' "$output"

    printf 'Convertito: %s -> %s\n' "$input" "$output"
}

input=${1:-$default_input}
output_directory=${2:-}
if [ -d "$input" ]; then
    output_directory=${output_directory:-$default_output}
    mkdir -p "$output_directory"

    # Nota il flag -L aggiunto a find per seguire i collegamenti simbolici
    while IFS= read -r -d '' markdown_file; do
        filename=$(basename "$markdown_file" .md)
        convert_file "$markdown_file" "$output_directory/$filename.tex"
    done < <(find -L "$input" -maxdepth 1 \( -type f -o -type l \) -name '*.md' -print0 | sort -z)
else
    if [ ! -f "$input" ] && [ ! -L "$input" ]; then
        printf 'File non trovato: %s\n' "$input" >&2
        exit 1
    fi
    output=${2:-${input%.md}.tex}
    convert_file "$input" "$output"
fi