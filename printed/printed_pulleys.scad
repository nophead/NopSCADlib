//
// NopSCADlib Copyright Chris Palmer 2020
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
//! Printed pulleys are a remix of droftarts's (see <https://www.thingiverse.com/droftarts/designs>) Parametric Pulleys
//! on Thingiverse (see <https://www.thingiverse.com/thing:16627>) and are licensed under the
//! Creative Commons - Attribution - Share Alike license (see <https://creativecommons.org/licenses/by-sa/3.0/>)
//

include <../core.scad>
include <../vitamins/pulleys.scad>

printed_pulley_GT2_profile = [[0.747183,-0.5],[0.747183,0],[0.647876,0.037218],[0.598311,0.130528],[0.578556,0.238423],[0.547158,0.343077],[0.504649,0.443762],[0.451556,0.53975],[0.358229,0.636924],[0.2484,0.707276],[0.127259,0.750044],[0,0.76447],[-0.127259,0.750044],[-0.2484,0.707276],[-0.358229,0.636924],[-0.451556,0.53975],[-0.504797,0.443762],[-0.547291,0.343077],[-0.578605,0.238423],[-0.598311,0.130528],[-0.648009,0.037218],[-0.747183,0],[-0.747183,-0.5]];

function printed_pulley_inverted(type) = pulley_hub_dia(type) < pulley_flange_dia(type); //! Need to print upside down to prevent overhang

function printed_pulley_od(tooth_count, tooth_pitch, pitch_line_offset)
    = tooth_count * tooth_pitch / PI - 2 * pitch_line_offset;

module printed_pulley_teeth_from_profile(tooth_count, tooth_depth, tooth_width, tooth_profile) {
    pulley_od = printed_pulley_od(tooth_count, 2, 0.254);

    difference() {
        rotate (90 / tooth_count)
            circle(r = pulley_od / 2, $fn = tooth_count * 4);
        tooth_distance_from_centre = sqrt(pulley_od * pulley_od - (tooth_width + 0.2) * (tooth_width + 0.2)) / 2;
        for(i = [1 : tooth_count])
            rotate(i * 360 / tooth_count)
                translate([0, -tooth_distance_from_centre])
                    scale([(tooth_width + 0.2) / tooth_width, 1])
                        polygon(tooth_profile);
    }
}

module printed_pulley_GT2_teeth(type) {
    tooth_count = pulley_teeth(type);
    if (tooth_count == 0)
        circle(r = pulley_od(type) / 2);
    else
        printed_pulley_teeth_from_profile(tooth_count, 0.764, 1.494, printed_pulley_GT2_profile);
}


module printed_pulley_teeth(type) { //! Draw the pulley's teeth
    tooth_count = pulley_teeth(type);
    tw = pulley_od(type) * PI / (tooth_count * 2);
    ir = pulley_ir(type);
    or = pulley_od(type) / 2;

    T_angle = 40;
    GT_r = 0.555;
    for (i = [0 : 1 : tooth_count - 1])
        rotate(i * 360 / tooth_count)
            if (pulley_type(type)[0] == "G")
                translate([0, ir + GT_r])
                    hull() {
                        circle(GT_r);
                        translate([0, GT_r])
                            square(2 * GT_r, center = true);
                    }
            else
                translate([0, (ir + or) / 2])
                    hull() {
                        for(side = [-1, 1])
                            translate([side * tw / 2, 0])
                                rotate(-side * T_angle / 2)
                                    square([eps, (or - ir)], center = true);

                        translate([0, 1])
                            square([tw, eps], center = true);
                    }
}

module printed_pulley(type) { //! Draw a printable pulley
    ft = pulley_flange_thickness(type);
    hl = pulley_hub_length(type);
    w = pulley_width(type);
    r1 = pulley_bore(type) / 2;
    or = pulley_od(type) / 2;
    screw_z = pulley_screw_z(type);


    module core() {
        translate_z(pulley_hub_length(type) + ft)
            linear_extrude(w + 1) let($fa  = 1, $fs = 0.1)
                if ("GT2" == str(pulley_type(type)[0], pulley_type(type)[1], pulley_type(type)[2]))
                    difference() {
                        printed_pulley_GT2_teeth(type);
                        circle(d = pulley_bore(type));
                    }
                else
                    difference() {
                        circle(or);
                        printed_pulley_teeth(type);
                        circle(d = pulley_bore(type));
                    }
    }

    module screw_holes() {
        if(pulley_screws(type))
            translate_z(screw_z)
                for(i = [0 : pulley_screws(type) - 1])
                    rotate([-90, 180, i * -90])
                        if(show_supports())
                            teardrop(r = screw_pilot_hole(pulley_screw(type)), h = pulley_flange_dia(type) / 2 + 1, center = false);
                        else
                            cylinder(r = screw_radius(pulley_screw(type)), h = pulley_flange_dia(type) / 2 + 1);
    }

    module hub()
        linear_extrude(hl)
            difference() {
                circle(d= pulley_hub_dia(type));
                circle(d = pulley_bore(type));
            }

    stl(str("printed_pulley_", type[0]))
        translate_z(printed_pulley_inverted(type) ? - hl : 0) {
            // hub
            if(hl)
                translate_z(printed_pulley_inverted(type) ? hl + w + 2 * ft : 0)
                    if(screw_z && screw_z < hl)
                        render()
                            difference() {
                                hub();

                                screw_holes();
                            }
                    else
                        hub();

            // bottom flange
            translate_z(hl)
                linear_extrude(ft)
                    difference() {
                        circle(d = pulley_flange_dia(type));
                        circle(d = pulley_bore(type));
                    }

            // top flange
            translate_z(hl + ft + w) {
                // inner part, supported by core
                linear_extrude(ft)
                    difference() {
                        circle(r = or);
                        circle(d = pulley_bore(type));
                    }
                // outer part at 45 degrees for printing
                rotate_extrude()
                    translate([or - eps, ft])
                        vflip()
                            right_triangle(ft, ft);
            }

            if(screw_z && screw_z > hl)
                render()
                    difference() { // T5 pulleys have screws through the teeth
                        core();

                        translate_z(printed_pulley_inverted(type) ? pulley_height(type) + hl - 2 * screw_z : 0)
                            screw_holes();
                    }
                else
                    core();
        }
}

module printed_pulley_assembly(type, colour = pp1_colour) //! Draw a printed pulley with its grub screws in place
assembly(str("printed_pulley_", type[0]), ngb = true) {
    translate_z(pulley_offset(type)) {
        stl_colour(colour)
            if(printed_pulley_inverted(type))
                translate_z(pulley_height(type))
                    hflip()
                        printed_pulley(type);
            else
                printed_pulley(type);

        if(pulley_screws(type))
            translate_z(pulley_screw_z(type))
                for(i = [0 : pulley_screws(type) - 1])
                    rotate([-90, 0, i * -90])
                        translate_z(pulley_bore(type) / 2 + pulley_screw_length(type))
                            screw(pulley_screw(type), pulley_screw_length(type));
    }
}
