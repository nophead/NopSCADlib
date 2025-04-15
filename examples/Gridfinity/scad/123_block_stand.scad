include <NopSCADlib/core.scad>

use <NopSCADlib/printed/gridfinity.scad>
use <NopSCADlib/utils/maths.scad>
use <NopSCADlib/utils/chamfer.scad>

tool_size = 8;

box = gridfinity_bin("123_block_stand", 2, 2, 5);

123_block = inch([3, 1, 2]);

102040_block = [20, 10, 40];

blocks = [123_block, 123_block, 102040_block];

box_mm = gridfinity_bin_size_mm(box);
wall = 1.75;
bwall = 1;
clearance = 0.5;

gap = (box_mm.y - sumv([for(b = blocks) b.y])) / (len(blocks) + 1);

module holes() {
    let($b = blocks[0])
        translate([0, box_mm.y / 2 - gap - $b.y / 2])
            children();

    let($b = blocks[1])
        translate([0, box_mm.y / 2 - gap - blocks[0].y - gap - $b.y / 2])
            children();

    for(side = [-1, 1])
        let($b = blocks[2])
            translate([side * (blocks[2].x + 2 * gap) / 2,
                       box_mm.y / 2 - gap - blocks[0].y - gap - blocks[1].y - gap - blocks[2].y / 2 ])
                children();
}

module 123_block_stand_stl()
    gridfinity_bin(box) union() {
        holes() {
            translate_z(gridfinity_base_z() + bwall + $b.z / 2 + eps)
                cube([$b.x + clearance, $b.y + clearance, $b.z + 2 * eps], true);

            chamfer = 1;
            translate_z(box_mm.z)
                chamfer_hole(chamfer)
                    square([$b.x + clearance, $b.y + clearance], true);
        }
        translate_z(gridfinity_base_z() + bwall)
            difference() {
                rounded_rectangle([box_mm.x - 2 * wall, box_mm.y - 2 * wall, box_mm.z - gridfinity_base_z() - bwall - wall], gridfinity_corner_r() - wall);

                holes()
                    rounded_rectangle([$b.x + clearance + 2 * wall, $b.y + clearance + 2 * wall, 100], wall, center = true);
            }
    }
