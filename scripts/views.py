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
#: Generate assembly views and intructions
#
from __future__ import print_function
from set_config import *
import openscad
from tests import do_cmd, update_image
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

def add_assembly(flat_bom, bom):
    if not bom in flat_bom:
        big = False
        for ass in bom["assemblies"]:
            add_assembly(flat_bom, ass)
            if ass["routed"]:
                big = True
        bom["big"] = big or bom["routed"]
        flat_bom.append(bom)

def bom_to_assemblies(bom_dir):
    global flat_bom
    #
    # Make a list of all the parts in the BOM
    #
    bom  = {}
    bom_file = bom_dir + "/bom.json"
    with open(bom_file) as json_file:
        bom = json.load(json_file)
    flat_bom = []
    add_assembly(flat_bom, bom)
    ass =  flat_bom[-1]
    if len(ass["assemblies"]) < 2 and not ass["vitamins"] and not ass["printed"] and not ass["routed"]:
        flat_bom = flat_bom[:-1]
    return [assembly["name"] for  assembly in flat_bom]

def eop(print_mode, project, doc_file, last = False, first = False):
    if print_mode:
         print('\n<div style="page-break-after: always;"></div>', file = doc_file)
    else:
        if not first:
            print('[Top](#%s)' % project.lower().replace(' ', '-'),   file = doc_file)
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
    #
    # Find all the assemblies
    #
    assemblies = bom_to_assemblies(bom_dir)
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
    lib_dir = os.environ['OPENSCADPATH'] + '/NopSCADlib'
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
                                            openscad.run("-D$pose=1", "-D$explode=%d" % explode, "--projection=p", "--imgsize=4096,4096", "--autocenter", "--viewall", "-d", dname, "-o", tmp_name, png_maker_name);
                                            times.add_time(png_name, t)
                                            do_cmd(["magick", tmp_name, "-trim", "-resize", "1004x1004", "-bordercolor", "#ffffe5", "-border", "10", tmp_name])
                                            update_image(tmp_name, png_name)
                                        tn_name = png_name.replace('.png', '_tn.png')
                                        if mtime(png_name) > mtime(tn_name):
                                            do_cmd(("magick "+ png_name + " -trim -resize 280x280 -background #ffffe5 -gravity Center -extent 280x280 -bordercolor #ffffe5 -border 10 " + tmp_name).split())
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
            print('# %s' % project, file = doc_file)
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
            eop(print_mode, project, doc_file, first = True)
            #
            # Build TOC
            #
            print('## Table of Contents', file = doc_file)
            print('[TOC]\n', file = doc_file)
            eop(print_mode, project, doc_file)
            #
            # Global BOM
            #
            print('## Parts list', file = doc_file)
            vitamins = {}
            printed = {}
            routed = {}
            for ass in flat_bom:
                for v in ass["vitamins"]:
                    if v in vitamins:
                        vitamins[v] += ass["vitamins"][v]
                    else:
                        vitamins[v] = ass["vitamins"][v]
                for p in ass["printed"]:
                    if p in printed:
                        printed[p] += ass["printed"][p]
                    else:
                        printed[p] = ass["printed"][p]
            for ass in flat_bom:
                name = ass["name"][:-9].replace('_', ' ').title().replace(' ','&nbsp;')
                print('| <span style="writing-mode: vertical-rl; text-orientation: mixed;">%s</span> ' % name, file = doc_file, end = '')
            print('| <span style="writing-mode: vertical-rl; text-orientation: mixed;">TOTALS</span> |  |', file = doc_file)
            print(('|--:' * len(flat_bom) + '|--:|:--|'), file = doc_file)
            for v in sorted(vitamins, key = lambda s: s.split(":")[-1]):
                for ass in flat_bom:
                    count = ass["vitamins"][v] if v in ass["vitamins"] else '.'
                    print('| %s ' % pad(count, 2, 1), file = doc_file, end = '')
                print('|  %s | %s |' % (pad(vitamins[v], 2, 1), pad(v.split(":")[1], 2)), file = doc_file)
            print(('|  ' * len(flat_bom) + '| | **3D Printed parts** |'), file = doc_file)
            for p in sorted(printed):
                for ass in flat_bom:
                    count = ass["printed"][p] if p in ass["printed"] else '.'
                    print('| %s ' % pad(count, 2, 1), file = doc_file, end = '')
                print('| %s | %s |' % (pad(printed[p], 2, 1), pad(p, 3)), file = doc_file)
            eop(print_mode, project, doc_file)
            #
            # Assembly instructions
            #
            for ass in flat_bom:
                name = ass["name"]
                cap_name = name.replace('_', ' ').title()
                if ass["count"] > 1:
                    print("## %d x %s" % (ass["count"], cap_name), file = doc_file)
                else:
                    print("## %s" % cap_name, file = doc_file)
                vitamins = ass["vitamins"]
                if vitamins:
                    print("### Vitamins",         file = doc_file)
                    print("|Qty|Description|",    file = doc_file)
                    print("|--:|:----------|",    file = doc_file)
                    for v in vitamins:
                        print("|%d|%s|" % (vitamins[v], v.split(":")[1]),     file = doc_file)
                    print("\n", file = doc_file)

                printed = ass["printed"]
                if printed:
                    print('### 3D Printed parts', file = doc_file)
                    i = 0
                    for p in printed:
                        print('%s %d x %s |' % ('\n|' if not (i % 3) else '', printed[p], p), file = doc_file, end = '')
                        if (i % 3) == 2 or i == len(printed) - 1:
                            n = (i % 3) + 1
                            print('\n|%s' % ('--|' * n), file =  doc_file)
                            for j in range(n):
                                part = list(printed.keys())[i - n + j + 1]
                                print('| ![%s](stls/%s) %s' % (part, part.replace('.stl','.png'), '|\n' if j == j - 1 else ''), end = '', file = doc_file)
                            print('\n', file = doc_file)
                        i += 1
                    print('\n', file  = doc_file)

                routed = ass["routed"]
                if routed:
                    print("### CNC Routed parts", file = doc_file)
                    i = 0
                    for r in routed:
                        print('%s %d x %s |' % ('\n|' if not (i % 3) else '', routed[r], r), file = doc_file, end = '')
                        if (i % 3) == 2 or i == len(routed) - 1:
                            n = (i % 3) + 1
                            print('\n|%s' % ('--|' * n), file =  doc_file)
                            for j in range(n):
                                part = list(routed.keys())[i - n + j + 1]
                                print('| ![%s](dxfs/%s) %s' % (part, part.replace('.dxf','.png'), '|\n' if j == j - 1 else ''), end = '', file = doc_file)
                            print('\n', file = doc_file)
                        i += 1
                    print('\n', file  = doc_file)

                sub_assemblies = ass["assemblies"]
                if sub_assemblies:
                    print("### Sub-assemblies", file = doc_file)
                    i = 0
                    for a in sub_assemblies:
                        print('%s %d x %s |' % ('\n|' if not (i % 3) else '', a["count"], a["name"]), file = doc_file, end = '')
                        if (i % 3) == 2 or i == len(sub_assemblies) - 1:
                            n = (i % 3) + 1
                            print('\n|%s' % ('--|' * n), file =  doc_file)
                            for j in range(n):
                                a = sub_assemblies[i - n + j + 1]["name"].replace('_assembly', '_assembled')
                                print('| ![%s](assemblies/%s) %s' % (a, a + '_tn.png', '|\n' if j == j - 1 else ''), end = '', file = doc_file)
                            print('\n', file = doc_file)
                        i += 1
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
                eop(print_mode, project, doc_file, last = ass == flat_bom[-1] and not main_blurb)
            #
            # If main module is suppressed print any blurb here
            #
            if main_blurb:
                print(main_blurb, file = doc_file)
                eop(print_mode, project, doc_file, last = True)
        #
        # Convert to HTML
        #
        html_name = "printme.html" if print_mode else "readme.html"
        with open(top_dir + html_name, "wt") as html_file:
            do_cmd(("python -m markdown -x tables -x toc -x sane_lists " + doc_name).split(), html_file)
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
