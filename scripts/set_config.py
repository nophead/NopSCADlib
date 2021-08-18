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
#! Sets the target configuration for multi-target projects that have variable configurations.
#
from __future__ import print_function

source_dir = 'scad'

import sys
import os

def valid_targets():
    return [i[7:-5] for i in os.listdir(source_dir) if i[0:7] == "config_" and i[-5:] == ".scad"]

def valid_targets_string():
    result = ''
    targets = valid_targets()
    for t in targets:
        if result:
            if t == targets[-1]:
                result +=  ' and '
            else:
                result += ', '
        result += t
    return result


def set_config(target, usage = None):
    if target and target[:1] == '-' and usage: usage()
    targets = valid_targets()
    if not target:
        if not targets:
            return ""
        print("Must specify a configuration: " + valid_targets_string())
        if usage:
            usage()
        sys.exit(1)

    if not targets:
        print("Not a muli-configuration project (no config_<target>.scad files found)")
        if usage:
            usage()
        sys.exit(1)

    if not target in targets:
        print(target + " is not a configuration, avaliable configurations are: " + valid_targets_string())
        if usage:
            usage()
        sys.exit(1)

    fname = source_dir + "/target.scad"
    text = ['include <config_%s.scad>\n' % target,
            '$target = "%s";\n' % target,
            '$cwd="%s";\n' % os.getcwd().replace('\\', '/')
    ]

    lines = [""]
    try:
        with open(fname,"rt") as f:
            lines = f.readlines()
    except:
        pass

    if lines != text:
        with open(fname,"wt") as f:
            for t in text:
                f. write(t);
    return target + "/"

def usage():
        print("\nusage:\n\tset_config config_name")
        sys.exit(1)

if __name__ == '__main__':
    args = len(sys.argv)
    if args == 2:
       set_config(sys.argv[1], usage)
    else:
        usage()
