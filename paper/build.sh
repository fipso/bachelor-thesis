#!/bin/bash

pdflatex -pdf -shell-escape expose.tex
bibtext expose
pdflatex -pdf -shell-escape expose.tex
