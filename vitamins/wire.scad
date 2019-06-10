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
//! Wires. Just a BOM entry at the moment and cable bundle size fuctions for holes. See
//! <http://mathworld.wolfram.com/CirclePacking.html>.
//
include <../core.scad>
include <zipties.scad>

module wire(color, strands, length, strand = 0.2)
    vitamin(str(": Wire ", color, " ", strands, "/", strand, "mm strands, length ",length, "mm"));

module ribbon_cable(ways, length)
    vitamin(str(": Ribbon cable ", ways, " way ", length, "mm"));

//
// Cable sizes
//
function cable_wires(cable)     = cable[0];
function cable_wire_size(cable) = cable[1];

// numbers from http://mathworld.wolfram.com/CirclePacking.html
function cable_radius(cable) = ceil([0, 1, 2, 2.15, 2.41, 2.7, 3, 3, 3.3][cable_wires(cable)] * cable_wire_size(cable)) / 2; // radius of a bundle

function wire_hole_radius(cable) = cable_radius(cable) + 0.5;

// arrangement of bundle in flat cable clip
function cable_bundle(cable) = [[0,0], [1,1], [2,1], [2, 0.5 + sin(60)], [2,2], [3, 0.5 + sin(60)], [3,2]][cable_wires(cable)];

function cable_width(cable)  = cable_bundle(cable)[0] * cable_wire_size(cable); // width in flat clip
function cable_height(cable) = cable_bundle(cable)[1] * cable_wire_size(cable); // height in flat clip

module mouse_hole(cable, h = 100) {
    r = wire_hole_radius(cable);

    rotate(90) slot(r, 2 * r, h = h);
}

module cable_tie_holes(cable_r, h = 100) {
    r = cnc_bit_r;
    l = 3;
    extrude_if(h)
        for(side = [-1, 1])
            translate([0, side * (cable_r + r)])
                hull()
                    for(end = [-1, 1])
                        translate([end * (l / 2 - r), 0])
                            drill(r, 0);
}

module cable_tie(cable_r, thickness) {
    w =  2 * (cable_r + cnc_bit_r);
    translate_z(thickness / 2)
        rotate([-90, 0, 90])
            ziptie(small_ziptie, w / 2);
}

//cable_tie_holes(6 / 2);
//cable_tie(6 / 2, 3);
