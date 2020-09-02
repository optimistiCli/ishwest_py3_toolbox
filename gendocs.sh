#!/usr/bin/env bash

DEFAULT_PDOC_TEMPLATES_DIR='pdoc_templates'

if [ -n "$PDOC_PYENV" ] ; then
    . "${PDOC_PYENV}/bin/activate"
fi

if ! which pdoc 2>/dev/null >/dev/null ; then
cat >&2 << EOE
Error: pdoc not in PATH

You might wanna install pdoc or export PDOC_PYENV that points to a
Python virual environment where pdoc is installed.

EOE
exit 1
fi

if [ -n "$PDOC_TEMPLATES" ] ; then
    EFFECTIVE_TEMPLATES_DIR="$PDOC_TEMPLATES"
elif ls -l ./"$DEFAULT_PDOC_TEMPLATES_DIR"/*.mako >/dev/null 2>/dev/null ; then
    EFFECTIVE_TEMPLATES_DIR="./$DEFAULT_PDOC_TEMPLATES_DIR"
fi

if [ -n "$EFFECTIVE_TEMPLATES_DIR" ] ; then
    TEMPLATES_OPT="--template-dir $EFFECTIVE_TEMPLATES_DIR"
    echo "Pdoc templates dir: $EFFECTIVE_TEMPLATES_DIR"
fi

pdoc --html -f $TEMPLATES_OPT -o doc iwp3tb

export EFFECTIVE_TEMPLATES_DIR
./cook_combined_md.py > README.md.temp \
    && mv -v README.md.temp README.md