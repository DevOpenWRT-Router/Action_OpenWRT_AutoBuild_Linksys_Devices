#!/bin/sh

mkdir output

# pandoc -s main.md -o output/main.html
# pandoc main.md -o output/main_bare.html
# pandoc -s main.md -o output/main.pdf
# pandoc -s main.md -o output/main.epub
# pandoc -s main.md -o output/main.odt
# pandoc -s main.md -o output/main.docx

date > output/.build_date.txt

echo "generated_at: $(date)" > variables.yml

# mustache variables.yml index.output.html > output/index.html
# mustache variables.yml README.output.md > output/README.md
