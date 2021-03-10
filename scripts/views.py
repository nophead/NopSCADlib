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
import options
from deps import *
import os
import json
import blurb
import bom
import shutil
import re
import copy
from colorama import Fore
from tmpdir import *

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
        if  bom["big"] == None:
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
    if flat_bom:
        ass = flat_bom[-1]
        if len(ass["assemblies"]) < 2 and not ass["vitamins"] and not ass["printed"] and not ass["routed"]:
            flat_bom = flat_bom[:-1]
    return [assembly["name"] for  assembly in flat_bom]

def eop(doc_file, last = False, first = False):
    print('<span></span>', file = doc_file)     # An invisable marker for page breaks because markdown takes much longer if the document contains a div
    if not first:
        print('[Top](#TOP)', file = doc_file)
    if not last:
        print("\n---", file = doc_file)

def pad(s, before, after = 0):
    return '&nbsp;' * before + str(s) + '&nbsp;' * after

def titalise(name):
    cap_next = True
    result = ''
    for c in name.replace('_', ' '):
        result = result + (c.upper() if cap_next else c);
        cap_next = c == ' '
    return result

def usage():
    print("\nusage:\n\t views [target_config] [<name1>_assembly] ... [<nameN>_assembly] - Create assembly images and readme.")
    sys.exit(1)

types = ["vitamins", "printed", "routed"]

def merged(bom):
    bom = copy.deepcopy(bom)
    for aname in bom["assemblies"]:
        count = bom["assemblies"][aname]
        for ass in flat_bom:
            if ass['name'] == aname and ass['ngb']:
                merged_assembly = merged(ass)
                total = ass['count']
                for t in types:
                    for thing in merged_assembly[t]:
                        items = merged_assembly[t][thing]['count'] * count // total
                        if thing in bom[t]:
                            bom[t][thing]['count'] += items
                        else:
                            bom[t][thing] = merged_assembly[t][thing]
                            bom[t][thing]['count'] = items
                break
    return bom

