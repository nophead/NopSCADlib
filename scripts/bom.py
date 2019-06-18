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

#! Generates BOM files for the project.
from __future__ import print_function

import os
import sys
import shutil
import openscad
from time import *
from set_config import *
import json

def find_scad_file(mname):
    for filename in os.listdir(source_dir):
        if filename[-5:] == ".scad":
            #
            # look for module which makes the assembly
            #
            with open(source_dir + "/" + filename, "r") as f:
                for line in f.readlines():
                    words = line.split()
                    if len(words) and words[0] == "module":
                        module = words[1].split('(')[0]
                        if module == mname:
                            return filename
    return None

class BOM:
    def __init__(self, name):
        self.name = name
        self.count = 1
        self.vitamins = {}
        self.printed = {}
        self.routed = {}
        self.assemblies = {}

    def flat_data(self):
        assemblies = {}
        for ass in self.assemblies:
            assemblies[ass] = self.assemblies[ass].count
        return {
             "name"       : self.name,
             "count"      : self.count,
             "assemblies" : assemblies,
             "vitamins"   : self.vitamins,
             "printed"    : self.printed,
             "routed"     : self.routed
        }

    def add_part(self, s):
        if s[-4:] == ".stl":
            parts = self.printed
        else:
            if s[-4:] == ".dxf":
                parts = self.routed
            else:
                parts = self.vitamins
        if s in parts:
            parts[s] += 1
        else:
            parts[s] = 1

    def add_assembly(self, ass):
        if ass in self.assemblies:
            self.assemblies[ass].count += 1
        else:
            self.assemblies[ass] = BOM(ass)

    def make_name(self, ass):
        if self.count == 1:
            return ass
        return ass.replace("assembly", "assemblies")

    def print_bom(self, breakdown, file = None):
        if self.vitamins:
            print("Vitamins:", file=file)
        if breakdown:
            longest = 0
            for ass in self.assemblies:
                name = ass.replace("_assembly","")
                longest = max(longest, len(name))
            for i in range(longest):
                line = ""
                for ass in sorted(self.assemblies):
                    name = ass.replace("_assembly","").replace("_"," ").capitalize()
                    index = i - (longest - len(name))
                    if index < 0:
                        line += "   "
                    else:
                        line += (" %s " % name[index])
                print(line[:-1], file=file)

        for part in sorted(self.vitamins):
            if ': ' in part:
                part_no, description = part.split(': ')
            else:
                part_no, description = "", part
            if breakdown:
                for ass in sorted(self.assemblies):
                    bom = self.assemblies[ass]
                    if part in bom.vitamins:
                        file.write("%2d|" % bom.vitamins[part])
                    else:
                        file.write("  |")
            print("%3d" % self.vitamins[part], description, file=file)

        if self.printed:
            if self.vitamins:
                print(file=file)
            print("Printed:", file=file)
            for part in sorted(self.printed):
                if breakdown:
                    for ass in sorted(self.assemblies):
                        bom = self.assemblies[ass]
                        if part in bom.printed:
                            file.write("%2d|" % bom.printed[part])
                        else:
                            file.write("  |")
                print("%3d" % self.printed[part], part, file=file)

        if self.routed:
            print(file=file)
            print("CNC cut:", file=file)
            for part in sorted(self.routed):
                if breakdown:
                    for ass in sorted(self.assemblies):
                        bom = self.assemblies[ass]
                        if part in bom.routed:
                            file.write("%2d|" % bom.routed[part])
                        else:
                            file.write("  |")
                print("%3d" % self.routed[part], part, file=file)

        if self.assemblies:
            print(file=file)
            print("Assemblies:", file=file)
            for ass in sorted(self.assemblies):
                print("%3d %s" % (self.assemblies[ass].count, self.assemblies[ass].make_name(ass)), file=file)

def parse_bom(file = "openscad.log", name = None):
    main = BOM(name)
    main.ordered_assemblies = []
    stack = []

    for line in open(file):
        pos = line.find('ECHO: "~')
        if pos > -1:
            s = line[pos + 8 : line.rfind('"')]
            if s[-1] == '{':
                ass = s[:-1]
                if stack:
                    main.assemblies[stack[-1]].add_assembly(ass)    #add to nested BOM
                stack.append(ass)
                main.add_assembly(ass)                              #add to flat BOM
                if ass in main.ordered_assemblies:
                    main.ordered_assemblies.remove(ass)
                main.ordered_assemblies.insert(0, ass)
            else:
                if s[0] == '}':
                    if s[1:] != stack[-1]:
                        raise Exception("Mismatched assembly " + s[1:] + str(stack))
                    stack.pop()
                else:
                    main.add_part(s)
                    if stack:
                        main.assemblies[stack[-1]].add_part(s)
    return main

def boms(target = None, assembly = None):
    bom_dir = set_config(target) + "bom"
    if assembly:
        bom_dir += "/accessories"
        if not os.path.isdir(bom_dir):
            os.makedirs(bom_dir)
    else:
        assembly = "main_assembly"
        if os.path.isdir(bom_dir):
            shutil.rmtree(bom_dir)
            sleep(0.1)
        os.makedirs(bom_dir)
    #
    # Find the scad file that makes the module
    #
    scad_file = find_scad_file(assembly)
    if not scad_file:
        raise Exception("can't find source for " + assembly)
    #
    # make a file to use the module
    #
    bom_maker_name = source_dir + "/bom.scad"
    with open(bom_maker_name, "w") as f:
        f.write("use <%s>\n" % scad_file)
        f.write("%s();\n" % assembly);
    #
    # Run openscad
    #
    openscad.run("-D","$bom=2","-D","$preview=true","-o", "openscad.echo", bom_maker_name)
    os.remove(bom_maker_name)
    print("Generating bom ...", end=" ")

    main = parse_bom("openscad.echo", assembly)

    if assembly == "main_assembly":
        main.print_bom(True, open(bom_dir + "/bom.txt","wt"))

    for ass in main.assemblies:
        with open(bom_dir + "/" + ass + ".txt", "wt") as f:
            bom = main.assemblies[ass]
            print(bom.make_name(ass) + ":", file=f)
            bom.print_bom(False, f)

    data = [main.assemblies[ass].flat_data() for ass in main.ordered_assemblies]
    with open(bom_dir + "/bom.json", 'w') as outfile:
        json.dump(data, outfile, indent = 4)

    print("done")

if __name__ == '__main__':
    args = len(sys.argv)
    if args > 1:
        if args > 2:
            boms(sys.argv[1], sys.argv[2])
        else:
            boms(sys.argv[1])
    else:
        boms();
