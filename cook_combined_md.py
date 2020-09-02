#!/usr/bin/env python3

import re
import os
import sys
import pdoc

templ_dir_var='EFFECTIVE_TEMPLATES_DIR'


if templ_dir_var in os.environ:
    pdoc.tpl_lookup.directories.clear()
    pdoc.tpl_lookup.directories.append(os.environ[templ_dir_var])

generated_md = '\n\n'.join([ m.text() for m in pdoc.Module('iwp3tb').submodules() ])

with open('README.md') as f:
    readme = f.read()

m = re.search(r'(.*?^#\s+[^\n]+?)\s*$.*?^((?:##\s+)(?!Module\b).*)',
              readme,
              flags=re.M + re.I + re.S,
              )

first_line = m[1]
rest_of = m[2].rstrip()

title_counter = {}

def number_title(s):
    if s in title_counter:
        title_counter[s] += 1
        return '%s-%i' % (s, title_counter[s])
    else:
        title_counter[s] = 0
        return s

toc = ''

for h_level, h_title in re.findall(r'(#{2,})\s+(.+)\b',
                            re.sub(r'`{3}.*?`{3}', '', generated_md + rest_of, flags=re.M + re.S)
                           ):
    level = len(h_level)
    anch = number_title(re.sub(r'[^\w\-]+', 
                               '', 
                               re.sub(r'\s+', 
                                      '-', 
                                      h_title.lower(),
                                      )
                               )
                        )
    toc += '%s- [%s](#%s)\n' % ('  ' * (level - 2), h_title, anch)

print('%s\n\n%s\n\n%s\n\n\n\%s' % (first_line, toc, generated_md, rest_of))