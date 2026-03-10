"""
fix_saif_escaping.py
--------------------
XSim incorrectly double-escapes Verilog escaped identifiers when writing SAIF:

  XSim writes:  (\\result\[0\]_i_2_n_0\  (T0 ...)
  SAIF should:  (\result[0]_i_2_n_0   (T0 ...)

Vivado's read_saif takes the net name literally, so the double-escaped form
fails to match DCP net names like \result[0]_i_2_n_0 , keeping matching at ~38%.
This script fixes the escaping so Vivado can match those nets.

Usage:
  python fix_saif_escaping.py <saif_file> [<saif_file2> ...]
"""
import re, sys, os

# Matches:  (\\<ident_body>\<space>
#
# Where <ident_body> is:
#   - sequences of non-backslash, non-whitespace, non-paren chars, OR
#   - escaped bracket pairs \[ or \]
#
# Converts to: (\<ident_body_unescaped><space>
#   i.e. single leading backslash, brackets unescaped, trailing space

PATTERN = re.compile(
    r'\('           # literal (
    r'\\\\'         # two literal backslashes
    r'('            # start capture of identifier body
        r'(?:'
            r'[^\\\s()]+'   # one or more non-backslash/space/paren chars
            r'|'
            r'\\[\[\]]'     # OR escaped bracket: \[ or \]
        r')+'
    r')'            # end capture
    r'\\ '          # trailing backslash-space (Verilog escaped ID terminator)
)

def fix_ident(m):
    body = m.group(1)
    body = body.replace('\\[', '[').replace('\\]', ']')
    return '(\\' + body + ' '

def process(path):
    with open(path, 'r', encoding='ascii', errors='replace') as f:
        text = f.read()

    fixed, count = PATTERN.subn(fix_ident, text)

    with open(path, 'w', encoding='ascii') as f:
        f.write(fixed)

    print(f"  {os.path.basename(path)}: fixed {count} escaped identifiers")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python fix_saif_escaping.py <saif> [<saif2> ...]")
        sys.exit(1)
    for p in sys.argv[1:]:
        if os.path.exists(p):
            process(p)
        else:
            print(f"  SKIP (not found): {p}")