def views(target, do_assemblies = None):
    done_assemblies = []
    #
    # Make the target directory
    #
    top_dir = set_config(target, usage)
    tmp_dir = mktmpdir(top_dir)
    target_dir = top_dir + 'assemblies'
    deps_dir = target_dir + "/deps"
    bom_dir = top_dir + "bom"
    if not os.path.isdir(target_dir):
        os.makedirs(target_dir)
    if not os.path.isdir(deps_dir):
        os.makedirs(deps_dir)

    times.read_times(target_dir)
    options.check_options(deps_dir)
    bounds_fname = top_dir + 'stls/bounds.json'
    with open(bounds_fname) as json_file:
        bounds_map = json.load(json_file)
    #
    # Find all the assemblies and remove any old views
    #
    assemblies = bom_to_assemblies(bom_dir, bounds_map)
    lc_assemblies = [ass.lower() for ass in assemblies]
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
    pngs = []
    for dir in source_dirs(bom_dir):
        if os.path.isdir(dir):
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
                                lc_module = module.lower()
                                if lc_module in lc_assemblies:
                                    real_name = assemblies[lc_assemblies.index(lc_module)]
                                    #
                                    # Scrape the assembly instructions
                                    #
                                    for ass in flat_bom:
                                        if ass["name"] == real_name:
                                            zoomed = ass['zoomed']
                                            if not "blurb" in ass:
                                                ass["blurb"] = blurb.scrape_module_blurb(lines[:line_no])
                                            break

                                    #
                                    # Run openscad on the created file
                                    #
                                    dname = deps_name(deps_dir, filename)
                                    for explode in [0, 1]:
                                        #
                                        # Generate png name
                                        #
                                        png_name = target_dir + '/' + real_name + '.png'
                                        if not explode:
                                            png_name = png_name.replace('_assembly', '_assembled')
                                        pngs.append(png_name)

                                        if not do_assemblies or real_name in do_assemblies:
                                            changed = check_deps(png_name, dname)
                                            changed = times.check_have_time(changed, png_name)
                                            changed = options.have_changed(changed, png_name)
                                            tmp_name = tmp_dir + '/' + real_name + '.png'
                                            if changed:
                                                print(changed)
                                                #
                                                # make a file to use the module
                                                #
                                                png_maker_name = tmp_dir + '/png.scad'
                                                with open(png_maker_name, "w") as f:
                                                    f.write("use <%s/%s>\n" % (reltmp(dir, target), filename))
                                                    f.write("%s();\n" % module);
                                                t = time.time()
                                                target_def = ['-D$target="%s"' % target] if target else []
                                                cwd_def = ['-D$cwd="%s"' % os.getcwd().replace('\\', '/')]
                                                view_def = ['--viewall', '--autocenter'] if not (zoomed & (1 << explode)) else ['--camera=0,0,0,55,0,25,140']
                                                openscad.run_list(["-o", tmp_name, png_maker_name] + options.list() + target_def + cwd_def + view_def + ["-D$pose=1", "-D$explode=%d" % explode, colour_scheme, "--projection=p", "--imgsize=4096,4096", "-d", dname]);
                                                times.add_time(png_name, t)
                                                do_cmd(["magick", tmp_name, "-trim", "-resize", "1004x1004", "-bordercolor", background, "-border", "10", tmp_name])
                                                update_image(tmp_name, png_name)
                                                os.remove(png_maker_name)
                                            tn_name = png_name.replace('.png', '_tn.png')
                                            if mtime(png_name) > mtime(tn_name):
                                                do_cmd(("magick "+ png_name + " -trim -resize 280x280 -background " + background + " -gravity Center -extent 280x280 -bordercolor " + background + " -border 10 " + tmp_name).split())
                                                update_image(tmp_name, tn_name)
                                    done_assemblies.append(real_name)
                                else:
                                    if module == 'main_assembly':
                                        main_blurb = blurb.scrape_module_blurb(lines[:line_no])
                        line_no += 1
    #
    # Build the document
    #
    doc_name = top_dir + "readme.md"
    with open(doc_name, "wt") as doc_file:
        #
        # Title, description and picture
        #
        project = ' '.join(word[0].upper() + word[1:] for word in os.path.basename(os.getcwd()).split('_'))
        print('<a name="TOP"></a>', file = doc_file)
        print('# %s' % project, file = doc_file)
        main_file = bom.find_scad_file('main_assembly')
        if not main_file:
            raise Exception("can't find source for main_assembly")
        text = blurb.scrape_blurb(source_dir + '/' + main_file)
        blurbs = blurb.split_blurb(text)
        if len(text):
            print(blurbs[0], file = doc_file)
        else:
            print(Fore.MAGENTA + "Missing project description" + Fore.WHITE)
        #
        # Only add the image if the first blurb section doesn't contain one.
        #
        if not re.search(r'\!\[.*\]\(.*\)', blurbs[0], re.MULTILINE):
            print('![Main Assembly](assemblies/%s.png)\n' % flat_bom[-1]["name"].replace('_assembly', '_assembled'), file = doc_file)
        eop(doc_file, first = True)
        #
        # Build TOC
        #
        print('## Table of Contents', file = doc_file)
        print('1. [Parts list](#Parts_list)', file = doc_file)
        for ass in flat_bom:
            name =  ass["name"]
            cap_name = titalise(name)
            print('1. [%s](#%s)' % (cap_name, name), file = doc_file)
        print(file = doc_file)
        if len(blurbs) > 1:
            print(blurbs[1], file = doc_file)
        eop(doc_file)
        #
        # Global BOM
        #
        global_bom = [merged(ass) for ass in flat_bom if not ass['ngb']]
        print('<a name="Parts_list"></a>\n## Parts list', file = doc_file)
        headings = {"vitamins" : "vitamins", "printed" : "3D printed parts", "routed" : "CNC routed parts"}
        things = {}
        for t in types:
            things[t] = {}
        for ass in flat_bom:
            for t in types:
                for thing in ass[t]:
                    if thing in things[t]:
                        things[t][thing] += ass[t][thing]["count"]
                    else:
                        things[t][thing] = ass[t][thing]["count"]
        for ass in global_bom:
            name = titalise(ass["name"][:-9]).replace(' ','&nbsp;')
            if ass["count"] > 1:
                name = "%d x %s" % (ass["count"], name)
            print('| <span style="writing-mode: vertical-rl; text-orientation: mixed;">%s</span> ' % name, file = doc_file, end = '')
        print('| <span style="writing-mode: vertical-rl; text-orientation: mixed;">TOTALS</span> |  |', file = doc_file)
        print(('|---:' * len(global_bom) + '|---:|:---|'), file = doc_file)

        for t in types:
            if things[t]:
                totals = {}
                grand_total2 = 0
                heading = headings[t][0].upper() + headings[t][1:]
                print(('|  ' * len(global_bom) + '| | **%s** |') % heading, file = doc_file)
                for thing in sorted(things[t], key = lambda s: s.split(":")[-1]):
                    for ass in global_bom:
                        count = ass[t][thing]["count"] if thing in ass[t] else 0
                        print('| %s ' % pad(count if count else '.', 2, 1), file = doc_file, end = '')
                        name = ass["name"]
                        if name in totals:
                            totals[name] += count
                        else:
                            totals[name] = count
                        grand_total2 += count
                    print('|  %s | %s |' % (pad(things[t][thing], 2, 1), pad(thing.split(":")[-1], 2)), file = doc_file)

                grand_total = 0
                for ass in global_bom:
                    name = ass["name"]
                    total = totals[name] if name in totals else 0
                    print('| %s ' % pad(total if total else '.', 2, 1), file = doc_file, end = '')
                    grand_total += total
                print("| %s | %s |" % (pad(grand_total, 2, 1), pad('Total %s count' % headings[t], 2)), file = doc_file)
                assert grand_total == grand_total2
        print(file = doc_file)
        if len(blurbs) > 2:
            print(blurbs[2], file = doc_file)
        eop(doc_file)
        #
        # Assembly instructions
        #
        for ass in flat_bom:
            name = ass["name"]
            cap_name = titalise(name)

            print('<a name="%s"></a>' % name, file = doc_file)
            if ass["count"] > 1:
                print('## %d x %s' % (ass["count"], cap_name), file = doc_file)
            else:
                print('## %s' % cap_name, file = doc_file)
            vitamins = ass["vitamins"]
            if vitamins:
                print("### Vitamins",         file = doc_file)
                print("|Qty|Description|",    file = doc_file)
                print("|---:|:----------|",    file = doc_file)
                for v in sorted(vitamins, key = lambda s: s.split(":")[-1]):
                    print("|%d|%s|" % (vitamins[v]["count"], v.split(":")[1]),     file = doc_file)
                print("\n", file = doc_file)

            printed = ass["printed"]
            if printed:
                print('### 3D Printed parts', file = doc_file)
                keys = sorted(list(printed.keys()))
                for i, p in enumerate(keys):
                    print('%s %d x %s |' % ('\n|' if not (i % 3) else '', printed[p]["count"], p), file = doc_file, end = '')
                    if (i % 3) == 2 or i == len(printed) - 1:
                        n = (i % 3) + 1
                        print('\n|%s' % ('---|' * n), file =  doc_file)
                        for j in range(n):
                            part = keys[i - n + j + 1]
                            print('| ![%s](stls/%s) %s' % (part, part.replace('.stl','.png'), '|\n' if j == j - 1 else ''), end = '', file = doc_file)
                        print('\n', file = doc_file)
                print('\n', file  = doc_file)

            routed = ass["routed"]
            if routed:
                print("### CNC Routed parts", file = doc_file)
                keys = sorted(list(routed.keys()))
                for i, r in enumerate(keys):
                    print('%s %d x %s |' % ('\n|' if not (i % 3) else '', routed[r]["count"], r), file = doc_file, end = '')
                    if (i % 3) == 2 or i == len(routed) - 1:
                        n = (i % 3) + 1
                        print('\n|%s' % ('---|' * n), file =  doc_file)
                        for j in range(n):
                            part = keys[i - n + j + 1]
                            print('| ![%s](dxfs/%s) %s' % (part, part.replace('.dxf','.png'), '|\n' if j == j - 1 else ''), end = '', file = doc_file)
                        print('\n', file = doc_file)
                print('\n', file  = doc_file)

            sub_assemblies = ass["assemblies"]
            if sub_assemblies:
                print("### Sub-assemblies", file = doc_file)
                keys = sorted(list(sub_assemblies.keys()))
                for i, a in enumerate(keys):
                    print('%s %d x %s |' % ('\n|' if not (i % 3) else '', sub_assemblies[a], a), file = doc_file, end = '')
                    if (i % 3) == 2 or i == len(keys) - 1:
                        n = (i % 3) + 1
                        print('\n|%s' % ('---|' * n), file =  doc_file)
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
                print(Fore.MAGENTA + "Missing instructions for %s" % name, Fore.WHITE)

            name = name.replace('_assembly', '_assembled')
            print('![%s](assemblies/%s)\n' % (name, name + suffix), file = doc_file)
            eop(doc_file, last = ass == flat_bom[-1] and not main_blurb)
        #
        # If main module is suppressed print any blurb here
        #
        if main_blurb:
            print(main_blurb, file = doc_file)
            eop(doc_file, last = True)
    #
    # Convert to HTML
    #
    html_name = top_dir + 'readme.html'
    t = time.time()
    with open(html_name, "wt") as html_file:
        do_cmd(("python -m markdown -x tables -x sane_lists " + doc_name).split(), html_file)
    times.add_time(html_name, t)
    times.print_times(pngs + [html_name])
    #
    # Make the printme.html by replacing empty spans that invisbly mark the page breaks by page break divs.
    #
    with open(html_name, 'rt') as src:
        lines = src.readlines()

    i = 0
    with open(top_dir + 'printme.html', 'wt') as dst:
        while i < len(lines):
            line = lines[i]
            if line.startswith('<p><span></span>'):                # Empty span used to mark page breaks
                i += 1
                if lines[i].startswith('<a href="#TOP">Top</a>'):  # The first page break won't have one
                    i += 1
                if i < len(lines) and lines[i] == '<hr />\n':      # The last page break doesn't have one
                    dst.write('<div style="page-break-after: always;"></div>\n')
                    i += 1
            else:
                dst.write(line)
                i += 1
    #
    # Remove tmp dir
    #
    rmtmpdir(tmp_dir)
    #
    # Spell check
    #
    do_cmd(('codespell -L od ' + top_dir + 'readme.md').split())
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

    for a in assemblies:
        if a[-9:] != "_assembly": usage()

    views(target, assemblies)
