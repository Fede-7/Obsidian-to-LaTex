# Dispensa LaTeX da note Obsidian

Questo progetto converte le note scritte in Markdown (stile Obsidian) in capitoli LaTeX tramite **Pandoc**, poi compila un documento unico con **LuaLaTeX** usando la classe personalizzata `unina_doc_class.cls`. I diagrammi **Mermaid** vengono generati come PDF e inseriti nel documento.

## Esempio di output

Il PDF di esempio mostra il risultato finale del progetto:

📄 [Apri il PDF di esempio](Output_Example.pdf)

---

## Funzionalità

- Conversione automatica di tutte le note `.md` in capitoli `.tex`
- Supporto ai **callout Obsidian** (`> [!note]`, `> [!warning]`, `> [!esempio]`, `> [!quote]`, ecc.)
- Callout speciale `> [!aside]` per affiancare testo e immagine (o un grafico Mermaid)
- Wikilink `![[immagine.png|300]]` e immagini Markdown con larghezza in pixel o percentuale
- Blocchi di codice con evidenziazione sintattica (`listings`) ed etichetta del linguaggio
- Diagrammi Mermaid (` ```mermaid `) compilati automaticamente in PDF
- Conversione automatica delle immagini `.webp` in `.png`
- Generazione in **quattro formati di stampa** (B5 per tablet, A4, 2 pagine per foglio, schermo)
- Tema chiaro di default e tema scuro con l'opzione `dark`

---

## Struttura del progetto

```
.
├── .env_example            # Modello della configurazione locale
├── .env                    # La tua configurazione (da creare, non va versionata)
├── main.tex                # Documento principale (include i capitoli)
├── chapters_md/            # Collegamenti simbolici alle note Obsidian (generato)
├── chapters/               # Capitoli .tex generati da Pandoc (generato)
├── Images/                 # Immagini usate nelle note
├── fonts/                  # Font .ttf / .otf usati dalla classe
├── sources/                # uni_logo.pdf per la copertina
├── Output_Example.pdf          # PDF di esempio (output del progetto)
├── pdf/                    # PDF finali per formato (generato)
└── build/
    ├── build.sh                 # Script principale
    ├── md-to-tex.sh             # Conversione Markdown -> LaTeX
    ├── md-to-tex.template       # Template dei frammenti Pandoc
    ├── obsidian_to_latex.lua    # Filtro Lua (callout, immagini, codice, aside)
    ├── convert_webp_to_png.sh   # Utility per convertire i .webp
    ├── unina_doc_class.cls      # Classe del documento
    ├── template.tex             # Template del documento completo
    ├── mermaid.sty              # Pacchetto LaTeX per i diagrammi Mermaid
    ├── package.json             # Dipendenze Node (mermaid-cli)
    └── package-lock.json
```

Le cartelle `chapters_md/`, `chapters/`, `pdf/`, `mermaid/`, `build/node_modules/` e `Images/` sono escluse da Git (vedi `.gitignore`).

---

## Requisiti

| Strumento | Versione consigliata | Note |
|---|---|---|
| Pandoc | 3.x | Deve supportare l'estensione `wikilinks_title_after_pipe` |
| TeX Live (o MacTeX) | 2024 o successiva | Compilatore `lualatex` con pacchetti completi |
| Node.js + npm | 22.13 o successiva | Richiesto da `@mermaid-js/mermaid-cli` 12 |
| Chromium | automatico | Scaricato da Puppeteer alla prima installazione di `mmdc` |
| ffmpeg | qualsiasi | Solo per `convert_webp_to_png.sh` |
| Bash, perl, sed, find, sort, realpath, file | GNU/Linux | Vedi sezioni macOS e Windows |

### Pacchetti LaTeX usati

La classe carica, tra gli altri: `fontspec`, `lualatex`-specifici, `babel` (opzione `italian`), `tcolorbox` (con `skins`, `breakable`, `listings`), `listings`, `lstfiracode`, `xltabular`, `longtable`, `booktabs`, `array`, `tikz`, `pgfornament`, `titlesec`, `titletoc`, `fancyhdr`, `geometry`, `parskip`, `enumitem`, `caption`, `float`, `needspace`, `ulem`, `hyphenat`, `microtype`, `pdfpages`, `hyperref`, `xurl`, `newunicodechar`, `mathtools`, `amssymb`, `etoolbox`, `iftex`.

Con una distribuzione completa (`texlive-full` su Linux, MacTeX su macOS) sono già presenti tutti. Con una installazione minimale installa i pacchetti mancanti con `tlmgr install <nome>`.

---

## Installazione su Linux (Debian / Ubuntu)

```bash
# Pandoc, TeX, ffmpeg e strumenti di base
sudo apt update
sudo apt install pandoc texlive-full ffmpeg file perl

# Node.js 22 (quello dei repository Ubuntu può essere troppo vecchio)
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

# Verifica
pandoc --version
lualatex --version
node --version      # deve essere >= 22.13
npm --version
```

Su Arch: `sudo pacman -S pandoc texlive-meta nodejs npm ffmpeg file perl`.
Su Fedora: `sudo dnf install pandoc texlive-scheme-full nodejs npm ffmpeg file perl`.

---

## Configurazione

1. Copia il file di esempio:

   ```bash
   cp .env_example .env
   ```

2. Apri `.env` e imposta il percorso della cartella delle note Obsidian:

   ```bash
   OBSIDIAN_NOTES_DIR="/percorso/alla/tua/vault/obsidian"
   ```

   Lo script crea un collegamento simbolico per ogni file `.md` della cartella dentro `chapters_md/`, quindi le note originali non vengono mai modificate.

3. Verifica che esistano:
   - `fonts/` con i file `.ttf` / `.otf` richiesti (Lato, Scientifica, FiraCode, JetBrainsMonoNL, Agency, Alte-DIN-1451-Mittelschrift-G, Gobold, IcoMoon, IcoFont)
   - `sources/uni_logo.pdf` (logo della copertina)
   - `Images/` con le immagini citate nelle note

   I font non vanno installati nel sistema: vengono letti direttamente dalla cartella `fonts/`.

---

## Avvio

Esegui tutto dalla **radice del progetto** (lo script legge `./.env`):

```bash
chmod +x build/*.sh          # solo la prima volta
./build/build.sh             # genera tutti i formati
./build/build.sh A4          # genera solo il formato A4
./build/build.sh B5J Screen  # genera più formati specifici
```

Alla prima esecuzione lo script:

1. crea i collegamenti alle note in `chapters_md/`;
2. converte i `.md` in `chapters/*.tex` con Pandoc;
3. installa automaticamente le dipendenze Node in `build/node_modules/` (`mmdc`);
4. compila il documento con LuaLaTeX **due volte** per ogni formato (la prima per produrre l'indice).

### Formati disponibili

| Argomento | Formato | Uso |
|---|---|---|
| `B5J` | B5 (182 × 257 mm) | Tablet e lettura digitale |
| `A4` | A4 | Stampa classica |
| `Print2Up` | A5 | Stampa, 2 pagine per foglio A4 |
| `Screen` | 528 × 297 mm | Monitor e proiettori |

### Risultato

- `pdf/main-B5J.pdf`, `pdf/main-A4.pdf`, `pdf/main-Print2Up.pdf`, `pdf/main-Screen.pdf`
- `main.pdf` nella radice (copia del primo formato richiesto)

Per generare solo il PDF di un singolo formato senza ripetere le conversioni, puoi lanciare la compilazione direttamente, ma il modo consigliato è sempre `build.sh`.

### Convertire le immagini WebP

```bash
./build/convert_webp_to_png.sh Images
```

Lo script converte i `.webp` in `.png` (anche quelli con estensione `.png` che in realtà sono WebP) e cancella l'originale `.webp`.

---

## Sintassi Obsidian supportata

**Callout** (tipi riconosciuti: `note`, `info`, `tip`, `warning`, `danger`, `error`, `example`, `esempio`, `esercizio`, `lab`, `laboratorio`, `quote`, `citazione`, `def`, e altri):

```markdown
> [!esempio] Titolo facoltativo
> Testo dell'esempio.
```

**Aside** (testo a sinistra, immagine a destra):

```markdown
> [!aside] 250
> - Punto uno
> - Punto due
>
> ---
>
> ![[schema.png|250]]
```

Al posto dell'immagine si può usare un grafico Mermaid dopo la riga `---`.

**Immagini**:

```markdown
![[figura.png|300]]          # 300 px di larghezza
![[figura.png|40%]]          # 40% della riga
![Didascalia|200](figura.png)
```

**Diagrammi Mermaid**: blocco ` ```mermaid ` standard. Ogni diagramma viene salvato in `mermaid/` e compilato in PDF da `mmdc`.

**Codice**: ogni blocco ` ```python `, ` ```js `, ` ```bash `, ecc. viene colorato secondo il linguaggio e riceve un'etichetta in alto a destra.

---

## Adattamenti per macOS

Il progetto è scritto per Linux e usa strumenti GNU. Su macOS servono queste modifiche.

### 1. Installazione dei pacchetti

```bash
brew install pandoc node ffmpeg coreutils gnu-sed bash
brew install --cask mactex          # oppure basictex + tlmgr
```

Dopo l'installazione di MacTeX apri un nuovo terminale, così `lualatex` è nel `PATH`.

### 2. File da modificare

**`build/md-to-tex.sh`**

- `sed -i` su macOS richiede un argomento vuoto per il backup. Ogni chiamata `sed -i 's/.../'` va scritta `sed -i '' 's/.../'`. Ci sono sei occorrenze (trasformazione di `\pandocbounded`, `longtable`/`xltabular`, `\usepackage`, pulizia righe vuote).
  In alternativa, usa `gsed` installato con Homebrew: sostituisci `sed` con `gsed` in tutto il file.
- `realpath -e` richiede GNU `realpath`. Sostituiscilo con `grealpath -e` (installato con `coreutils`).

**`build/build.sh`**

- Non richiede modifiche se si usa Bash 5. Il Bash di sistema di macOS è la versione 3.2: esegui lo script con `bash` installato via Homebrew, ad esempio `/opt/homebrew/bin/bash build/build.sh`, oppure cambia lo shebang.

**`build/convert_webp_to_png.sh`**

- Funziona così com'è. Richiede `ffmpeg` installato con Homebrew e il comando `file`, già presente su macOS.

**`build/mermaid.sty`**, **`build/unina_doc_class.cls`**, **`build/obsidian_to_latex.lua`**, **`.env`**

- Nessuna modifica. Il percorso `build/node_modules/.bin/mmdc` funziona anche su macOS.

### 3. Note

- Compila sempre con `--shell-escape` (lo script lo fa già): senza di esso i diagrammi Mermaid non vengono generati.
- Su Apple Silicon Homebrew installa in `/opt/homebrew/bin`: assicurati che sia nel `PATH`.

---

## Adattamenti per Windows

Il progetto non funziona nativamente su Windows: usa symlink, Bash, `sed`, `find`, `realpath` e separatori `:` nel `TEXINPUTS`. La strada consigliata è **WSL2** (Windows Subsystem for Linux); in quel caso non serve modificare nulla.

### Opzione consigliata: WSL2 (Ubuntu)

1. Apri PowerShell come amministratore ed esegui:

   ```powershell
   wsl --install -d Ubuntu
   ```

2. Riavvia e segui le istruzioni di Ubuntu. Poi installa gli strumenti come nella sezione **Installazione su Linux**.

3. **Lavora dentro il filesystem Linux** (`~/progetto`), non in `/mnt/c/...`: è molto più veloce e i symlink funzionano correttamente.

4. Se il progetto è sul disco Windows, copialo in WSL:

   ```bash
   cp -r /mnt/c/Users/TuoNome/progetto ~/progetto
   ```

5. Il vault Obsidian può restare su Windows: in `.env` usa il percorso WSL, ad esempio `/mnt/c/Users/TuoNome/Documents/Obsidian`.

### Opzione alternativa: Windows nativo con Git Bash

Non consigliata, ma possibile. Devi modificare questi file:

**`build/build.sh`**

- `TEXINPUTS="$script_dir:"`: su Windows il separatore è `;`. Usa `TEXINPUTS="$script_dir;"`.
- `ln -sfn`: i symlink su Windows richiedono la **Modalità sviluppatore** attiva (Impostazioni → Per sviluppatori) o privilegi di amministratore. In alternativa sostituisci `ln -sfn` con `cp`.

**`build/md-to-tex.sh`**

- `realpath -e` non esiste in Git Bash in forma compatibile: rimuovi la chiamata e usa direttamente `"$input"`.
- Se hai sostituito i symlink con copie, rimuovi anche la risoluzione del percorso reale.

**`build/mermaid.sty`**

- Su Windows `mmdc` è installato come `mmdc.cmd`. Nella macro `\ShellEscape` cambia `build/node_modules/.bin/mmdc` in `build/node_modules/.bin/mmdc.cmd`.

**`build/convert_webp_to_png.sh`**

- Il comando `file` non è disponibile in Git Bash di default. Installalo con `pacman` (MSYS2) oppure usa `ffprobe` per riconoscere il formato.

**Tutti i file `.sh`**

- Git su Windows converte i fine riga in CRLF, e Bash fallisce con errori tipo `$'\r': command not found`. Converti i file in LF (in VS Code: barra in basso → `CRLF` → `LF`) oppure aggiungi un file `.gitattributes` con:

  ```
  *.sh text eol=lf
  *.cls text eol=lf
  *.sty text eol=lf
  *.lua text eol=lf
  *.template text eol=lf
  ```

**`.env`**

- Usa percorsi Windows con slash in avanti o racchiusi tra virgolette, ad esempio `OBSIDIAN_NOTES_DIR="C:/Users/TuoNome/Documents/Obsidian"`.

---

## Risoluzione dei problemi

| Problema | Causa probabile |
|---|---|
| `File non trovato: chapters_md` | Il vault in `.env` non esiste o `OBSIDIAN_NOTES_DIR` è vuoto |
| `Errore: mmdc non trovato` | `npm install` non è andato a buon fine: `npm install --prefix build` |
| I diagrammi Mermaid non compaiono | Compilazione senza `--shell-escape` oppure Chromium non scaricato |
| `Font ... non trovato` | Manca il file nella cartella `fonts/`: il documento usa `\sffamily` come ripiego |
| `Logo ... non trovato` | Manca `sources/uni_logo.pdf` |
| Il codice non è colorato | Il linguaggio non è in `LANGUAGE_MAP` di `obsidian_to_latex.lua` |
| Errore LaTeX su un pacchetto | Pacchetto mancante: `tlmgr install <nome>` |
| `Undefined control sequence` dopo le modifiche | Controlla il log `main.log` nella radice del progetto |

Per aggiungere un linguaggio ai blocchi di codice, modifica le tabelle `LANGUAGE_MAP` e `DISPLAY_NAME` in `build/obsidian_to_latex.lua`.

---

## Licenza

Il progetto è ad uso personale e didattico. Il logo e i nomi dell'ateneo appartengono all'Università degli Studi di Napoli Federico II.
