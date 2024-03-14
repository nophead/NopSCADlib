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
import os
from set_config import source_dir
from colorama import Fore

def mtime(file):
    if os.path.isfile(file):
        return os.path.getmtime(file)
    return 0

def deps_name(dir, scad_name):
    return dir + '/' + scad_name[:-5] + '.deps'

def read_deps(dname):
    with open(dname, "rt") as file:
        lines = file.readlines()
    deps = []
    for line in lines:
        if line.startswith('\t'):
            dep = line[1 : -1].rstrip(' \\').replace('\\ ', ' ')
            if not os.path.basename(dep) in ['stl.scad', 'dxf.scad', 'svg.scad', 'png.scad', 'target.scad']:
                deps.append(dep)
    return deps

def check_deps(target, dname):
    target_mtime = mtime(target)
    if not target_mtime:
        return Fore.CYAN + target + " missing" + Fore.WHITE
    if not os.path.isfile(dname):
        return Fore.CYAN + "no deps" + Fore.WHITE
    deps = read_deps(dname)
    for dep in deps:
        if mtime(dep) > target_mtime:
            return Fore.CYAN + dep + ' changed' + Fore.WHITE
    return None

def source_dirs(bom_dir):
    dirs = set()
    lib_dirs = set()
    deps = read_deps(bom_dir + '/bom.deps')
    cwd = os.getcwd().replace('\\', '/')
    for dep in deps:
        dir = os.path.dirname(dep)
        if dir.startswith(cwd):
            dirs.add(dir[len(cwd) + 1:])
        else:
            if dir.endswith('/printed'):
                lib_dirs.add(dir)
    dirs.discard(source_dir)
    return [source_dir] + sorted(dirs) + sorted(lib_dirs)
