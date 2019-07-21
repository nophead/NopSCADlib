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

#
#! Generates exploded and unexploded assembly views and scrapes build instructions to make readme.md, readme.html and printme.html files for the project.
#
from __future__ import print_function
from set_config import *
import openscad
from tests import do_cmd, update_image, colour_scheme, background
import time
import times
from deps import *
import os
import json
import blurb
import bom
import shutil
from colorama import Fore

def is_assembly(s):
    return s[-9:] == '_assembly' or s[-11:] == '_assemblies'

def bom_to_assemblies(bom_dir, bounds_map):
    global flat_bom
    #
    # Make a list of all the parts in the BOM
    #
    bom_file = bom_dir + "/bom.json"
    with open(bom_file) as json_file:
        flat_bom = json.load(json_file)
    #
    # Decide if we need big or small assembly pictures
    #
    for bom in flat_bom:
        big = False
        for ass in bom["assemblies"]:
            for b in flat_bom:
                if b["name"] == ass:
                    if b["big"]:
                        big = True
                    break
        if not big:
            for stl in bom["printed"]:
                bounds = bounds_map[stl]
                width = bounds[1][0] - bounds[0][0]
                depth = bounds[1][1] - bounds[0][1]
                if max(width, depth) > 80:
                    big = True
                    break
        bom["big"] = big or bom["routed"]
    #
    # Remove the main assembly if it is a shell
    #
    ass =  flat_bom[-1]
    if len(ass["assemblies"]) < 2 and not ass["vitamins"] and not ass["printed"] and not ass["routed"]:
        flat_bom = flat_bom[:-1]
    return [assembly["name"] for  assembly in flat_bom]

def eop(print_mode, doc_file, last = False, first = False):
    if print_mode:
         print('\n<div style="page-break-after: always;"></div>', file = doc_file)
    else:
        if not first:
            print('[Top](#TOP)',   file = doc_file)
        if not last:
            print("\n---", file = doc_file)

def pad(s, before, after = 0):
    return '&nbsp;' * before + str(s) + '&nbsp;' * after

