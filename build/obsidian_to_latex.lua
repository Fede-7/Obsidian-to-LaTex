-- Pandoc Lua filter for Obsidian to LaTeX conversion
-- Features:
--   1. Image handling (webp → png, dimensions, figure environment)
--   2. Converts Obsidian callouts ([!tipo]) to LaTeX environments
--   3. Preserves code block languages for listings
-- 
-- Usage: pandoc input.md --lua-filter=obsidian_to_latex_COMPLETE.lua --listings -t latex -o output.tex

--- ============================================================
--- PART 1: IMAGE HANDLING
--- ============================================================

function Image(elem)
    local src = elem.src
    
    -- 1. Converti .webp in .png
    if src:match("%.webp$") then
        src = src:gsub("%.webp$", ".png")
    end
    
    -- 2. Estrai il testo dal title (Obsidian: ![[img|230]]) e dal caption (Markdown: ![230](img))
    local title_text = elem.title or ""
    
    local caption_text = ""
    if elem.caption then
        for _, inline in ipairs(elem.caption) do
            if inline.text then
                caption_text = caption_text .. inline.text
            end
        end
    end
    
    local width, height = nil, nil
    local is_dimension = false
    
    -- Controlla prima il title (Obsidian wikilink)
    local clean_title = title_text:gsub("%s+", "")
    local w, h = clean_title:match("^(%d+)x(%d+)$")
    if w and h then
        width, height = w, h
        is_dimension = true
    else
        local w_only = clean_title:match("^(%d+)$")
        if w_only then
            width = w_only
            is_dimension = true
        end
    end
    
    -- Se non trovato nel title, controlla il caption (Markdown standard)
    if not is_dimension then
        local clean_caption = caption_text:gsub("%s+", "")
        local w2, h2 = clean_caption:match("^(%d+)x(%d+)$")
        if w2 and h2 then
            width, height = w2, h2
            is_dimension = true
        else
            local w2_only = clean_caption:match("^(%d+)$")
            if w2_only then
                width = w2_only
                is_dimension = true
            end
        end
    end
    
    -- 3. PULIZIA CRITICA: Svuota title e caption.
    -- Questo impedisce a Pandoc di generare "alt={...}" che fa crashare LaTeX.
    -- Come richiesto, se c'era del testo vero (didascalia), viene rimosso per evitare errori.
    elem.title = ""
    elem.caption = {} 
    
    -- 4. Genera il codice LaTeX pulito
    local options = {}
    if width and height then
        table.insert(options, string.format("width=%spx", width))
        table.insert(options, string.format("height=%spx", height))
    elseif width then
        table.insert(options, string.format("width=%spx", width))
    end
    table.insert(options, "keepaspectratio")
    
    local options_str = table.concat(options, ", ")

    -- 5. Genera il codice LaTeX con \begin{figure}[H]
    -- Usiamo RawInline per evitare l'errore __toinline, ma LaTeX lo leggerà come un blocco.
    -- Non inseriamo \caption{}, quindi non ci sarà nessuna didascalia.
    local latex_code = string.format(
        "\\begin{figure}[H]\n\\centering\n\\includegraphics[%s]{%s}\n\\end{figure}", 
        options_str, src
    )
    
    return pandoc.RawInline('tex', latex_code)
end

--- ============================================================
--- PART 2: BLOCKQUOTE / CALLOUT HANDLING
--- ============================================================

--- Extract plain text from Pandoc inline content
local function extract_text(inlines)
    local text = ""
    for _, inline in ipairs(inlines) do
        if inline.text then
            text = text .. inline.text
        elseif inline.t == "Str" then
            text = text .. inline.text
        elseif inline.t == "SoftBreak" or inline.t == "LineBreak" then
            text = text .. " "
        elseif inline.t == "Space" then
            text = text .. " "
        elseif inline.content then
            text = text .. extract_text(inline.content)
        end
    end
    return text
end

--- Parse callout marker from text
local function parse_callout_type(text)
    local callout_type = text:match("^%[!([^%]]+)%]")
    return callout_type
end

--- Extract title from text (content after [!TYPE])
local function extract_title(text)
    local title = text:gsub("^%[![^%]]+%]%s*", "")
    return title
end

