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
//! Standard domed through hole LEDs. Can specify colour and lead length.
//
include <../utils/core/core.scad>
use <../utils/rounded_cylinder.scad>
use <../utils/pcb_utils.scad>

function led_diameter(type) = type[1]; //! Body diameter
function led_rim_dia(type)  = type[2]; //! Rim diameter
function led_rim_t(type)    = type[3]; //! Rim height
function led_height(type)   = type[4]; //! Body height
function led_pitch(type)    = type[5]; //! Lead pitch
function led_lead_t(type)   = type[6]; //! Lead thickness
function led_radius(type) = led_diameter(type) / 2; //! Radius

function led_hole_radius(type) = led_radius(type); //! Radius of panel hole to accept LED

module led(type, colour = "red", lead = 5, right_angle = 0) { //! Draw specified LED with desired colour and lead length
    d = led_diameter(type);
    vitamin(str("led(", type[0], arg(colour, "red"), "): LED ", d, " mm ", colour));

    rotate([right_angle ? 90 : 0, 0, 0])
        translate_z(right_angle ? right_angle - led_rim_t(type) : 0)
            color(colour) {
                if (is_num(d)) {
                    rotate_extrude()
                        rounded_corner(r = d / 2, h = led_height(type), r2 =  d / 2);

                    linear_extrude(led_rim_t(type))
                        difference() {
                            circle(d = led_rim_dia(type));

                            translate([d / 2 + eps, -5])
                                square(10);
                        }
                } else {
                    translate_z(led_height(type)/2) cube([d.x, d.y, led_height(type)], center = true);
                    translate_z(led_rim_t(type)/2) cube([led_rim_dia(type).x, led_rim_dia(type).y, led_rim_t(type)], center = true);
                }
            }
    t = led_lead_t(type);
    len = lead - (right_angle ? t : 0);
    color("silver")
        for(side = [-1, 1])
            translate([side * led_pitch(type) / 2, 0]) {
                vflip()
                    translate_z(len / 2 + (right_angle ? t : 0))
                        cube([t, t, len], center = true);

                if(right_angle) {
                    translate([0, -right_angle / 2 - t])
                        cube([t, right_angle, t], center = true);

                translate([0, -t, - t])
                    rotate([0, -90, 0])
                        rotate_extrude(angle = 90)
                            translate([t, 0])
                                square(t, center = true);
                }
                solder();
            }
}
