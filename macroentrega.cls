%% =====================================================================
%% macroentrega.cls
%% Classe para relatórios de macroentrega de projetos EMBRAPII.
%%
%% Opções:
%%   rascunho (padrão)  mostra marcadores \ph{} e caixas \orientacao{}
%%   entrega            os marcadores pendentes viram erro de compilação
%%                      e as caixas de orientação desaparecem
%% =====================================================================
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{macroentrega}[2026/10/27 v1.0 Relatorio de Macroentrega (projetos EMBRAPII)]

% --- OPÇÕES -----------------------------------------------------------
\newif\ifme@entrega
\DeclareOption{rascunho}{\me@entregafalse}
\DeclareOption{entrega}{\me@entregatrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{report}}
\ExecuteOptions{rascunho}
\ProcessOptions\relax
\LoadClass[12pt,a4paper]{report}

% --- PACOTES ----------------------------------------------------------
\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}
\RequirePackage{lmodern}
\RequirePackage[brazil]{babel}
\RequirePackage{microtype}
\RequirePackage{graphicx}
\RequirePackage[table]{xcolor}
\RequirePackage{eso-pic}
\RequirePackage{multicol}
\RequirePackage{etoolbox}
\RequirePackage{keyval}
\RequirePackage{array}
\RequirePackage{longtable}
\RequirePackage{tabularx}
\RequirePackage{enumitem}
\RequirePackage{amssymb}
\RequirePackage{geometry}
\RequirePackage{setspace}
\RequirePackage{titlesec}
\RequirePackage{needspace}
\RequirePackage{fancyhdr}
\RequirePackage{indentfirst}
\RequirePackage{caption}
\RequirePackage{subcaption}
\RequirePackage{soul}
\RequirePackage[skins,breakable]{tcolorbox}
\RequirePackage{hyperref}

% --- CORES ------------------------------------------------------------
\definecolor{reqcolor}{HTML}{3B5998}      % cabeçalho de tabela
\definecolor{reqlight}{HTML}{DCE4F7}      % linha zebrada
\definecolor{sidebarcolor}{HTML}{7798F4}  % barra lateral
\definecolor{statusgray}{HTML}{9E9E9E}
\definecolor{statusyellow}{HTML}{F9A825}
\definecolor{statusblue}{HTML}{1E88E5}
\definecolor{statusgreen}{HTML}{43A047}
\definecolor{phbg}{HTML}{FFF176}          % marcador pendente
\definecolor{orientbg}{HTML}{F3F6FD}      % caixa de orientação

% --- PÁGINA, PARÁGRAFO E LISTAS ----------------------------------------
\geometry{a4paper, left=3.5cm, right=2cm, top=3.5cm, bottom=2.5cm,
          headheight=2.5cm, headsep=0.5cm}
\setlength{\parindent}{1.25cm}
\setlength{\parskip}{7pt plus 2pt minus 1pt}
\setlist{topsep=4pt, itemsep=2pt, parsep=0pt, partopsep=0pt}
\onehalfspacing
% Nenhuma linha órfã no alto ou no pé da página.
\widowpenalty=10000 \clubpenalty=10000
% Página só de flutuantes: alinhada ao topo, não centralizada na vertical.
\setlength{\@fptop}{0pt}
\setlength{\@fpsep}{12pt}
\setlength{\@fpbot}{0pt plus 1fil}
\addto\captionsbrazil{\renewcommand{\appendixname}{Anexo}%
  \renewcommand{\bibname}{Referências}}
\captionsetup{font=small, labelfont=bf, skip=6pt}

\hypersetup{colorlinks=true, linkcolor=reqcolor, citecolor=reqcolor,
            urlcolor=reqcolor, bookmarksnumbered=true}

% --- TÍTULOS ----------------------------------------------------------
% Sem hifenização nos títulos, para a última palavra não ser partida.
\newcommand{\me@titulofmt}{\raggedright\hyphenpenalty=10000 \exhyphenpenalty=10000 }
\titlespacing*{\chapter}{0pt}{-20pt}{20pt}
\titleformat{\chapter}[display]
  {\normalfont\huge\bfseries\me@titulofmt}
  {\chaptertitlename\ \thechapter}{10pt}{\Huge}
