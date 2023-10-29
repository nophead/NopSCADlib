//
// NopSCADlib Copyright Chris Palmer 2021
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
//! 7 Segment displays.
//!
//! Can be single digits stacked side by side or can be multiple digits in one unit. This is determined by the overall width compared to the width of a digit.
//! Presence of a decimal point is determined by the number of pins. Its position is determined by a heuristic.
//
include <../utils/core/core.scad>
use <../utils/pcb_utils.scad>


function 7_segment_size(type)       = type[1]; //! Size of the body
function 7_segment_digit_size(type) = type[2]; //! Size of the actual digit and segment width and angle
function 7_segment_pins(type)       = type[3]; //! [x, y] array of pins
function 7_segment_pin_pitch(type)  = type[4]; //! x and y pin pitches and pin diameter

function 7_segment_digits(type) = let(d = 7_segment_digit_size(type)) floor(7_segment_size(type).x / (d.x + d.y * tan(d[3])));

module 7_segment_digit(type, colour = grey(95), pin_length = 6.4) { //! Draw the specified 7 segment digit
    size = 7_segment_size(type);
    digit = 7_segment_digit_size(type);
    pins = 7_segment_pins(type);
    pin_pitch = 7_segment_pin_pitch(type);

    t = digit[2];
    a = digit[3];
    digits = 7_segment_digits(type);
    pitch = size.x / digits;
    has_dp = (pins.x * pins.y) > 7 + digits;

    color(grey(95))
        linear_extrude(size.z)
            square([size.x - 0.1, size.y], center = true);

    color(grey(15))
        translate_z(size.z)
            cube([size.x - 0.1, size.y, eps], center = true);

    color(colour)
        for(i = [0 : digits - 1])
            translate([(i - (digits - 1) / 2) * pitch, 0, size.z])
                linear_extrude(2 * eps) {
                    sq = [digit.x - 2 * t, (digit.y - 3 * t) / 2];

                    multmatrix([                    // Skew
                        [1, tan(a), 0, 0],
                        [0, 1, 0, 0],
                        [0, 0, 1, 0],
                        [0, 0, 0, 1]
                    ])
                    difference() {
                        square([digit.x, digit.y], center = true);

                        for(y = [-1, 1], x = [-1, 1]) {
                            translate([0, y * (t + sq.y) / 2])
                                square(sq, center = true);


                            translate([x * digit.x / 2, y * digit.y / 2])
                                rotate(-45 * x * y) {
                                    square([10, t], center = true);

                                    square([t / 5, 10], center = true);
                                }

                            translate([x * (digit.x - t) / 2, 0])
                                rotate(45) {
                                    square([t / 5, t * 2], center = true);

                                    square([t * 2, t / 5], center = true);

                                    translate([x * t / 2, -x * t / 2])
                                        square([t, t], center = true);
                                }
                        }
                    }
                    r = 1.25 * t / 2;
                    if(has_dp)
                        translate([max(digit.x / 2 + digit.y / 2 * tan(a) - r, digit.x / 2 - digit.y /2 * tan(a) + r * 1.25), -digit.y / 2 + r])
                            circle(r);
                }

    color(silver)
        for(x = [0 : 1 : pins.x - 1], y = [0 : 1 : pins.y - 1])
            translate([(x - (pins.x - 1) / 2) * pin_pitch.x, (y - (pins.y - 1) / 2) * pin_pitch.y]) {
                vflip()
                    cylinder(d = pin_pitch[2], h = pin_length, $fn = fn);

                solder();
             }
}

module 7_segment_digits(type, n, colour = grey(70), pin_length = 6.4, cutout = false) { //! Draw n digits side by side
    size = 7_segment_size(type);

    if(cutout)
        linear_extrude(100)
            square([n * size.x, size.y], center = true);
    else
        for(i = [0 : 1 : n - 1])
            translate([(i - (n - 1) / 2) * size.x, 0])
                7_segment_digit(type, colour, pin_length);
}
