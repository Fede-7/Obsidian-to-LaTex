#!/usr/bin/env bash

set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)

# carico il file .env
set -a
source "$project_dir/.env"
set +a

# Path configurabili in .env (vedi .env_example). Quelli relativi sono
# riferiti alla radice del progetto; quelli assoluti sono usati cosi' come sono.
resolve_path() {
  case "$1" in
    /*) printf '%s' "$1" ;;
    *)  printf '%s' "$project_dir/$1" ;;
  esac
}
MD_DIR=$(resolve_path "${MD_SOURCE_DIR:-chapters_md}")
CHAPTERS_OUT=$(resolve_path "${CHAPTERS_DIR:-chapters}")
PDF_OUT=$(resolve_path "${PDF_DIR:-pdf}")
MERMAID_OUT=$(resolve_path "${MERMAID_DIR:-mermaid}")
FONTS_PATH=$(resolve_path "${FONTS_DIR:-fonts}")
IMAGES_PATH=$(resolve_path "${IMAGES_DIR:-Images}")
SOURCES_PATH=$(resolve_path "${SOURCES_DIR:-sources}")
MAIN_TEX_FILE="${MAIN_TEX:-main.tex}"

# Cartella di destinazione dove creare i collegamenti.
DEST_DIR="$MD_DIR"

# Crea la cartella di destinazione se non esiste già
mkdir -p "$DEST_DIR"

# Rimuove i collegamenti rotti creati da versioni precedenti dello script.
find "$DEST_DIR" -maxdepth 1 -type l ! -exec test -e {} \; -delete

# Cartella opzionale delle note Obsidian. Può essere sovrascritta per ogni progetto.
OBSIDIAN_DIR=$(resolve_path "${OBSIDIAN_NOTES_DIR:?OBSIDIAN_NOTES_DIR non impostata in .env}")

# Ciclo sui file .md
for f in "$OBSIDIAN_DIR"/*.md; do
  # Verifica che ci siano effettivamente file .md prima di creare il symlink
  if [ -e "$f" ]; then
    ln -sfn -- "$f" "$DEST_DIR/$(basename "$f")"
  fi
done

echo "Collegamenti creati con successo in $DEST_DIR/"

for command_name in pandoc lualatex; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Errore: %s non trovato nel PATH.\n' "$command_name" >&2
    exit 1
  fi
done

# Genera i frammenti LaTeX inclusi da main.tex.
"$script_dir/md-to-tex.sh" "$MD_DIR" "$CHAPTERS_OUT"

# Compila il documento principale e aggiorna l'indice.
cd "$project_dir"
if [ ! -d "$script_dir/node_modules" ]; then
  if ! command -v npm >/dev/null 2>&1; then
    printf 'Errore: npm non trovato. Installa Node.js/npm prima di usare build/.\n' >&2
    exit 1
  fi
  npm install --prefix "$script_dir" --no-audit --no-fund
fi

if [ -x "$script_dir/node_modules/.bin/mmdc" ]; then
  export PATH="$script_dir/node_modules/.bin:$PATH"
fi

if ! command -v mmdc >/dev/null 2>&1; then
  printf 'Errore: mmdc non trovato nella cartella build/. Esegui npm install --prefix build.\n' >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Formati di uscita. Senza argomenti genera tutti i formati; altrimenti solo
# quelli indicati:   
    # A4        : Stampa Classica
    # Print2Up  : 2 Fogli per pagina
    # B5J       : Per Tablet
    # Screen    : Monitor/Proiettore 
# Ogni PDF finisce in pdf/main-<formato>.pdf (e B5 resta anche come main.pdf).
# Il formato arriva alla classe tramite \ubpaper (vedi unina_doc_class.cls).
# ---------------------------------------------------------------------------
paper_spec() {
  case "$1" in
    # Stampa
    A4)         printf 'a4paper' ;;
    Print2Up)   printf 'a5paper' ;;

    # Tablet & Lettura digitale standard
    B5J)        printf 'paperwidth=182mm,paperheight=257mm' ;;

    # Dispositivi Desktop
    Screen)     printf 'paperwidth=528mm, paperheight=297mm' ;;

    *)          return 1 ;;
  esac
}

if [ "$#" -gt 0 ]; then
  formats=("$@")
else
  formats=(B5J A4 Print2Up Screen)
fi

for fmt in "${formats[@]}"; do
  paper_spec "$fmt" >/dev/null || {
    printf 'Errore: formato "%s" sconosciuto (B5J, A4, Print2Up, Screen).\n' "$fmt" >&2
    exit 1
  }
done

compile_format() {
  local fmt=$1
  local paper
  paper=$(paper_spec "$fmt")

  # Le cartelle arrivano alle classi come macro (\ubfontdir, \ubimgdir, ...); cosi' il LaTeX usa i path del .env senza doverli scrivere nel .cls.
  local tex_input="\\def\\ubpaper{$paper}\\def\\ubfontdir{$FONTS_PATH/}\\def\\ubimgdir{$IMAGES_PATH/}\\def\\ubsrcdir{$SOURCES_PATH/}\\def\\ubmermaiddir{$MERMAID_OUT}\\input{$MAIN_TEX_FILE}"

  printf '\n=== Formato %s (%s) ===\n' "$fmt" "$paper"

  # Usa un job separato nella prima passata: un aux interrotto non deve mai
  # essere letto dalla compilazione finale. L'indice dipende dal formato,
  # quindi ogni formato ha le sue due passate.
  rm -f main.aux main.toc main.out main.lof main.lot main.log main-pass1.*
  
  # openout_any=a: i path da .env possono essere assoluti (es. MERMAID_DIR),
  # e con la modalita' paranoica di TeX la scrittura del sorgente mermaid fallisce.
  TEXINPUTS="$script_dir:" openout_any=a lualatex --shell-escape -jobname=main-pass1 -interaction=nonstopmode -halt-on-error "$tex_input"
  cp main-pass1.toc main.toc
  rm -f main.aux main.out main.log main-pass1.*
  TEXINPUTS="$script_dir:" openout_any=a lualatex --shell-escape -jobname=main -interaction=nonstopmode -halt-on-error "$tex_input"

  mkdir -p "$PDF_OUT"
  cp main.pdf "$PDF_OUT/main-$fmt.pdf"
}

# Il pacchetto NON rigenera un PDF gia' presente: va svuotata a ogni build, altrimenti i diagrammi modificati restano quelli vecchi.

mkdir -p "$MERMAID_OUT"
rm -f "$MERMAID_OUT/"*.mmd "$MERMAID_OUT/"*.pdf

for fmt in "${formats[@]}"; do
  compile_format "$fmt"
done

# main.pdf = primo formato richiesto (B5 se si genera tutto)
cp "$PDF_OUT/main-${formats[0]}.pdf" main.pdf

echo "Compilazione completata -> $PDF_OUT/: $(printf 'main-%s.pdf ' "${formats[@]}")"