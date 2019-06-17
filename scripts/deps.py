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
            dep = line[1 : -1].rstrip(' \\')
            if not os.path.basename(dep) in ['stl.scad', 'dxf.scad', 'svf.scad', 'png.scad', 'target.scad']:
                deps.append(dep)
    return deps

def check_deps(target_mtime, dname):
    if not target_mtime:
        return "target missing"
    if not os.path.isfile(dname):
        return "no deps"
    deps = read_deps(dname)
    for dep in deps:
        if mtime(dep) > target_mtime:
            return dep + ' changed'
    return None