local CALLOUT_ENV_MAP = {
    ["esempio"]   = "esempiobox",
    ["example"]   = "esempiobox",
    ["esercizio"] = "esercizio",
    ["exercise"]  = "esercizio",
    ["note"]      = "infobox",
    ["info"]      = "infobox",
    ["warning"]   = "warningbox",
    ["warn"]      = "warningbox",
    ["error"]     = "errorbox",
    ["danger"]    = "errorbox",
    ["tip"]       = "infobox",
    ["hint"]      = "infobox",
    ["important"] = "warningbox",
    ["caution"]   = "warningbox",
    ["bug"]       = "errorbox",
    ["fail"]      = "errorbox",
    ["success"]   = "infobox",
    ["question"]  = "infobox",
    ["faq"]       = "infobox",
    ["abstract"]  = "infobox",
    ["summary"]   = "infobox",
    ["tldr"]      = "infobox",
    ["def"]       = "Definition",
    ["lab"]       = "labbox",
    ["laboratorio"]      = "labbox",
    ["pratica"]   = "labbox",
    ["quote"]     = "ubquote",     -- titolo = autore
    ["citazione"] = "ubquote",
    ["cite"]      = "ubquote"
}

local function escape_latex(text)
    return text
        :gsub("\\", "\\textbackslash{}")
        :gsub("([%$%&%%_#{}~^])", "\\%1")
end

function BlockQuote(elem)
    if #elem.content == 0 then return elem end

    local first_block = elem.content[1]
    if first_block.t ~= "Para" and first_block.t ~= "Plain" then return elem end

    local inlines = first_block.content
    if #inlines == 0 then return elem end

    -- Separiamo gli inlines della prima riga (titolo) da quelli successivi (corpo)
    local title_inlines = {}
    local body_inlines = {}
    local is_title_line = true

    for _, inline in ipairs(inlines) do
        if is_title_line then
            if inline.t == "SoftBreak" or inline.t == "LineBreak" then
                is_title_line = false
            else
                table.insert(title_inlines, inline)
            end
        else
            table.insert(body_inlines, inline)
        end
    end

    -- Verifichiamo se la prima riga è un callout [!tipo]
    local first_line_text = pandoc.utils.stringify(title_inlines)
    local callout_type = first_line_text:match("^%[%!([^%]]+)%]")
    if not callout_type then return elem end

    callout_type = callout_type:lower():match("^%s*(.-)%s*$")
    local latex_env = CALLOUT_ENV_MAP[callout_type]
    if not latex_env then return elem end

    -- Estragga il titolo pulito
    local raw_title = first_line_text:gsub("^%[%![^%]]+%]%s*", "")
    local escaped_title = escape_latex(raw_title:match("^%s*(.-)%s*$"))

    -- Inseriamo \begin{ambiente}{titolo}% come primo elemento del primo paragrafo
    local begin_raw = pandoc.RawInline('tex', '\\begin{' .. latex_env .. '}{' .. escaped_title .. '}')
    table.insert(body_inlines, 1, begin_raw)

    local blocks = {}

    -- Ricostruiamo il primo paragrafo contenente sia l'apertura che il testo
    table.insert(blocks, pandoc.Plain(body_inlines))

    -- Aggiungiamo eventuali paragrafi successivi nel callout
    for i = 2, #elem.content do
        table.insert(blocks, elem.content[i])
    end

    -- Chiudiamo l'ambiente alla fine
    table.insert(blocks, pandoc.RawBlock('tex', '\\end{' .. latex_env .. '}'))

    return blocks
end

--- ============================================================
--- PART 2b: CALLOUT [!aside]  (testo a sinistra, immagine a destra)
--- ============================================================
--- Sintassi Obsidian:
---   > [!aside]
---   > - testo...
---   >
---   > ---
---   >
---   > ![descrizione|200](foto.png)      oppure   ![[foto.png|200]]
--- Larghezza dell'immagine (come per le altre immagini del progetto):
---   |200   -> 200 px          |40%   -> 40% della riga
---   |200x100 -> 200 px (l'altezza e' ignorata)
---   nessun valore (o testo, es. "textwidth") -> si adatta alla forma dell'immagine
--- Il testo occupa sempre tutto lo spazio che resta.
--- Al posto dell'immagine puo' esserci un grafico:  ```mermaid ... ```
--- (larghezza di default 42% della riga; si cambia con  > [!aside] 250  o  40%).
--- Deve girare PRIMA del filtro Image, che trasformerebbe l'immagine in figure.


