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
#! Runs all the tests in the tests directory and makes the readme file with a catalog of the results.

from __future__ import print_function
import os
import sys
import openscad
import subprocess
import bom
import times
import time
import json
import shutil
from deps import *
from blurb import *
from colorama import Fore

w = 4096
h = w
threshold = 20  # Image comparison allowed number of different pixels
fuzz = 5       # Image comparison allowed percentage error in pixel value

colour_scheme = "--colorscheme=Nature"
background = "#F8F8F8"

def do_cmd(cmd, output = sys.stdout):
    for arg in cmd:
        print(arg, end = " ")
    print()
    return subprocess.call(cmd, stdout = output, stderr = output)

def compare_images(a, b, c):
    if not os.path.isfile(a):
        return -1
    log_name = 'magick.log'
    with open(log_name, 'w') as output:
        do_cmd(("magick compare -metric AE -fuzz %d%% %s %s %s" % (fuzz, a, b, c)).split(), output = output)
    with open(log_name, 'r') as f:
        pixels = int(f.read().strip())
    os.remove(log_name)
    return pixels

def update_image(tmp_name, png_name):
    """Update an image only if different, otherwise just change the mod time"""
    diff_name = png_name.replace('.png', '_diff.png')
    pixels = compare_images(png_name, tmp_name, diff_name)
    if pixels < 0 or pixels > threshold:
        shutil.copyfile(tmp_name, png_name)
        print(Fore.YELLOW + png_name + " updated" + Fore.WHITE, pixels if pixels > 0 else '')
    else:
        os.utime(png_name, None)
        os.remove(diff_name)
    os.remove(tmp_name)


def depluralise(name):
    if name[-3:] == "ies" and name != "zipties":
        return name[:-3] + 'y'
    if name[-3:] == "hes":
        return name[:-2]
    if name[-1:] == 's':
        return name[:-1]
    return name

def is_plural(name):
    return name != depluralise(name)

