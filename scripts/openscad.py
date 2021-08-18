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
#! Run `openscad.exe` and capture `stdout` and `stderr` in `openscad.log` as well as printing to the console.
#
from __future__ import print_function

import subprocess, sys

def run_list(args, silent = False, verbose = False):
    cmd = ["openscad"] + args + ["--hardwarnings"]
    if not silent:
        for arg in cmd:
            print(arg, end=" ")
        print()
    with open("openscad.log", "w") as log:
        rc = subprocess.call(cmd, stdout = log, stderr = log)
    log_file = "openscad.echo" if "openscad.echo" in cmd else "openscad.log"
    bad = False
    for line in open(log_file, "rt"):
        if verbose or 'ERROR:' in line or 'WARNING:' in line:
            bad = True
            print(line[:-1])
    if rc:
        sys.exit(rc)

    if bad:
        sys.exit(1)

def run(*args):
    run_list(list(args), False)

def run_silent(*args):
    run_list(list(args), True);

if __name__ == '__main__':
    run_list(sys.argv[1:], True, True)
