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
//! Variable auto transformers.
//
include <../utils/core/core.scad>
use <screw.scad>

function variac_diameter(type)       = type[2];     //! Body diameter
function variac_height(type)         = type[3];     //! Body height
function variac_bulge_dia(type)      = type[4];     //! Bulge to opposite edge
function variac_bulge_width(type)    = type[5];     //! Width of the bulge
function variac_shaft_dia(type)      = type[6];     //! Shaft diameter
function variac_shaft_length(type)   = type[7];     //! Shaft length
function variac_screws(type)         = type[8];     //! Number of screws
function variac_screw_pitch(type)    = type[9];     //! Pitch of screws
function variac_screw(type)          = type[10];    //! Screw type
function variac_dial_dia(type)       = type[11];    //! Dial diameter
function variac_dial_thickness(type) = type[12];    //! Dial thickness
function variac_dial_hole_pitch(type)= type[13] ? type[13] : variac_screw_pitch(type);                      //! Screw pitch for the dial
function variac_dial_hole_r(type)    = type[14] ? type[14] : screw_clearance_radius(variac_screw(type));    //! Dial screw hole radius
function variac_dial_big_hole(type)  = type[15] ? type[15] : variac_shaft_dia(type) + 2;                    //! Central dial hole diameter

function variac_radius(type) = variac_diameter(type) / 2;   //! Body radius

module variac_hole_positions(type, pitch = undef)   //! Position children at the screw positions
    for(i = [0 : variac_screws(type) - 1])
        rotate(360 * (i + 0.5) / variac_screws(type) - 90)
            translate([pitch ? pitch : variac_screw_pitch(type), 0])
                children();

module variac_holes(type, h = 100) {    //! Drill panel holes for specified variac
    variac_hole_positions(type)
        drill(screw_clearance_radius(variac_screw(type)), h);

    drill(variac_shaft_dia(type) / 2 + 1, h);
}

module variac_dial(type)            //! Draw the dial for the specified variac
    color("silver") linear_extrude(variac_dial_thickness(type))
        difference() {
            circle(d = variac_dial_dia(type));

            circle(variac_dial_big_hole(type) / 2);

            variac_hole_positions(type, variac_dial_hole_pitch(type))
                circle(variac_dial_hole_r(type));
        }

module variac(type, thickness = 3, dial = true) {   //! Draw the specified variac with screws and possibly the dial when it is fixed and not rotating
    vitamin(str("variac(", type[0], ", 3): Variac ", type[1]));
    dia = variac_diameter(type);
    w = variac_bulge_width(type);
    h = variac_height(type);

    bulge_r = variac_bulge_dia(type) - dia / 2;

    module shape() {
        circle(d = dia);

        translate([-w / 2, -bulge_r])
            square([w, bulge_r]);
    }

    translate_z(-h) {
        color("#A66955") {
            linear_extrude(h)
                difference() {
                    shape();

                    variac_hole_positions(type)
                        circle(screw_radius(variac_screw(type)));
                }

            linear_extrude(h - 10)
                shape();
        }
        color("silver")
            translate_z(1)
                cylinder(d = variac_shaft_dia(type), h = h + variac_shaft_length(type) - 1);

        if(dial)
            translate_z(thickness + h)
                variac_dial(type);

        translate_z(thickness + h + (dial ? variac_dial_thickness(type) : 0))
            not_on_bom()
                variac_hole_positions(type)
                    screw_and_washer(variac_screw(type), 16);
    }
}
