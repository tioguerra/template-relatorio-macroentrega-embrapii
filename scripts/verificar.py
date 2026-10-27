#!/usr/bin/env python3
"""Confere o relatório compilado antes de entregá-lo.

Uso:
    python3 scripts/verificar.py [documento] [--entrega] [--paginas]

    documento   nome do PDF sem extensão (padrão: main)
    --entrega   trata pendências e avisos como bloqueio
    --paginas   renderiza as páginas em _verificacao/ para leitura visual

O script não compila: assume que o PDF e o log do documento já existem.
Sai com código diferente de zero quando encontra defeito bloqueante.
"""
import glob
import os
import re
import subprocess
import sys

HBOX_LIMITE_PT = 1.0
RESUMO_MIN, RESUMO_MAX = 150, 300
PADROES_PDF = [
    (r"\?\?", "referência ou citação não resolvida (??)"),
    (r"\bFigure X\b|\bTable x\b|\bFigura X\b|\bTabela X\b", "figura ou tabela sem número"),
    (r"\bInformar\b|\bDEFINIR\b|\bLorem\b", "texto de preenchimento"),
    (r"\bXXX\b|\bAAAA\b", "identificador ou data de preenchimento (XXX, AAAA)"),
    (r"Nome Sobrenome|RAZÃO SOCIAL", "dado de exemplo na capa ou na assinatura"),
    (r"Orientação\n", "caixa de orientação visível (compile em modo entrega)"),
]

bloqueios, avisos = [], []


def ler(caminho):
    with open(caminho, encoding="utf8", errors="replace") as f:
        return f.read()


def sem_comentarios(texto):
    return "\n".join(re.sub(r"(?<!\\)%.*", "", linha) for linha in texto.splitlines())


def grupo(texto, i):
    """Lê o grupo entre chaves que começa em texto[i] == '{'."""
    nivel, j = 0, i
    while j < len(texto):
        c = texto[j]
        if c == "\\":
            j += 2
            continue
        if c == "{":
            nivel += 1
        elif c == "}":
            nivel -= 1
            if nivel == 0:
                return texto[i + 1 : j], j + 1
        j += 1
    return texto[i + 1 :], len(texto)


def argumentos(texto, i, n):
    """Lê n grupos consecutivos a partir de texto[i]; devolve (lista, fim)."""
    args = []
    for _ in range(n):
        while i < len(texto) and texto[i] in " \t\n":
            i += 1
        if i >= len(texto) or texto[i] != "{":
            break
        conteudo, i = grupo(texto, i)
        args.append(conteudo)
    return args, i


def verificar_log(base):
    """Devolve False quando a compilação foi interrompida por marcador pendente."""
    caminho = base + ".log"
    if not os.path.exists(caminho):
        bloqueios.append(f"{caminho} não existe: compile antes de verificar")
        return False
    log = ler(caminho)
    marcadores = re.findall(r"^! Class macroentrega Error: Marcador pendente: (.+?)\.?$", log, re.M)
    if marcadores:
        unicos = list(dict.fromkeys(marcadores))
        bloqueios.append(f"{len(marcadores)} marcador(es) \\ph{{}} pendente(s) no modo entrega")
        for texto in unicos[:20]:
            bloqueios.append(f"  pendente: {texto}")
        if len(unicos) > 20:
            bloqueios.append(f"  ... e mais {len(unicos) - 20} marcadores distintos")
        bloqueios.append("  (as demais conferências do log e do PDF valem só depois de a compilação terminar)")
        return False
    for m in re.finditer(r"^! (.+)$", log, re.M):
        bloqueios.append("erro de compilação: " + m.group(1))
    for m in re.finditer(r"(Reference|Citation) `([^']+)' on page (\d+) undefined", log):
        bloqueios.append(f"{m.group(1).lower()} não resolvida: {m.group(2)} (página {m.group(3)})")
    for m in re.finditer(r"File `([^']+)' not found", log):
        bloqueios.append(f"arquivo ausente: {m.group(1)}")
    for m in re.finditer(r"Label `([^']+)' multiply defined", log):
        bloqueios.append(f"rótulo repetido: {m.group(1)}")
    for m in re.finditer(r"Overfull \\vbox \(([\d.]+)pt too high\)", log):
        bloqueios.append(f"conteúdo estoura a página (Overfull vbox, {m.group(1)} pt)")
    for m in re.finditer(r"Overfull \\hbox \(([\d.]+)pt too wide\)[^\n]*\n([^\n]*)", log):
        if float(m.group(1)) > HBOX_LIMITE_PT:
            trecho = re.sub(r"\\[A-Za-z0-9/@]+|[\[\]|]", " ", m.group(2))
            trecho = re.sub(r"\s+", " ", trecho).strip()
            avisos.append(f"texto estoura a mancha em {m.group(1)} pt, perto de: {trecho[:60]}")
    if "Label(s) may have changed" in log:
        avisos.append("rótulos podem ter mudado: compile mais uma vez")
    m = re.search(r"(\d+) marcador\(es\) pendente\(s\)", log)
    if m:
        avisos.append(f"{m.group(1)} marcador(es) \\ph{{}} pendente(s)")
    return True


