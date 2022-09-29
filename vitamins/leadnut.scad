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
//! Nuts for leadscrews.
//
include <../utils/core/core.scad>
use <../utils/tube.scad>
use <../utils/thread.scad>
use <../vitamins/screw.scad>

function leadnut_bore(type)          = type[2];     //! Thread size
function leadnut_od(type)            = type[3];     //! Outer diameter of the shank
function leadnut_height(type)        = type[4];     //! Total height
function leadnut_flange_dia(type)    = type[5];     //! Flange diameter
function leadnut_flange_t(type)      = type[6];     //! Flange thickness
function leadnut_flange_offset(type) = type[7];     //! Offset of the flange from the top
function leadnut_holes(type)         = type[8];     //! The number of screw holes
function leadnut_hole_dia(type)      = type[9];     //! The diameter of the screw holes
function leadnut_hole_pitch(type)    = type[10];    //! The radial pitch of the screw holes
function leadnut_screw(type)         = type[11];    //! The type of the fixing screws
function leadnut_pitch(type)         = type[12];    //! Screw pitch
function leadnut_lead(type)          = type[13];    //! Screw lead
function leadnut_flat(type)          = type[14];    //! Flat section width
function leadnut_colour(type)        = type[15];    //! The colour

function leadnut_shank(type)         = leadnut_height(type) - leadnut_flange_t(type) - leadnut_flange_offset(type); //! The length of the shank below the flange

function leadnuthousing_length(type)            = type[2];  //! Length of housing
function leadnuthousing_width(type)             = type[3];  //! Width of housing
function leadnuthousing_height(type)            = type[4];  //! Height of housing
function leadnuthousing_hole_pos(type)          = type[5];  //! Offset from center for nut hole
function leadnuthousing_screw_dist_l(type)      = type[6];  //! Distance between mounting holes length
function leadnuthousing_screw_dist_w(type)      = type[7];  //! Distance between mounting holes width
function leadnuthousing_mount_screw(type)       = type[8];  //! Mounting screw
function leadnuthousing_mount_screw_len(type)   = type[9];  //! Mounting screw length
function leadnuthousing_nut(type)               = type[10]; //! Nut type this is suitable for
function leadnuthousing_nut_screw_length(type)  = type[11]; //! Length of mounting screw for nut

module leadnut_screw_positions(type) { //! Position children at the screw holes
    holes = leadnut_holes(type);
    flat = leadnut_flat(type);
    angles = flat ? [let(h = holes / 2, a = 90 / (h - 1)) for(i = [0 : h - 1], side = [-1, 1]) side * (45 + i * a)]
                  : [for(i = [0 : holes - 1]) i * 360 / holes + 180];
    for(a = angles)
        rotate(a)
            translate([leadnut_hole_pitch(type), 0, leadnut_flange_t(type)])
                rotate(45)
                    children();
}

module leadnut(type) { //! Draw specified leadnut
    vitamin(str("leadnut(", type[0], "): ", type[1]));
    bore_d = leadnut_bore(type);
    bore_r = bore_d / 2;
    h = leadnut_height(type);
    pitch = leadnut_pitch(type);
    lead = leadnut_lead(type);
    flat = leadnut_flat(type);
    flange_d = leadnut_flange_dia(type);

    color(leadnut_colour(type)) vflip()
        translate_z(-leadnut_flange_offset(type) - leadnut_flange_t(type)) {
            tube(or = leadnut_od(type) / 2, ir = bore_r, h = h, center = false);

            if(show_threads)
                thread(bore_d, lead, h, thread_profile(pitch / 2, pitch * 0.366, 30), false, starts = lead / pitch, female = true, solid = false);

            translate_z(leadnut_flange_offset(type))
                linear_extrude(leadnut_flange_t(type))
                    difference() {
                        circle(d = flange_d);

                        circle(bore_r);

                        leadnut_screw_positions(type)
                            circle(d = leadnut_hole_dia(type));

                        if(flat)
                            for(side = [-1, 1])
                                translate([side * flange_d / 2, 0])
                                    square([flange_d - flat, flange_d], center = true);
                    }
        }
}

module leadnuthousing_screw_positions(type) { //! Get screw positions to mount the leadnut housing
    for(p = [[-1,-1], [1,-1], [1,1], [-1,1]])
        translate([p.x * leadnuthousing_screw_dist_l(type)/2, p.y * leadnuthousing_screw_dist_w(type)/2, 0])
            children();
}
module leadnuthousing_nut_position(type) { //! The position of the nut may be off-center, use this to get the position
    translate([leadnuthousing_hole_pos(type),0, leadnuthousing_height(type)/2])
        children();
}

module leadnuthousing_nut_screw_positions(type) { //! get screw positions to mount the nut to the nut housing
    translate([leadnuthousing_hole_pos(type),0, 0])
        leadnut_screw_positions(leadnuthousing_nut(type))
            children();
}

module leadnuthousing(type) { //! Nut housing, to connect a lead nut to another object
    vitamin(str("nuthousing(", type[0], "): ", type[1]));

    leadnut = leadnuthousing_nut(type);
    screw = leadnut_screw(leadnut);
    d = screw_radius(screw) * 2;
    p = metric_coarse_pitch(d);
    sl = leadnuthousing_nut_screw_length(type);
    ms = leadnuthousing_mount_screw(type);
    msl = leadnuthousing_mount_screw_len(type);
    md = screw_radius (ms) * 2;
    mp = metric_coarse_pitch(md);

    color("silver")
        difference() {
            cube([leadnuthousing_length(type), leadnuthousing_width(type), leadnuthousing_height(type)], center = true);
            translate([leadnuthousing_hole_pos(type),0,0]) {
                cylinder(d=leadnut_od(leadnut), h=leadnuthousing_length(type)+2, center=true);
                translate_z(leadnut_flange_offset(leadnut))
                    leadnut_screw_positions(leadnut)
                cylinder(r=screw_radius(leadnut_screw(leadnut)), h=sl+1);
            }

            rotate([0,90,0])
                leadnuthousing_screw_positions(type)
                    cylinder(r=screw_radius(ms), h=msl+1);

        }
    if(show_threads) {
        translate([leadnuthousing_hole_pos(type),0,leadnuthousing_height(type)/2 - sl/2 - leadnut_flange_t(leadnut)])
            leadnut_screw_positions(leadnut)
                female_metric_thread(d, p, sl, center = true, colour = silver);
        rotate([0,90,0])
            translate_z(msl/2)
                leadnuthousing_screw_positions(type)
                    female_metric_thread(md, mp, msl, center = true, colour = silver);
    }
}
