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
# Run openscad
#
from __future__ import print_function

import subprocess, sys

def _run(args, silent):
    cmd = ["openscad"] + args
    if not silent:
        for arg in cmd:
            print(arg, end=" ")
        print()
    with open("openscad.log", "w") as log:
        rc = subprocess.call(cmd, stdout = log, stderr = log)
    for line in open("openscad.log", "rt"):
        if 'ERROR:' in line or 'WARNING:' in line:
            print(line[:-1])
    if rc:
        sys.exit(rc)

def run(*args):
    _run(list(args), False)

def run_silent(*args):
    _run(list(args), True);
