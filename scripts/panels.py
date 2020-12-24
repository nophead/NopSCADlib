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
#! Panelises DXF files so they can be routed together by running scad files found in the `panels` directory.

from __future__ import print_function
import sys

from plateup import plateup

def usage():
    print("\nusage:\n\tpanels [target_config] - Aggregate DXF files for routing together.")
    sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) > 2: usage()

    if len(sys.argv) > 1:
        target = sys.argv[1]
    else:
        target = None
    plateup(target, 'dxf', usage)
