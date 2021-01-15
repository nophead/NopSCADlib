#!/usr/bin/env python

#
# NopSCADlib Copyright Chris Palmer 2018
# nop.head@gmail.com
# hydraraptor.blogspot.com
#
# This file is part of NopSCADlib.
#
# NopSCADlib is free software: you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# NopSCADlib is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with NopSCADlib.
# If not, see <https://www.gnu.org/licenses/>.
#

#
#! Makes this document and doc/usage.md.
#
from __future__ import print_function

import os
from tests import do_cmd
import argparse

dir = 'scripts'

def doc_scripts():
    doc_name = dir + '/readme.md'
    with open(doc_name, 'wt') as doc_file:
        print(
'''
# Python scripts
These are located in the `scripts` subdirectory, which needs to be added to the program search path.

They should work with both Python 2 and Python 3.

| Script  | Function  |
|:---|:---|''', file = doc_file)
        for file in os.listdir('scripts'):
            if file.endswith('.py'):
                blurb = ''
                with open(dir + '/' + file, 'rt') as f:
                    lines = f.readlines()
                for line in lines:
                    if line == "if __name__ == '__main__':\n":
                        break
                else:
                    continue
                for line in lines[1:]:
                    if line.startswith('#! '):
                        line = line.replace('~\n', '  \n')
                        blurb = blurb + line[3 : -1]
                    if line.startswith("def "):
                        break
                if not blurb:
                    print("Missing description for", file)
                else:
                    print("| `%s` | %s |" % (file, blurb), file = doc_file)

    with open(dir + "/readme.html", "wt") as html_file:
        do_cmd(("python -m markdown -x tables " + doc_name).split(), html_file)

    with open("docs/usage.html", "wt") as html_file:
        do_cmd(("python -m markdown -x tables docs/usage.md").split(), html_file)
    #
    # Spell check
    #
    do_cmd(('codespell -L od ' + doc_name).split())
    do_cmd(('codespell -L od docs/usage.md').split())


if __name__ == '__main__':
    argparse.ArgumentParser(description='Generate scripts/readme.md and make html versions of that and doc/usage.md').parse_args()
    doc_scripts()
