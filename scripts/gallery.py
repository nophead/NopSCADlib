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
# Find projects and add them to the gallery
#
from __future__ import print_function
import os
from colorama import Fore, init
from tests import do_cmd
import re
from shutil import copyfile
from tests import update_image
import sys

project_dir = '../..'
target_dir = 'gallery'
output_name = target_dir + '/readme.md'

def gallery(force):
    if not os.path.isdir(target_dir):
        os.makedirs(target_dir)

    projects = [i for i in os.listdir(project_dir) if os.path.isdir(project_dir + '/' + i + '/assemblies')]
    with open(output_name, 'wt') as output_file:
        print("# A gallery of projects made with NopSCADlib", file = output_file)
        for project in projects:
            path = project_dir + '/' + project
            print(project)
            document = path + '/readme.md'
            if force:
                os.system('cd %s && make_all' % path)
            if os.path.isfile(document):
                with open(document, 'rt') as readme:
                    for line in readme.readlines():
                        match = re.match(r"^.*!(\[.*\]\(.*\)).*$", line)
                        if match:
                            image = match.group(0)
                            if image.startswith('![Main Assembly](assemblies/'):
                                file = image[17 : -1]
                                line = line.replace(image, '![](%s.png)' % project)
                                tmp_name = 'tmp.png'
                                target_name = '%s/%s.png' %(target_dir, project)
                                copyfile(path + '/' + file, tmp_name)
                                update_image(tmp_name, target_name)
                            else:
                                line = line.replace(image, '')
                        else:
                            match = re.match(r"^(#+).*$", line)
                            if match:
                                line = '#' + line
                        print(line[:-1], file = output_file)
                        if line == '---\n':
                            break;
            else:
                print(Fore.MAGENTA + "Can't find", document, Fore.WHITE);
    with open(target_dir + "/readme.html", "wt") as html_file:
        do_cmd(("python -m markdown -x tables " + output_name).split(), html_file)

if __name__ == '__main__':
    init()
    gallery(force = len(sys.argv) > 1 and sys.argv[1] == '-f')
