## Define mini-templates for each portion of the doco.

<%!
import re

def indent(s, spaces=4):
    return '  ' + s

def fix_headers(s, n):
    return re.sub(
        r'(?:(```.*?```))|(?:^\s*([^\n]*?)\s*\n(?:(=+)|(?:-+))\s*$)|(?:^(\s*)(#+\s+.*?)$)', 
        lambda m: m[1] if m[1] is not None \
                  else '%s%s%s' % (m[4], '#' * n, m[5]) if m[4] is not None \
                  else '%s %s' % (
                                    ('#' + '#' * n) if m[3] is not None \
                                    else ('##' + '#' * n),
                                 m[2]
                                 ), 
        s, 
        flags=re.M + re.S,
        )
%>

<%def name="hs(s,n)">${'#' * n} ${s}
</%def>

<%def name="function(func)" buffered="True">
    <%
        returns = show_type_annotations and func.return_annotation() or ''
        if returns:
            returns = ' \N{non-breaking hyphen}> ' + returns
    %>
${hs('Function ' + func.name, 3)}
`${func.name}(${", ".join(func.params(annotate=show_type_annotations))})${returns}`

${fix_headers(cook_md(func.docstring), 2)}
</%def>

<%def name="variable(var)" buffered="True">
    <%
        annot = show_type_annotations and var.type_annotation() or ''
        if annot:
            annot = ': ' + annot
    %>
${hs('Variable ' + var.name, 3)}
`${var.name}${annot}`

${fix_headers(cook_md(var.docstring), 2)}
</%def>

<%def name="class_(cls)" buffered="True">
${hs('Class ' + cls.name, 3)}
`${cls.name}(${", ".join(cls.params(annotate=show_type_annotations))})`

${fix_headers(cook_md(cls.docstring), 2)}
<%
  class_vars = cls.class_variables(show_inherited_members, sort=sort_identifiers)
  static_methods = cls.functions(show_inherited_members, sort=sort_identifiers)
  inst_vars = cls.instance_variables(show_inherited_members, sort=sort_identifiers)
  methods = cls.methods(show_inherited_members, sort=sort_identifiers)
  mro = cls.mro()
  subclasses = cls.subclasses()
%>
% if mro:
${hs('Ancestors', 4)}
% for c in mro:
* ${c.refname}
% endfor

% endif
% if subclasses:
${hs('Descendants', 4)}
% for c in subclasses:
* ${c.refname}
% endfor

% endif
% if class_vars:
${hs('Class variables', 4)}
% for v in class_vars:
${variable(v) | indent}

% endfor
% endif
% if static_methods:
${hs('Static methods', 4)}
% for f in static_methods:
${function(f) | indent}

% endfor
% endif
% if inst_vars:
${hs('Instance variables', 4)}
% for v in inst_vars:
${variable(v) | indent}

% endfor
% endif
% if methods:
${hs('Methods', 4)}
% for m in methods:
${function(m) | indent}

% endfor
% endif
</%def>

## Start the output logic for an entire module.

<%
import pdoc
import pdoc.html_helpers

def link(dobj: pdoc.Doc, name=None):
    name = name or dobj.qualname + ('()' if isinstance(dobj, pdoc.Function) else '')
    if isinstance(dobj, pdoc.External) and not external_links:
        return name
    url = dobj.url(relative_to=module, 
                   link_prefix=link_prefix,
                   top_ancestor=not show_inherited_members)
    return '[%s](%s)' % (name, url)


def cook_md(text):
    return re.sub(
        r'^\*{2}`{3}(\S+)`{3}\*{2}\s*:\s*([^\n]*?)\s*\n:\s*(.*?)\n\n',
        lambda m: '```%s``` %s\n\n%s\n' 
            % (
                m[1],
                re.sub(
                    r'(?:&\w+;)|(?:<[^>]+>)',
                    '',
                    m[2],
                    ),
                re.sub(
                    r'^\s*(.*?)\s*$',
                    r'\1',
                    m[3],
                    flags=re.M,
                    ),
                ),
        pdoc.html_helpers.to_markdown(text, 
            docformat=docformat, module=module, link=link),
        flags=re.M + re.S,
    )

variables = module.variables(sort=sort_identifiers)
classes = module.classes(sort=sort_identifiers)
functions = module.functions(sort=sort_identifiers)
submodules = module.submodules()
heading = 'Namespace' if module.is_namespace else 'Module'
%>

${hs(heading + ' ' + module.name, 2)}
${fix_headers(cook_md(module.docstring), 1)}


% if submodules:
${hs('Sub-modules', 3)}
    % for m in submodules:
* ${m.name}
    % endfor
% endif

% if variables:
    % for v in variables:
${variable(v)}

    % endfor
% endif

% if functions:
    % for f in functions:
${function(f)}

    % endfor
% endif

% if classes:
    % for c in classes:
${class_(c)}

    % endfor
% endif