--- Converte il testo dopo "|" in una dimensione LaTeX ("200px", "0.400\\linewidth")
--- oppure nil (= automatico).
local function aside_size(str)
    if not str then return nil end
    str = str:gsub("%s+", "")
    local n = str:match("^(%d+)%%$")
    if n then
        local p = math.max(10, math.min(70, tonumber(n)))
        return string.format("%.3f\\linewidth", p / 100)
    end
    n = str:match("^(%d+)px$") or str:match("^(%d+)x%d+$") or str:match("^(%d+)$")
    if n then return n .. "px" end
    return nil
end

local function aside_image_size(img)
    local sz = aside_size(img.title)
    if sz then return sz end
    local cap = pandoc.utils.stringify(img.caption or {})
    return aside_size(cap:match("|%s*([^|]*)$")) or aside_size(cap)
end

function Aside(elem)
    local first = elem.content[1]
    if not first or (first.t ~= "Para" and first.t ~= "Plain") then return nil end

    -- prima riga = [!aside]; l'eventuale resto del paragrafo e' testo
    local title, rest, in_title = {}, {}, true
    for _, inl in ipairs(first.content) do
        if in_title then
            if inl.t == "SoftBreak" or inl.t == "LineBreak" then in_title = false
            else table.insert(title, inl) end
        else
            table.insert(rest, inl)
        end
    end
    local tag = pandoc.utils.stringify(title):match("^%[!([^%]]+)%]")
    if not tag or tag:lower():match("^%s*(.-)%s*$") ~= "aside" then return nil end

    local text, after, seen_rule = {}, {}, false
    if #rest > 0 then table.insert(text, pandoc.Plain(rest)) end
    for i = 2, #elem.content do
        local b = elem.content[i]
        if b.t == "HorizontalRule" and not seen_rule then
            seen_rule = true
        elseif seen_rule then
            table.insert(after, b)
        else
            table.insert(text, b)
        end
    end

    -- dimensione indicata sul tag: "> [!aside] 250" / "40%" (vale per immagine e grafico)
    local tag_size = aside_size((pandoc.utils.stringify(title):gsub("^%[![^%]]+%]%s*", "")))

    -- grafico mermaid dopo il "---": al posto dell'immagine
    local mermaid_code
    for _, b in ipairs(after) do
        if b.t == "CodeBlock" and b.classes and b.classes[1]
           and b.classes[1]:lower() == "mermaid" then
            mermaid_code = b.text:gsub("\n+$", "")
            break
        end
    end
    if seen_rule and mermaid_code and mermaid_code ~= "" then
        local blocks = {
            pandoc.RawBlock('tex', string.format("\\begin{ubasidem}{%s}",
                tag_size or "0.420\\linewidth"))
        }
        for _, b in ipairs(text) do table.insert(blocks, b) end
        table.insert(blocks, pandoc.RawBlock('tex',
            "\\ubasidesplit\n\\begin{mermaid}\n" .. mermaid_code .. "\n\\end{mermaid}"))
        table.insert(blocks, pandoc.RawBlock('tex', "\\end{ubasidem}"))
        return blocks
    end

    -- immagine: Image gia' parsata da Pandoc, oppure wikilink ![[file|N]] rimasto testo
    local src, size
    for _, b in ipairs(after) do
        pandoc.walk_block(b, { Image = function(x)
            if not src then
                src = x.src
                size = aside_image_size(x)
            end
        end })
    end
    if not src then
        for _, b in ipairs(after) do
            local t = pandoc.utils.stringify(b):gsub("%s+", " ")
            local f, o = t:match("^%s*!?%[%[([^|%]]+)|?([^%]]*)%]%]%s*$")
            if f then
                src = f
                size = aside_size(o)
                break
            end
        end
    end
    if not seen_rule or not src then
        io.stderr:write("[aside] manca '---' oppure l'immagine/il grafico mermaid dopo di esso: callout lasciato com'e'\n")
        return nil
    end

    src = src:gsub("%.webp$", ".png")
    local blocks = {
        pandoc.RawBlock('tex', string.format("\\begin{ubaside}{%s}{%s}", size or tag_size or "auto", src))
    }
    for _, b in ipairs(text) do table.insert(blocks, b) end
    table.insert(blocks, pandoc.RawBlock('tex', "\\end{ubaside}"))
    return blocks
