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

function leadnut_shank(type)         = leadnut_height(type) - leadnut_flange_t(type) - leadnut_flange_offset(type); //! The length of the shank below the flange

module leadnut_screw_positions(type) { //! Position children at the screw holes
    holes = leadnut_holes(type);
    for(i = [0 : holes - 1], a = i * 360 / holes + 180)
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

    color("dimgrey") vflip()
        translate_z(-leadnut_flange_offset(type) - leadnut_flange_t(type)) {
            tube(or = leadnut_od(type) / 2, ir = bore_r, h = h, center = false);

            if(show_threads)
                thread(bore_d, lead, h, thread_profile(pitch / 2, pitch * 0.366, 30), false, starts = lead / pitch, female = true, solid = false);

            translate_z(leadnut_flange_offset(type))
                linear_extrude(leadnut_flange_t(type))
                    difference() {
                        circle(d = leadnut_flange_dia(type));

                        circle(bore_r);

                        leadnut_screw_positions(type)
                            circle(d = leadnut_hole_dia(type));
                    }
        }
}
