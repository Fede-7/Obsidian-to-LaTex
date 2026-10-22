%% ============================================================
%%  unina_doc_class.cls  --  versione ripulita
%%  Compilare con:  lualatex --shell-escape
%%
%%  Struttura del progetto (relativa alla cartella da cui parte lualatex):
%%     fonts/    font .ttf/.otf        (FONTS_DIR nel .env)
%%     Images/   immagini             (IMAGES_DIR nel .env)
%%     sources/  uni_logo.pdf         (SOURCES_DIR nel .env)
%%  Le cartelle arrivano da build.sh come macro (\ubfontdir, \ubimgdir,
%%  \ubsrcdir, \ubmermaiddir); i valori qui sopra sono i predefiniti.
%% ============================================================
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{unina_doc_class}[Modern Unina Doc Class V2]
% Opzione [dark]: palette scura per i box (\documentclass[dark]{unina_doc_class})
\newif\ifub@dark
\DeclareOption{dark}{\ub@darktrue}
% Opzione [codelight]: blocchi di codice chiari (Amethyst) invece di Carbon scuro
\newif\ifub@codelight
\DeclareOption{codelight}{\ub@codelighttrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{extreport}}
\ProcessOptions\relax
\LoadClass[10pt,oneside]{extreport}

%% In un .cls la @ e' gia' una lettera: niente \makeatletter / \makeatother.

%% ------------------------------------------------------------
%%  Pacchetti (nessun duplicato, hyperref/xurl verso la fine)
%% ------------------------------------------------------------
\RequirePackage{iftex}
\RequireLuaTeX
\RequirePackage[svgnames]{xcolor}
\RequirePackage{etoolbox}
\RequirePackage{graphicx}
\RequirePackage{float}
\RequirePackage{caption}
\RequirePackage{geometry}
\RequirePackage{mathtools}   % carica amsmath
\RequirePackage{amssymb}
\RequirePackage[no-math]{fontspec}
\RequirePackage[italian]{babel}
\RequirePackage{parskip}
\RequirePackage[explicit]{titlesec}
\RequirePackage{titletoc}
\RequirePackage{fancyhdr}
\RequirePackage{enumitem}
\RequirePackage{booktabs}
\RequirePackage{xltabular}   % carica anche tabularx, longtable, array
\RequirePackage{needspace}
\RequirePackage[normalem]{ulem}
\RequirePackage{tikz}
\RequirePackage[object=vectorian]{pgfornament}
\RequirePackage{tcolorbox}
\RequirePackage{listings}
\RequirePackage{lstautogobble}
\RequirePackage{lstfiracode}
\RequirePackage[htt]{hyphenat}
\RequirePackage{microtype}
\RequirePackage{pdfpages}
\RequirePackage[hidelinks]{hyperref}
\RequirePackage{xurl}

\providecommand\ubimgdir{Images/}   % sovrascritto da build.sh (IMAGES_DIR)
\graphicspath{{\ubimgdir}}

\usetikzlibrary{arrows.meta, matrix, positioning, fit, backgrounds, trees,
                shapes.geometric, calc, automata,
                decorations.pathreplacing, decorations.pathmorphing}
\tcbuselibrary{skins,breakable,listings}

%% ------------------------------------------------------------
%%  Colori
%%  I colori standard di xcolor (blue, red, green, ...) NON vengono
%%  piu' ridefiniti: le tinte dell'ateneo hanno il prefisso "ub-".
%% ------------------------------------------------------------
\definecolor{sapphire}{HTML}{2B50AA}
\definecolor{cherryred}{HTML}{FF004D}
\definecolor{turquoise}{HTML}{00F5CC}
\definecolor{seagreen}{HTML}{22AAA1}
\definecolor{naplesyellow}{HTML}{FFDF64}
\definecolor{ub-orange}{HTML}{FF9507}
\definecolor{ub-blue}{HTML}{179AFF}
\definecolor{ub-green}{HTML}{17FF7C}
\definecolor{ub-red}{HTML}{FF3E4B}
\definecolor{ub-yellow}{HTML}{DBED00}
\definecolor{ub-violet}{HTML}{47007D}

\definecolor{azure-gradient-1}{HTML}{B1E7E1}
\definecolor{azure-gradient-2}{HTML}{A1E2DB}
\definecolor{azure-gradient-3}{HTML}{92DDD6}
\definecolor{azure-gradient-4}{HTML}{83D8CF}
\definecolor{azure-gradient-5}{HTML}{73D3C9}
\definecolor{azure-gradient-6}{HTML}{64CEC3}

% Colori usati nei capitoli (spostati da main.tex)
\definecolor{codegreen}{RGB}{80,160,80}
\definecolor{codegray}{RGB}{130,130,130}
\definecolor{activeline}{RGB}{220,245,220}
\definecolor{boxbg}{RGB}{245,245,245}
\definecolor{mainbg}{RGB}{235,245,255}

\definecolor{primary}{HTML}{003366} % Blu Unina (copertina e tema chiaro)
\colorlet{accent}{ub-violet}

%% ------------------------------------------------------------
%%  Tema della pagina: light (default) / dark  (opzione [dark])
%%  Ogni colore che dipende dallo sfondo e' un "token" ub-*: il tema
%%  chiaro ha i valori di sempre, quello scuro ha sfondo scuro e testo
%%  chiaro. La copertina non cambia (ha lo sfondo a tutta pagina).
%% ------------------------------------------------------------
\ifub@dark
  \definecolor{ub-page-bg}{HTML}{12151C}    % sfondo pagina
  \definecolor{ub-text}{HTML}{E2E8F0}       % testo base
  \definecolor{ub-rule}{HTML}{FC8181}       % linee sotto i titoli
  \definecolor{ub-toc-num}{HTML}{90CDF4}    % indice: numeri
  \definecolor{ub-toc-text}{HTML}{BEE3F8}   % indice: titoli
  \definecolor{ub-toc-page}{HTML}{63B3ED}   % indice: pagine
  \definecolor{ub-toc-line}{HTML}{2D3748}   % indice: filetti
  \definecolor{ub-hi}{HTML}{D6BCFA}         % \hi
  \definecolor{ub-file}{HTML}{B794F4}       % \file
  \definecolor{ub-dir}{HTML}{90CDF4}        % \dir
  \definecolor{ub-ink}{HTML}{90CDF4}        % \qterm, \qstruct, nome listing
  \definecolor{ub-fn}{HTML}{FEB2B2}         % \qfunction
  \definecolor{ub-sep}{HTML}{B794F4}        % \separator
  \definecolor{ub-abs-title}{HTML}{90CDF4}  % abstract: titolo
  \definecolor{ub-abs-text}{HTML}{CBD5E0}   % abstract: testo
  \definecolor{ub-solid-text}{HTML}{1A202C} % testo nei box con sfondo chiaro scelto a mano
  \definecolor{ub-half-bg}{HTML}{2D3748}    % halfframedbox
  \definecolor{ub-half-text}{HTML}{EDF2F7}
  \definecolor{ub-quote-text}{HTML}{CBD5E0} % citazioni
  \definecolor{ub-quote-bar}{HTML}{4A5568}
\else
  \colorlet{ub-page-bg}{white}
  \colorlet{ub-text}{black}
  \colorlet{ub-rule}{Maroon}
  \colorlet{ub-toc-num}{primary!60!black}
  \colorlet{ub-toc-text}{primary}
  \colorlet{ub-toc-page}{primary!80!black}
  \colorlet{ub-toc-line}{primary!40}
  \colorlet{ub-hi}{accent!80!black}
  \colorlet{ub-file}{accent!80!white}
  \colorlet{ub-dir}{primary!75!black}
  \colorlet{ub-ink}{primary}
  \colorlet{ub-fn}{cherryred}
  \colorlet{ub-sep}{DarkViolet}
  \colorlet{ub-abs-title}{primary!75!black}
  \colorlet{ub-abs-text}{primary!35!black}
  \colorlet{ub-solid-text}{black}
  \colorlet{ub-half-bg}{White!96!black}
  \colorlet{ub-half-text}{black}
  \colorlet{ub-quote-text}{black!78}
  \colorlet{ub-quote-bar}{black!25}
