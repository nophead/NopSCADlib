//
// NopSCADlib Copyright Chris Palmer 2024
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
//! 45 degree chamfer the entrance to holes.
//!
//! If the hole shape is concave then it must be described as a list of 2D convex children.
//
include <core/core.scad>

module chamfer_hole(depth = 1) {    //! Chamfer a hole given a 2D outline as a child
    for(i = [0 : $children - 1])
        hull() {
            linear_extrude(eps)
                offset(depth)
                    children(i);

            translate_z(-depth)
                linear_extrude(eps)
                    children(i);
        }
}
