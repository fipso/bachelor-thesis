#!/bin/bash

pdflatex -pdf expose.tex
bibtext expose
pdflatex -pdf expose.tex
