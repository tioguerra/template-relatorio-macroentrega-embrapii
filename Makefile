LATEXMK = latexmk -pdf -interaction=nonstopmode
ENTREGA = -g -jobname=$(1)-entrega -usepretex='\PassOptionsToClass{entrega}{macroentrega}'

.PHONY: pdf final entrega entrega-final verificar verificar-final limpar

# Rascunho: marcadores \ph{} e caixas de orientação visíveis.
pdf:
	$(LATEXMK) -halt-on-error main.tex

final:
	$(LATEXMK) -halt-on-error main-final.tex

# Entrega: marcador pendente vira erro e as orientações somem.
# Gera main-entrega.pdf e roda a verificação em modo entrega.
entrega:
	-$(LATEXMK) $(call ENTREGA,main) main.tex
	python3 scripts/verificar.py main-entrega --entrega --paginas

entrega-final:
	-$(LATEXMK) $(call ENTREGA,main-final) main-final.tex
	python3 scripts/verificar.py main-final-entrega --entrega --paginas

verificar: pdf
	python3 scripts/verificar.py main --paginas

verificar-final: final
	python3 scripts/verificar.py main-final --paginas

limpar:
	latexmk -C main.tex main-final.tex
	rm -f main-entrega.* main-final-entrega.* capitulos*/*.aux
	rm -rf _verificacao
