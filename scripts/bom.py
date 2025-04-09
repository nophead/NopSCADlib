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
import re

try:
    import parts
    got_parts_py = True
except:
    got_parts_py = False

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

def main_assembly(target):
    file = None
    if target:
        assembly = target + "_assembly"
        file = find_scad_file(assembly)
    if not file:
        assembly = "main_assembly"
        file = find_scad_file(assembly)
    if not file:
        raise Exception("can't find source for " + assembly)
    return assembly, file

class Part:
    def __init__(self, args):
        self.count = 1
        for arg in args:
            arg = arg.replace('true',  'True').replace('false', 'False').replace('undef', 'None')
            try:
               exec('self.' + arg)
            except:
               print(arg)

    def data(self):
        return self.__dict__

class BOM:
    def __init__(self, name):
        self.name = name
        self.big = None
        self.ngb = False
        self.zoomed = 0
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
             "big"        : self.big,
             "ngb"        : self.ngb,
             "zoomed"     : self.zoomed,
             "count"      : self.count,
             "assemblies" : assemblies,
             "vitamins"   : {v : self.vitamins[v].data() for v in self.vitamins},
             "printed"    : {p : self.printed[p].data() for p in self.printed},
             "routed"     : {r : self.routed[r].data() for r in self.routed}
        }

    def add_part(self, s):
        args = []
        match = re.match(r'^(.*?\.stl|.*?\.dxf|.*?\.svg)\((.*)\)$', s)                             #look for name.stl(...), name.dxf(...) or name.svg(...)
        if match:
            s = match.group(1)
            args = match.group(2).split('|')
        if s[-4:] == ".stl":
            parts = self.printed
        else:
            if s[-4:] == ".dxf" or s[-4:] == ".svg":
                parts = self.routed
            else:
                parts = self.vitamins
        if s in parts:
            parts[s].count += 1
        else:
            parts[s] = Part(args)

    def add_assembly(self, ass, args = []):
        if ass in self.assemblies:
            self.assemblies[ass].count += 1
        else:
            bom = BOM(ass)
            for arg in args:
                arg = arg.replace('true',  'True').replace('false', 'False').replace('undef', 'None')
                exec('bom.' + arg, locals())
            self.assemblies[ass] = bom

    def make_name(self, ass):
        if self.count == 1:
            return ass
        return ass.replace("assembly", "assemblies")

    def print_CSV(self,  file = None):
        i = 0
        for part in sorted(self.vitamins):
            i += 1
            if ': ' in part:
                part_no, description = part.split(': ', 1)
            else:
                part_no, description = "", part
            qty = self.vitamins[part].count
            if got_parts_py:
                match = re.match(r'^.*\((.*?)[,\)].*$', part_no)
                if match and not match.group(1).startswith('"'):
                    part_no = part_no.replace('(' + match.group(1), '_' + match.group(1) + '(').replace('(, ', '(')
                func = 'parts.' + part_no.replace('(', '(%d, ' % qty).replace(', )', ')')
                func = func.replace('true',  'True').replace('false', 'False').replace('undef', 'None')
                try:
                    price, url = eval(func)
                    print("'%s',%3d,%.2f,'=B%d*C%d',%s" % (description, qty, price, i, i, url), file=file)
                except:
                    if part_no:
                        print("%s not found in parts.py" % func)
                    print("'%s',%3d" % (description, qty), file=file)
            else:
                print("'%s',%3d" % (description, qty), file=file)
        if got_parts_py:
            print(",'=SUM(B1:B%d)',,'=SUM(D1:D%d)'" %(i, i), file=file)

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
                part_no, description = part.split(': ', 1)
            else:
                part_no, description = "", part
            if breakdown:
                for ass in sorted(self.assemblies):
                    bom = self.assemblies[ass]
                    if part in bom.vitamins:
                        file.write("%2d|" % bom.vitamins[part].count)
                    else:
                        file.write("  |")
            print("%3d" % self.vitamins[part].count, description, file=file)

        if self.printed:
            if self.vitamins:
                print(file=file)
            print("Printed:", file=file)
            for part in sorted(self.printed):
                if breakdown:
                    for ass in sorted(self.assemblies):
                        bom = self.assemblies[ass]
                        if part in bom.printed:
                            file.write("%2d|" % bom.printed[part].count)
                        else:
                            file.write("  |")
                print("%3d" % self.printed[part].count, part, file=file)

        if self.routed:
            print(file=file)
            print("CNC cut:", file=file)
            for part in sorted(self.routed):
                if breakdown:
                    for ass in sorted(self.assemblies):
                        bom = self.assemblies[ass]
                        if part in bom.routed:
                            file.write("%2d|" % bom.routed[part].count)
                        else:
                            file.write("  |")
                print("%3d" % self.routed[part].count, part, file=file)

        if self.assemblies:
            print(file=file)
            print("Assemblies:", file=file)
            for ass in sorted(self.assemblies):
                print("%3d %s" % (self.assemblies[ass].count, self.assemblies[ass].make_name(ass)), file=file)

def parse_bom(file = "openscad.log", name = None):
    main = BOM(name)
    main.ordered_assemblies = []
    stack = []
    prog = re.compile(r'^(.*)\((.*)\)$')
    for line in open(file):
        pos = line.find('ECHO: "~')
        if pos > -1:
            s = line[pos + 8 : line.rfind('"')]
            if s[-1] == '{':
                ass = s[:-1]
                args = []
                match = prog.match(ass)                             #look for (...)
                if match:
                    ass = match.group(1)
                    args = match.group(2).split(',')
                if stack:
                    main.assemblies[stack[-1]].add_assembly(ass)    #add to nested BOM
                stack.append(ass)
                main.add_assembly(ass, args)                        #add to flat BOM
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
        else:
            if 'ERROR:' in line or 'WARNING:' in line:
                raise Exception(line[:-1])
    return main

def usage():
    print("\nusage:\n\tbom [target_config] - Generate BOMs for a project.")
    sys.exit(1)

def boms(target = None):
    try:
        bom_dir = set_config(target, usage) + "bom"
        if os.path.isdir(bom_dir):
            shutil.rmtree(bom_dir)
            sleep(0.1)
        os.makedirs(bom_dir)
        #
        # Find the scad file that makes the main assembly
        #
        assembly, scad_file = main_assembly(target)
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
        openscad.run("-D", "$bom=2", "-D", "$preview=true", "-o", "openscad.echo", "-d", bom_dir + "/bom.deps", bom_maker_name)
        os.remove(bom_maker_name)
        print("Generating bom ...", end=" ")

        main = parse_bom("openscad.echo", assembly)

        main.print_bom(True, open(bom_dir + "/bom.txt","wt"))

        main.print_CSV(open(bom_dir + "/bom.csv","wt"))

        for ass in main.assemblies:
            with open(bom_dir + "/" + ass + ".txt", "wt") as f:
                bom = main.assemblies[ass]
                print(bom.make_name(ass) + ":", file=f)
                bom.print_bom(False, f)

        data = [main.assemblies[ass].flat_data() for ass in main.ordered_assemblies]
        with open(bom_dir + "/bom.json", 'w') as outfile:
            json.dump(data, outfile, indent = 4)

        print("done")
    except Exception as e:
        print(str(e))
        sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) > 2: usage()

    target = sys.argv[1] if len(sys.argv) == 2 else None

    boms(target)
