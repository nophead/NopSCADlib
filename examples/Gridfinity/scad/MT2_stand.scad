//
// Stand for MT2 taper lathe tools
//
include <NopSCADlib/core.scad>
use <NopSCADlib/utils/maths.scad>
use <NopSCADlib/utils/chamfer.scad>

use <NopSCADlib/printed/gridfinity.scad>

box = gridfinity_bin("MT2_stand", 4, 2, 8);

box_mm = gridfinity_bin_size_mm(box);
wall = 1.75;
bwall = 1;


diameters1 = [43, 47, 64];
d2 = 20;

clearance = 1;
clearance2 = 4;

MT2_base = 5; // smaller diameters
MT2_D1 = 15; // diameter at the bottom of the taper at base height
MT2_half_angle = 1.4302777777777778;

hole_depth = box_mm.z - gridfinity_base_z() - bwall;
MT2_r1 = MT2_D1 / 2;
MT2_r2 = MT2_r1 + (hole_depth - MT2_base) * tan(MT2_half_angle);

gap = (box_mm.x - sumv(diameters1) - 2 * clearance) / (len(diameters1) - 1);
gap2 = 18;

module MT2_socket() {
    clearance = 0.3;

    translate_z(-hole_depth) {
        poly_cylinder(MT2_r1 + clearance / 2, MT2_base + eps);

        translate_z(MT2_base)
            hull() {
                poly_cylinder(MT2_r1 + clearance / 2, eps);

                translate_z(hole_depth - MT2_base)
                    poly_cylinder(MT2_r2 + clearance / 2, eps);
            }
    }
    chamfer_hole(1)
        poly_circle(MT2_r2 + clearance / 2);
}

function pos(i)  = [clearance + sumv(slice(diameters1, 0, i)) + i * gap + diameters1[i] / 2 - box_mm.x / 2, box_mm.y / 2 - clearance - diameters1[i] / 2, box_mm.z];
function pos2(i) = [clearance2 + i * gap2 + (i + 0.5) * d2 - box_mm.x / 2, -box_mm.y / 2 + clearance2 + d2 / 2, box_mm.z];

module holes()
    for(i = [0 : len(diameters1) - 1]) {
        translate(pos(i))
            children();

        translate(pos2(i))
            children();
    }

module MT2_stand_stl()
    gridfinity_bin(box) union() {
        holes()
            MT2_socket();

        translate_z(gridfinity_base_z() + bwall)
            difference() {
                rounded_rectangle([box_mm.x - 2 * wall, box_mm.y - 2 * wall, box_mm.z - gridfinity_base_z() - bwall - wall], gridfinity_corner_r() - wall);

                holes()
                    cylinder(r =  MT2_r2 + wall, h = 200, center = true);

                for(x = [-box_mm.x / 2 : 20 :  box_mm.x /2])
                    translate([x, 0])
                        cube([squeezed_wall, 200, 200], center = true);
            }
    }