\fi
% Con [dark] la pagina diventa scura e il testo chiaro
\AtBeginDocument{\ifub@dark\pagecolor{ub-page-bg}\color{ub-text}\fi}

%% ------------------------------------------------------------
%%  Font
%%  Un solo punto per il percorso. Se un file manca la classe NON
%%  si ferma: avvisa e ripiega su \sffamily.
%% ------------------------------------------------------------
\providecommand\ubfontdir{fonts/}   % sovrascritto da build.sh (FONTS_DIR)
\providecommand\ub@fontdir{\ubfontdir}

% \ub@newfont{<comando>}{<nome font>}{<file di controllo, senza estensione>}{<ext>}{<opzioni fontspec>}
\newcommand\ub@newfont[5]{%
  \IfFileExists{\ub@fontdir#3.#4}{%
    \edef\ub@tmp{\noexpand\newfontfamily\noexpand#1{#2}%
      [Path=\ub@fontdir,Extension=.#4,\unexpanded{#5}]}%
    \ub@tmp
  }{%
    \ClassWarningNoLine{unina_doc_class}{Font \ub@fontdir#3.#4 non trovato:
      \string#1 usa \string\sffamily}%
    \newcommand#1{\sffamily}%
  }%
}

\ub@newfont\Lato{Lato}{Lato-Regular}{ttf}{%
  UprightFont=*-Regular, BoldFont=*-Bold,
  ItalicFont=*-Italic, BoldItalicFont=*-BoldItalic}
\ub@newfont\LatoBlack{Lato-Black}{Lato-Black}{ttf}{UprightFont=*}
\ub@newfont\Scientifica{scientifica}{scientifica}{ttf}{%
  UprightFont=*, BoldFont=*Bold, ItalicFont=*Italic}
\ub@newfont\FiraCode{FiraCode}{FiraCode-Regular}{ttf}{%
  UprightFont=*-Regular, BoldFont=*-Bold, Contextuals=Alternate}
\ub@newfont\Agency{Agency}{Agency}{ttf}{UprightFont=*}
% fontspec toglie gli spazi dal nome: il file e' AlteDIN1451MittelschriftG.ttf
\ub@newfont\AlteG{Alte-DIN-1451-Mittelschrift-G}{Alte-DIN-1451-Mittelschrift-G}{ttf}{%
  UprightFont=*, BoldFont=*, ItalicFont=*, BoldItalicFont=*,
  BoldFeatures={FakeBold=2}, ItalicFeatures={FakeSlant=0.25},
  BoldItalicFeatures={FakeBold=2, FakeSlant=0.25}}
\ub@newfont\Gobold{Gobold}{Gobold-Regular}{otf}{%
  UprightFont=*-Regular, BoldFont=*-Bold,
  ItalicFont=*-Italic, BoldItalicFont=*-BoldItalic}
\ub@newfont\IcoMoon{IcoMoon}{IcoMoon}{ttf}{UprightFont=*}
\ub@newfont\IcoFont{IcoFont}{IcoFont}{ttf}{UprightFont=*}
% JetBrains Mono NL: usato SOLO per il codice (listings, \lstinline, \texttt).
% Non si usa \setmonofont: cambierebbe il monospace ovunque (url, verbatim, ...).
% Nome = base del file: JetBrainsMonoNL-{Regular,Bold,Italic,BoldItalic}.ttf
\ub@newfont\JetBrains{JetBrainsMonoNL}{JetBrainsMonoNL-Regular}{ttf}{%
  UprightFont=*-Regular, BoldFont=*-Bold,
  ItalicFont=*-Italic, BoldItalicFont=*-BoldItalic}
% Se il font manca, il codice ripiega sul monospace standard (non su sans)
\IfFileExists{\ub@fontdir JetBrainsMonoNL-Regular.ttf}{}{\renewcommand\JetBrains{\ttfamily}}
% \texttt (usato da Pandoc per il codice inline nei titoli) -> JetBrains
\DeclareTextFontCommand{\texttt}{\JetBrains}

%% Icone (solo quelle usate). \char"XXXX\relax: il \relax chiude la costante.
\newcommand\ub@moon[1]{{\IcoMoon\char"#1\relax}}
\newcommand\ub@ico[1]{{\IcoFont\char"#1\relax}}

\newcommand\ifolder{\ub@moon{E92F}}
\newcommand\iwrench{\ub@moon{E991}}
\newcommand\icodeopentag{\ub@moon{EA7F}}
\newcommand\iterminal{\ub@moon{EA81}}
\newcommand\ilabel{\ub@moon{E90A}}
\newcommand\iuser{\ub@moon{E903}}
\newcommand\iauto{\ub@ico{EEA9}}
\newcommand\ifile{\ub@ico{EB08}}
\newcommand\ifilecode{\ub@ico{EB0C}}

%% ------------------------------------------------------------
%%  Impaginazione
%%  Misurata sulla classe originale: textwidth/textheight/marginparwidth
%%  erano ignorati da geometry (sovra-specificati). Qui: solo margini.
%% ------------------------------------------------------------
\@ifundefined{ubpaper}{\def\ubpaper{b5paper}}{}
\edef\ub@geomopts{\ubpaper,}
\expandafter\geometry\expandafter{\ub@geomopts
  left      = 0\paperwidth,   % margine sinistro  (vedi sotto: viene sovrascritto)
  right     = .05\paperwidth,   % margine destro
  top       = .05\paperheight,  % margine alto
  bottom    = .08\paperheight,  % margine basso
  headheight= 14pt,
  headsep   = .03\paperheight,
  footskip  = 20pt,             % distanza del numero di pagina dal testo
  heightrounded,
}

\setlength\parindent{0pt}
\setlength\emergencystretch{3em}   % codice inline lungo: niente sbordi, va a capo
\setlength\parskip{0.35em}
\numberwithin{equation}{section}

\fancypagestyle{plain}{%
  \fancyhf{}%
  \fancyfoot[C]{\color{ub-text}\hfill-- \thepage\ --\hfill}%
  \renewcommand{\headrulewidth}{0pt}%
  \renewcommand{\footrulewidth}{0pt}%
}

%% Larghezza disponibile per le etichette nel margine sinistro
\newlength\ub@labelw
\AtBeginDocument{\setlength\ub@labelw{\dimexpr\oddsidemargin+1in-16pt\relax}}

\providecommand{\documentname}{\IfFontExistsTF{DejaVu Sans}{{\fontspec{DejaVu Sans}(╯°□°)╯}}{(°□°)}}    % ← EasterEgg
\providecommand{\documentyear}{\IfFontExistsTF{DejaVu Sans}{{\fontspec{DejaVu Sans}☉ ‿ ⚆}}{o\_o}}   % ← EasterEgg

\providecommand{\documentlsttitle}{Listings}
\providecommand{\documentlstlabel}{Listing}

\newcommand\blankpage{\null\thispagestyle{empty}\addtocounter{page}{-1}\newpage}

%% ------------------------------------------------------------
%%  Titoli
%% ------------------------------------------------------------
\setcounter{chapter}{-1}   % il primo \chapter diventa il capitolo 0
\def\currentchapter{}

\titlespacing*{\chapter}{0pt}{0ex}{3ex}
\titleformat{\chapter}[display]
  {\normalfont}
  {\footnotesize\textsc{\chaptername\ \thechapter}}
  {0pt}
  {\Needspace{6\baselineskip}\Large\bfseries\sffamily #1\global\def\currentchapter{#1}}
  [\vspace{-10pt}{\color{ub-rule}\rule{\textwidth}{.6pt}}]
\titleformat{name=\chapter,numberless}[display]
  {\normalfont\filcenter}
  {}
  {0pt}
  {\Needspace{6\baselineskip}\Large\bfseries\sffamily #1\global\def\currentchapter{#1}}
  [\vspace{-10pt}{\color{ub-rule}\rule{\textwidth}{.6pt}}]

\titlespacing*{\section}{0pt}{1.2ex plus .2ex minus .2ex}{1.5ex plus .2ex minus .2ex}
\titleformat{\section}[display]
  {\normalfont}
  {\footnotesize\textsc{Sezione \thesection}}
  {0pt}
  {\Needspace{4\baselineskip}\Large\bfseries #1}
  [\vspace{-10pt}{\color{ub-rule}\rule{\textwidth}{.6pt}}]
\titleformat{name=\section,numberless}[display]
  {\normalfont}
  {}
  {0pt}
  {\Needspace{4\baselineskip}\Large\bfseries #1}
  [\vspace{-10pt}{\color{ub-rule}\rule{\textwidth}{.6pt}}]

\titlespacing*{\subsection}{0pt}{1.2ex plus .2ex minus .2ex}{1ex plus .2ex minus .2ex}
\titleformat{\subsection}[display]
  {\normalfont}
  {\footnotesize\textsc{Sottosezione \thesubsection}}
  {0pt}
  {\Needspace{3\baselineskip}\normalsize\bfseries #1}
\titleformat{name=\subsection,numberless}[display]
  {\normalfont}
  {}
  {0pt}
  {\Needspace{3\baselineskip}\normalsize\bfseries #1}

\titlespacing*{\subsubsection}{0pt}{1ex plus .2ex minus .2ex}{0.5ex plus .2ex minus .2ex}
\titleformat{\subsubsection}[hang]
  {\normalfont\normalsize\bfseries}
  {}
  {0pt}
  {\Needspace{2\baselineskip}#1}

%% ------------------------------------------------------------
%%  Indice
%%  (prima: \titlecontents* con asterisco = voci "run-in" sulla stessa
%%   riga; \fontsize{..}{0} = interlinea nulla. Corretti entrambi.)
%% ------------------------------------------------------------
\titlecontents{part}
  [0pt]
  {\addvspace{1cm}\centering}
  {\color{ub-toc-num}\fontsize{16}{19}\selectfont\Gobold Parte \thecontentslabel\quad}
  {\color{ub-toc-num}\fontsize{16}{19}\selectfont\Gobold}
  {\hfill\color{ub-toc-page}\bfseries\Scientifica\fontsize{14}{17}\selectfont\contentspage}
  [\addvspace{0.3cm}\hrule height 1.5pt\addvspace{0.5cm}]

\titlecontents{chapter}
  [0pt]
  {\addvspace{0.5cm}}
  {\color{ub-toc-num}\fontsize{12}{15}\selectfont\Gobold\thecontentslabel\hspace{0.125cm}\color{ub-toc-text}}
  {}
  {\color{ub-toc-page}\hfill\bfseries\Scientifica\fontsize{12}{15}\selectfont\contentspage}
  [\addvspace{1pt}{\color{ub-toc-line}\hrule height 1pt}]

\titlecontents{section}
  [0.5cm]
  {}
  {\color{ub-toc-num}\fontsize{10}{12}\selectfont\AlteG\thecontentslabel\hspace{0.125cm}\color{ub-toc-text}}
  {}
  {\color{ub-toc-page}\hfill\bfseries\Scientifica\fontsize{10}{12}\selectfont\contentspage}

\titlecontents{subsection}
  [1cm]
  {}
  {\color{ub-toc-num}\fontsize{8}{10}\selectfont\Lato\thecontentslabel\hspace{0.125cm}\color{ub-toc-text}}
  {}
  {\color{ub-toc-page}\hfill\bfseries\Scientifica\fontsize{8}{10}\selectfont\contentspage}

%% ------------------------------------------------------------
%%  Abstract
%% ------------------------------------------------------------
\let\abstract\relax
\let\endabstract\relax
\newenvironment{abstract}
  {\thispagestyle{empty}\vfill
   {\par\raggedleft\fontsize{16}{19}\selectfont\Gobold\color{ub-abs-title} Estratto\par
    \vspace{0.25cm}\hrule height 2pt\par}%
   \setlength{\parskip}{0.5em}\color{ub-abs-text}\Lato\fontsize{12}{15}\selectfont}
  {\newpage}

%% ------------------------------------------------------------
%%  Comandi di evidenziazione e icone in apice
%% ------------------------------------------------------------
\newcommand\ub@scale[1]{%
  \fontsize{#1\dimexpr\f@size pt\relax}{\dimexpr\f@size pt\relax}\selectfont}
\newcommand\ub@apexmeasure[2]{\raisebox{#2\dimexpr\f@size pt\relax}{\ub@scale{#2}#1}}
\newcommand\ub@apex[1]{\ub@apexmeasure{#1}{0.65}}
\newcommand\ub@sptext[2]{{#1\ub@scale{0.7}\ub@apex{#2}}}
\newcommand\ub@sprtext[2]{{\ub@scale{0.7}\ub@apex{#2}}{#1}}

\newcommand\hi[1]{{\color{ub-hi}\LatoBlack\mbox{#1}}}
\newcommand\file[1]{{\color{ub-file}\FiraCode\mbox{\penalty 100\ifile\hspace{1pt}#1}}}
\newcommand\dir[1]{{\color{ub-dir}\ub@sprtext{#1}{\ifolder}}}

\newcommand\qmake{\ub@sptext{gnu make}{\iauto}}
\newcommand\qmakefile{\ub@sptext{makefile}{\ifile\iauto}}
\newcommand\qterm{{\color{ub-ink}\ub@sprtext{terminal emulator}{\iterminal}}\ }
\newcommand\qstruct[1]{{\color{ub-ink}\ub@apexmeasure{struct}{0.5}\ub@sptext{#1}{\iwrench}}}
\newcommand\qfunction[1]{{\color{ub-fn}\ub@sptext{#1}{\ifile\icodeopentag}}}

\newcommand{\mycbox}[1]{\tikz{\path[draw=#1,fill=#1] (0,0) rectangle (1cm,1cm);}}

%% ------------------------------------------------------------
%%  Separatori con ornamenti
%% ------------------------------------------------------------
\newcommand{\shapeableseparator}[2]{%
  \nointerlineskip\vspace{.5\baselineskip}\hspace{\fill}%
  {\color{#1}\resizebox{0.5\linewidth}{2ex}{%
     \begin{tikzpicture}
       \node (C) at (0,0) {};
       \node (D) at (9,0) {};
       \path (C) to [ornament=#2] (D);
     \end{tikzpicture}}}%
  \hspace{\fill}\par\nointerlineskip\vspace{.5\baselineskip}}

\newcommand{\separator}{\shapeableseparator{ub-sep}{85}}

\NewDocumentCommand{\optional}{o}{\IfValueT{#1}{#1}}

%% ------------------------------------------------------------
%%  Copertina
%%  \coverpage{<corpo anno>}{<anno>}{<corpo titolo>}{<titolo>}
%% ------------------------------------------------------------
\providecommand\ubsrcdir{sources/}   % sovrascritto da build.sh (SOURCES_DIR)
\providecommand\ub@logo{\ubsrcdir uni_logo.pdf}

\tikzset{
  mpath/.style={fill=#1, draw=#1, line width=0pt},
  square/.style={regular polygon, regular polygon sides=4, inner sep=0pt, outer sep=0pt},
}

\tikzset{mpath/.style={draw=none, fill=#1}}

\newcommand\coverpage[4]{%
  \clearpage
  \thispagestyle{empty}%
  \pgfmathsetmacro\ub@titlebaseline{1.2*#3}%
  % Disegna lo sfondo TikZ direttamente durante lo Shipout del foglio PDF
  \AddToShipoutPictureBG*{%
    \begin{tikzpicture}[remember picture, overlay, shift={(current page.south west)}]
      \begin{scope}[x={(current page.south east)}, y={(current page.north west)}, overlay]
        
        % Background geometrico
        \fill [primary!75!white] (0,0) rectangle (1,1);
        \path [mpath=primary!25!white] (0,0.25) -- (0.2,0.4) -- (0.8,0.4) -- (1,0.55) -- (1,0.1) -- (0.93,0.05) -- (0.07,0.05) -- (0,0) -- cycle;
        \path [mpath=primary!85!white] (0,0.27) -- (0.17,0.40) -- (0.2,0.40) -- (0,0.25) -- cycle;
        \path [mpath=primary!85!white] (0.77,0.4) -- (0.8,0.40) -- (1,0.55) -- (1,0.57) -- cycle;
        \path [mpath=primary!65!black] (0,0) -- (0.025,0) -- (0.075,0.035) -- (0.94,0.035) -- (1,0.08) -- (1,0.1) -- (0.93,0.05) -- (0.07,0.05) -- (0,0) -- cycle;
        \path [mpath=primary!35!black] (0,0.27) -- (0.17,0.40) -- (0.77,0.40) -- (1,0.57) -- (1,0.8) -- (0.85,0.8) -- (0.6,0.6) -- (0.13,0.6) -- (0,0.5) -- cycle;

        % Logo Ateneo
        \IfFileExists{\ub@logo}{%
          \node (fiisymbol) at ([yshift=-0.5cm, xshift=0.5cm]0,1)
            [align=center, anchor=north west, inner sep=0pt, outer sep=0pt]
            {\includegraphics[width=3cm, height=3cm, keepaspectratio]{\ub@logo}};
        }{%
          \ClassWarningNoLine{unina_doc_class}{Logo \ub@logo non trovato}%
          \node (fiisymbol) at ([yshift=-0.5cm, xshift=0.5cm]0,1)
            [anchor=north west, inner sep=0pt, minimum size=3cm] {};
        }

        % Intestazione Università
        \node (fiitext) at ([xshift=0.25cm] fiisymbol.north east) [align=left, anchor=north west]
          {{\color{primary!65!black}\Lato\fontsize{10}{12}\selectfont Università degli Studi di Napoli}};
        \node (fiiname) at ([xshift=0.01cm, yshift=0.2cm] fiitext.south west) [align=left, anchor=north west]
          {{\color{primary!65!black}\Agency\fontsize{24}{29}\selectfont Federico II}};
          
        % Anno Accademico
        \node (academicyear) at ([xshift=-0.5cm] fiitext.north -| 1,1) [align=right, anchor=north east]
          {{\color{primary!65!black}\Gobold\fontsize{#1}{\ub@titlebaseline}\selectfont #2}};
          
        % Titolo Principale Centrato
        \node at ([xshift=0.1cm, yshift=0.1cm] $(0,0)!0.5!(1,1)$)
          [align=center, anchor=center, inner sep=0pt, outer sep=0pt]
          {{\color{primary!70!white}\Gobold\fontsize{#3}{\ub@titlebaseline}\selectfont #4}};

      \end{scope}
    \end{tikzpicture}%
  }%
  \null\newpage
}

%% ------------------------------------------------------------
%%  Callout (Definition, Info, Warning, ...)
%%
%%  Prima: etichetta nel margine con \marginnote (fragile: serve una
%%  seconda compilazione, salta dentro altri box, \reversemarginpar...).
%%  Ora: nodo TikZ ancorato all'angolo del box (stile NotesTeX),
%%  funziona alla prima compilazione e solo sul primo frammento.
%% ------------------------------------------------------------
%% Palette dei box: {nome}{sfondo}{bordo}{testo}{titolo}  (esadecimali RGB)
\newcommand\ub@boxpalette[5]{%
  \definecolor{ub-#1-bg}{HTML}{#2}%
  \definecolor{ub-#1-frame}{HTML}{#3}%
  \definecolor{ub-#1-text}{HTML}{#4}%
  \definecolor{ub-#1-title}{HTML}{#5}}

\ifub@dark
  %%            nome   sfondo   bordo    testo    titolo
  \ub@boxpalette{def}  {1A2634}{4299E1}{E2E8F0}{EDF2F7}
  \ub@boxpalette{info} {182A3A}{63B3ED}{E2E8F0}{90CDF4}
  \ub@boxpalette{warn} {2D2615}{ECC94B}{FEEBC8}{FAF089}
  \ub@boxpalette{err}  {321D1D}{FC8181}{FED7D7}{FEB2B2}
  \ub@boxpalette{ex}   {152E22}{48BB78}{C6F6D5}{9AE6B4}
  \ub@boxpalette{lab}  {231B32}{B794F4}{E9D8FD}{D6BCFA}
  \ub@boxpalette{gen}  {2D3748}{A0AEC0}{EDF2F7}{F7FAFC}
\else
  \ub@boxpalette{def}  {F0F4F8}{2B6CB0}{1A365D}{1A202C}
  \ub@boxpalette{info} {F0F7FF}{3182CE}{1A365D}{2C5282}
  \ub@boxpalette{warn} {FEFCBF}{B7791B}{744210}{744210}
  \ub@boxpalette{err}  {FFF5F5}{E53E3E}{742A2A}{9B2C2C}
  \ub@boxpalette{ex}   {F0FFF4}{38A169}{1C4532}{22543D}
  \ub@boxpalette{lab}  {F3E8FF}{805AD5}{322659}{44337A}
  \ub@boxpalette{gen}  {F7FAFC}{4A5568}{2D3748}{1A202C}
\fi

% \ub@boxlabel[colore]{testo}{spostamento verticale}
\NewDocumentCommand\ub@boxlabel{O{ub-text} m m}{%
  \node[anchor=north east, inner sep=0pt, xshift=-8pt, yshift=-#3,
        text width=\ub@labelw, align=right,
        font=\footnotesize\bfseries\sffamily, text=#1]
    at (frame.north west) {#2};}

% \ub@title{prefisso}{titolo}{colore}: niente se il titolo e' vuoto
\newcommand\ub@title[3]{%
  \ifblank{#2}{}{{\color{#3}\textbf{\ifblank{#1}{}{#1: }#2}\par}\smallskip}}

% stile con palette: {etichetta}{palette}{spazio sopra/sotto}
\tcbset{
  ub callout/.style n args={3}{
    enhanced, breakable, sharp corners,
    colback=ub-#2-bg, colframe=ub-#2-frame, coltext=ub-#2-text,
    boxrule=0pt, boxsep=0pt,
    borderline west={2pt}{0pt}{ub-#2-frame},
    left=5pt, right=5pt, top=#3, bottom=#3,
    before skip=10pt, after skip=10pt,
    before={\Needspace{4\baselineskip}},
    overlay unbroken and first={\ub@boxlabel[ub-#2-title]{#1}{#3}},
  },
  % stile con colori espliciti (halfframedbox): {etichetta}{bordo}{sfondo}{spazio}
  ub callout raw/.style n args={4}{
    enhanced, breakable, sharp corners,
    colback=#3, colframe=#2,
    boxrule=0pt, boxsep=0pt,
    borderline west={2pt}{0pt}{#2},
    left=5pt, right=5pt, top=#4, bottom=#4,
    before skip=10pt, after skip=10pt,
    before={\Needspace{4\baselineskip}},
    overlay unbroken and first={\ub@boxlabel{#1}{#4}},
  },
}

% \ub@newcallout{ambiente}{etichetta}{prefisso titolo}{palette}{vpad}{extra}
\newcommand\ub@newcallout[6]{%
  \newtcolorbox{#1}[1]{%
    ub callout={#2}{#4}{#5},
    before upper={\ub@title{#3}{##1}{ub-#4-title}},
    #6}}

\newcommand\ubLabelDefinition{Definition}
\newcommand\ubLabelInfo{Info}
\newcommand\ubLabelWarning{Warning}
\newcommand\ubLabelError{Error}
\newcommand\ubLabelExample{Example}
\newcommand\ubLabelLab{Lab}

%% Margine sinistro: calcolato sull'etichetta piu' larga (Definition, Warning...)
%% nello stesso font/corpo con cui viene composta, cosi' non esce mai dal foglio.
%% left = etichetta piu' larga + 32pt (8pt di spostamento dal box, 16pt di
%% respiro verso il bordo, 8pt di scarto); \ub@labelpad si puo' ritoccare.
\newlength\ub@maxlabel
\newlength\ub@tmpw
\newlength\ub@labelpad
\setlength\ub@labelpad{20pt}   % ← cambia qui: più grande = margine sinistro più largo
\newcommand\ub@measurelabel[1]{%
  \settowidth\ub@tmpw{\footnotesize\bfseries\sffamily #1}%
  \ifdim\ub@tmpw>\ub@maxlabel \setlength\ub@maxlabel{\ub@tmpw}\fi}
\ub@measurelabel{\ubLabelDefinition}
\ub@measurelabel{\ubLabelInfo}
\ub@measurelabel{\ubLabelWarning}
\ub@measurelabel{\ubLabelError}
\ub@measurelabel{\ubLabelExample}
\ub@measurelabel{\ubLabelLab}
\geometry{left=\dimexpr\ub@maxlabel+\ub@labelpad\relax}

\ub@newcallout{Definition}{\ubLabelDefinition}{}{def} {4pt}{}
\ub@newcallout{infobox}   {\ubLabelInfo}      {}{info}{4pt}{}
\ub@newcallout{warningbox}{\ubLabelWarning}   {}{warn}{4pt}{}
\ub@newcallout{errorbox}  {\ubLabelError}     {}{err} {4pt}{}
\ub@newcallout{esempiobox}{\ubLabelExample}   {}{ex}  {8pt}{left=10pt,right=10pt}
\ub@newcallout{labbox}    {\ubLabelLab}       {}{lab} {4pt}{}

% Alias identici a infobox
\let\infoboxtag\infobox
\let\endinfoboxtag\endinfobox

% Box generici (riga di etichetta vuota, titolo opzionale)
\newtcolorbox{halfframedbox}[2]{%
  ub callout raw={}{#1}{ub-half-bg}{4pt}, coltext=ub-half-text,
  overlay unbroken and first={\ub@boxlabel{#2}{4pt}},
  before upper={\ub@title{}{#2}{ub-half-text}}}

\newtcolorbox{simpletbox}[2]{%
  enhanced, breakable, sharp corners,
  colback=#1, colframe=#2, coltext=ub-solid-text,
  boxrule=0pt, boxsep=0pt, left=5pt, right=5pt,
  before skip=10pt, after skip=10pt,
  borderline west={2pt}{0pt}{#2}}
\let\boxwithfold\simpletbox
\let\endboxwithfold\endsimpletbox

\newtcolorbox{generalbox}[2][]{%
  enhanced, breakable, sharp corners,
  colback=ub-gen-bg, colframe=ub-gen-frame, coltext=ub-gen-text,
  boxrule=0pt, boxsep=0pt,
  borderline west={2pt}{0pt}{ub-gen-frame},
  left=5pt, right=5pt,
  before skip=10pt, after skip=10pt,
  before upper={\ub@title{}{#2}{ub-gen-title}},
  #1}

% Abbreviazioni
\newcommand{\lab}[2]{\begin{labbox}{#1}#2\end{labbox}}
\newcommand{\dfn}[2]{\begin{Definition}{#1}#2\end{Definition}}
\newcommand{\info}[2]{\begin{infobox}{#1}#2\end{infobox}}
\newcommand{\warning}[2]{\begin{warningbox}{#1}#2\end{warningbox}}
\newcommand{\error}[2]{\begin{errorbox}{#1}#2\end{errorbox}}
\newcommand{\infoalt}[2]{\begin{infobox}{#1}#2\end{infobox}}
\newcommand{\framedbox}[3]{\begin{halfframedbox}{#1}{#2}#3\end{halfframedbox}}
\newcommand{\marker}[3]{\begin{simpletbox}{#1}{#2}#3\end{simpletbox}}
\newcommand{\simplebox}[3]{\begin{simpletbox}{#1}{#2}#3\end{simpletbox}}
\newcommand{\gbox}[3]{\begin{generalbox}[colframe=#2]{#1}#3\end{generalbox}}
\newcommand{\example}[2]{\begin{esempiobox}{#1}#2\end{esempiobox}}

%% ------------------------------------------------------------
%%  Testo + immagine di lato (callout Obsidian [!aside])
%%  \begin{ubaside}{<larghezza immagine>}{<file>}
%%  - <larghezza immagine> = una dimensione (es. 200px, 0.4\linewidth)
%%  - oppure "auto": la colonna dell'immagine si adatta alla sua forma
%%    (altezza di riferimento 0.30\textheight, larghezza tra 20% e 45%).
%%  Il testo occupa sempre tutto lo spazio che resta; l'immagine non
%%  supera mai il 70% della riga.
%% ------------------------------------------------------------
\newlength\ub@aside@iw
\newlength\ub@aside@tw
\newlength\ub@aside@nw
\newlength\ub@aside@nh
\newenvironment{ubaside}[2]{%
  \par\Needspace{6\baselineskip}\vspace{0.4em}\noindent
  \def\ub@aside@img{#2}\edef\ub@aside@spec{#1}%
  \ifdefstring{\ub@aside@spec}{auto}{%
    \settowidth\ub@aside@nw{\includegraphics{\ub@aside@img}}%
    \settoheight\ub@aside@nh{\includegraphics{\ub@aside@img}}%
    \setlength\ub@aside@iw{\dimexpr0.30\textheight*\numexpr\ub@aside@nw*1000/\ub@aside@nh\relax/1000\relax}%
    \ifdim\ub@aside@iw>0.45\linewidth \setlength\ub@aside@iw{0.45\linewidth}\fi
    \ifdim\ub@aside@iw<0.20\linewidth \setlength\ub@aside@iw{0.20\linewidth}\fi
  }{%
    \setlength\ub@aside@iw{#1}%
    \ifdim\ub@aside@iw>0.70\linewidth \setlength\ub@aside@iw{0.70\linewidth}\fi
  }%
  \setlength\ub@aside@tw{\dimexpr\linewidth-\ub@aside@iw-0.05\linewidth\relax}%
  \minipage[c]{\ub@aside@tw}\setlength\parskip{0.35em}%
}{%
  \endminipage\hfill
  \minipage[c]{\ub@aside@iw}%
    \includegraphics[width=\linewidth,height=0.45\textheight,keepaspectratio]{\ub@aside@img}%
  \endminipage\par\vspace{0.8em}%
}

%% ------------------------------------------------------------
%%  Citazioni
%%  - blockquote Markdown semplice (">")  ->  ambiente quote
%%  - callout [!quote] Autore             ->  \begin{ubquote}{Autore}
%%  Rientrate, in corsivo, con filetto a sinistra; l'autore (se c'e')
%%  va in basso a destra come "- Autore".
%% ------------------------------------------------------------
\newtcolorbox{ubquote}[1]{%
  blanker, breakable,
  borderline west={2.5pt}{0pt}{ub-quote-bar},
  left=1.1em, right=1.2em, top=2pt, bottom=2pt,
  before skip=0.8em, after skip=0.8em,
  before upper={\itshape\color{ub-quote-text}},
  after upper={\ifstrempty{#1}{}{\par\nopagebreak\vspace{0.3em}\hfill\upshape\small -- #1}}%
}
\renewenvironment{quote}{\begin{ubquote}{}}{\end{ubquote}}

%% Variante con grafico mermaid al posto dell'immagine.
%% Il filtro emette:  \begin{ubasidem}{<larghezza>} testo \ubasidesplit
%%                    \begin{mermaid}...\end{mermaid} \end{ubasidem}
\newcommand\ubasidesplit{\endminipage\hfill\minipage[c]{\ub@aside@iw}}
\newenvironment{ubasidem}[1]{%
  \par\Needspace{0.3\textheight}\vspace{0.4em}\noindent
  \setlength\ub@aside@iw{#1}%
  \ifdim\ub@aside@iw>0.70\linewidth \setlength\ub@aside@iw{0.70\linewidth}\fi
  \setlength\ub@aside@tw{\dimexpr\linewidth-\ub@aside@iw-0.05\linewidth\relax}%
  \minipage[c]{\ub@aside@tw}\setlength\parskip{0.35em}%
}{%
  \endminipage\par\vspace{0.8em}%
}

%% ------------------------------------------------------------
%%  Tabelle
%% ------------------------------------------------------------
\newcolumntype{Y}{>{\raggedright\arraybackslash}X}
\setlength{\tabcolsep}{4pt}
\renewcommand{\arraystretch}{1.15}
\setlength{\LTleft}{0pt}
\setlength{\LTright}{0pt}

%% ------------------------------------------------------------
%%  Esempi ed esercizi numerati
%% ------------------------------------------------------------
\newcounter{esempio}[section]
\newcounter{esercizio}[section]

\newenvironment{esempio}[1]{%
  \refstepcounter{esempio}%
  \vspace{0.8em}\noindent\rule{\linewidth}{0.5pt}\par\vspace{0.15em}%
  \noindent\textbf{Esempio \thesection.\theesempio}%
  \ifblank{#1}{}{\textbf{ --- #1}}\par\vspace{0.3em}%
}{%
  \par\vspace{0.3em}\noindent\rule{\linewidth}{0.5pt}\vspace{0.8em}%
}

\newenvironment{esercizio}[1]{%
  \refstepcounter{esercizio}%
  \vspace{0.8em}\noindent\rule{\linewidth}{1.2pt}\vspace{1pt}\par
  \noindent\rule{\linewidth}{0.4pt}\par\vspace{0.15em}%
  \noindent\textbf{Esercizio \thesection.\theesercizio}%
  \ifblank{#1}{}{\textbf{ --- #1}}\par\vspace{0.3em}%
}{%
  \par\vspace{0.3em}\noindent\rule{\linewidth}{0.4pt}\vspace{1pt}\par
  \noindent\rule{\linewidth}{1.2pt}\vspace{0.8em}%
}

%% ------------------------------------------------------------
%%  Listings: UNO stile, applicato una volta sola
%%  (prima due \lstset in conflitto; il secondo imponeva anche
%%   language=bash a ogni blocco senza linguaggio)
%% ------------------------------------------------------------
\lst@Key{firstlineandnumber}\relax{%
  \def\lst@firstline{#1\relax}\def\lst@firstnumber{#1\relax}}

\newcommand\ub@lsttitle{{\color{ub-ink}\fontsize{10}{12}\selectfont
  \ub@sprtext{\lstname}{\ifilecode}}}

%% Palette "Amethyst Ink" per il codice. Colori ESPLICITI su ogni ruolo:
%% vincono sempre sul colore del testo del box (coltext) dentro i callout.
\ifub@dark
  \definecolor{CodeBg}{HTML}{231B32}
  \definecolor{CodeText}{HTML}{E2E8F0}
  \definecolor{CodeAccent}{HTML}{B794F4}
  \definecolor{CodeKeyword}{HTML}{B794F4}
  \definecolor{CodeString}{HTML}{9AE6B4}
  \definecolor{CodeComment}{HTML}{A0AEC0}
  \definecolor{CodeFunction}{HTML}{90CDF4}
  \definecolor{CodeType}{HTML}{90CDF4}
  \definecolor{CodeNumber}{HTML}{FEB2B2}
  \definecolor{CodeInlineBg}{HTML}{2D3748}
  \definecolor{CodeInlineText}{HTML}{EDF2F7}
\else
  \definecolor{CodeBg}{HTML}{F7FAFC}
  \definecolor{CodeText}{HTML}{2D3748}
  \definecolor{CodeAccent}{HTML}{805AD5}
  \definecolor{CodeKeyword}{HTML}{6B46C1}
  \definecolor{CodeString}{HTML}{276749}
  \definecolor{CodeComment}{HTML}{4A5568}
  \definecolor{CodeFunction}{HTML}{2C5282}
  \definecolor{CodeType}{HTML}{2C5282}
  \definecolor{CodeNumber}{HTML}{9C4221}
  \definecolor{CodeInlineBg}{HTML}{EDF2F7}
  \definecolor{CodeInlineText}{HTML}{1A202C}
\fi

%% Palette dei blocchi ubcode: "Shades of Purple" (come Carbon).
%% Con l'opzione [codelight] si usa invece la palette Amethyst chiara.
\ifub@codelight
  \colorlet{ShBg}{CodeBg}
  \colorlet{ShText}{CodeText}
  \colorlet{ShKeyword}{CodeKeyword}
  \colorlet{ShString}{CodeString}
  \colorlet{ShComment}{CodeComment}
  \colorlet{ShFunction}{CodeFunction}
  \colorlet{ShNumber}{CodeNumber}
  \colorlet{ShType}{CodeType}
  \colorlet{ShLineNo}{CodeComment}
  \colorlet{ShLabel}{CodeComment}
\else
  \definecolor{ShBg}{HTML}{2D2B55}
  \definecolor{ShText}{HTML}{FFFFFF}
  \definecolor{ShKeyword}{HTML}{FF9D00}
  \definecolor{ShString}{HTML}{A5FF90}
  \definecolor{ShComment}{HTML}{B362FF}
  \definecolor{ShFunction}{HTML}{FAD000}
  \definecolor{ShNumber}{HTML}{FF628C}
  \definecolor{ShType}{HTML}{9EFFFF}
  \definecolor{ShLineNo}{HTML}{7E7CA6}
  \definecolor{ShLabel}{HTML}{9A98C8}
\fi

% Grassetto delle keyword nei linguaggi: attivo solo con [codelight]
\newcommand\ub@kwb{\bfseries}
% Dentro ubcode i ruoli Code* puntano ai colori Sh*: le definizioni dei
% linguaggi (che usano Code*) si adattano da sole al tema del blocco.
\newcommand\ub@useshades{%
  \colorlet{CodeBg}{ShBg}\colorlet{CodeText}{ShText}\colorlet{CodeKeyword}{ShKeyword}%
  \colorlet{CodeString}{ShString}\colorlet{CodeComment}{ShComment}%
  \colorlet{CodeFunction}{ShFunction}\colorlet{CodeNumber}{ShNumber}%
  \colorlet{CodeType}{ShType}\colorlet{CodeAccent}{ShKeyword}%
  \ifub@codelight\else\renewcommand\ub@kwb{}\fi}

\lstdefinestyle{ub}{
  style=FiraCodeStyle,
  autogobble=true,
  mathescape=false,
  backgroundcolor=\color{CodeBg},
  basicstyle=\linespread{1.15}\footnotesize\JetBrains\color{CodeText},
  identifierstyle=\color{CodeText},
  commentstyle=\itshape\color{CodeComment},
  keywordstyle=\bfseries\color{CodeKeyword},
  stringstyle=\color{CodeString},
  % solo barra sinistra da 2pt, nessuna cornice
  frame=l, framerule=2pt, rulecolor=\color{CodeAccent},
  framesep=10pt,
  breaklines=true,
  keepspaces=true,
  tabsize=2,
  escapeinside={(*@}{@*)},
  xleftmargin=0.5cm, xrightmargin=0.5cm,
  extendedchars=true,
  showstringspaces=false,
  showtabs=false,
  captionpos=b,
  columns=fixed,
  moreliterate={≤}{{$\leq$}}1 {≥}{{$\geq$}}1 {−}{{-}}1
               {→}{{\textrightarrow}}1 {≠}{{$\neq$}}1
               {≈}{{$\approx$}}1 {×}{{$\times$}}1,
}
\lstset{style=ub}

% la chiave tagstyle appartiene all'aspetto "html" di listings, che di norma si
% carica solo quando si usa un linguaggio HTML/XML: lo carichiamo subito.
\lst@RequireAspects{html}
% Stile dei blocchi ubcode (tema Carbon): numeri di riga come un IDE
\lstdefinestyle{ubblock}{
  % azzera cornice, sfondo e margini dello stile globale: li gestisce il box
  frame=none, backgroundcolor={}, xleftmargin=0pt, xrightmargin=0pt,
  framesep=0pt, aboveskip=0pt, belowskip=0pt,
  autogobble=true,
  mathescape=false,
  basicstyle=\linespread{1.15}\footnotesize\JetBrains\color{CodeText},
  identifierstyle=\color{CodeText},
  commentstyle=\itshape\color{CodeComment},
  keywordstyle=\color{CodeKeyword},
  stringstyle=\color{CodeString},
  tagstyle=\color{CodeType},
  numbers=left, stepnumber=1, numbersep=9pt,
  numberstyle=\scriptsize\JetBrains\color{ShLineNo},
  breaklines=true,
  keepspaces=true,
  tabsize=2,
  showstringspaces=false,
  showtabs=false,
  columns=fixed, basewidth=0.6em,
  extendedchars=true,
  escapeinside={(*@}{@*)},
  moreliterate={≤}{{$\leq$}}1 {≥}{{$\geq$}}1 {−}{{-}}1
               {→}{{\textrightarrow}}1 {≠}{{$\neq$}}1
               {≈}{{$\approx$}}1 {×}{{$\times$}}1,
}

% Etichetta del linguaggio in alto a destra dentro il blocco
\newcommand\ub@codelabel[1]{%
  \ifblank{#1}{}{%
    \node[anchor=north east, inner sep=0pt, xshift=-12pt, yshift=-8pt,
          font=\scriptsize\JetBrains, text=ShLabel]
      at (frame.north east) {#1};}}

% \begin{ubcode}{<linguaggio listings>}{<etichetta>} ... \end{ubcode}
\newtcblisting{ubcode}[2]{%
  enhanced, breakable, listing only,
  listing options={style=ubblock, language={#1}},
  colback=ShBg, colframe=ShBg, boxrule=0pt,
  arc=5pt, outer arc=5pt,
  boxsep=0pt, left=36pt, right=12pt, top=24pt, bottom=12pt,
  before skip=10pt, after skip=10pt,
  before={\Needspace{5\baselineskip}},
  before upper={\ub@useshades},
  overlay unbroken and first={\ub@codelabel{#2}},
}

% Intestazione con icona + nome file, SOLO se il listing ha name=...
% (prima: title= globale => riga di intestazione anche senza nome)
\lst@AddToHook{PreInit}{\ifdefempty{\lstname}{}{\def\lst@title{\ub@lsttitle}}}

\lstdefinestyle{wnumbers}{
  xleftmargin=1cm,
  numbers=left,
  numberstyle=\Lato\scriptsize\color{ub-orange!80!black},
  frame=l,
  framesep=0.5cm,
  framexleftmargin=0.3cm,
  rulecolor=\color{white},
  fillcolor=\color{naplesyellow!40!white}
}

% Linee guida di indentazione
\newcommand{\indentrule}{\color{gray}\rlap{\smash{\hspace{6pt}\rule[-.35em]{1pt}{1.45em}}}}

% Elenco dei listing nell'indice
\renewcommand\lstlistlistingname{\documentlsttitle}
\renewcommand\lstlistingname{\documentlstlabel}
\renewcommand\l@lstlisting[2]{%
  \@dottedtocline{1}{0em}{2.3em}%
    {\textcolor{ub-ink}{\ilabel\selectfont\AlteG\documentlstlabel\space #1}}{#2}}

%% ------------------------------------------------------------
%%  Linguaggi per listings
%%  Qui solo la parte "lessicale": keyword, commenti, stringhe.
%% ------------------------------------------------------------
\lstdefinelanguage{makefile}{morecomment=[l]{\#}}

\lstdefinelanguage{ini}{
  morecomment=[s][\color{CodeKeyword}\ub@kwb]{[}{]},
  morecomment=[l]{\#},
  morecomment=[l]{;},
  commentstyle=\color{CodeComment}\JetBrains\itshape,
  otherkeywords={=,:},
  keywordstyle={\color{CodeFunction}\ub@kwb},
  autogobble=false,
  escapeinside={(*}{*)},
}

\lstdefinelanguage{asd}{
  alsoletter={\#},
  sensitive=true,
  moredelim=*[s][{\color{CodeNumber}}]{[}{]},
  comment=[l]//,
  morecomment=[s]{/*}{*/},
  string=[b]{"},
  morestring=[b]{'},
  keywords=[0]{i, j, k, n},
  keywords=[1]{if, else, then, for, while, do},
  keywords=[2]{return},
  keywords=[3]{SUM, MAX, RIS, A, Search},
  keywords=[4]{free, pos},
  otherkeywords={*, &},
  escapechar={@},
  directivestyle=\color{CodeType},
  keywordstyle=[0]\color{CodeNumber},
  keywordstyle=[1]\ub@kwb\color{CodeKeyword},
  keywordstyle=[2]\ub@kwb\color{CodeKeyword},
  keywordstyle=[3]\color{CodeFunction},
  keywordstyle=[4]\color{CodeString},
}[keywords,comments,strings,directives]

\lstdefinelanguage{mermaid}[]{asd}{}

\lstdefinelanguage[POSIX]{JAVA}{
  alsoletter={\#},
  sensitive=true,
  moredelim=*[s][{\color{CodeKeyword}}]package,
  moredelim=*[l][{\color{CodeKeyword}}]import,
  comment=[l]//,
  morecomment=[s]{/*}{*/},
  string=[b]{"},
  morestring=[b]{'},
  keywords=[0]{class, public, private, static, volatile, Enum},
  keywords=[1]{int, Integer, String, double, long, short, char, void, bool},
  keywords=[2]{if, else, return, for, while, do},
  otherkeywords={*, &},
  directivestyle=\color{CodeType},
  keywordstyle=[0]\ub@kwb\color{CodeKeyword},
  keywordstyle=[1]\color{CodeType},
  keywordstyle=[2]\ub@kwb\color{CodeKeyword},
  keywordstyle=[3]\color{CodeNumber},
}[keywords,comments,strings,directives]

\lstdefinelanguage[POSIX]{C}{
  alsoletter={\#},
  sensitive=true,
  moredelim=*[s][{\color{CodeString}}]{\#include\ <}{.h>},
  moredelim=*[l][{\color{CodeKeyword}}]\#if,
  moredelim=*[l][{\color{CodeKeyword}}]\#endif,
  moredelim=*[s][{\color{CodeString}}]{\#include\ "}{.h"},
  moredelim=*[l][{\color{CodeKeyword}}]\#define,
  moredelim=*[s][{\color{CodeNumber}}]{[}{]},
  comment=[l]//,
  morecomment=[s]{/*}{*/},
  string=[b]{"},
  morestring=[b]{'},
  keywords=[0]{const, unsigned, signed, static, volatile, typedef, struct, union, enum, atomic_t},
  keywords=[1]{int, float, double, long, short, char, void, bool},
  keywords=[2]{if, else, return, for, while, do},
  otherkeywords={*, &},
  directivestyle=\color{CodeType},
  keywordstyle=[0]\ub@kwb\color{CodeKeyword},
  keywordstyle=[1]\color{CodeType},
  keywordstyle=[2]\ub@kwb\color{CodeKeyword},
  keywordstyle=[3]\color{CodeNumber},
}[keywords,comments,strings,directives]

\lstdefinelanguage{http}{
  morekeywords={GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS, CONNECT, TRACE, HTTP},
  sensitive=true,
  morecomment=[l]{\#},
  morestring=[b]",
  morestring=[b]',
  alsoletter={-},
  ndkeywords={Host, Content-Type, Authorization, Accept, User-Agent, Content-Length},
  ndkeywordstyle=\color{CodeFunction}\ub@kwb,
}

\lstdefinelanguage{nginx}{
  morekeywords={server, listen, server_name, location, root, index, proxy_pass,
                proxy_set_header, try_files, error_page, access_log, error_log,
                events, http, upstream, include, default_type, sendfile, keepalive_timeout},
  alsoletter={\$_},
  ndkeywords={$host, $remote_addr, $proxy_add_x_forwarded_for, $scheme, $request_uri},
  sensitive=true,
  morecomment=[l]{\#},
  morestring=[b]",
  morestring=[b]',
}

\lstdefinelanguage{CSS}{
  sensitive=true,
  alsoletter={-},
  comment=[s]{/*}{*/},
  morestring=[b]",
  morestring=[b]',
  keywords=[0]{
    display, position, top, right, bottom, left, float, clear, overflow,
    width, height, min-width, max-width, min-height, max-height,
    margin, margin-top, margin-right, margin-bottom, margin-left,
    padding, padding-top, padding-right, padding-bottom, padding-left,
    border, border-style, border-color, border-width, border-radius,
    color, background, background-color, background-image, background-size,
    font, font-family, font-size, font-weight, line-height, text-align,
    flex, flex-direction, justify-content, align-items, grid, grid-template-columns,
    box-shadow, transform, transition, animation, opacity, z-index, cursor
  },
  keywords=[1]{
    hover, active, focus, visited, link, first-child, last-child,
    nth-child, before, after, checked, disabled, root
  },
  keywords=[2]{rgb, rgba, hsl, hsla, calc, var, url, attr, min, max, clamp},
  keywords=[3]{
    auto, inherit, initial, unset, none, block, inline, inline-block,
    flex, grid, absolute, relative, fixed, static, sticky, hidden, visible,
    bold, italic, center, solid, dashed, dotted, transparent, pointer
  },
  keywordstyle=[0]\color{CodeFunction}\ub@kwb,
  keywordstyle=[1]\color{CodeKeyword}\ub@kwb,
  keywordstyle=[2]\color{CodeNumber}\ub@kwb,
  keywordstyle=[3]\color{CodeText},
  commentstyle=\color{CodeComment}\itshape,
  stringstyle=\color{CodeString},
}[keywords,comments,strings]

% --- Linguaggi non presenti in listings ---
\lstdefinelanguage{JavaScript}{
  sensitive=true,
  alsoletter={\$_},
  keywords={break,case,catch,class,const,continue,debugger,default,delete,do,
    else,export,extends,finally,for,function,if,import,in,instanceof,let,new,
    return,static,super,switch,this,throw,try,typeof,var,void,while,with,
    yield,async,await,of},
  keywords=[2]{true,false,null,undefined,NaN,Infinity},
  keywords=[3]{console,Object,Array,String,Number,Boolean,JSON,Math,Promise,
    Map,Set,Date,Symbol,window,document,Error,TypeError,ReferenceError,
    RegExp,parseInt,parseFloat,setTimeout,setInterval,fetch,require,module},
  comment=[l]{//},
  morecomment=[s]{/*}{*/},
  morestring=[b]',
  morestring=[b]",
  morestring=[b]`,
  keywordstyle=\ub@kwb\color{CodeKeyword},
  keywordstyle=[2]\color{CodeNumber},
  keywordstyle=[3]\color{CodeType},
}

\lstdefinelanguage{TypeScript}[]{JavaScript}{
  morekeywords={interface,type,enum,implements,public,private,protected,
    readonly,abstract,namespace,declare,keyof,as,is},
  keywords=[4]{number,string,boolean,any,unknown,never,void,object},
  keywordstyle=[4]\color{CodeType},
}

\lstdefinelanguage{JSON}{
  sensitive=true,
  keywords=[2]{true,false,null},
  morestring=[b]",
  keywordstyle=[2]\color{CodeNumber},
}

\lstdefinelanguage{YAML}{
  sensitive=true,
  keywords=[2]{true,false,null,yes,no,on,off},
  comment=[l]{\#},
  morestring=[b]',
  morestring=[b]",
  keywordstyle=[2]\color{CodeNumber},
}

\lstdefinelanguage{Docker}{
  sensitive=false,
  morekeywords={FROM,RUN,CMD,LABEL,EXPOSE,ENV,ADD,COPY,ENTRYPOINT,VOLUME,USER,
    WORKDIR,ARG,ONBUILD,STOPSIGNAL,HEALTHCHECK,SHELL,AS},
  comment=[l]{\#},
  morestring=[b]',
  morestring=[b]",
}

% bash di listings + comandi Linux comuni come seconda classe di keyword.
% Ridefinisce SOLO il linguaggio bash (prima i comandi erano aggiunti
% globalmente a ogni linguaggio).
\lstdefinelanguage{bash}[]{sh}{
  morekeywords={alias,bg,bind,builtin,caller,command,compgen,compopt,
      complete,coproc,declare,disown,dirs,enable,fc,fg,help,history,
      jobs,let,local,logout,mapfile,printf,pushd,popd,readarray,select,
      set,suspend,shopt,source,times,type,typeset,ulimit,unalias,wait},
  morekeywords=[2]{sudo, apt, systemctl, mkdir, cd, ls, chmod, chown, grep, sed, awk, dig},
  keywordstyle=[2]\color{CodeFunction}\ub@kwb,
}

\lstdefinestyle{tailwindstyle}{
  language=CSS,
  morekeywords=[2]{bg,text,border,p,m,mx,my,px,py,pt,pb,pl,pr,w,h,max,min,flex,grid,items,justify,content,between,around,center,auto,row,col,gap,order,grow,shrink,basis,full,none,block,inline,hidden,visible,collapse,static,fixed,absolute,relative,sticky,inset,top,right,bottom,left,z,overflow,truncate,ellipsis,clip,scroll,rounded,shadow,opacity,transform,scale,rotate,translate,skew,transition,duration,ease,delay,animate,spin,ping,pulse,bounce,filter,blur,brightness,contrast,drop,grayscale,container,sm,md,lg,xl,screen,dark,light,group,hover,focus,active,visited,target,first,last,only,odd,even,checked,disabled,placeholder,prose,xs,s,base,2xl,3xl,4xl,5xl,6xl,7xl,8xl,9xl,transparent,current,black,white,gray,red,orange,yellow,green,teal,cyan,sky,blue,indigo,violet,purple,fuchsia,pink,rose,slate,zinc,neutral,stone,amber,lime,inherit,from,via,to,fill,stroke,accent,primary,secondary,success,warning,error,info,backdrop,sepia,invert,saturate,hue},
  keywordstyle=[2]\color{CodeFunction}\ub@kwb,
}

%% ------------------------------------------------------------
%%  Matematica
%% ------------------------------------------------------------
\DeclarePairedDelimiter\ub@abs{\lvert}{\rvert}
\DeclarePairedDelimiter\ub@norm{\lVert}{\rVert}
% senza * le parentesi si adattano; con * dimensione normale
\newcommand\abs{\@ifstar{\ub@abs}{\ub@abs*}}
\newcommand\norm{\@ifstar{\ub@norm}{\ub@norm*}}

\newcommand\abrakets[1]{\displaystyle{\left\langle{#1}\right\rangle}}
\newcommand\cbrakets[1]{\displaystyle{\left\{{#1}\right\}}}
\newcommand\rbrakets[1]{\displaystyle{\left({#1}\right)}}
\newcommand\xor{{\displaystyle{\dot{\vee}}}}

% \mcA..\mcZ (senza J e K, come prima) e \mbA..\mbZ
\@for\ub@l:=A,B,C,D,E,F,G,H,I,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z\do{%
  \expandafter\edef\csname mc\ub@l\endcsname{\noexpand\mathcal{\ub@l}}}
\@for\ub@l:=A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z\do{%
  \expandafter\edef\csname mb\ub@l\endcsname{\noexpand\mathbb{\ub@l}}}

%% ------------------------------------------------------------
%%  Impostazioni spostate da main.tex
%% ------------------------------------------------------------
% Solo i capitoli sono numerati (sezioni e sottosezioni no)
\setcounter{secnumdepth}{0}

% Niente vedove/orfane
\widowpenalty=10000
\clubpenalty=10000

% Workaround bug Pandoc #11201: le tabelle senza caption usano
% \LTcaptype{none}, che richiede un counter "none".
\@ifundefined{c@none}{\newcounter{none}}{}

% Caratteri Unicode non presenti nei font
\RequirePackage{newunicodechar}
\newunicodechar{→}{\ensuremath{\rightarrow}}
\newunicodechar{←}{\ensuremath{\leftarrow}}
\newunicodechar{∈}{\ensuremath{\in}}
\newunicodechar{∉}{\ensuremath{\notin}}
\newunicodechar{ᵢ}{\textsubscript{i}}
\newunicodechar{✓}{\checkmark}
% \newunicodechar{&}{}

% Diagrammi Mermaid (mermaid.sty sta in build/, vedi TEXINPUTS in build.sh)
\RequirePackage{mermaid}

%% End of unina_doc_class.cls