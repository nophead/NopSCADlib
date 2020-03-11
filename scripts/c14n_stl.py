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
#! OpenSCAD produces randomly ordered STL files. This script re-orders them consistently so that GIT can tell if they have changed or not.
#
# OpenSCAD produces randomly ordered STL files so source control like GIT can't tell if they have changed or not.
# This scrip orders each triangle to start with the lowest vertex first (comparing x, then y, then z)
# It then sorts the triangles to start with the one with the lowest vertices first (comparing first vertex, second, then third)
# This has no effect on the model but makes the STL consistent. I.e. it makes a canonical form.
#

from __future__ import print_function

import sys

def cmz(x):
    ''' Convert "-0" to "0". '''
    return '0' if x == '-0' else x

class Vertex:
    def __init__(self, x, y, z):
        self.x, self.y, self.z = x, y, z
        self.key = (float(x), float(y), float(z))

class Normal:
    def __init__(self, dx, dy, dz):
        self.dx, self.dy, self.dz = dx, dy, dz

class Facet:
    def __init__(self, normal, v1, v2, v3):
        self.normal = normal
        if v1.key < v2.key:
            if v1.key < v3.key:
                self.vertices = (v1, v2, v3)    #v1 is the smallest
            else:
                self.vertices = (v3, v1, v2)    #v3 is the smallest
        else:
            if v2.key < v3.key:
                self.vertices = (v2, v3, v1)    #v2 is the smallest
            else:
                self.vertices = (v3, v1, v2)    #v3 is the smallest

    def key(self):
        return (self.vertices[0].x, self.vertices[0].y, self.vertices[0].z,
                self.vertices[1].x, self.vertices[1].y, self.vertices[1].z,
                self.vertices[2].x, self.vertices[2].y, self.vertices[2].z)

class STL:
    def __init__(self, fname):
        self.facets = []

        with open(fname) as f:
            words = [cmz(s.strip()) for s in f.read().split()]

        if words[0] == 'solid' and words[1] == 'OpenSCAD_Model':
            i = 2
            while words[i] == 'facet':
                norm = Normal(words[i + 2],  words[i + 3],  words[i + 4])
                v1   = Vertex(words[i + 8],  words[i + 9],  words[i + 10])
                v2   = Vertex(words[i + 12], words[i + 13], words[i + 14])
                v3   = Vertex(words[i + 16], words[i + 17], words[i + 18])
                i += 21
                self.facets.append(Facet(norm, v1, v2, v3))

            self.facets.sort(key = Facet.key)
        else:
            print("Not an OpenSCAD ascii STL file")
            sys.exit(1)

    def write(self, fname):
        mins = [float('inf'), float('inf'), float('inf')]
        maxs = [float('-inf'), float('-inf'), float('-inf')]
        with open(fname,"wt") as f:
            print('solid OpenSCAD_Model', file=f)
            for facet in self.facets:
                print('  facet normal %s %s %s' % (facet.normal.dx, facet.normal.dy, facet.normal.dz), file=f)
                print('    outer loop', file=f)
                for vertex in facet.vertices:
                    print('      vertex %s %s %s' % (vertex.x, vertex.y, vertex.z), file=f)
                    for i in range(3):
                        ordinate = vertex.key[i]
                        if ordinate > maxs[i]:  maxs[i] = ordinate
                        if ordinate < mins[i]:  mins[i] = ordinate
                print('    endloop', file=f)
                print('  endfacet', file=f)
            print('endsolid OpenSCAD_Model', file=f)
        return mins, maxs

def canonicalise(fname):
    stl = STL(fname)
    return stl.write(fname)

if __name__ == '__main__':
    if len(sys.argv) == 2:
        canonicalise(sys.argv[1])
    else:
        print("\nusage:\n\t c14n_stl file - Canonicalise an STL file created by OpenSCAD.")
        sys.exit(1)
