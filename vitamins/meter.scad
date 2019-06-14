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
//! LED volt meter modules available from China and a printed bezel that allows them to be mounted into a
//! CNC cut panel. The meter is held in the bezel by melting the stakes with a soldering iron set to 200&deg;C. The
//! bezel is fixed in the panel with hot glue.
//!
//! The 7 SEGMENT.TTF font from the [docs](docs) directory needs to be installed to get realistic digits.
//
include <../core.scad>

led_meter = ["led_meter", 22.72, 10.14, 6.3, 22.72, 11.04, 0.96, 30, 4.2, 26, 2.2 / 2];

function meter() = led_meter; //! Default meter type

function meter_length(type = led_meter)        = type[1];     //! Length of body
function meter_width(type = led_meter)         = type[2];     //! Width of body
function meter_height(type = led_meter)        = type[3];     //! Height of body excluding PCB
function meter_pcb_length(type = led_meter)    = type[4];     //! PCB length excluding lugs
function meter_pcb_width(type = led_meter)     = type[5];     //! PCB width
function meter_pcb_thickness(type = led_meter) = type[6];     //! PCB thickness
function meter_lug_length(type = led_meter)    = type[7];     //! PCB length including lugs
function meter_lug_width(type = led_meter)     = type[8];     //! Lug width
function meter_hole_pitch(type = led_meter)    = type[9];     //! Lug hole pitch
function meter_hole_radius(type = led_meter)   = type[10];    //! Lug hole radius

module meter_hole_positions(type = led_meter) //! Position children over the holes
    for(side = [-1, 1])
        translate([side * meter_hole_pitch(type) / 2, 0])
            children();

module meter(type = led_meter, colour = "red", value = "888", display_colour = false) //! Draw a meter with optional colour and display value
{
    vitamin(str("meter(", type[0], arg(colour, "red", "colour"), "): LED meter ", colour));

    color("grey")
        translate_z(meter_height(type) / 2)
            cube([meter_length(type), meter_width(type), meter_height(type)], center = true);

    color("green")
        translate_z(meter_height(type))
            linear_extrude(height = meter_pcb_thickness(type))
                difference() {
                    union() {
                        square([meter_pcb_length(type), meter_pcb_width(type)], center = true);

                        square([meter_lug_length(type), meter_lug_width(type)], center = true);
                    }
                    meter_hole_positions(type)
                        circle(meter_hole_radius(type));
                }

    color(display_colour ? display_colour : colour)
        linear_extrude(height = 0.2, center = true)
            mirror([1,0,0])
                text(value, font = "7 segment", valign = "center", halign = "center", size = meter_width(type) - 2, spacing = 1.2);
}

clearance = 0.1;
overlap = 1;
flange_t = 1;

function meter_bezel_wall(type = led_meter) = (meter_lug_length(type) - meter_length(type)) / 2;              //! Printed bezel wall thickness
function meter_bezel_rad(type = led_meter) = meter_bezel_wall(type);                                          //! Printed bezel corner radius
function meter_bezel_length(type = led_meter) = meter_length(type) + 2 * (meter_bezel_wall(type) + overlap);  //! Printed bezel length
function meter_bezel_width(type = led_meter) = meter_width(type) + 2 * (meter_bezel_wall(type) + overlap);    //! Printed bezel width

module meter_bezel_hole(type = led_meter, h = 100) { //! Make a hole to fit the meter Bezel
    wall = meter_bezel_wall(type) + clearance;
    rad = meter_bezel_rad(type) + clearance;
    l = meter_length(type);
    w = meter_width(type);

    extrude_if(h)
        rounded_square([l + 2 * wall, w + 2 * wall], rad);
}

module meter_bezel(type = led_meter) { //! Generate the STL for the meter bezel
    stl("meter_bezel");

    wall = meter_bezel_wall(type);
    rad = meter_bezel_rad(type);
    l = meter_length(type);
    w = meter_width(type);
    h = meter_height(type);

    union() {
        linear_extrude(height = h)
            difference() {
                rounded_square([l + 2 * wall, w + 2 * wall], rad);

                square([l + 2 * clearance, w + 2 * clearance], center = true);
            }

        linear_extrude(height = flange_t)
            difference() {
                rounded_square([l + 2 * wall + 2 * overlap, w + 2 * wall + 2 * overlap], rad + overlap);

                square([l + 2 * clearance, w + 2 * clearance], center = true);
        }
        meter_hole_positions(type)
            cylinder(r = meter_hole_radius(type), h = h + meter_pcb_thickness(type) * 2);
    }
}

module meter_assembly(type = led_meter, colour = "red", value = "888", display_colour = false) { //! Meter assembled into the bezel
    vflip()
        translate_z(-flange_t) {
            color("dimgrey") meter_bezel(type);

            meter(type, colour, value, display_colour);
        }
}
