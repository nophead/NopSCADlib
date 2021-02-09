#
# NopSCADlib Copyright Chris Palmer 2020
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

# Set command line options from enviroment variables and check if they have changed

import json, os, deps
from colorama import Fore, init

def check_options(dir = '.'):
    global options, options_mtime
    options = { "show_threads": str(os.getenv("NOPSCADLIB_SHOW_THREADS")) }
    options_fname = dir + '/options.json'
    try:
        with open(options_fname) as json_file:
            last_options = json.load(json_file)
    except:
        last_options = {}
    if last_options != options:
        with open(options_fname, 'w') as outfile:
            json.dump(options, outfile, indent = 4)
    options_mtime = deps.mtime(options_fname)

def have_changed(changed, target):
    if not changed and deps.mtime(target) < options_mtime:
        return Fore.CYAN + "command line options changed" + Fore.WHITE
    return changed

def list():
    result = []
    for name in options.keys():
        value = options[name]
        if value != 'None':
            result.append('-D$' + name + '=' + value)
    return result
