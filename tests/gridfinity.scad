//
// NopSCADlib Copyright Chris Palmer 2025
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
include <../core.scad>

include <../printed/gridfinity.scad>

use <../utils/chamfer.scad>

box = gridfinity_bin("chuck_stand", 2, 2, 5);

box_mm = gridfinity_bin_size_mm(box);

bwall = 1;

chuck_d = 80;
ring_od = 50;
ring_id = 40;
ring_h = 4;

hole_pitch = (60 + 72.5) / 2;
hole_d = (72.5 - 60) / 2;
hole_depth = 15;
clearance = 0.5;
chamfer = 1;

z_bot = gridfinity_base_z() + bwall;

module chuck_stand_stl()
    gridfinity_bin(box) union() {
        translate_z(z_bot) {
            for(a = [0 : 30 : 330])
                rotate(a)
                    translate([0, hole_pitch / 2]) {
                        poly_cylinder(hole_d / 2 + clearance / 2, h = 100);

                        translate_z(hole_depth)
                            chamfer_hole(chamfer)
                                poly_circle(hole_d / 2 + clearance / 2);
                    }

            translate_z(hole_depth) {
                poly_cylinder(r = chuck_d / 2 + clearance / 2, h = 100);

                poly_tube(or = ring_od / 2 + clearance, ir = ring_id / 2 - clearance, h = 2 * ring_h, center = true);

                chamfer_hole(chamfer)
                    poly_circle(ring_od / 2 + clearance);
            }


        }
        translate_z(box_mm.z)
            chamfer_hole(chamfer)
                poly_circle(r = chuck_d / 2 + clearance / 2);
    }

module gridfinity_test()
    stl_colour(pp1_colour) chuck_stand_stl();

gridfinity_test();
