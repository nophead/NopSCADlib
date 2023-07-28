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

//
//! Parametric green terminal blocks
//
include <../utils/core/core.scad>
use <../utils/tube.scad>
use <../utils/pcb_utils.scad>

function gt_pitch(type)        = type[1];   //! Pitch between terminals
function gt_depth(type)        = type[2];   //! Total front to back depth
function gt_height(type)       = type[3];   //! Height of the flat top
function gt_top(type)          = type[4];   //! Depth at the top
function gt_front_height(type) = type[5];   //! Height at the front
function gt_front_depth(type)  = type[6];   //! Front ledge depth
function gt_back_height(type)  = type[7];   //! Height at the back
function gt_back_depth(type)   = type[8];   //! Back ledge depth
function gt_screw_r(type)      = type[9];   //! Screw head radius
function gt_front_t(type)      = type[10];  //! Thickness of frame around the front aperture
function gt_box_w(type)        = type[11];  //! Width inside the cable entry box
function gt_box_h(type)        = type[12];  //! Height of the cable entry box
function gt_box_setback(type)  = type[13];  //! How far the contact box is set back from the front
function gt_y_offset(type)     = type[14];  //! Offset of the pins from centre of the depth
function gt_y_offset2(type)    = type[15];  //! Offset of the pins from the screws
function gt_tube_h(type)       = type[16];  //! Height of optional tubes around the screws

module green_terminal(type, ways, skip = [], colour = "lime") { //! Draw green terminal blocks, skip can be used to remove pins.
    pitch = gt_pitch(type);
    imperial = str(pitch / inch(1));
    vitamin(str("green_terminal(", type[0], ", ", ways, "): Terminal block ", ways, " way ", len(imperial) < 5 ? str(pitch / inch(1), "\"") : str(pitch, "mm")));
    width = ways * pitch;
    depth = gt_depth(type);
    height = gt_height(type);
    ledge_height =  gt_front_height(type);
    ledge_depth = gt_front_depth(type);
    top = gt_top(type);
    back = gt_back_height(type);
    back_ledge = gt_back_depth(type);
    tube_h = gt_tube_h(type);
    module single(skip = false) {
        screw_r = gt_screw_r(type);
        box_w1 = pitch - 2 * gt_front_t(type);
        box_h1 = ledge_height - 2 * gt_front_t(type);
        box_w2 = gt_box_w(type);
        box_h2 = gt_box_h(type);
        y = gt_y_offset(type);
        y2 = gt_y_offset2(type);
        box_front = y + depth / 2 - gt_box_setback(type);
        box_back = y - depth / 2 + 1;

        module horizontal_section()
            difference() {
                translate([y, 0])
                    square([depth, pitch], center = true);

                translate([y + 1, 0])
                    square([depth, box_w2], center = true);

                translate([y + depth / 2, 0])
                    hull() {
                        square([1, box_w1], center = true);
                        square([4, box_w2], center = true);
                    }
            }

        color(colour) {
            rotate([90, 0, 0])
                linear_extrude(pitch, center = true, convexity = 5)
                    polygon(points = [                          // Vertical section
                        [y + depth / 2,                  0],
                        [y + depth / 2,                  ledge_height / 2 - box_h1 / 2],
                        [y + depth / 2 - 0.5,            ledge_height / 2 - box_h1 / 2],
                        [box_front,                      ledge_height / 2 - box_h2 / 2],
                        [box_back,                       ledge_height / 2 - box_h2 / 2],
                        [box_back,                       ledge_height / 2 + box_h2 / 2],
                        [box_front,                      ledge_height / 2 + box_h2 / 2],
                        [y + depth / 2 - 0.5,            ledge_height / 2 + box_h1 / 2],
                        [y + depth / 2,                  ledge_height / 2 + box_h1 / 2],
                        [y + depth / 2,                  ledge_height],
                        [y + depth / 2 - ledge_depth,    ledge_height],
                        [y2 + top / 2,                   height],
                        [y2 + screw_r + eps,             height],
                        [y2 + screw_r + eps,             ledge_height / 2 + box_h2 / 2],
                        [y2 - screw_r - eps,             ledge_height / 2 + box_h2 / 2],
                        [y2 - screw_r - eps,             height],
                        [y2 -top / 2,                    height],
                        [y - depth / 2 + back_ledge,     back],
                        [y - depth / 2,                  back],
                        [y - depth / 2,                  0],
                    ]);

            translate([y2, 0, ledge_height / 2 + box_h2 / 2])   // Screw socket
                linear_extrude(height - ledge_height / 2 - box_h2 / 2)
                    difference() {
                        square([screw_r * 2 + 0.1, pitch], center = true);

                        circle(screw_r);
                    }


            linear_extrude(ledge_height)
                intersection() {
                    horizontal_section();

                    translate([0, -5])
                        square([10, 10]);
                }

            linear_extrude(back)
                intersection() {
                    horizontal_section();

                    translate([-10, -5])
                        square([10, 10]);
                }

            if(tube_h)
                translate([y2, 0, height])
                    linear_extrude(tube_h - height)
                        intersection() {
                            ring(or = top / 2, ir = screw_r);

                            square([10, pitch], center = true);
                        }

        }
        if(!skip)
            color("silver") {
                slot_depth = 1;
                screw_top = height - 0.5;
                pin_l = 3.3;
                translate([y2, 0]) {
                    translate_z(screw_top - 2 * slot_depth)        // screw head
                        cylinder(r = screw_r, h = slot_depth);

                    translate_z(screw_top - slot_depth)         // screw head
                        linear_extrude(slot_depth)
                            difference() {
                                circle(screw_r);

                                square([10, screw_r / 4], center = true);
                            }
                }
                translate([box_back, 0, ledge_height / 2]) {
                    rotate([0, 90, 0])
                        linear_extrude(box_front - box_back)
                            difference() {
                                square([box_h2, box_w2], center = true);

                                square([box_h2 - 0.1, box_w2 - 0.1], center = true);

                            }

                    cube([1, box_w2, box_h2], center = true); // terminal back
                }

                translate_z(-pin_l / 2)
                    cube([0.44, 0.75, pin_l], center = true);     // pin
                solder();
            }
    }
    for(i = [0: ways - 1])
        translate([0, i * pitch - width / 2 + pitch / 2])
            single(in(skip, i));
}
