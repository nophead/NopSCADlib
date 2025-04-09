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

#! Renders STL and DXF files to PNG for inclusion in the build instructions.

from __future__ import print_function
from set_config import *
from exports import bom_to_parts
import os
import openscad
from tests import do_cmd, update_image, colour_scheme, background, image_size
from deps import mtime
from colorama import init
import json
from tmpdir import *

def usage():
    print("\nusage:\n\trender [target_config] - Render images of the stl, dxf and svg files.");
    sys.exit(1)

def render(target, type):
    top_dir = set_config(target, usage)
    bom_dir = top_dir + 'bom'
    #
    # Find all the parts
    #
    parts = bom_to_parts(bom_dir, type)
    if not parts:
        return
    #
    # Make the target directory
    #
    tmp_dir = mktmpdir(top_dir)
    target_dir = top_dir + type + 's'
    if not os.path.isdir(target_dir):
        os.makedirs(target_dir)
    #
    # Read the json bom to get the colours
    #
    bom_file = bom_dir + "/bom.json"
    with open(bom_file) as json_file:
        flat_bom = json.load(json_file)

    things = { 'stl' : 'printed', 'dxf' : 'routed', 'svg' : 'routed' }[type]
    colours = {}
    cameras = {}
    for ass in flat_bom:
        for part in ass[things]:
             obj = ass[things][part]
             if "colour" in obj:
                colours[part] = obj["colour"]
             if "camera" in obj:
                cameras[part] = obj["camera"]
    #
    # Remove unused png files
    #
    for file in os.listdir(target_dir):
        if file.endswith('.png'):
            if not file[:-4] + '.' + type in parts:
                print("Removing %s" % file)
                os.remove(target_dir + '/' + file)
    #
    # Render the parts
    #
    for part in parts:
        part_file = target_dir + '/' + part
        png_name = target_dir + '/' + part[:-4] + '.png'
        #
        # make a file to import the stl
        #
        if mtime(part_file) > mtime(png_name):
            png_maker_name = tmp_dir + "/png.scad"
            pp1 = [0, 146/255, 0]
            colour = pp1
            camera = "0,0,0,70,0,315,500"
            if part in cameras:
                camera = cameras[part]
            if part in colours:
                colour = colours[part]
                if not '[' in colour:
                    colour = '"' + colour + '"'
            with open(png_maker_name, "w") as f:
                f.write('color(%s) import("%s");\n' % (colour, reltmp(part_file, target)))
            cam = "--camera=" + camera if type == 'stl' else "--camera=0,0,0,0,0,0,500"
            render = "--preview" if type == 'stl' or colour != pp1 else "--render"
            tmp_name = tmp_dir + '/' + part[:-4] + '.png'
            dummy_deps_name = tmp_dir + '/tmp.deps' # work around for OpenSCAD issue #3879
            openscad.run("-o", tmp_name, png_maker_name, colour_scheme, "--projection=p", image_size, cam, render, "--autocenter", "--viewall", "-d", dummy_deps_name)
            do_cmd(("magick "+ tmp_name + " -trim -resize 280x280 -background %s -gravity Center -extent 280x280 -bordercolor %s -border 10 %s"
                    % (background, background, tmp_name)).split())
            update_image(tmp_name, png_name)
            os.remove(png_maker_name)
            os.remove(dummy_deps_name)
    #
    # Remove tmp dir
    #
    rmtmpdir(tmp_dir)

if __name__ == '__main__':
    init()
    if len(sys.argv) > 2: usage()
    target =  sys.argv[1] if len(sys.argv) > 1 else None
    render(target, 'stl')
    render(target, 'dxf')
    render(target, 'svg')
