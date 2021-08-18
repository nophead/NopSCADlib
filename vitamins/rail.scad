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
include <../utils/core/core.scad>

use <screw.scad>

function rail_width(type)      = type[1];   //! Width of rail section
function rail_height(type)     = type[2];   //! Height of rail section
function rail_end(type)        = type[3];   //! Minimum distance screw can be from the end
function rail_pitch(type)      = type[4];   //! Distance between screws
function rail_bore(type)       = type[5];   //! Counter bore diameter for screw head
function rail_hole(type)       = type[6];   //! Screw hole diameter
function rail_bore_depth(type) = type[7];   //! Counter bore depth
function rail_screw(type)      = type[8];   //! Screw type
function rail_end_screw(type)  = type[9];   //! Screw used for ends only (Countersink used for better location)
function rail_groove_offset(type)=type[10]; //! Offset of centre of groove from top of rail
function rail_groove_width(type)=type[11];  //! Groove width

function rail_screw_height(type, screw) = rail_height(type) - rail_bore_depth(type) + screw_head_depth(screw, rail_hole(type)); //! Position screw taking into account countersink into counterbored hole

function carriage_length(type)       = type[1]; //! Overall length
function carriage_block_length(type) = type[2]; //! Length of the metal part
function carriage_width(type)        = type[3]; //! Width of carriage
function carriage_height(type)       = type[4]; //! Height of carriage
function carriage_clearance(type)    = type[5]; //! Gap under the carriage
function carriage_pitch_x(type)      = type[6]; //! Screw hole x pitch
function carriage_pitch_y(type)      = type[7]; //! Screw hole y pitch
function carriage_screw(type)        = type[8]; //! Carriage screw type
function carriage_rail(type)         = type[9]; //! Rail type

function carriage_screw_depth(type)  = 2 * screw_radius(carriage_screw(type)); //! Carriage thread depth
function carriage_travel(type, rail_length) = rail_length - carriage_length(type); //! How far the carriage can travel on a given length rail
function carriage_size(type)         = [ carriage_length(type), carriage_width(type), carriage_height(type) ]; //! Size of carriage

function rail_holes(type, length) = //! Number of holes in a rail given its `length`
    floor((length - 2 * rail_end(type)) / rail_pitch(type)) + 1;

module rail_hole_positions(type, length, first = 0, screws = 100, both_ends = true) { //! Position children over screw holes
    pitch = rail_pitch(type);
    holes = rail_holes(type, length);
    last = first + min(screws, both_ends ? ceil(holes / 2) : holes);
    for(i = [first : holes - 1], j = holes - 1 - i)
        if(i < last || both_ends && (j >= first && j < last))
            translate([i * pitch - length / 2 + (length - (holes - 1) * pitch) / 2, 0])
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

module carriage(type, end_colour = grey(20), wiper_colour = grey(20)) { //! Draw the specified carriage
    vitamin(str("carriage(", type[0], "_carriage): Linear rail carriage ", type[0]));

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
        w = rail_width(carriage_rail(type)) + 0.4;
        translate([-w / 2, 0])
            square([w , rail_height(carriage_rail(type)) + 0.2]);
    }

    color(grey(90)) {
        rotate([90, 0, 90])
            linear_extrude(block_l, center = true)
                 difference() {
                    translate([-block_w / 2, carriage_clearance(type)])
                        square([block_w, block_h - screw_depth]);

                    cutout();
                }

        translate_z(carriage_height(type) - screw_depth)
            linear_extrude(screw_depth)
                difference() {
                    square([block_l, block_w], center = true);

                    carriage_hole_positions(type)
                        circle(screw_pilot_hole(screw));
                }
    }

    module carriage_end(type, end_w, end_h, end_l) {
        wiper_length = 0.5;
        color(wiper_colour) translate_z(-end_l / 2) linear_extrude(wiper_length)
            difference() {
                translate([-end_w / 2, carriage_clearance(type)])
                    square([end_w, end_h]);

                cutout();
            }
        color(end_colour) translate_z(wiper_length-end_l / 2) linear_extrude(end_l - wiper_length)
            difference() {
                translate([-end_w / 2, carriage_clearance(type)])
                    square([end_w, end_h]);

                cutout();
            }
    }

    translate([-(block_l + end_l) / 2, 0])
        rotate([90, 0, 90])
            carriage_end(type, end_w, end_h, end_l);

    translate([(block_l + end_l) / 2, 0])
        rotate([90, 0, -90])
            carriage_end(type, end_w, end_h, end_l);
}

module rail(type, length, colour = grey(90), use_polycircles = false) { //! Draw the specified rail
    width = rail_width(type);
    height = rail_height(type);

    vitamin(str("rail(", type[0], ", ", length, "): Linear rail ", type[0], " x ", length, "mm"));
    assert(rail_end(type) < (rail_pitch(type) - rail_bore(type)) / 2, type[0]);

    color(colour) {
        rbr = rail_bore(type) / 2;
        w = corrected_radius(rbr) * 2 + 2 * eps; // width of core big enough for the holes
        linear_extrude(height - rail_bore_depth(type)) difference() {
            square([length, w], center = true);

            rail_hole_positions(type, length)
                if (use_polycircles)
                    poly_circle(rail_hole(type) / 2);
                else
                    circle(d = rail_hole(type));
        }
        translate_z(rail_height(type) - rail_bore_depth(type))
            linear_extrude(rail_bore_depth(type)) difference() {
                square([length, w], center = true);

                rail_hole_positions(type, length)
                    if (use_polycircles)
                        poly_circle(rbr);
                    else
                        circle(rbr);
            }

        go = height - rail_groove_offset(type);
        gw = rail_groove_width(type);
        gd = gw / 2;
        sw = (width - w) / 2;
        for (m = [0, 1])
            mirror([0, m, 0])
                translate([0, -width / 2])
                    rotate([0, -90, 0])
                        linear_extrude(length, center = true)
                            polygon([ [0, 0], [0, sw], [height, sw], [height, 0], [go + gw/2, 0], [go, gd], [go - gw/2, 0] ]);
    }
}

module rail_assembly(carriage, length, pos, carriage_end_colour = grey(20), carriage_wiper_colour = grey(20)) { //! Rail and carriage assembly
    rail(carriage_rail(carriage), length);

    translate([pos, 0])
        carriage(carriage, carriage_end_colour, carriage_wiper_colour);
}

module rail_screws(type, length, thickness, screws = 100, index_screws = undef) { //! Place screws in the rail
    screw = rail_screw(type);
    end_screw = rail_end_screw(type);
    screw_len = screw_longer_than(rail_screw_height(type, screw) + thickness);
    end_screw_len = screw_longer_than(rail_screw_height(type, end_screw) + thickness);

    index_screws = is_undef(index_screws) ? screws > 2 ? 1 : 2 : index_screws;

    translate_z(rail_screw_height(type, end_screw))
        rail_hole_positions(type, length, 0, index_screws)
            screw(end_screw, end_screw_len);

    translate_z(rail_screw_height(type, screw))
        rail_hole_positions(type, length, index_screws, screws - index_screws)
            screw(screw, screw_len);
}
