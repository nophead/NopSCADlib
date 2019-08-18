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

from __future__ import print_function
import os
import openscad
import sys
import c14n_stl
from set_config import *
from deps import *
from shutil import copyfile

source_dirs = { "stl" : "platters", "dxf" : "panels" }
target_dirs = { "stl" : "printed",  "dxf" : "routed" }

def plateup(target, part_type):
    #
    # Make the target directory
    #
    top_dir = set_config(target)
    parts_dir = top_dir + part_type + 's'
    target_dir = parts_dir + '/' + target_dirs[part_type]
    source_dir = top_dir + source_dirs[part_type]
    deps_dir = source_dir + "/deps"
    if not os.path.isdir(source_dir):
        return
    if not os.path.isdir(target_dir):
        os.makedirs(target_dir)
    if not os.path.isdir(deps_dir):
        os.makedirs(deps_dir)
    #
    # Decide which files to make
    #
    sources = [file for file in os.listdir(source_dir) if file.endswith('.scad')]
    #
    # Run OpenSCAD on the source files to make the targets
    #
    used = []
    for src in sources:
        src_file = source_dir + '/' + src
        part_file = target_dir + '/' + src[:-4] + part_type
        dname = deps_name(deps_dir, src)
        changed = check_deps(part_file, dname)
        if changed:
            print(changed)
            openscad.run("-D$bom=1", "-d", dname, "-o", part_file, src_file)
            if part_type == 'stl':
                c14n_stl.canonicalise(part_file)
            log_name = 'openscad.log'
        else:
            log_name = 'openscad.echo'
            openscad.run_silent("-D$bom=1", "-o", log_name, src_file)
        #
        # Add the files on the BOM to the used list
        #
        with open(log_name) as file:
            for line in file.readlines():
                if line.startswith('ECHO: "~') and line.endswith('.' + part_type + '"\n'):
                    used.append(line[8:-2])
    #
    # Copy file that are not included
    #
    copied = []
    for file in os.listdir(parts_dir):
        if file.endswith('.' + part_type) and not file in used:
            src = parts_dir + '/' + file
            dst = target_dir + '/' + file
            if mtime(src) > mtime(dst):
                print("Copying %s to %s" % (src, dst))
                copyfile(src, dst)
            copied.append(file)
    #
    # Remove any cruft
    #
    targets = [file[:-4] + part_type for file in sources]
    for file in os.listdir(target_dir):
        if file.endswith('.' + part_type):
            if not file in targets and not file in copied:
                print("Removing %s" % file)
                os.remove(target_dir + '/' + file)
