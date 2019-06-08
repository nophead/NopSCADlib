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
from set_config import *
from exports import bom_to_parts
import os
import openscad
from tests import do_cmd
from deps import mtime

def render(target, type):
    #
    # Make the target directory
    #
    target_dir = set_config(target) + type + 's'
    if not os.path.isdir(target_dir):
        os.makedirs(target_dir)
    #
    # Find all the parts
    #
    parts = bom_to_parts(target_dir, type)
    #
    # Remove unused png files
    #
    for file in os.listdir(target_dir):
        if file.endswith('.png'):
            if not file[:-4] + '.' + type in parts:
                print("Removing %s" % file)
                os.remove(target_dir + '/' + file)

    for part in parts:
        part_file = target_dir + '/' + part
        png_name = target_dir + '/' + part[:-4] + '.png'
        #
        # make a file to import the stl
        #
        if mtime(part_file) > mtime(png_name):
            png_maker_name = "png.scad"
            with open(png_maker_name, "w") as f:
                f.write('color("lime") import("%s");\n' % part_file)
            cam = "--camera=0,0,0,70,0,315,500" if type == 'stl' else "--camera=0,0,0,0,0,0,500"
            render = "--preview" if type == 'stl' else "--render"
            openscad.run("--projection=p", "--imgsize=4096,4096", cam, render, "--autocenter", "--viewall", "-o", png_name, png_maker_name);
            do_cmd(("magick "+ png_name + " -trim -resize 280x280 -background #ffffe5 -gravity Center -extent 280x280 -bordercolor #ffffe5 -border 10 " + png_name).split())
            os.remove(png_maker_name)

if __name__ == '__main__':
    target =  sys.argv[1] if len(sys.argv) > 1 else None
    render(target, 'stl')
    render(target, 'dxf')
