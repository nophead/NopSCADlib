//
// NopSCADlib Copyright Chris Palmer 2018
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// This file is part of NopSCADlib.
//
// NopSCADlib is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of
// the License, or (at your option) any later version.
//
// NopSCADlib is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with NopSCADlib.
// If not, see <https://www.gnu.org/licenses/>.
//

//
//! Construct arbitrarily large box to partition 3D space and clip objects, useful for creating cross sections to see the inside when debugging.
//!
//! Original version by Doug Moen on the OpenSCAD forum
//
//
module box(xmin, ymin, zmin, xmax, ymax, zmax) //! Construct a box given its bounds
    polyhedron(
        [[xmin, ymin, zmin],  // 0
         [xmin, ymin, zmax],  // 1
         [xmin, ymax, zmin],  // 2
         [xmin, ymax, zmax],  // 3
         [xmax, ymin, zmin],  // 4
         [xmax, ymin, zmax],  // 5
         [xmax, ymax, zmin],  // 6
         [xmax, ymax, zmax]], // 7
        [[7,5,1,3],  // top
         [2,0,4,6],  // bottom
         [5,4,0,1],  // front
         [3,2,6,7],  // back
         [5,7,6,4],  // right
         [0,2,3,1]]  // left
    );

module clip(xmin = -big, ymin = -big, zmin = -big, xmax = big, ymax = big, zmax = big, convexity = 1) //! Clip child to specified boundaries
    render(convexity = convexity) intersection() {
        children();

        box(xmin, ymin, zmin, xmax, ymax, zmax);
    }
