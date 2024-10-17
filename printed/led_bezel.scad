//
// NopSCADlib Copyright Chris Palmer 2022
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
//! Printed LED bezels for panel mounting
//
include <../core.scad>

use <../vitamins/led.scad>

function led_bezel(led, flange = 1, flange_h = 1, wall = 1, height = 8) = [led, flange, flange_h, wall, height]; //! Constructor
function led_bezel_led(type)      = type[0]; //! The LED
function led_bezel_flange(type)   = type[1]; //! Flange width
function led_bezel_flange_t(type) = type[2]; //! Flange thickness
function led_bezel_wall(type)     = type[3]; //! Wall thickness
function led_bezel_height(type)   = type[4]; //! Total height

function led_bezel_r(type)   =     //! Radius of the tube
    corrected_radius(led_rim_dia(led_bezel_led(type)) / 2) + led_bezel_wall(type);

function led_bezel_hole_r(type)   =     //! Panel hole radius
    led_bezel_r(type) + 0.1;

module led_bezel(type) { //! Makes the STL for the bezel
    led = led_bezel_led(type);
    stl(str(led[0],"_bezel")) {
        wall = led_bezel_wall(type);
        if(is_num(led_diameter(led))) {
            rl = led_diameter(led) / 2;
            rr = led_rim_dia(led) / 2;
            poly_tube(or = rr + wall + led_bezel_flange(type), ir = rl, h = led_bezel_flange_t(type));              // Flange
            poly_tube(or = rl + wall,                          ir = rl, h = led_height(led) - rl - led_rim_t(led)); // Tube up to LED flange
            poly_tube(or = corrected_radius(rr) + wall,        ir = rr, h = led_bezel_height(type));                // Tube beyond the flange
        }
        else {
            linear_extrude(led_bezel_flange_t(type))        // Flange
                difference() {
                    offset(wall + led_bezel_flange(type))
                        square(led_rim_dia(led), true);

                    square(led_diameter(led), true);
                }

            linear_extrude(led_height(led) - led_rim_t(led)) // Tube up to the LED flange
                difference() {
                    offset(wall)
                        square(led_diameter(led), true);

                    square(led_diameter(led), true);
                }

            linear_extrude(led_bezel_height(type)) // Tube beyond the LED flange
                difference() {
                    offset(wall)
                        square(led_rim_dia(led), true);

                    square(led_rim_dia(led), true);
                }
        }
    }
}

module led_bezel_retainer(type) { //! Makes the STL for the retaining ring
    led = led_bezel_led(type);
    stl(str(led[0],"_bezel_retainer")) {
        wall = led_bezel_wall(type);
        if(is_num(led_diameter(led))) {
             ir =  led_bezel_r(type);
             poly_tube(or = ir + wall, ir = ir, h = 4);
        }
        else
            linear_extrude(4)
                difference() {
                    offset(2 * wall)
                        square(led_rim_dia(led), true);

                    offset(wall)
                        square(led_rim_dia(led), true);
                }
    }
}

module led_bezel_assembly(type, colour = "red") {//! Led bezel with LED
    led = led_bezel_led(type);
    d = led_diameter(led);
    assembly(str(led[0], "_", colour, "_bezel")) {
        translate_z(led_bezel_flange_t(type)) {
            vflip()
                stl_colour(pp1_colour)
                    led_bezel(type);

            translate_z(-led_height(led) + (is_num(d) ? d / 2 : 0))
                explode(-20)
                    led(led, colour);
        }
    }
}

module led_bezel_fastened_assembly(type, t, colour = "red") //! Led bezel fitted to panel with  and retaining ring
{
    explode(20)
        led_bezel_assembly(type, colour);

    translate_z(-t)
        vflip()
            stl_colour(pp2_colour)
                explode(60)
                    led_bezel_retainer(type);
}
