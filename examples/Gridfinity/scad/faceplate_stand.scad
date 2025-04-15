include <NopSCADlib/core.scad>

use <NopSCADlib/printed/gridfinity.scad>
use <NopSCADlib/utils/maths.scad>
use <NopSCADlib/utils/chamfer.scad>

tool_size = 8;

box = gridfinity_bin("faceplate_stand", 3, 1, 5);

faceplate = [112, 16, 17];
sanding_disc = [69, 6.7, 14.5];

discs = [faceplate, sanding_disc];

box_mm = gridfinity_bin_size_mm(box);
wall = 1.8;
bwall = 1;
clearance = 0.5;

gap = (box_mm.y - sumv([for(b = discs) b.z])) / (len(discs) + 1);

module holes() {
    for(i = [0 : len(discs) - 1]) let($d = discs[i])
        translate([0, box_mm.y / 2 - gap - (i ? discs[0].z + gap : 0) - $d.z / 2])
            children();
}

module faceplate_stand_stl()
    gridfinity_bin(box) union() {
        holes() {
            $fa = 1;
            r = $d.x / 2 + clearance / 2;
            z = gridfinity_base_z() + bwall + r;
            translate_z(z)
                rotate([90, 0, 0])
                    teardrop_plus(r = r, h = $d.y + clearance, center = true);

            chamfer = 1;
            h = z - box_mm.z + wall;
            translate_z(box_mm.z)
                chamfer_hole(chamfer)
                    square([2 * sqrt(sqr(r) - sqr(h)), $d.y + clearance], true);
        }
        difference() {
            translate_z(gridfinity_base_z() + bwall)
                rounded_rectangle([box_mm.x - 2 * wall, box_mm.y - 2 * wall, box_mm.z - gridfinity_base_z() - bwall - wall], gridfinity_corner_r() - wall);

            holes() {
                r = $d.x / 2 + clearance / 2;
                translate_z(gridfinity_base_z() + bwall + r)
                    rotate([90, 0, 0])
                        teardrop_plus(r = r + wall, h = $d.y + clearance + 2 * wall);
            }
        }
    }
