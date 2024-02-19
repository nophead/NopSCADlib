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
//! T-Tracks used in woodworking jigs
//
include <../utils/core/core.scad>
use <../utils/thread.scad>

use <screw.scad>

function ttrack_width(type)         = type[1];   //! Width of track section
function ttrack_height(type)        = type[2];   //! Height of track section
function ttrack_opening(type)       = type[3];   //! Width of the opening
function ttrack_slot_width(type)    = type[4];   //! Width of the slot
function ttrack_slot_height(type)   = type[5];   //! Height of the slot
function ttrack_top_thickness(type) = type[6];   //! Thickness of the top layer
function ttrack_screw_pitch(type)   = type[7];   //! Distance between screws
function ttrack_screw(type)         = type[8];   //! Screw used to fasten track
function ttrack_fixture(type)         = type[9];  //! Fixture, such as T-bolt or Miter insert used with this track

function tbolt_description(type)    = type[1];   //! Description of this t-track bolt
function tbolt_head_length(type)    = type[2];   //! Head length for t-track bolt
function tbolt_head_width(type)     = type[3];   //! Head width for t-track bolt
function tbolt_head_thickness(type) = type[4];   //! Head thickness for t-track bolt
function tbolt_thread(type)         = type[5];   //! M thread for this bolt

function t_insert_description(type)   = type[1];   //! Description of this t-track insert
function t_insert_top_width(type)     = type[2];   //! Top Width of t-track insert
function t_insert_width(type)         = type[3];   //! Width of t-track insert
function t_insert_height(type)        = type[4];   //! Height of t-track insert
function t_insert_top_thickness(type) = type[5];   //! Top thickness for t-track insert
function t_insert_thread(type)        = type[6];   //! M thread for this the screw hole in this insert

function ttrack_holes(type, length) = //! Number of holes in a rail given its `length`
    floor((length - 2 * ttrack_screw_end(type)) / ttrack_screw_pitch(type)) + 1;



module ttrack(type, length, colour = "LightSlateGray") { //! Draw the specified rail
    W  = ttrack_width(type);
    H  = ttrack_height(type);
    SW = ttrack_slot_width(type);
    SH = ttrack_slot_height(type);
    T  = ttrack_top_thickness(type);
    O  = ttrack_opening(type);
    screw=ttrack_screw(type);

    vit_colour = (colour == "LightSlateGray" ? "" : str(", colour=\"", colour, "\""));

    vitamin(str("ttrack(", type[0], ", ", length, vit_colour, "): T-Track ", type[0], " x ", length, "mm"));

    color(colour) {
        difference() {
            rotate([90,0,0])
                linear_extrude(length, center=true, convexity = 3)
                    polygon([
                        [ -O/2,       0 ], // left side of the opening
                        [ -W/2,       0 ], // left top
                        [ -W/2,      -H ], // left bottom
                        [  W/2,      -H ], // right bottom
                        [  W/2,       0 ], // right top
                        [  O/2,       0 ], // right side of the opening
                        [  O/2,      -T ], // right bottom side of the opening
                        [ SW/2,      -T ], // right top of the slot
                        [ SW/2, -T - SH ], // right bottom of the slot
                        [ -SW/2,-T - SH ], // left bottom of the slot
                        [ -SW/2,     -T ], // left top of the slot
                        [ -O/2,      -T ]  // left bottom side of the opening
                    ]);
                ttrack_hole_positions(type, length) {
                    B = H - (SH + T);
                    screw_countersink(screw, true);
                    translate_z(-B/2)
                        cylinder(r=screw_clearance_radius(screw), h=(H-(SH+T) + 0.2), center=true);
                }
            }

        }

}

module ttrack_assembly(type, length, colour = "LightSlateGray") {
    ttrack(type, length, colour);
    ttrack_hole_positions(type, length)
        explode(20)
            screw(ttrack_screw(type), 15);
}
module ttrack_hole_positions(type, length) { //! Position children over screw holes
    P = ttrack_screw_pitch(type);
    H  = ttrack_height(type);
    B = H - (ttrack_slot_height(type) +  ttrack_top_thickness(type));

    count = floor(length / P);
    first = (length - count * P)/2;

    c = first < P/3 ? count - 1 : count;  // we don't want screws right on the edge
    N = (length - c * P)/2;

    for (y = [N:P:length-N])
        translate([0,length/2 - y, -H + B])
            children();
}

module ttrack_place_bolt(type, pos, bolt = undef) { //! Place a T-Bolt relative to the centre of the track
    bolt = is_undef(bolt) ? ttrack_fixture(type) : bolt;

    T = tbolt_head_thickness(bolt);
    translate([0,pos,-(ttrack_top_thickness(type)/2) - T])
        rotate([0,0,90])
            children();
}

module ttrack_place_insert(type, pos, insert = undef) { //! Place a T-Insert relative to the centre of the track
    insert = is_undef(insert) ? ttrack_fixture(type) : insert;
    TT = t_insert_top_thickness(insert);
    T = ttrack_top_thickness(type);
    translate([0,pos,-T+TT])
        rotate([0,0,90])
            children();
}

module ttrack_bolt(type, length) {
    L = tbolt_head_length(type);
    W = tbolt_head_width(type);
    T = tbolt_head_thickness(type);
    distance = L - W;

    D = tbolt_thread(type);
    pitch = metric_coarse_pitch(D);

    vitamin(str(tbolt_description(type), ":", "M", D, " x ", length, "mm"));

    color(silver) {
        hull()
            for (x = [-1, 1])
                translate([x * distance/2, 0, 0])
                    cylinder(d=W, h=T, center=true);

        translate_z((length/2))
            male_metric_thread(D, pitch, length - T, center = true, top = -1, bot = 0, solid = true, colour = undef);
    }

}

module ttrack_insert(type, length, num_holes = 1, colour="LightSlateGray") {
    TW = t_insert_top_width(type);
    W  = t_insert_width(type);
    H  = t_insert_height(type);
    T  = t_insert_top_thickness(type);
    //distance = L - W;

    D = t_insert_thread(type);
    pitch = metric_coarse_pitch(D);

    vit_colour = (colour == "LightSlateGray" ? "" : str(", colour=\"", colour, "\""));
    vitamin(str("ttrack_insert(", type[0], ", ", length, ", ", num_holes, vit_colour, "):", t_insert_description(type), ", M", length, "mm, with ", num_holes, " M", D));

    color(colour) {
        union() {
            difference() {
                rotate([90,0,90]) {
                    linear_extrude(length, center=true, convexity=2)
                        polygon([
                            [ -TW/2,  0 ], // left top
                            [ -TW/2, -T ], // left centre, bottom of top
                            [  -W/2, -T ], // left centre
                            [  -W/2, -H ], // left bottom
                            [   W/2, -H ], // right bottom
                            [   W/2, -T ], // right centre
                            [  TW/2, -T ], // right centre, bottom of top
                            [  TW/2,  0 ] // right top
                        ]);
                }
                ttrack_insert_hole_positions(type, length, num_holes)
                    translate_z(-H/2)
                        cylinder(h=H+1, d=t_insert_thread(type), center=true);
            }
            ttrack_insert_hole_positions(type, length, num_holes)
                translate_z(-H/2)
                    female_metric_thread(D, pitch, H, center = true);
        }
    }



}

module ttrack_insert_hole_positions(type, length, num_holes) {
    P = length / (num_holes + 1);
    for (x = [P:P:length-P])
        translate([length/2 - x,0,0])
            children();
}
