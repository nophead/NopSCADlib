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
//! LED voltmeter and ammeter modules available from China and a printed bezel that allows the voltmeter to be mounted into a
//! CNC cut panel. The meter is held in the bezel by melting the stakes with a soldering iron set to 200&deg;C. The
//! bezel is fixed in the panel with hot glue.
//!
//! The 7 SEGMENT.TTF font from the [docs](docs) directory needs to be installed to get realistic digits.
//
include <../utils/core/core.scad>
use <axial.scad>

function meter_size(type)        = type[1];     //! Size of display
function meter_offset(type)      = type[2];     //! Display position, 0 = center, +1 = top
function meter_pcb_size(type)    = type[3];     //! PCB size excluding lugs
function meter_lug_size(type)    = type[4];     //! Lug length and width
function meter_lug_offset(type)  = type[5];     //! Lug position, 0 = center, +1 = top
function meter_hole_pitch(type)  = type[6];     //! Lug hole pitch
function meter_hole_radius(type) = type[7];     //! Lug hole radius
function meter_shunt(type)       = type[8];     //! Ammeter shunt wire

function meter_pos(type) = (meter_pcb_size(type).y - meter_size(type).y) * meter_offset(type) / 2;
function meter_lug_pos(type) = (meter_pcb_size(type).y - meter_lug_size(type).y) * meter_lug_offset(type) / 2;

module meter_hole_positions(type) //! Position children over the holes
    for(side = [-1, 1])
        translate([side * meter_hole_pitch(type) / 2, meter_lug_pos(type)])
            children();

function meter_shunt_y(type) = meter_pos(type) - meter_pcb_size(type).y / 2; //! Shunt y coordinate

module meter(type, colour = "red", value = "888", display_colour = false) //! Draw a meter with optional colour and display value
{
    vitamin(str("meter(", type[0], arg(colour, "red", "colour"), "): LED ", meter_shunt(type) ? "am" : "volt", "meter ", colour));

    size = meter_size(type);

    color("grey")
        translate([0, meter_pos(type), size.z / 2])
            cube(size, center = true);

    color("green")
        translate_z(meter_size(type).z)
            linear_extrude(meter_pcb_size(type).z)
                difference() {
                    union() {
                        square([meter_pcb_size(type).x, meter_pcb_size(type).y], center = true);

                        translate([0, meter_lug_pos(type)])
                            square([meter_lug_size(type).x, meter_lug_size(type).y], center = true);
                    }
                    meter_hole_positions(type)
                        circle(meter_hole_radius(type));
                }

    color(display_colour ? display_colour : colour)
        linear_extrude(0.2, center = true)
            mirror([1, 0, 0])
                translate([-size.x / 2 + 1, meter_pos(type)])
                    resize([size.x - 2, size.y - 2]) {
                        text(value, font = "7 Segment", valign = "center");

                        square(eps);        // Tiny invisible pixel at the origin so numbers starting with 1 scale correctly.
                    }

    shunt = meter_shunt(type);
    if(shunt)
        translate([0, meter_shunt_y(type), size.z])
            vflip()
                color("#b87333")
                    not_on_bom()
                        wire_link(shunt.y, shunt.x, shunt.z, tail = 2);
}

clearance = 0.1;
overlap = 1;
flange_t = 1;

function meter_bezel_wall(type) = (meter_lug_size(type).x - meter_size(type).x) / 2;              //! Printed bezel wall thickness
function meter_bezel_rad(type) = meter_bezel_wall(type);                                          //! Printed bezel corner radius
function meter_bezel_length(type) = meter_size(type).x + 2 * (meter_bezel_wall(type) + overlap);  //! Printed bezel length
function meter_bezel_width(type) = meter_size(type).y + 2 * (meter_bezel_wall(type) + overlap);   //! Printed bezel width

module meter_bezel_hole(type, h = 100) { //! Make a hole to fit the meter Bezel
    wall = meter_bezel_wall(type) + clearance;
    rad = meter_bezel_rad(type) + clearance;
    l = meter_size(type).x;
    w = meter_size(type).y;

    extrude_if(h)
        rounded_square([l + 2 * wall, w + 2 * wall], rad);
}

module meter_bezel(type) { //! Generate the STL for the meter bezel
    stl("meter_bezel");

    wall = meter_bezel_wall(type);
    rad = meter_bezel_rad(type);
    l = meter_size(type).x;
    w = meter_size(type).y;
    h = meter_size(type).z;

    union() {
        linear_extrude(h)
            difference() {
                rounded_square([l + 2 * wall, w + 2 * wall], rad);

                square([l + 2 * clearance, w + 2 * clearance], center = true);
            }

        linear_extrude(flange_t)
            difference() {
                rounded_square([l + 2 * wall + 2 * overlap, w + 2 * wall + 2 * overlap], rad + overlap);

                square([l + 2 * clearance, w + 2 * clearance], center = true);
        }

        translate([0, -meter_pos(type)])
            meter_hole_positions(type)
                cylinder(r = meter_hole_radius(type), h = h + meter_pcb_size(type).z * 2);
    }
}

module meter_assembly(type, colour = "red", value = "888", display_colour = false) { //! Meter assembled into the bezel
    hflip()
        translate_z(-flange_t) {
            color("dimgrey") meter_bezel(type);

            translate([0, -meter_pos(type)])
                meter(type, colour, value, display_colour);
        }
}
