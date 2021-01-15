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
#! Generates all the files for a project by running `bom.py`, `stls.py`, `dxfs.py`, `render.py` and `views.py`.

import sys

from exports import make_parts
from bom import boms
from render import render
from views import views
from plateup import plateup
from set_config import set_config


def usage():
    print("\nusage:\n\tmake_all [target_config] - Make all the manufacturing files and readme for a project.")
    sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) > 2: usage()
    target = None if len(sys.argv) == 1 else sys.argv[1]
    set_config(target, usage)
    boms(target)
    for part in ['stl', 'dxf']:
        make_parts(target, part)
        render(target, part)
        plateup(target, part)

    views(target)
