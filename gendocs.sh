#!/usr/bin/env bash

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

pdoc --html -f -o doc iwp3tb
