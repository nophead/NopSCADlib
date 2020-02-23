include <NopSCADlib/core.scad>
include <screws.scad>
include <nuts.scad>


module extrusion20InnerCornerBracket(grubScrews = true) { //! Inner corner bracket for 20mm extrusion
    vitamin(str("extrusion20InnerCornerBracket(): Extrusion20 inner corner bracket"));

    size = [25, 25, 4.5];
    armLength = size.x;
    bottomTabOffset = 4;
    topTabOffset = 10;
    sizeBottom = [armLength - bottomTabOffset, 6, size.z];
    sizeTop = [armLength - topTabOffset, 6, size.z];
    tabSizeY1 = 10;
    tabSizeY2 = 6;
    tabSizeZ = 3.25;
    holeRadius = M4_tap_radius;

    translate([-size.z - 0.75, -size.z - 0.75, 0])
        rotate([-90, 0, 0]) {
            color("silver") {
                translate([(armLength + bottomTabOffset) / 2, 0, tabSizeZ])
                    rotate([0, 180, 0])
                        extrusionSlidingNut(sizeBottom, tabSizeY1, tabSizeY2, tabSizeZ, holeRadius, (bottomTabOffset - armLength) / 2 + 5);
                translate([tabSizeZ, 0, (armLength + topTabOffset) / 2])
                    rotate([0, -90, 0])
                        extrusionSlidingNut(sizeTop, tabSizeY1, tabSizeY2, tabSizeZ, holeRadius,-(topTabOffset - armLength) / 2 - 5);
                translate([0, -size.z / 2, 0]) {
                    cube([bottomTabOffset, size.z, size.z]);
                    cube([size.z, size.z, topTabOffset]);
                }
            }
            if(grubScrews)
                not_on_bom() no_explode() {
                    grubScrewLength = 6;
                    for(angle = [[0, 0, 0], [0, -90, 180]])
                        rotate(angle)
                            translate([armLength - 5, 0, size.z])
                                screw(M3_grub_screw, grubScrewLength);
                }
        }
}

function extrusion20CornerBracket_base_thickness() = 2;
function extrusion20CornerBracket_hole_offset() = 19.5;

module extrusion20CornerBracket() { //! Corner bracket for 20mm extrusion
    vitamin(str("extrusion20CornerBracket(): Extrusion20 corner bracket"));

    eSize = 20;
    cbSize = 28;
    baseThickness = extrusion20CornerBracket_base_thickness();

    module base() {
        linear_extrude(baseThickness)
            difference() {
                translate([0, -eSize / 2, 0])
                    square([cbSize, eSize]);
                hull() {
                    translate([extrusion20CornerBracket_hole_offset() + 1.5, 0, 0])
                        circle(r = M5_clearance_radius);
                    translate([extrusion20CornerBracket_hole_offset() - 1.5, 0, 0])
                        circle(r = M5_clearance_radius);
                }
            }
    }

    color("silver") {
        rotate([90, 0, 90])
            base();
        translate([0, baseThickness, 0])
            rotate([90, 0, 0])
                base();
        sideThickness = 3;
        for(z = [-eSize / 2, eSize / 2 - sideThickness]) {
            translate_z(z) {
                right_triangle(cbSize, cbSize, sideThickness, center = false);
                cube([5, cbSize, sideThickness]);
                cube([cbSize, 5, sideThickness]);
            }
        }
    }
}

module extrusion20CornerBracket_hole_positions() { //! Place children at hole positions
    for(angle = [ [0, 90, 0], [-90, -90, 0] ])
        rotate(angle)
            translate([0, extrusion20CornerBracket_hole_offset(), extrusion20CornerBracket_base_thickness()])
                children();
}

module extrusion20CornerBracket_assembly(part_thickness = 2, screw_type = M4_cap_screw, nut_type = M4_sliding_t_nut, max_screw_depth = 6) { //! Assembly with fasteners in place
    extrusion20CornerBracket();

    screw_washer_thickness = washer_thickness(screw_washer(screw_type));
    nut_washer_type = nut_washer(nut_type);
    nut_washer_thickness = nut_washer_type ? washer_thickness(nut_washer_type) : 0;

    nut_offset = extrusion20CornerBracket_base_thickness() + part_thickness;
    screw_length = max_screw_depth ? screw_shorter_than(extrusion20CornerBracket_base_thickness() + screw_washer_thickness + max_screw_depth)
                                   : screw_longer_than(nut_offset + screw_washer_thickness + nut_washer_thickness + nut_thickness(nut_type));

    extrusion20CornerBracket_hole_positions() {
        screw_and_washer(screw_type, screw_length);
        translate_z(-nut_offset)
            vflip()
                if(nut_washer_type)
                    nut_and_washer(nut_type);
                else
                    rotate(90)
                        sliding_t_nut(nut_type);
    }
}

