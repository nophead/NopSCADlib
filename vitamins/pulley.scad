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
//! Timing belt pulleys, both toothed and plain with internal bearings for idlers.
//
include <../utils/core/core.scad>

use <screw.scad>
use <belt.scad>
use <../utils/round.scad>

function pulley_type(type)             = type[1];  //! Part description
function pulley_teeth(type)            = type[2];  //! Number of teeth
function pulley_od(type)               = type[3];  //! Outer diameter
function pulley_belt(type)             = type[4];  //! Belt type
function pulley_width(type)            = type[5];  //! Width of teeth / belt channel
function pulley_hub_dia(type)          = type[6];  //! Hub diameter
function pulley_hub_length(type)       = type[7];  //! Hub length
function pulley_bore(type)             = type[8];  //! Bore diameter for shaft
function pulley_flange_dia(type)       = type[9];  //! Flange diameter
function pulley_flange_thickness(type) = type[10]; //! Flange thickness
function pulley_screw_length(type)     = type[11]; //! Grub screw length
function pulley_screw_z(type)          = type[12]; //! Grub screw position
function pulley_screw(type)            = type[13]; //! Grub screw type
function pulley_screws(type)           = type[14]; //! Number of grub screws

function pulley_ir(type)     = pulley_od(type) / 2 - (pulley_teeth(type) ? belt_tooth_height(pulley_belt(type)) : 0);   //! Inside radius of the teeth
function pulley_pr(type, belt = undef) = let(belt = is_undef(belt) ? pulley_belt(type) : belt)      //! Pitch radius, `belt` only needed for non-standard belt over smooth pulleys
                                 pulley_teeth(type) ? pulley_teeth(type) * belt_pitch(belt) / 2 / PI
                                                    : pulley_ir(type) + belt_thickness(belt) - belt_pitch_height(belt);

function pulley_offset(type) = -pulley_hub_length(type) - pulley_flange_thickness(type) - pulley_width(type) / 2; //! Offset of the belt path centre
function pulley_height(type) = pulley_hub_length(type) + 2 * pulley_flange_thickness(type) + pulley_width(type); //! Total height of pulley
function pulley_extent(type) = max(pulley_flange_dia(type), pulley_hub_dia(type)) / 2;                          //! Largest diameter

T_angle = 40;
GT_r = 0.555;

module pulley(type, colour = silver) { //! Draw a pulley, any children are placed above.
    teeth = pulley_teeth(type);
    od = pulley_od(type);

    vitamin(str("pulley(", type[0], "): Pulley ", pulley_type(type), pulley_screws(type) ? " " : " idler ", teeth ? str(teeth, " teeth") : str("smooth ", od, "mm")));

    ft = pulley_flange_thickness(type);
    tw = pulley_od(type) * PI / (teeth * 2);
    hl = pulley_hub_length(type);
    w = pulley_width(type);
    r1 = pulley_bore(type) / 2;
    screw_z = pulley_screw_z(type);

    or =  od / 2;
    ir =  pulley_ir(type);
    $fa  = fa; $fs = fs;
    module core() {
        translate_z(pulley_hub_length(type) + ft)
            linear_extrude(w)
                 difference() {
                    circle(or);

                    circle(r1);

                    for(i = [0 : 1 : teeth - 1])
                        rotate(i * 360 / teeth)
                            if(pulley_type(type)[0] == "G")
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
    }

    module hub()
        rotate_extrude() translate([r1, 0]) {
            if(hl)
                square([pulley_hub_dia(type) / 2 - r1,  hl]);

            for(z = [pulley_hub_length(type), hl + ft + w])
                translate([0, z])
                    square([pulley_flange_dia(type) / 2 - r1, ft]);
        }

    module screw_holes()
        translate_z(screw_z)
            for(i = [0 : pulley_screws(type) - 1])
                rotate([-90, 0, i * -90])
                    cylinder(r = screw_radius(pulley_screw(type)), h = 100);

    color(colour) {
        if(screw_z && screw_z < hl)
            render()
                difference() {
                    hub();

                    screw_holes();
                }
        else
            hub();

        if(screw_z && screw_z > hl) // T5 pulleys have screw through the teeth
            render()
                difference() {
                    core();

                    screw_holes();
                }
        else
            core();
    }

    if($children)
        translate_z(pulley_height(type))
            children();
}

module pulley_assembly(type, colour = silver) { //! Draw a pulley with its grub screws in place
    translate_z(pulley_offset(type)) {
        pulley(type, colour);

        if(pulley_screws(type))
            translate_z(pulley_screw_z(type))
                for(i = [0 : pulley_screws(type) - 1])
                    rotate([-90, 0, i * -90])
                        translate_z(pulley_bore(type) / 2 + pulley_screw_length(type))
                            screw(pulley_screw(type), pulley_screw_length(type));
    }
}