\titleformat*{\section}{\normalfont\Large\bfseries\me@titulofmt}
\titleformat*{\subsection}{\normalfont\large\bfseries\me@titulofmt}
\titleformat*{\subsubsection}{\normalfont\normalsize\bfseries\me@titulofmt}
% Título de seção nunca fica sozinho no pé da página.
\pretocmd{\section}{\Needspace{11\baselineskip}}{}{}
\pretocmd{\subsection}{\Needspace{6\baselineskip}}{}{}

% --- BARRA LATERAL ----------------------------------------------------
\AddToShipoutPictureBG{%
  \AtPageLowerLeft{\color{sidebarcolor}\rule{1cm}{\paperheight}}}

% --- DADOS DO RELATÓRIO -----------------------------------------------
% Valores ainda não informados aparecem como marcador \ph{} na capa.
\def\me@tipo{intermediaria}
\def\me@numero{\ph{NN}}
\def\me@projeto{\ph{NOME DO PROJETO}}
\def\me@codigo{}
\def\me@subtitulo{}
\def\me@titulo{\ph{título da macroentrega}}
\def\me@deliverable{}
\def\me@wp{}
\def\me@equipe{\ph{Nome Sobrenome}}
\def\me@unidade{Unidade EMBRAPII iTec/FURG}
\def\me@parceiro{}
\def\me@periodo{}
\def\me@local{\ph{Cidade}}
\def\me@data{\ph{Mês de AAAA}}
\def\me@confid{}
\def\me@codrel{}
\def\me@coordenador{\ph{Nome do Coordenador}}
\def\me@cargocoord{Coordenador do Projeto}
\def\me@razao{\ph{RAZÃO SOCIAL}}
\def\me@repres{\ph{Nome do Representante}}
\def\me@cargorepres{\ph{Cargo}}
\def\me@dataassin{\ph{DD de mês de AAAA}}