def tests(tests):
    scad_dir = "tests"
    deps_dir = scad_dir + "/deps"
    png_dir  = scad_dir + "/png"
    bom_dir  = scad_dir + "/bom"
    for dir in [deps_dir, png_dir, bom_dir]:
        if not os.path.isdir(dir):
            os.makedirs(dir)
    doc_name = "readme.md"
    index = {}
    bodies = {}
    times.read_times()
    #
    # Make cover pic if does not exist as very slow. Delete it to force an update.
    #
    png_name = "libtest.png"
    scad_name = "libtest.scad"
    if not os.path.isfile(png_name):
        openscad.run(colour_scheme, "--projection=p", "--imgsize=%d,%d" % (w, h), "--camera=0,0,0,50,0,340,500", "--autocenter", "--viewall", "-o", png_name, scad_name);
        do_cmd(["magick", png_name, "-trim", "-resize", "1280", "-bordercolor", background, "-border", "10", png_name])
    #
    # List of individual part files
    #
    scads = [i for i in os.listdir(scad_dir) if i[-5:] == ".scad"]

    for scad in scads:
        base_name = scad[:-5]
        if not tests or base_name in tests:
            print(base_name)
            cap_name = base_name[0].capitalize() + base_name[1:]
            scad_name = scad_dir + '/' + scad
            png_name = png_dir + '/' + base_name + '.png'
            bom_name = bom_dir + '/' + base_name + '.json'

            objects_name = None
            vits_name = 'vitamins/' + base_name + '.scad'
            if is_plural(base_name) and os.path.isfile(vits_name):
                objects_name = vits_name

            locations = [
                ('vitamins/' + depluralise(base_name) + '.scad', 'Vitamins'),
                ('printed/' + base_name + '.scad',               'Printed'),
                ('utils/' + base_name + '.scad',                 'Utilities'),
                ('utils/core/' + base_name + '.scad',            'Core Utilities'),
            ]

            for name, type in locations:
                if os.path.isfile(name):
                    impl_name = name
                    break
            else:
                print("Can't find implementation!")
                continue

            vsplit = "N"
            vtype = locations[0][1]
            types = [vtype + ' A-' + vsplit[0], vtype + ' ' + chr(ord(vsplit) + 1) + '-Z'] + [loc[1] for loc in locations[1 :]]
            if type == vtype:
                type = types[0] if cap_name[0] <= vsplit else types[1]

            for t in types:
                if not t in bodies:
                    bodies[t] = []
                    index[t] = []

            body = bodies[type]

            index[type] += [cap_name]
            body += ['<a name="%s"></a>' % cap_name]
            body += ["## " + cap_name]

            doc = None
            if impl_name:
                doc = scrape_code(impl_name)
                blurb = doc["blurb"]
            else:
                blurb = scrape_blurb(scad_name)

            if not len(blurb):
                print("Blurb not found!")
            else:
                body += [ blurb ]

            if objects_name:
                body += ["[%s](%s) Object definitions.\n" % (objects_name, objects_name)]

            if impl_name:
                body += ["[%s](%s) Implementation.\n" % (impl_name, impl_name)]

            body += ["[%s](%s) Code for this example.\n" % (scad_name.replace('\\','/'), scad_name)]

            if doc:
                for thing, heading in [("properties", "Function"), ("functions", "Function"), ("modules", "Module")]:
                    things = doc[thing]
                    if things:
                        body += ['### %s\n| %s | Description |\n|:--- |:--- |' % (thing.title(), heading)]
                        for item in sorted(things):
                            body += ['| ```%s``` | %s |' % (item, things[item])]
                        body += ['']

            body += ["![%s](%s)\n" %(base_name, png_name)]

            dname = deps_name(deps_dir, scad)
            oldest = min(mtime(png_name), mtime(bom_name))
            changed = check_deps(oldest, dname)
            changed = times.check_have_time(changed, scad_name)
            if changed:
                print(changed)
                t = time.time()
                tmp_name = 'tmp.png'
                openscad.run("-D", "$bom=2", colour_scheme, "--projection=p", "--imgsize=%d,%d" % (w, h), "--camera=0,0,0,70,0,315,500", "--autocenter", "--viewall", "-d", dname, "-o", tmp_name, scad_name);
                times.add_time(scad_name, t)
                do_cmd(["magick", tmp_name, "-trim", "-resize", "1000x600", "-bordercolor", background, "-border", "10", tmp_name])
                update_image(tmp_name, png_name)
                BOM = bom.parse_bom()
                with open(bom_name, 'wt') as outfile:
                    json.dump(BOM.flat_data(), outfile, indent = 4)

            with open(bom_name, "rt") as bom_file:
                BOM = json.load(bom_file)
                for thing, heading in [("vitamins", "Module call | BOM entry") , ("printed", "Filename"), ("routed", "Filename"), ("assemblies", "Name")]:
                    things = BOM[thing]
                    if things:
                        body += ['### %s\n| Qty | %s |\n| ---:|:--- |%s' % (thing.title(), heading, ':---|' if '|' in heading else '')]
                        for item in sorted(things, key = lambda s: s.split(":")[-1]):
                            name = item
                            desc = ''
                            if thing == "vitamins":
                                vit = item.split(':')
                                name = '```' + vit[0] + '```' if vit[0] else ''
                                while '[[' in name and ']]' in name:
                                    i = name.find('[[')
                                    j = name.find(']]') + 2
                                    name = name.replace(name[i : j], '[ ... ]')
                                desc = vit[1]
                                body += ['| %3d | %s | %s |' % (things[item], name, desc)]
                            else:
                                body += ['| %3d | %s |' % (things[item], name)]
                        body += ['']

            body += ['\n<a href="#top">Top</a>']
            body += ["\n---"]

    with open(doc_name, "wt") as doc_file:
        print('# NopSCADlib', file = doc_file)
        print('''\
An ever expanding library of parts modelled in OpenSCAD useful for 3D printers and enclosures for electronics, etc.

It contains lots of vitamins (the RepRap term for non-printed parts), some general purpose printed parts and
some utilities. There are also Python scripts to generate Bills of Materials (BOMs),
 STL files for all the printed parts, DXF files for CNC routed parts in a project and a manual containing assembly
instructions and exploded views by scraping markdown embedded in OpenSCAD comments, [see scripts](scripts/readme.md). A simple example project can be found [here](examples/MainsBreakOutBox/readme.md).

For more examples of what it can make see the [gallery](gallery/readme.md).

The license is GNU General Public License v3.0, see [COPYING](COPYING).

See [usage](docs/usage.md) for requirements, installation instructions and a usage guide.

<img src="libtest.png" width="100%"/>\n
''', file = doc_file)

        print('## Table of Contents<a name="top"/>', file = doc_file)
        print('<table><tr>', file = doc_file)
        n = 0
        for type in types:
            print('<th align="left"> %s </th>' % type, end = '', file = doc_file)
            n = max(n, len(index[type]))
        print('</tr>',  file = doc_file)
        for i in range(n):
            print('<tr>',  file = doc_file, end = '')
            for type in types:
                if i < len(index[type]):
                    name = index[type][i]
                    print('<td> <a href = "#' + name + '">' + name + '</a> </td>', file = doc_file, end = '')
                else:
                    print('<td></td>', file = doc_file, end = '')
            print('</tr>', file = doc_file)
        print('</table>\n\n---', file = doc_file)
        for type in types:
            for line in bodies[type]:
                print(line, file = doc_file)
    with open("readme.html", "wt") as html_file:
        do_cmd("python -m markdown -x tables readme.md".split(), html_file)
    times.print_times()
    do_cmd('codespell -L od readme.md'.split())

if __name__ == '__main__':
    tests(sys.argv[1:])