def views(target, do_assemblies = None):
    done_assemblies = []
    #
    # Make the target directory
    #
    top_dir = set_config(target)
    target_dir = top_dir + 'assemblies'
    deps_dir = top_dir + "deps"
    bom_dir = top_dir + "bom"
    if not os.path.isdir(target_dir):
        os.makedirs(target_dir)
    if not os.path.isdir(deps_dir):
        os.makedirs(deps_dir)

    times.read_times(target_dir)
    bounds_fname = top_dir + 'stls/bounds.json'
    with open(bounds_fname) as json_file:
        bounds_map = json.load(json_file)
    #
    # Find all the assemblies
    #
    assemblies = bom_to_assemblies(bom_dir, bounds_map)
    for file in os.listdir(target_dir):
        if file.endswith('.png'):
            assembly = file[:-4].replace('_assembled', '_assembly')
            if assembly.endswith('_tn'):
                assembly = assembly[:-3]
            if not assembly in assemblies:
                print("Removing %s" % file)
                os.remove(target_dir + '/' + file)
    #
    # Find all the scad files
    #
    main_blurb = None
    lib_dir = os.environ['OPENSCADPATH'] + '/NopSCADlib/printed'
    for dir in [source_dir, lib_dir]:
        for filename in os.listdir(dir):
            if filename.endswith('.scad'):
                #
                # find any modules with names ending in _assembly
                #
                with open(dir + "/" + filename, "r") as f:
                    lines = f.readlines()
                line_no = 0
                for line in lines:
                    words = line.split()
                    if len(words) and words[0] == "module":
                        module = words[1].split('(')[0]
                        if is_assembly(module):
                            if module in assemblies:
                                #
                                # Scrape the assembly instructions
                                #
                                for ass in flat_bom:
                                    if ass["name"] == module:
                                        if not "blurb" in ass:
                                            ass["blurb"] = blurb.scrape_module_blurb(lines[:line_no])
                                        break
                                if not do_assemblies or module in do_assemblies:
                                    #
                                    # make a file to use the module
                                    #
                                    png_maker_name = 'png.scad'
                                    with open(png_maker_name, "w") as f:
                                        f.write("use <%s/%s>\n" % (dir, filename))
                                        f.write("%s();\n" % module);
                                    #
                                    # Run openscad on the created file
                                    #
                                    dname = deps_name(deps_dir, filename)
                                    for explode in [0, 1]:
                                        png_name = target_dir + '/' + module + '.png'
                                        if not explode:
                                            png_name = png_name.replace('_assembly', '_assembled')
                                        changed = check_deps(mtime(png_name), dname)
                                        changed = times.check_have_time(changed, png_name)
                                        tmp_name = 'tmp.png'
                                        if changed:
                                            print(changed)
                                            t = time.time()
                                            openscad.run("-D$pose=1", "-D$explode=%d" % explode, colour_scheme, "--projection=p", "--imgsize=4096,4096", "--autocenter", "--viewall", "-d", dname, "-o", tmp_name, png_maker_name);
                                            times.add_time(png_name, t)
                                            do_cmd(["magick", tmp_name, "-trim", "-resize", "1004x1004", "-bordercolor", background, "-border", "10", tmp_name])
                                            update_image(tmp_name, png_name)
                                        tn_name = png_name.replace('.png', '_tn.png')
                                        if mtime(png_name) > mtime(tn_name):
                                            do_cmd(("magick "+ png_name + " -trim -resize 280x280 -background " + background + " -gravity Center -extent 280x280 -bordercolor " + background + " -border 10 " + tmp_name).split())
                                            update_image(tmp_name, tn_name)
                                    os.remove(png_maker_name)
                                done_assemblies.append(module)
                            else:
                                if module == 'main_assembly':
                                    main_blurb = blurb.scrape_module_blurb(lines[:line_no])
                    line_no += 1
    times.print_times()
    #
    # Build the document
    #
    for print_mode in [True, False]:
        doc_name = top_dir + "readme.md"
        with open(doc_name, "wt") as doc_file:
            #
            # Title, description and picture
            #
            project = ' '.join(word[0].upper() + word[1:] for word in os.path.basename(os.getcwd()).split('_'))
            print('<a name="TOP"></a>\n# %s' % project, file = doc_file)
            main_file = bom.find_scad_file('main_assembly')
            if not main_file:
                raise Exception("can't find source for main_assembly")
            text = blurb.scrape_blurb(source_dir + '/' + main_file)
            if len(text):
                print(text, file = doc_file, end = '')
            else:
                if print_mode:
                    print(Fore.MAGENTA + "Missing project description" + Fore.WHITE)
            print('![Main Assembly](assemblies/%s.png)\n' % flat_bom[-1]["name"].replace('_assembly', '_assembled'), file = doc_file)
            eop(print_mode, doc_file, first = True)
            #
            # Build TOC
            #
            print('## Table of Contents', file = doc_file)
            print('1. [Parts list](#Parts_list)', file = doc_file)
            for ass in flat_bom:
                name =  ass["name"]
                cap_name = name.replace('_', ' ').title()
                print('1. [%s](#%s)' % (cap_name, name), file = doc_file)
            print(file = doc_file)
            eop(print_mode, doc_file)
            #
            # Global BOM
            #
            print('<a name="Parts_list"></a>\n## Parts list', file = doc_file)
            types = ["vitamins", "printed", "routed"]
            headings = {"vitamins" : "vitamins", "printed" : "3D printed parts", "routed" : "CNC routed parts"}
            things = {}
            for t in types:
                things[t] = {}
            for ass in flat_bom:
                for t in types:
                    for thing in ass[t]:
                        if thing in things[t]:
                            things[t][thing] += ass[t][thing]
                        else:
                            things[t][thing] = ass[t][thing]
            for ass in flat_bom:
                name = ass["name"][:-9].replace('_', ' ').title().replace(' ','&nbsp;')
                print('| <span style="writing-mode: vertical-rl; text-orientation: mixed;">%s</span> ' % name, file = doc_file, end = '')
            print('| <span style="writing-mode: vertical-rl; text-orientation: mixed;">TOTALS</span> |  |', file = doc_file)

            print(('|--:' * len(flat_bom) + '|--:|:--|'), file = doc_file)

            for t in types:
                if things[t]:
                    totals = {}
                    heading = headings[t][0:1].upper() + headings[t][1:]
                    print(('|  ' * len(flat_bom) + '| | **%s** |') % heading, file = doc_file)
                    for thing in sorted(things[t], key = lambda s: s.split(":")[-1]):
                        for ass in flat_bom:
                            count = ass[t][thing] if thing in ass[t] else 0
                            print('| %s ' % pad(count if count else '.', 2, 1), file = doc_file, end = '')
                            name = ass["name"]
                            if name in totals:
                                totals[name] += count
                            else:
                                totals[name] = count
                        print('|  %s | %s |' % (pad(things[t][thing], 2, 1), pad(thing.split(":")[-1], 2)), file = doc_file)

                    grand_total = 0
                    for ass in flat_bom:
                        name = ass["name"]
                        total = totals[name] if name in totals else 0
                        print('| %s ' % pad(total if total else '.', 2, 1), file = doc_file, end = '')
                        grand_total += total
                    print("| %s | %s |" % (pad(grand_total, 2, 1), pad('Total %s count' % headings[t], 2)), file = doc_file)

            print(file = doc_file)
            eop(print_mode, doc_file)
            #
            # Assembly instructions
            #
            for ass in flat_bom:
                name = ass["name"]
                cap_name = name.replace('_', ' ').title()

                if ass["count"] > 1:
                    print('<a name="%s"></a>\n## %d x %s' % (name, ass["count"], cap_name), file = doc_file)
                else:
                    print('<a name="%s"></a>\n## %s' % (name, cap_name), file = doc_file)
                vitamins = ass["vitamins"]
                if vitamins:
                    print("### Vitamins",         file = doc_file)
                    print("|Qty|Description|",    file = doc_file)
                    print("|--:|:----------|",    file = doc_file)
                    for v in sorted(vitamins, key = lambda s: s.split(":")[-1]):
                        print("|%d|%s|" % (vitamins[v], v.split(":")[1]),     file = doc_file)
                    print("\n", file = doc_file)

                printed = ass["printed"]
                if printed:
                    print('### 3D Printed parts', file = doc_file)
                    keys = sorted(list(printed.keys()))
                    for i in range(len(keys)):
                        p = keys[i]
                        print('%s %d x %s |' % ('\n|' if not (i % 3) else '', printed[p], p), file = doc_file, end = '')
                        if (i % 3) == 2 or i == len(printed) - 1:
                            n = (i % 3) + 1
                            print('\n|%s' % ('--|' * n), file =  doc_file)
                            for j in range(n):
                                part = keys[i - n + j + 1]
                                print('| ![%s](stls/%s) %s' % (part, part.replace('.stl','.png'), '|\n' if j == j - 1 else ''), end = '', file = doc_file)
                            print('\n', file = doc_file)
                    print('\n', file  = doc_file)

                routed = ass["routed"]
                if routed:
                    print("### CNC Routed parts", file = doc_file)
                    keys = sorted(list(routed.keys()))
                    for i in range(len(keys)):
                        r = keys[i]
                        print('%s %d x %s |' % ('\n|' if not (i % 3) else '', routed[r], r), file = doc_file, end = '')
                        if (i % 3) == 2 or i == len(routed) - 1:
                            n = (i % 3) + 1
                            print('\n|%s' % ('--|' * n), file =  doc_file)
                            for j in range(n):
                                part = keys[i - n + j + 1]
                                print('| ![%s](dxfs/%s) %s' % (part, part.replace('.dxf','.png'), '|\n' if j == j - 1 else ''), end = '', file = doc_file)
                            print('\n', file = doc_file)
                    print('\n', file  = doc_file)

                sub_assemblies = ass["assemblies"]
                if sub_assemblies:
                    print("### Sub-assemblies", file = doc_file)
                    keys = sorted(list(sub_assemblies.keys()))
                    for i in range(len(keys)):
                        a = keys[i]
                        print('%s %d x %s |' % ('\n|' if not (i % 3) else '', sub_assemblies[a], a), file = doc_file, end = '')
                        if (i % 3) == 2 or i == len(keys) - 1:
                            n = (i % 3) + 1
                            print('\n|%s' % ('--|' * n), file =  doc_file)
                            for j in range(n):
                                a = keys[i - n + j + 1].replace('_assembly', '_assembled')
                                print('| ![%s](assemblies/%s) %s' % (a, a + '_tn.png', '|\n' if j == j - 1 else ''), end = '', file = doc_file)
                            print('\n', file = doc_file)
                    print('\n', file  = doc_file)

                small = not ass["big"]
                suffix = '_tn.png' if small else '.png'
                print('### Assembly instructions', file = doc_file)
                print('![%s](assemblies/%s)\n' % (name, name + suffix), file = doc_file)

                if "blurb" in ass and ass["blurb"]:
                    print(ass["blurb"], file = doc_file)
                else:
                    if print_mode:
                        print(Fore.MAGENTA + "Missing instructions for %s" % name, Fore.WHITE)

                name = name.replace('_assembly', '_assembled')
                print('![%s](assemblies/%s)\n' % (name, name + suffix), file = doc_file)
                eop(print_mode, doc_file, last = ass == flat_bom[-1] and not main_blurb)
            #
            # If main module is suppressed print any blurb here
            #
            if main_blurb:
                print(main_blurb, file = doc_file)
                eop(print_mode, doc_file, last = True)
        #
        # Convert to HTML
        #
        html_name = "printme.html" if print_mode else "readme.html"
        with open(top_dir + html_name, "wt") as html_file:
            do_cmd(("python -m markdown -x tables -x sane_lists " + doc_name).split(), html_file)
    #
    # Spell check
    #
    do_cmd('codespell -L od readme.md'.split())
    #
    # List the ones we didn't find
    #
    missing = set()
    for assembly in assemblies + (do_assemblies if do_assemblies else []):
        if assembly not in done_assemblies:
            missing.add(assembly)
    if missing:
        for assembly in missing:
            print(Fore.MAGENTA + "Could not find a module called", assembly, Fore.WHITE)
        sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1][-9:] != "_assembly":
        target, assemblies = sys.argv[1], sys.argv[2:]
    else:
        target, assemblies = None, sys.argv[1:]

    views(target, assemblies)
