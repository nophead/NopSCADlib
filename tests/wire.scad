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
use <../utils/sweep.scad>
use <../utils/bezier.scad>

use <../vitamins/wire.scad>

twist_len = 25; // [5 : 50]
wires = 7; // [1 : 7]
irot = -60; // [-90 : 0]

/* [Hidden] */
wire_d = 1.4;
bundle = cable(wires, wire_d);
bundle_r = cable_radius(bundle);

thickness = 2;
w = 60;
d = 20;
h = 10;
wire_l = 60;
mouse_y = 10;
cable_pitch = 7;

module wires() {
    translate([0, mouse_y, bundle_r])
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
                    square([w, h]);

                    translate([mouse_y, 0])
                        mouse_hole(bundle, 0, true);

                    for(i = [1 : 6])
                        let(cable = cable(i, wire_d), bundle = cable_bundle(cable))
                            translate([mouse_y + cable_pitch * i - bundle.x / 2, -eps])
                                square([bundle.x, bundle.y]);
                }

        translate_z(-thickness)
            linear_extrude(thickness)
                difference() {
                    translate([thickness -d, 0])
                        square([d, w]);

                    translate([-15, mouse_y])
                        cable_tie_holes(bundle_r, 0);
                }
    }

    translate([-15, mouse_y])
        cable_tie(bundle_r, thickness);

    for(i = [1 : 6]) let(cable = cable(i, wire_d, [grey(10), "blue", "red", "orange", "yellow", "green"], tlen = twist_len))
        translate([0, mouse_y + cable_pitch * i]) {
            tr = cable_twisted_radius(cable);
            bend_r = 5;
            x = -d + thickness - bend_r;
            path = [
                        [-5, 0, tr],
                        [x,  0, tr],
                bend_r, [x,  0, -25]
            ];
            rpath = rounded_path(path);
            tpaths = twisted_cable(cable, rpath, irot = irot, frot = -irot);
            positions = cable_bundle_positions(cable);

            ends = [for(p = positions) [[30, p.x, p.y], [0, p.x, p.y]]];
            paths = [for(i = [0 : len(tpaths) - 1]) bezier_join(ends[i], tpaths[i], 1.3, 3)];
            cable(cable, paths, $fs = fs, $fa = fa);
        }
}

if($preview)
    wires();
