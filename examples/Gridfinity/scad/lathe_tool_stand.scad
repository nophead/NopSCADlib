include <NopSCADlib/core.scad>

use <NopSCADlib/printed/gridfinity.scad>
use <NopSCADlib/utils/chamfer.scad>

tool_size = 8;

rows = 2;
cols = 5;
spacing = 8;

hole = tool_size + 0.2;

tool_pitch = hole + spacing;

box = gridfinity_bin("lathe_tool_stand", 2, 1, 5);

module holes()
    for(x = [0 : cols - 1], y = [0 : rows - 1])
        translate([x - (cols -1) / 2, y - (rows - 1) / 2] * tool_pitch)
            children();

box_mm = gridfinity_bin_size_mm(box);
wall = 1.75;
bwall = 1;

module lathe_tool_stand_stl()
    gridfinity_bin(box) union() {
        translate_z(box_mm.z)
            holes() {
                cube([hole, hole, 2 * (box_mm.z - gridfinity_base_z() - bwall)], true);

                chamfer = 1;
                chamfer_hole(chamfer)
                    square([hole, hole], true);
            }

        translate_z(gridfinity_base_z() + bwall)
            difference() {
                rounded_rectangle([box_mm.x - 2 * wall, box_mm.y - 2 * wall, box_mm.z - gridfinity_base_z() - bwall - wall], gridfinity_corner_r() - wall);

                holes()
                    rounded_rectangle([hole + 2 * wall, hole + 2 * wall, 100], wall, center = true);
            }
    }
