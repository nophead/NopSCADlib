//
// NopSCADlib Copyright Chris Palmer 2020
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

// Link length between hinges
x = 10; //[8 : 30]

// Link inner width
y = 10; //[5 : 30]

// Link inner height
z = 5;  //[4 : 11]
// Side wall thickness
wall = 1.6; //[0.9: 0.1: 3]
// Bottom wall thickness
bwall = 1.5; //[1: 0.25: 3]
// Top wall thickness
twall = 1.5; //[1: 0.25: 3]
// Max travel in each direction
travel = 100;
// Current position
pos = 50; // [-100 : 1 : 100]

include <../core.scad>
use <../printed/drag_chain.scad>

include <../vitamins/leadnuts.scad>

drag_chain = drag_chain("x", [x, y, z], travel, wall = wall, bwall = bwall, twall = twall);

module drag_chains()
    drag_chain_assembly(drag_chain, pos);

if($preview)
    drag_chains();
else {
    drag_chain_link(drag_chain);

    translate([-x * 2, 0])
        drag_chain_link(drag_chain, start = true);

    translate([x * 2, 0])
        drag_chain_link(drag_chain, end = true);
}
