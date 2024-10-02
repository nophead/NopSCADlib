//
// NopSCADlib Copyright Chris Palmer 2024
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
//! A rod end, sometimes called a spherical bearing or rod-end eye, is a component used in mechanical systems to create a flexible connection between two parts.
//
include <../utils/core/core.scad>
include <../utils/thread.scad>

function rod_end_bearing_bore(type)          = type[1];    //! radius of the  bore hole in the bearing
function rod_end_bearing_od(type)            = type[2];    //! Outer diameter of the bearing
function rod_end_bore_width(type)            = type[3];    //! Width
function rod_end_bearing_width(type)         = type[4];    //! Width
function rod_end_bearing_shield_colour(type) = type[5];    //! Shield colour, "silver" for metal
function rod_end_screw_radius(type)          = type[6] / 2;//! radius of the screw end, not the bore
function rod_end_sphere_seg_width(type)      = type[7];    //! the width of the pivoting part, effectively a (sphere - sphereCaps - center bore)
function rod_end_sphere_radius(type)         = type[8];    //!radius of the rod end sphere
function rod_end_screw_length(type)          = type[9];    //! length of the screw from eye center, not the bore
function rod_end_thread_length(type)         = type[10];   //! length of the threads
function rod_end_overall_length(type)        = type[11];   //!  overall length of the rod end
function rod_end_bearing_rim(type)           = type[12];   //! Outer rim thickness guesstimate

module rod_end_bearing(type) {  //! Draw a rod end bearing

    bb_bore = rod_end_bearing_bore(type);
    bb_od = rod_end_bearing_od(type);
    bb_rim = rod_end_bearing_rim(type);

    bb_width = rod_end_bearing_width(type);
    bb_shield_colour = rod_end_bearing_shield_colour(type);
    length = rod_end_screw_length(type);
    sphere_rad = rod_end_sphere_radius(type) / 2;
    rod_end_sphere_seg_width= rod_end_sphere_seg_width(type);
    shaft_rad = rod_end_screw_radius(type) - eps;
    thread_rad = rod_end_screw_radius(type);
    thread = rod_end_thread_length(type); //length - bb_od/2;
    thread_offset = 0;
    thread_d = 2 * thread_rad;
    pitch = metric_coarse_pitch(thread_d);
    colour =  grey(80);
    shield_width=bb_width - (bb_width < 5 ? 0.5 : 1);
    chamfer = bb_rim / 6;

    description = str("Rod End Bearing ", type[1], length < 10 ? " x  " : " x ", length, "mm");
    vitamin(str("Rod End Bearing(", type[0], ", ", length, "): ", description));

    module shaft(socket = 0, headless = false) {
        shank  = length;

        if(show_threads && pitch)
            translate_z(-length - thread_offset)
                male_metric_thread(thread_d, pitch, thread, false, top = headless ? -1 : 0, solid = !headless, colour = colour);
        else
            color(colour * 0.9)
                rotate_extrude() {
                    translate([0, -length - thread_offset])
                        square([thread_rad - eps, thread ]);
                }
    }

    module bearingEye() {
        color(colour)
            rotate_extrude()
                difference() {
                    circle(r = sphere_rad);

                    translate(v = [0, -sphere_rad])
                        square(size = sphere_rad * 2);

                    for(i=[0, 1])
                        mirror(v = [0, i])
                            translate(v = [-sphere_rad,rod_end_sphere_seg_width / 2])
                                square(size = sphere_rad * 2);

                    square([bb_bore, rod_end_sphere_seg_width + 1], center = true);
                }

        color(bb_shield_colour)
            rotate_extrude()
                difference() {
                    translate([0, -shield_width / 2])
                        square([bb_od / 2 - bb_rim,shield_width]);

                    circle(r = sphere_rad);
                }

        color(colour) {
            rotate_extrude()
                hull() {
                    or = bb_od / 2;
                    h = bb_width;
                    translate([or - bb_rim, -h / 2 + chamfer])
                        square([bb_rim, h - 2 * chamfer]);

                    translate([or - bb_rim, -h / 2])
                        square([bb_rim - chamfer, h]);
                }

            translate_z(-bb_width/2+chamfer)
                linear_extrude(bb_width-chamfer*2)
                    difference() {
                        hull() {
                            circle(r = bb_od/2);
                            translate([length-thread,-shaft_rad])
                            square([0.5,shaft_rad*2]);
                        }
                        circle(r = bb_od/2-bb_rim);
                    }
        }
    }



    shaft();

    rotate([0,90,0])
        bearingEye();
}
