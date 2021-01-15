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
"""
Capture Markup lines in OpenSCAD source code denoted by '//!'.
"""
import re

def parse_line(line):
    """ process a line, add blurb to text and return true if got to a module or function """
    if line[:3] == '//!':
        line = line.replace('~\n', '  \n')
        start = 4 if line[3] == ' ' else 3
        return False, line[start :]
    else:
        words = line.split()
        return len(words) and (words[0] == "module" or words[0] == "function" or words[0] == 'include'), ""

def _scrape_blurb(lines):
    """ Find Markup lines before the first function or module given a list of lines."""
    text = ""
    for line in lines:
        b, t = parse_line(line)
        if b:
            break
        text += t
    return text

def scrape_blurb(scad_file):
    """ Find Markup lines before the first function or module."""
    with open(scad_file, "rt") as file:
        lines = file.readlines()
    return _scrape_blurb(lines)

def split_blurb(lines):
    """ Split blurb on horizontal rules."""
    blurbs = [""]
    for line in lines.split('\n')[:-1]:
        if re.match(r'\*{3,}',line):
            blurbs.append("")
        else:
            blurbs[-1] += line + '\n'
    return blurbs

def scrape_module_blurb(lines):
    """ Find the Markup lines before the last function or module. """
    text = ""
    for line in lines:
        b, t = parse_line(line)
        text = "" if b else text + t
    return text

def scrape_code(scad_file):
    """ Find the Markup lines on the first line of functions and modules. """
    with open(scad_file, "rt") as file:
        lines = file.readlines()
    blurb = _scrape_blurb(lines)
    properties = {}
    functions = {}
    modules = {}
    for line in lines:
        match = re.match(r'^function (.*\(type\)|.*\(type ?= ?.*?\)) *= *type\[.*\].*?(?://! ?(.*))?$', line)
        if match:
            properties[match.group(1)] = match.group(2)
        else:
            match = re.match(r'^function (.*?\(.*?\)).*?(?://! ?(.*))$', line)
            if match:
                functions[match.group(1)] = match.group(2)
        match = re.match(r'^module (.*?\(.*?\)).*?(?://! ?(.*))$', line)
        if match:
            modules[match.group(1)] = match.group(2)

    return { "blurb" : blurb, "properties" : properties, "functions" : functions, "modules": modules}
