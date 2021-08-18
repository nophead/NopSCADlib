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
import options
import time
import json
import shutil
from deps import *
from blurb import *
from colorama import Fore
from tmpdir import *

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
    if not os.path.isfile(b):
        print(Fore.MAGENTA + "Failed to generate %s while making %s" % (b, a), Fore.WHITE)
        sys.exit(1)
    if not os.path.isfile(a):
        return -1
    log_name = 'magick.log'
    with open(log_name, 'w') as output:
        do_cmd(("magick compare -metric AE -fuzz %d%% %s %s %s" % (fuzz, a, b, c)).split(), output = output)
    with open(log_name, 'r') as f:
        pixels = f.read().strip()
        pixels = int(float(pixels if pixels.isnumeric() else -1))
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

def usage():
    print("\nusage:\n\ttests [test_name1] ... [test_nameN] - Run specified tests or all tests in none specified.");
    sys.exit(1)

def tests(tests):
    scad_dir = "tests"
    tmp_dir = mktmpdir(scad_dir + '/')
    deps_dir = scad_dir + "/deps"
    png_dir  = scad_dir + "/png"
    bom_dir  = scad_dir + "/bom"
    for dir in [deps_dir, png_dir, bom_dir]:
        if not os.path.isdir(dir):
            os.makedirs(dir)
    index = {}
    bodies = {}
    done = []
    times.read_times()
    options.check_options(deps_dir)
    #
    # Make cover pic if does not exist as very slow. Delete it to force an update.
    #
    png_name = "libtest.png"
    scad_name = "libtest.scad"
    if os.path.isfile(scad_name):
        libtest = True
        lib_blurb = scrape_blurb(scad_name)
        if not os.path.isfile(png_name):
            openscad.run(scad_name, "-o", png_name, colour_scheme, "--projection=p", "--imgsize=%d,%d" % (w, h), "--camera=0,0,0,50,0,340,500", "--autocenter", "--viewall");
            do_cmd(["magick", png_name, "-trim", "-resize", "1280", "-bordercolor", background, "-border", "10", png_name])
    else:
        #
        # Project tests so just a title
        #
        libtest = False
        project = ' '.join(word[0].upper() + word[1:] for word in os.path.basename(os.getcwd()).split('_'))
        lib_blurb = '#' + project + ' Tests\n'

    doc_base_name = "readme" if libtest else "tests"
    doc_name = doc_base_name + ".md"
    #
    # List of individual part files
    #
    scads = [i for i in sorted(os.listdir(scad_dir), key = lambda s: s.lower()) if i[-5:] == ".scad"]
    types = []
    for scad in scads:
        base_name = scad[:-5]
        if not tests or base_name in tests:
            done.append(base_name)
            print(base_name)
            cap_name = base_name[0].capitalize() + base_name[1:]
            base_name = base_name.lower()
            scad_name = scad_dir + '/' + scad
            png_name = png_dir + '/' + base_name + '.png'
            bom_name = bom_dir + '/' + base_name + '.json'

            objects_name = None
            vits_name = 'vitamins/' + base_name + '.scad'
            if is_plural(base_name) and os.path.isfile(vits_name):
                objects_name = vits_name

            locations = []
            if os.path.isdir('vitamins'):
                locations.append(('vitamins/' + depluralise(base_name) + '.scad', 'Vitamins'))
            if os.path.isdir('printed'):
                locations.append(('printed/' + base_name + '.scad',               'Printed'))
            if os.path.isdir('utils'):
                locations.append(('utils/' + base_name + '.scad',                 'Utilities'))
            if libtest and os.path.isdir('utils/core'):
                locations.append(('utils/core/' + base_name + '.scad',            'Core Utilities'))

            for name, type in locations:
                if os.path.isfile(name):
                    impl_name = name
                    break
            else:
                if libtest:
                    print("Can't find implementation!")
                    continue
                else:
                    type = 'Tests'                         # OK when testing part of a project
                    impl_name = None

            if libtest:
                vsplit = "AIR" + chr(ord('Z') + 1)
                vtype = locations[0][1]
                types = [vtype + ' ' + vsplit[i] + '-' + chr(ord(vsplit[i + 1]) - 1) for i in range(len(vsplit) - 1)] + [loc[1] for loc in locations[1 :]]
                if type == vtype:
                    for i in range(1, len(vsplit)):
                        if cap_name[0] < vsplit[i]:
                             type = types[i - 1]
                             break
            else:
                if not types:
                    types = [loc[1] for loc in locations]   # No need to split up the vitamin list
                    if not type in types:                   # Will happen when implementation is not found and type is set to Tests
                        types.append(type)

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
                            body += ['| `%s` | %s |' % (item, things[item])]
                        body += ['']

            body += ["![%s](%s)\n" %(base_name, png_name)]

            dname = deps_name(deps_dir, scad.lower())
            oldest = png_name if mtime(png_name) < mtime(bom_name) else bom_name
            changed = check_deps(oldest, dname)
            changed = times.check_have_time(changed, scad_name)
            changed = options.have_changed(changed, oldest)
            if changed:
                print(changed)
                t = time.time()
                tmp_name = tmp_dir + '/tmp.png'
                openscad.run_list([scad_name, "-o", tmp_name] + options.list() + ["-D$bom=2", colour_scheme, "--projection=p", "--imgsize=%d,%d" % (w, h), "--camera=0,0,0,70,0,315,500", "--autocenter", "--viewall", "-d", dname]);
                times.add_time(scad_name, t)
                do_cmd(["magick", tmp_name, "-trim", "-resize", "1000x600", "-bordercolor", background, "-border", "10", tmp_name])
                update_image(tmp_name, png_name)
                BOM = bom.parse_bom()
                with open(bom_name, 'wt') as outfile:
                    json.dump(BOM.flat_data(), outfile, indent = 4)
                print()

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
                                name = '`' + vit[0] + '`' if vit[0] else ''
                                while '[[' in name and ']]' in name:
                                    i = name.find('[[')
                                    j = name.find(']]') + 2
                                    name = name.replace(name[i : j], '[ ... ]')
                                desc = vit[1]
                                body += ['| %3d | %s | %s |' % (things[item]["count"], name, desc)]
                            else:
                                count = things[item] if thing == 'assemblies' else things[item]["count"]
                                body += ['| %3d | %s |' % (count, name)]
                        body += ['']

            body += ['\n<a href="#top">Top</a>']
            body += ["\n---"]

    for test in done:
        if test in tests:
            tests.remove(test)
    if tests:
        for test in tests:
            print(Fore.MAGENTA + "Could not find a test called", test, Fore.WHITE)
        usage()

    with open(doc_name, "wt") as doc_file:
        print(lib_blurb, file = doc_file)
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
                    name = sorted(index[type])[i]
                    print('<td> <a href = "#' + name + '">' + name + '</a> </td>', file = doc_file, end = '')
                else:
                    print('<td></td>', file = doc_file, end = '')
            print('</tr>', file = doc_file)
        print('</table>\n\n---', file = doc_file)
        for type in types:
            for line in bodies[type]:
                print(line, file = doc_file)
    with open(doc_base_name + ".html", "wt") as html_file:
        do_cmd(("python -m markdown -x tables " + doc_name).split(), html_file)
    times.print_times()
    #
    # Remove tmp dir
    #
    rmtmpdir(tmp_dir)

    do_cmd(('codespell -L od ' + doc_name).split())

if __name__ == '__main__':
    for arg in sys.argv[1:]:
        if arg[:1] == '-': usage()
    tests(sys.argv[1:])
