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
import time
import times
from deps import *
import json

def bom_to_parts(target_dir, part_type, assembly = None):
    #
    # Make a list of all the parts in the BOM
    #
    part_files = []
    bom = assembly + '.txt' if assembly else "bom.txt"
    suffix = ".dxf" if part_type == 'svg' else '.' + part_type
    with open(target_dir + "/../bom/" + bom, "rt") as f:
        for line in f.readlines():
            words = line.split()
            if words:
                last_word = words[-1]
                if last_word.endswith(suffix):
                   part_files.append(last_word[:-4] + '.' + part_type)
    return part_files

def make_parts(target, part_type, parts = None):
    #
    # Make the target directory
    #
    top_dir = set_config(target)
    target_dir = top_dir + part_type + 's'
    deps_dir = top_dir + "deps"
    if not os.path.isdir(target_dir):
        os.makedirs(target_dir)
    if not os.path.isdir(deps_dir):
        os.makedirs(deps_dir)
    times.read_times(target_dir)
    #
    # Decide which files to make
    #
    if parts:
        targets = list(parts)           #copy the list so we dont modify the list passed in
    else:
        targets = bom_to_parts(target_dir, part_type)
        for file in os.listdir(target_dir):
            if file.endswith('.' + part_type):
                if not file in targets:
                    print("Removing %s" % file)
                    os.remove(target_dir + '/' + file)
    #
    # Read existing STL bounds
    #
    if part_type == 'stl':
        bounds_fname = target_dir + '/bounds.json'
        try:
            with open(bounds_fname) as json_file:
                bounds_map = json.load(json_file)
        except:
            bounds_map = {}
    #
    # Find all the scad files
    #
    lib_dir = os.environ['OPENSCADPATH'] + '/NopSCADlib/printed'
    used = []
    module_suffix = '_dxf' if part_type == 'svg' else '_' + part_type
    for dir in [source_dir, lib_dir]:
        for filename in os.listdir(dir):
            if filename[-5:] == ".scad":
                #
                # find any modules ending in _<part_type>
                #
                with open(dir + "/" + filename, "r") as f:
                    for line in f.readlines():
                        words = line.split()
                        if(len(words) and words[0] == "module"):
                            module = words[1].split('(')[0]
                            if module.endswith(module_suffix):
                                base_name = module[:-4]
                                part = base_name + '.' + part_type
                                if part in targets:
                                    #
                                    # make a file to use the module
                                    #
                                    part_maker_name = part_type + ".scad"
                                    with open(part_maker_name, "w") as f:
                                        f.write("use <%s/%s>\n" % (dir, filename))
                                        f.write("%s();\n" % module);
                                    #
                                    # Run openscad on the created file
                                    #
                                    part_file = target_dir + "/" + part
                                    dname = deps_name(deps_dir, filename)
                                    changed = check_deps(mtime(part_file), dname)
                                    changed = times.check_have_time(changed, part)
                                    if part_type == 'stl' and not changed and not part in bounds_map:
                                        changed = "No bounds"
                                    if changed:
                                        print(changed)
                                        t = time.time()
                                        openscad.run("-D$bom=1", "-d", dname, "-o", part_file, part_maker_name)
                                        times.add_time(part, t)
                                        if part_type == 'stl':
                                            bounds = c14n_stl.canonicalise(part_file)
                                            bounds_map[part] = bounds
                                    targets.remove(part)
                                    os.remove(part_maker_name)
                                    #
                                    # Add the files on the BOM to the used list for plates.py
                                    #
                                    for line in open("openscad.log"):
                                        if line[:7] == 'ECHO: "' and line[-6:] == '.' + part_type + '"\n':
                                            used.append(line[7:-2])
    #
    # Write new bounds file
    #
    if part_type == 'stl':
        with open(bounds_fname, 'w') as outfile:
            json.dump(bounds_map, outfile, indent = 4)
    #
    # List the ones we didn't find
    #
    if targets:
        for part in targets:
            if part[-4:] != '.' + part_type:
                print(part, "is not a", part_type, "file")
            else:
                print("Could not find a module called", part[:-4] + module_suffix, "to make", part)
        sys.exit(1)
    times.print_times()
    return used