def verificar_pdf(base):
    caminho = base + ".pdf"
    if not os.path.exists(caminho):
        bloqueios.append(f"{caminho} não foi gerado")
        return None
    saida = subprocess.run(["pdftotext", "-layout", caminho, "-"], capture_output=True, text=True)
    paginas = saida.stdout.split("\f")
    for padrao, descricao in PADROES_PDF:
        achadas = [i + 1 for i, p in enumerate(paginas) if re.search(padrao, p)]
        if achadas:
            alvo = bloqueios if "??" in padrao else avisos
            alvo.append(f"{descricao}: páginas {', '.join(map(str, achadas[:12]))}")
    return caminho


def verificar_resumo():
    arquivos = glob.glob("capitulos*/*resumo*.tex")
    for arq in arquivos:
        t = sem_comentarios(ler(arq))
        m = re.search(r"\\begin\{resumo\}(.*?)\\end\{resumo\}", t, re.S)
        if not m:
            continue
        corpo = m.group(1)
        k = corpo.find("\\orientacao")
        while k != -1:
            _, fim = argumentos(corpo, corpo.find("{", k), 1)
            corpo = corpo[:k] + corpo[fim:]
            k = corpo.find("\\orientacao")
        if "\\ph" in corpo:
            avisos.append(f"{arq}: resumo ainda tem marcador \\ph{{}}")
            continue
        corpo = re.sub(r"\\[A-Za-z]+\*?", " ", corpo)
        palavras = re.findall(r"[^\s{}~\\]+", corpo)
        n = len(palavras)
        print(f"Resumo: {n} palavras (faixa {RESUMO_MIN} a {RESUMO_MAX})")
        if not RESUMO_MIN <= n <= RESUMO_MAX:
            avisos.append(f"{arq}: resumo com {n} palavras, fora da faixa {RESUMO_MIN} a {RESUMO_MAX}")


def verificar_requisitos():
    contagem = {}
    arquivos = sorted(glob.glob("capitulos*/*.tex"))
    for arq in arquivos:
        t = sem_comentarios(ler(arq))
        colunas, ids = [], set()
        for m in re.finditer(r"\\begin\{tabelarequisitos\}\{([^}]*)\}|(?<![A-Za-z])\\req(?=\{)", t):
            if m.group(1) is not None:
                colunas = [c.strip() for c in m.group(1).split(",")]
                continue
            args, _ = argumentos(t, m.end(), 4)
            if len(args) < 4:
                bloqueios.append(f"{arq}: \\req com menos de 4 argumentos")
                continue
            rid, _, status, verif = args
            if rid in ids:
                bloqueios.append(f"{arq}: identificador repetido {rid}")
            ids.add(rid)
            estados = re.findall(r"\\(todo|wip|parc|done)\b", status)
            if len(estados) != len(colunas):
                bloqueios.append(f"{arq}: {rid} tem {len(estados)} status para {len(colunas)} colunas")
                continue
            for col, est in zip(colunas, estados):
                contagem.setdefault(col, {}).setdefault(est, 0)
                contagem[col][est] += 1
            if estados[-1] in ("parc", "done") and not verif.strip():
                avisos.append(f"{arq}: {rid} está {estados[-1].upper()} sem método e evidência na coluna Verificação")
    if contagem:
        print("Requisitos por status (contagem nas tabelas; exemplos incluídos):")
        print(f"  {'coluna':8}" + "".join(f"{e.upper():>7}" for e in ("todo", "wip", "parc", "done")))
        for col in sorted(contagem):
            c = contagem[col]
            print(f"  {col:8}" + "".join(f"{c.get(e, 0):>7}" for e in ("todo", "wip", "parc", "done")))


def renderizar(pdf):
    os.makedirs("_verificacao", exist_ok=True)
    for antigo in glob.glob("_verificacao/pag-*.png"):
        os.remove(antigo)
    subprocess.run(["pdftoppm", "-r", "70", "-png", pdf, "_verificacao/pag"], check=False)
    print(f"Páginas renderizadas em _verificacao/ ({len(glob.glob('_verificacao/pag-*.png'))})")


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    entrega = "--entrega" in sys.argv
    base = args[0].removesuffix(".pdf").removesuffix(".tex") if args else "main"
    completo = verificar_log(base)
    pdf = verificar_pdf(base) if completo else None
    verificar_resumo()
    verificar_requisitos()
    if "--paginas" in sys.argv and pdf:
        renderizar(pdf)
    if entrega:
        bloqueios.extend(avisos)
        avisos.clear()
    for a in avisos:
        print("AVISO     " + a)
    for b in bloqueios:
        print("BLOQUEIO  " + b)
    if bloqueios:
        print(f"\nNÃO ENTREGAR: {len(bloqueios)} bloqueio(s), {len(avisos)} aviso(s).")
        sys.exit(1)
    print(f"\nSem bloqueio. {len(avisos)} aviso(s).")


if __name__ == "__main__":
    main()
