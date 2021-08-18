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

include <../global_defs.scad>
use <../utils/tube.scad>


module tubes() {
    linear_extrude(eps)
        ring(10, 8);

    translate([50, 10])
        tube(10, 8, 30);

    translate([100, 10])
        rectangular_tube([10, 20, 30]);
}

tubes();
