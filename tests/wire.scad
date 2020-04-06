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
include <../utils/core/core.scad>

use <../vitamins/wire.scad>

bundle = [7, 1.4];

bundle_r = cable_radius(bundle);

thickness = 2;
w = 50;
d = 20;
h = 40;
wire_l = 90;

module wires() {
    translate_z(bundle_r)
        rotate([0, 90, 0]) {
            n = cable_wires(bundle);
            d = cable_wire_size(bundle);
            if(n > 6)
                color("green") {
                    cylinder(d = d, h = wire_l, center = true);
                    wire("green", 7, wire_l);
                }

            m = n > 6 ? n - 1 : n;
            for(i = [0 : m - 1])
                rotate(i * 360 / m)
                    translate([bundle_r - d / 2, 0]) {
                        colour = ["black", "brown", "red", "orange", "yellow", "blue", "purple"][i];
                        wire(colour, 7, wire_l);
                        color(colour)
                            cylinder(d = d, h = wire_l, center = true);
                   }

            %cylinder(r = bundle_r, h = wire_l - 10, center = true);
        }

    stl_colour(pp1_colour) {
        rotate([90, 0, 90])
            linear_extrude(thickness)
                difference() {
                    translate([-w / 2, 0])
                        square([w, h]);

                    mouse_hole(bundle, 0, true);
                }

        translate_z(-thickness)
            linear_extrude(thickness)
                difference() {
                    translate([thickness -d, -w / 2])
                        square([d, w]);

                    translate([-15, 0])
                        cable_tie_holes(bundle_r, 0);
                }
    }
    translate([-15, 0])
        cable_tie(bundle_r, thickness);
}

if($preview)
    wires();
