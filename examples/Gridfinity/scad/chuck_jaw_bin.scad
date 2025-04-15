include <NopSCADlib/core.scad>
use <NopSCADlib/utils/chamfer.scad>

use <NopSCADlib/printed/gridfinity.scad>

box = gridfinity_bin("chuck_jaw_bin", 1, 1, 5);

box_mm = gridfinity_bin_size_mm(box);

bwall = 1;

length = 37;
width = 34;


z_bot = gridfinity_base_z() + bwall;

depth = box_mm.z - z_bot;

module chuck_jaw_bin_stl()
    gridfinity_bin(box)
        translate_z(box_mm.z) {
            cube([length, width, depth * 2], true);

            chamfer = 1;

            chamfer_hole(chamfer)
                square([length, width], true);

            *hull() {
                rounded_rectangle([length + 2 * chamfer, width + 2 * chamfer, eps], chamfer);

                translate_z(-chamfer + eps / 2)
                    cube([length, width, eps], true);
            }
        }
