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
//! Linear rails with carriages.
//
include <../core.scad>

use <screw.scad>

function rail_width(type)      = type[1];   //! Width of rail section
function rail_height(type)     = type[2];   //! Height of rail section
function rail_end(type)        = type[3];   //! Minimum distance screw can be from the end
function rail_pitch(type)      = type[4];   //! Distance between screws
function rail_bore(type)       = type[5];   //! Counter bore diameter for screw head
function rail_hole(type)       = type[6];   //! Screw hole diameter
function rail_bore_depth(type) = type[7];   //! Counter bore depth
function rail_screw(type)      = type[8];   //! Screw type
function rail_carriage(type)   = type[9];   //! Carriage type
function rail_end_screw(type)  = type[10];  //! Screw used for ends only (Countersink used for better location)
function rail_screw_height(type, screw) = rail_height(type) - rail_bore_depth(type) + screw_head_depth(screw, rail_hole(type)); //! Position screw taking into account countersink into counterbored hole
function rail_travel(type, length) = length - carriage_length(rail_carriage(type)); //! How far the carriage can travel

function carriage_length(type)       = type[0]; //! Overall length
function carriage_block_length(type) = type[1]; //! Length of the metal part
function carriage_width(type)        = type[2]; //! Width of carriage
function carriage_height(type)       = type[3]; //! Height of carriage
function carriage_clearance(type)    = type[4]; //! Gap under the carriage
function carriage_pitch_x(type)      = type[5]; //! Screw hole x pitch
function carriage_pitch_y(type)      = type[6]; //! Screw hole y pitch
function carriage_screw(type)        = type[7]; //! Carriage screw type
function carriage_screw_depth(type)  = 2 * screw_radius(carriage_screw(type)); //! Carriage thread depth

module rail_hole_positions(type, length, first = 0, screws = 100, both_ends = true) { //! Position children over screw holes
    pitch = rail_pitch(type);
    holes = floor((length - 2 * rail_end(type)) / pitch) + 1;
    for(i = [first : holes - 1 - first])
        if(i < screws || (holes - i <= screws && both_ends))
            translate([i * pitch - length / 2 + (length - (holes -1) * pitch) / 2, 0, 0])
                children();
}

module carriage_hole_positions(type) { //! Position children over screw holes
    x_pitch = carriage_pitch_x(type);
    y_pitch = carriage_pitch_y(type);

    for(x = [-1, 1], y = [-1, 1])
        if(x < 0 || x_pitch)
            translate([x * x_pitch / 2, y * y_pitch / 2, carriage_height(type)])
                children();
}

module carriage(type, rail) { //! Draw the specified carriage
    total_l = carriage_length(type);
    block_l = carriage_block_length(type);
    block_w = carriage_width(type);
    block_h = carriage_height(type) - carriage_clearance(type);
    end_w = block_w - 0.6;
    end_h = block_h - 0.3;
    end_l = (total_l - block_l)/ 2;
    screw = carriage_screw(type);
    screw_depth = carriage_screw_depth(type);

    module cutout() {
        w = rail_width(rail) + 0.4;
        translate([-w / 2, 0])
            square([w , rail_height(rail) + 0.2]);
    }

    color(grey90) {
        rotate([90, 0, 90])
            linear_extrude(height = block_l, center = true)
                 difference() {
                    translate([-block_w / 2, carriage_clearance(type)])
                        square([block_w, block_h - screw_depth]);

                    cutout();
                }

        translate_z(carriage_height(type) - screw_depth)
            linear_extrude(height = screw_depth)
                difference() {
                    square([block_l, block_w], center = true);

                    carriage_hole_positions(type)
                        circle(screw_pilot_hole(screw));
                }

    }
    color(grey20)
        for(end = [-1, 1])
            translate([end * (block_l / 2 + end_l / 2), 0])
                rotate([90, 0, 90])
                    linear_extrude(height = end_l, center = true)
                        difference() {
                            translate([-end_w / 2,  carriage_clearance(type)])
                                square([end_w, end_h]);

                            cutout();
                        }
}

module rail(type, length) { //! Draw the specified rail
    width = rail_width(type);
    height = rail_height(type);

    vitamin(str("rail(", type[0], ", ", length, "): Linear rail ", type[0], " x ", length, "mm"));

    color(grey90) {
        linear_extrude(height = height - rail_bore_depth(type)) difference() {
            square([length, width], center = true);

            rail_hole_positions(type, length)
                 circle(d = rail_hole(type));
        }

        translate_z(rail_height(type) - rail_bore_depth(type))
            linear_extrude(height = rail_bore_depth(type)) difference() {
                square([length, width], center = true);

                rail_hole_positions(type, length)
                     circle(d = rail_bore(type));
            }
    }
}

module rail_assembly(type, length, pos) { //! Rail and carriage assembly
    rail(type, length);

    translate([pos, 0])
        carriage(rail_carriage(type), type);

}

module rail_screws(type, length, thickness, screws = 100) { //! Place screws in the rail
    screw = rail_screw(type);
    end_screw = rail_end_screw(type);
    screw_len = screw_longer_than(rail_screw_height(type, screw) + thickness);
    end_screw_len = screw_longer_than(rail_screw_height(type, end_screw) + thickness);

    index_screws = screws > 2 ? 1 : 2;

    translate_z(rail_screw_height(type, end_screw))
        rail_hole_positions(type, length, 0, index_screws)
            screw(end_screw, end_screw_len);

    translate_z(rail_screw_height(type, screw))
        rail_hole_positions(type, length, index_screws, screws)
            screw(screw, screw_len);
}