\define@key{me}{tipo}{\def\me@tipo{#1}}
\define@key{me}{numero}{\def\me@numero{#1}}
\define@key{me}{projeto}{\def\me@projeto{#1}}
\define@key{me}{codigo}{\def\me@codigo{#1}}
\define@key{me}{subtitulo}{\def\me@subtitulo{#1}}
\define@key{me}{titulo}{\def\me@titulo{#1}}
\define@key{me}{deliverable}{\def\me@deliverable{#1}}
\define@key{me}{wp}{\def\me@wp{#1}}
\define@key{me}{equipe}{\def\me@equipe{#1}}
\define@key{me}{unidade}{\def\me@unidade{#1}}
\define@key{me}{parceiro}{\def\me@parceiro{#1}}
\define@key{me}{periodo}{\def\me@periodo{#1}}
\define@key{me}{local}{\def\me@local{#1}}
\define@key{me}{data}{\def\me@data{#1}}
\define@key{me}{confidencialidade}{\def\me@confid{#1}}
\define@key{me}{codigorelatorio}{\def\me@codrel{#1}}
\define@key{me}{coordenador}{\def\me@coordenador{#1}}
\define@key{me}{cargocoordenador}{\def\me@cargocoord{#1}}
\define@key{me}{razaosocial}{\def\me@razao{#1}}
\define@key{me}{representante}{\def\me@repres{#1}}
\define@key{me}{cargorepresentante}{\def\me@cargorepres{#1}}
\define@key{me}{dataassinatura}{\def\me@dataassin{#1}}

\newcommand{\dadosrelatorio}[1]{\setkeys{me}{#1}}
\newcommand{\unidade}{\me@unidade}
\newcommand{\numeromacroentrega}{\me@numero}

% --- CABEÇALHO COM AS LOGOMARCAS --------------------------------------
\newif\ifme@firstlogo
\newlength{\logoheight}
\setlength{\logoheight}{1.2cm}
\newcommand{\setlogos}[1]{\def\me@logolist{#1}}
\setlogos{}
\newcommand{\me@logos}{%
  \noindent\hbox to\linewidth{\me@firstlogotrue
    \@for\me@l:=\me@logolist\do{%
      \ifme@firstlogo\me@firstlogofalse\else\hfill\fi
      \includegraphics[height=\logoheight]{\me@l}}}}

% As logomarcas sobem 0,6 cm, para ficarem acima da primeira linha de cada página.
\newcommand{\me@headlogos}{\raisebox{0.6cm}[0pt][0pt]{\me@logos}}

\pagestyle{fancy}
\renewcommand{\headrulewidth}{0pt}
\fancyhf{}
\fancyhead[C]{\me@headlogos}
\fancyfoot[C]{\thepage}
\fancyfoot[L]{\footnotesize\bfseries\me@confid}
\fancypagestyle{plain}{%
  \fancyhf{}
  \fancyhead[C]{\me@headlogos}
  \fancyfoot[C]{\thepage}
  \fancyfoot[L]{\footnotesize\bfseries\me@confid}}
\fancypagestyle{capa}{%
  \fancyhf{}
  \fancyhead[C]{\me@headlogos}}

% --- MARCADOR PENDENTE ------------------------------------------------
% Em rascunho, destaca o texto a preencher e conta as ocorrências.
% Em entrega, qualquer marcador restante interrompe a compilação.
\newcounter{me@ph}
\DeclareRobustCommand{\ph}[1]{%
  \leavevmode\ifme@entrega
    \ClassError{macroentrega}{Marcador pendente: #1}%
      {Substitua o marcador pelo conteudo definitivo antes de compilar em modo entrega.}%
  \else
    \stepcounter{me@ph}%
    \begingroup\color{black}\sethlcolor{phbg}\hl{[#1]}\endgroup
  \fi}
\pdfstringdefDisableCommands{\def\ph#1{#1}}
\AtEndDocument{%
  \ifme@entrega\else
    \ifnum\value{me@ph}>0
      \ClassWarningNoLine{macroentrega}%
        {\arabic{me@ph} marcador(es) pendente(s) neste documento}%
    \fi
  \fi}

% Moldura para figura ainda não produzida.
\newcommand{\figuraph}[2][5cm]{%
  \fcolorbox{statusgray}{white}{%
    \parbox[c][#1][c]{\dimexpr\linewidth-2\fboxsep-2\fboxrule\relax}{%
      \centering\ph{#2}}}}

% --- ORIENTAÇÃO AO AUTOR ----------------------------------------------
% Caixa visível apenas em rascunho. Em entrega, o conteúdo é descartado.
\ifme@entrega
  \newcommand{\orientacao}[2][Orientação]{}
\else
  \newcommand{\orientacao}[2][Orientação]{%
    \par\begin{tcolorbox}[enhanced, breakable, colback=orientbg,
      colframe=sidebarcolor, boxrule=0.6pt, arc=2pt, left=7pt, right=7pt,
      top=10pt, bottom=6pt, before skip=10pt, after skip=10pt,
      title={#1}, fonttitle=\footnotesize\bfseries, coltitle=white,
      colbacktitle=sidebarcolor, boxed title style={boxrule=0pt, arc=2pt},
      attach boxed title to top left={xshift=7pt, yshift=-2.5mm}]
    \footnotesize\setstretch{1.08}\setlength{\parindent}{0pt}%
    \setlength{\parskip}{3pt}\setlist{itemsep=1pt, topsep=2pt}#2%
    \end{tcolorbox}\par}
\fi

% --- TRANSCRIÇÃO LITERAL DO CONTRATO ----------------------------------
% O texto dentro desta caixa vem do contrato e não se edita.
\newtcolorbox{transcricao}[1]{enhanced, breakable, colback=reqlight!35,
  colframe=reqlight!35, boxrule=0pt, arc=0pt, left=10pt, right=8pt,
  top=6pt, bottom=6pt, before skip=8pt, after skip=10pt,
  borderline west={2.5pt}{0pt}{sidebarcolor},
  before upper={\setlength{\parindent}{0pt}\setlength{\parskip}{4pt}},
  after upper={\par\medskip\hfill\footnotesize\textit{Transcrição literal. Fonte: #1.}}}

% --- STATUS DE REQUISITO ----------------------------------------------
\newcommand{\todo}{\textcolor{statusgray}{\textbf{TODO}}}
\newcommand{\wip}{\textcolor{statusyellow}{\textbf{WIP}}}
\newcommand{\parc}{\textcolor{statusblue}{\textbf{PARC}}}
\newcommand{\done}{\textcolor{statusgreen}{\textbf{DONE}}}

% --- TABELAS ----------------------------------------------------------
\newcolumntype{C}[1]{>{\centering\arraybackslash}p{#1}}
\newcolumntype{P}[1]{>{\raggedright\arraybackslash}p{#1}}
\newcommand{\cab}[1]{\textcolor{white}{\textbf{#1}}}
% Corpo e espaçamento das tabelas comuns; use logo depois de \begin{table}.
\newcommand{\estilotabela}{%
  \footnotesize\setstretch{1}\renewcommand{\arraystretch}{1.3}%
  \setlength{\tabcolsep}{4pt}}

% Tabela de requisitos. O argumento lista as macroentregas, uma coluna
% de status para cada: \begin{tabelarequisitos}{M01,M02}
\newlength{\me@idw}   \setlength{\me@idw}{2.4cm}
\newlength{\me@stw}   \setlength{\me@stw}{1.2cm}
\newlength{\me@vw}    \setlength{\me@vw}{2.6cm}
\newlength{\me@dw}
\newcount\me@ncols
\newcounter{me@reqrow}
% O cabeçalho é montado antes da tabela, sem laço dentro do alinhamento.
\newcommand{\me@reqhead}[1]{%
  \rowcolor{reqcolor}\cab{ID} & \cab{Descrição} & #1\cab{Verificação} \\ \hline}
\newenvironment{tabelarequisitos}[1]{%
  \footnotesize\setstretch{1}\renewcommand{\arraystretch}{1.3}%
  \setlength{\tabcolsep}{4pt}\setcounter{me@reqrow}{1}%
  \me@ncols=0
  \@for\me@c:=#1\do{\advance\me@ncols by 1 }%
  \setlength{\me@dw}{\linewidth}%
  \addtolength{\me@dw}{-\me@idw}\addtolength{\me@dw}{-\me@vw}%
  \@tempdima=\me@ncols\me@stw \addtolength{\me@dw}{-\@tempdima}%
  \@tempcnta=\me@ncols \advance\@tempcnta by 3
  \@tempdima=\@tempcnta\tabcolsep \addtolength{\me@dw}{-2\@tempdima}%
  \advance\@tempcnta by 1
  \@tempdima=\@tempcnta\arrayrulewidth \addtolength{\me@dw}{-\@tempdima}%
  \edef\me@spec{|P{\the\me@idw}|P{\the\me@dw}|}%
  \@for\me@c:=#1\do{\edef\me@spec{\me@spec C{\the\me@stw}|}}%
  \edef\me@spec{\me@spec P{\the\me@vw}|}%
  \def\me@hdrcols{}%
  \@for\me@c:=#1\do{\edef\me@hdrcols{\unexpanded\expandafter{\me@hdrcols}\noexpand\cab{\me@c}&}}%
  \edef\me@begin{\noexpand\begin{longtable}{\me@spec}}\me@begin
  \hline
  \expandafter\me@reqhead\expandafter{\me@hdrcols}
  \endfirsthead
  \hline
  \expandafter\me@reqhead\expandafter{\me@hdrcols}
  \endhead
}{\end{longtable}}
% Linha: \req{ID}{descrição}{\wip & \done}{método e ponteiro de evidência}
% O contador avança dentro de \noalign, para \rowcolor ser o primeiro item da linha.
\newcommand{\req}[4]{%
  \ifodd\value{me@reqrow}\rowcolor{reqlight}\else\rowcolor{white}\fi
  \mbox{#1} & #2 & #3 & #4 \\ \hline\noalign{\stepcounter{me@reqrow}}}

% Lista de siglas (opcional, útil em documento longo).
\newenvironment{siglas}{%
  \clearpage\phantomsection\addcontentsline{toc}{chapter}{Lista de Siglas}%
  \chapter*{Lista de Siglas}%
  \begin{description}[font=\bfseries, leftmargin=3.2cm, labelwidth=2.8cm, align=left]}%
  {\end{description}}

% --- RESUMO -----------------------------------------------------------
\newenvironment{resumo}{%
  \clearpage\phantomsection\addcontentsline{toc}{chapter}{Resumo}%
  \chapter*{Resumo}}{\par}

% --- CAPA -------------------------------------------------------------
\newcommand{\capa}{%
  \begin{titlepage}
  \thispagestyle{capa}
  \centering\setstretch{1.3}
  \vspace*{1.2cm}
  \ifdefempty{\me@confid}{}{{\small\bfseries\me@confid\par}\vspace{0.4cm}}%
  {\Large\bfseries
    \ifdefstring{\me@tipo}{final}%
      {RELATÓRIO FINAL\par}%
      {RELATÓRIO DE MACROENTREGA\par MACROENTREGA \me@numero\par}}%
  \vspace{\stretch{1.3}}
  {\Large\bfseries Projeto \me@projeto\par}
  \ifdefempty{\me@codigo}{}{{\normalsize Código \me@codigo\par}}%
  \ifdefempty{\me@subtitulo}{}{{\large\me@subtitulo\par}}%
  \vspace{0.8cm}
  \ifdefstring{\me@tipo}{final}%
    {\ifdefempty{\me@periodo}{}{{\normalsize Período: \me@periodo\par}}}%
    {{\normalsize\textbf{Título da macroentrega}\par}%
     {\normalsize\me@titulo\par}}%
  \ifdefempty{\me@deliverable}{}{{\normalsize Deliverable: \me@deliverable%
    \ifdefempty{\me@wp}{}{\quad Work package: \me@wp}\par}}%
  \ifdefempty{\me@parceiro}{}{{\normalsize Parceiro tecnológico: \me@parceiro\par}}%
  \vspace{\stretch{1}}
  \ifdefstring{\me@tipo}{final}{}{%
    {\bfseries Equipe:\par}\vspace{0.3cm}
    {\small\begin{multicols}{2}\centering
      \@for\me@m:=\me@equipe\do{\ignorespaces\me@m\par}%
    \end{multicols}}
    \vspace{\stretch{1}}}
  {\large \me@local, \me@data\par}
  \ifdefempty{\me@codrel}{}{\vspace{0.3cm}{\footnotesize Código do relatório: \me@codrel\par}}%
  \end{titlepage}}

% --- REFERÊNCIAS ------------------------------------------------------
\newcommand{\referencias}[2][ieeetr]{%
  \clearpage\phantomsection\addcontentsline{toc}{chapter}{\bibname}%
  \bibliographystyle{#1}\bibliography{#2}}

% --- PÁGINA DE ASSINATURAS --------------------------------------------
\newcommand{\paginaassinaturas}{%
  \clearpage\phantomsection\addcontentsline{toc}{chapter}{Assinaturas}%
  \chapter*{Assinaturas}%
  \begingroup\setlength{\parindent}{0pt}\setstretch{1.15}%
  \vspace{1.5cm}
  \begin{center}
    \rule{10cm}{0.5pt}\\
    \textbf{\me@coordenador}\\
    \me@cargocoord\\
    \me@unidade
  \end{center}
  \vspace{2cm}
  \noindent Declaramos, para os devidos fins, que a empresa \me@razao,
  representada por \me@repres, \me@cargorepres, está ciente do conteúdo
  deste documento, confirma o seu recebimento e declara estar de acordo com
  as informações nele contidas.
  \vspace{2cm}
  \begin{center}
    \rule{10cm}{0.5pt}\\
    \textbf{\me@repres}\\
    \me@cargorepres\\
    \me@razao
  \end{center}
  \vfill
  \begin{flushright}\small\me@local, \me@dataassin.\end{flushright}
  \endgroup}

% --- METADADOS DO PDF -------------------------------------------------
\AtBeginDocument{%
  \ifdefstring{\me@tipo}{final}
    {\hypersetup{pdftitle={Relatório Final -- \me@projeto},
                 pdfsubject={Relatório final, projeto EMBRAPII}}}
    {\hypersetup{pdftitle={Relatório de Macroentrega \me@numero\ -- \me@projeto},
                 pdfsubject={Relatório de macroentrega, projeto EMBRAPII}}}%
  \hypersetup{pdfauthor={\me@unidade}}}

\endinput
