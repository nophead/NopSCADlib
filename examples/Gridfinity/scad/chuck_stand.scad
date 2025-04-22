include <NopSCADlib/core.scad>

use <NopSCADlib/printed/gridfinity.scad>
use <NopSCADlib/utils/chamfer.scad>

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
