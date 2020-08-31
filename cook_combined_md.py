#!/usr/bin/env python3

import re
import pdoc

def _fix_headers(s):
    return re.sub(
        r'(?:^\s*(.*?)\s*\n(?:(=+)|(?:-+))\s*$)|(?:^(\s*)##(#*\s+.*?)$)', 
        lambda m: '%s####%s' % (m[3], m[4]) if m[3] is not None \
                  else '%s %s' % (
                      '###' if m[2] is not None \
                          else '####',
                      m[1]
                      ), 
        s, 
        flags=re.M,
        )

insert_md = '\n\n'.join([_fix_headers(m.text()) for m in pdoc.Module('iwp3tb').submodules()])

with open('README.md') as f:
    readme = f.read()

print(re.sub(
        r'^(##\s+sub\W?modules)\s*$.*?^(##\s+)',
        r'\1\n%s\n\2' % insert_md,
        readme,
        flags=re.M + re.I + re.S,
        )
    )