end

--- ============================================================
--- PART 3: CODE BLOCK LANGUAGE HANDLING
--- ============================================================

--- Mapping: nome del fence Markdown -> linguaggio di `listings`.
--- Contiene SOLO linguaggi che listings conosce (di serie o definiti in
--- unina_doc_class.cls): un nome sconosciuto farebbe fallire la compilazione.
--- Per i fence non presenti qui il blocco resta senza colori ma con etichetta.
local LANGUAGE_MAP = {
    -- Web
    ["html"] = "HTML", ["html5"] = "HTML", ["vue"] = "HTML",
    ["css"] = "CSS",
    ["js"] = "JavaScript", ["javascript"] = "JavaScript", ["jsx"] = "JavaScript",
    ["ts"] = "TypeScript", ["typescript"] = "TypeScript", ["tsx"] = "TypeScript",
    ["xml"] = "XML", ["svg"] = "XML",
    ["http"] = "http",
    ["nginx"] = "nginx",
    ["php"] = "PHP",

    -- Backend
    ["python"] = "Python", ["py"] = "Python",
    ["java"] = "[POSIX]JAVA",
    ["c"] = "[POSIX]C",
    ["cpp"] = "C++", ["c++"] = "C++",
    ["rb"] = "Ruby", ["ruby"] = "Ruby",
    ["perl"] = "Perl", ["pl"] = "Perl",
    ["r"] = "R",
    ["scala"] = "Scala",

    -- Dati / configurazione
    ["json"] = "JSON", ["jsonc"] = "JSON",
    ["yaml"] = "YAML", ["yml"] = "YAML",
    ["toml"] = "ini", ["ini"] = "ini", ["conf"] = "ini", ["cfg"] = "ini",
    ["env"] = "bash",

    -- Shell
    ["bash"] = "bash", ["sh"] = "bash", ["shell"] = "bash", ["zsh"] = "bash",
    ["fish"] = "bash", ["powershell"] = "bash", ["ps1"] = "bash",
    ["cmd"] = "bash", ["batch"] = "bash",

    -- Database
    ["sql"] = "SQL", ["mysql"] = "SQL", ["postgresql"] = "SQL",
    ["postgres"] = "SQL", ["sqlite"] = "SQL", ["plpgsql"] = "SQL", ["tsql"] = "SQL",

    -- Funzionali
    ["haskell"] = "Haskell", ["hs"] = "Haskell",
    ["lisp"] = "Lisp", ["clojure"] = "Lisp", ["scheme"] = "Lisp",
    ["erlang"] = "erlang",

    -- Altro
    ["tex"] = "[LaTeX]TeX", ["latex"] = "[LaTeX]TeX",
    ["makefile"] = "makefile",
    ["dockerfile"] = "Docker", ["docker"] = "Docker",
    ["asd"] = "asd", ["pseudocode"] = "asd", ["algorithm"] = "asd",
}

