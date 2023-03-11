//
// NopSCADlib Copyright Chris Palmer 2023
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
//! Photo interrupter modules popular in robot kits and from China.
//
include <../utils/core/core.scad>
include <../utils/rounded_polygon.scad>

function pi_base_width(type)    = type[1]; //! Width of the base
function pi_base_length(type)   = type[2]; //! Length of the base
function pi_base_height(type)   = type[3]; //! Height of the base
function pi_gap_height(type)    = type[4]; //! Height of the gap where the light can be interrupted
function pi_gap_width(type)     = type[6]; //! Width of the gap
function pi_stem_width(type)    = type[5]; //! Width of the stems
function pi_hole_diameter(type) = type[7]; //! Diameter of the mounting holes
function pi_color(type)         = type[8]; //! Color of photo interrupter
function pi_pcb(type)           = type[9]; //! Parameter for the support PCB, created with pi_pcb

module pi_hole_locations(type) { //! Locations of photo interrupter mounting holes
    translate([0, -(pi_base_length(type) - pi_base_width(type)) / 2, 0])
        children();
    translate([0, (pi_base_length(type) - pi_base_width(type)) / 2, 0])
        children();
}

module pi_pcb_hole_locations(pcb) { //! Locations of the PCB holes
    for (xy = pcb[7]) {
        translate([xy[0], xy[1], 0])
            children();
    }
}

module pi_pcb(type) { //! Draw the support PCB
    pcb = pi_pcb(type);
    color(pcb[6]) {
        translate([0, 0, -pcb[2]]) {
            linear_extrude(pcb[2]) {
                difference() {
                    rounded_polygon([[0, -(pi_base_length(type) - pi_base_width(type)) / 2, -pi_base_width(type) / 2],
                                     [pi_base_width(type) / 2, -pcb[1]/2, eps],
                                     [pcb[0]+1, -pcb[1]/2, eps],
                                     [pcb[0]+1, pcb[1]/2, eps],
                                     [pi_base_width(type) / 2, pcb[1]/2, eps],
                                     [0, (pi_base_length(type) - pi_base_width(type)) / 2, -pi_base_width(type) / 2]
                                     ]);
                    pi_pcb_hole_locations(pcb)
                        circle(d = pcb[8]);
                    pi_hole_locations(type)
                        circle(d=pi_hole_diameter(type));
                }
            }
        }
    }
}

module photo_interrupter(type) { //! Draw the photo interrupter, with PCB
    vitamin(str("photo_interrupter(", type[0], "): ", type[0], " Photo interrupter"));
    color(pi_color(type)) {
        linear_extrude(pi_base_height(type)) {
            difference() {
                hull() {
                    pi_hole_locations(type)
                        circle(d = pi_base_width(type));
                }
                pi_hole_locations(type)
                    circle(d = pi_hole_diameter(type));
            }
        }
        translate([-pi_base_width(type)/2, -(pi_gap_width(type)/2 + pi_stem_width(type)), 0])
            cube([pi_base_width(type), pi_stem_width(type), pi_gap_height(type) + pi_base_height(type)]);
        translate([-pi_base_width(type)/2, pi_gap_width(type)/2, 0])
            cube([pi_base_width(type), pi_stem_width(type), pi_gap_height(type) + pi_base_height(type)]);
    }
    pi_pcb(type);
}

module pi_cutout(type) { //! Shape to subtract for fitting a photo interrupter
    hull() {
        pi_hole_locations(type)
            cylinder(h = pi_base_height(type), d = pi_base_width(type));
    }
    translate([-pi_base_width(type)/2, -(pi_gap_width(type)/2 + pi_stem_width(type)), 0])
        cube([pi_base_width(type), pi_stem_width(type), pi_gap_height(type) + pi_base_height(type)]);
    translate([-pi_base_width(type)/2, pi_gap_width(type)/2, 0])
        cube([pi_base_width(type), pi_stem_width(type), pi_gap_height(type) + pi_base_height(type)]);
};