--- Nome mostrato nell'etichetta del blocco (in alto a destra)
local DISPLAY_NAME = {
    ["html"] = "HTML", ["html5"] = "HTML", ["css"] = "CSS", ["vue"] = "Vue",
    ["js"] = "JavaScript", ["javascript"] = "JavaScript", ["jsx"] = "JSX",
    ["ts"] = "TypeScript", ["typescript"] = "TypeScript", ["tsx"] = "TSX",
    ["xml"] = "XML", ["svg"] = "SVG", ["http"] = "HTTP", ["nginx"] = "Nginx",
    ["php"] = "PHP", ["python"] = "Python", ["py"] = "Python",
    ["java"] = "Java", ["c"] = "C", ["cpp"] = "C++", ["c++"] = "C++",
    ["csharp"] = "C#", ["cs"] = "C#", ["go"] = "Go", ["rust"] = "Rust", ["rs"] = "Rust",
    ["rb"] = "Ruby", ["ruby"] = "Ruby", ["perl"] = "Perl", ["pl"] = "Perl",
    ["json"] = "JSON", ["jsonc"] = "JSON", ["yaml"] = "YAML", ["yml"] = "YAML",
    ["toml"] = "TOML", ["ini"] = "INI", ["conf"] = "Config", ["cfg"] = "Config",
    ["env"] = "ENV", ["bash"] = "Bash", ["sh"] = "Shell", ["shell"] = "Shell",
    ["zsh"] = "Zsh", ["fish"] = "Fish", ["powershell"] = "PowerShell",
    ["ps1"] = "PowerShell", ["cmd"] = "CMD", ["batch"] = "Batch",
    ["sql"] = "SQL", ["mysql"] = "MySQL", ["postgresql"] = "PostgreSQL",
    ["postgres"] = "PostgreSQL", ["sqlite"] = "SQLite", ["plpgsql"] = "PL/pgSQL",
    ["tsql"] = "T-SQL", ["haskell"] = "Haskell", ["hs"] = "Haskell",
    ["lisp"] = "Lisp", ["clojure"] = "Clojure", ["scheme"] = "Scheme",
    ["erlang"] = "Erlang", ["elixir"] = "Elixir", ["scala"] = "Scala",
    ["kotlin"] = "Kotlin", ["swift"] = "Swift", ["r"] = "R",
    ["markdown"] = "Markdown", ["md"] = "Markdown", ["tex"] = "LaTeX",
    ["latex"] = "LaTeX", ["makefile"] = "Makefile", ["cmake"] = "CMake",
    ["dockerfile"] = "Dockerfile", ["docker"] = "Dockerfile",
    ["graphql"] = "GraphQL", ["gql"] = "GraphQL",
    ["asd"] = "Pseudocodice", ["pseudocode"] = "Pseudocodice", ["algorithm"] = "Pseudocodice",
}

--- Restituisce chiave normalizzata del fence (es. "JavaScript " -> "javascript")
local function normalize_lang(lang)
    return (lang:lower():match("^%s*(.-)%s*$"))
end

--- Etichetta da mostrare: tabella, altrimenti il fence con la prima maiuscola
local function display_name(fence, key)
    if DISPLAY_NAME[key] then return DISPLAY_NAME[key] end
    if fence == "" then return "" end
    return fence:sub(1, 1):upper() .. fence:sub(2)
end

--- Ogni blocco di codice diventa
---   \begin{ubcode}{<linguaggio listings>}{<etichetta>} ... \end{ubcode}
--- (ambiente definito in unina_doc_class.cls). Si emette direttamente LaTeX
--- perché Pandoc, per i linguaggi che non conosce (es. JavaScript), scrive un
--- lstlisting SENZA language= e il codice perde i colori.
function CodeBlock(elem)
    if elem.classes and elem.classes[1] and elem.classes[1]:lower() == "mermaid" then
        return pandoc.RawBlock('tex', '\\begin{mermaid}\n' .. elem.text .. '\n\\end{mermaid}')
    end

    local fence = (elem.classes and elem.classes[1]) or ""
    local key = normalize_lang(fence)
    local lang = LANGUAGE_MAP[key] or ""
    local label = (display_name(fence, key):gsub("([%$%&%%_#{}~^])", "\\%1"))

    local text = elem.text:gsub("\n+$", "")
    if text == "" then return elem end

    return pandoc.RawBlock('tex', string.format(
        "\\begin{ubcode}{%s}{%s}\n%s\n\\end{ubcode}", lang, label, text))
end

--- ============================================================
--- PART 4: METADATA HANDLING
--- ============================================================

--- Add custom language mappings via YAML metadata
function Meta(m)
    if m.lstlanguages then
        local custom_langs = pandoc.utils.to_table(m.lstlanguages)
        for lang, mapped in pairs(custom_langs) do
            local lang_str = tostring(lang)
            local mapped_str = tostring(mapped)
            LANGUAGE_MAP[lang_str:lower()] = mapped_str
        end
    end
    return m
end

--- ============================================================
--- RETURN FILTER TABLE
--- ============================================================

return {
    { Meta = Meta },           -- Process metadata first
    { BlockQuote = Aside },    -- [!aside] (prima di Image)
    { Image = Image },         -- Process images
    { BlockQuote = BlockQuote }, -- Process callouts
    { CodeBlock = CodeBlock },  -- Process code blocks
}