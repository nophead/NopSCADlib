//
// NopSCADlib Copyright Chris Palmer 2020
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
//! Surface mount components for PCBs.
//
include <../utils/core/core.scad>

use <../utils/tube.scad>

function smd_led_size(type) = type[1]; //! Body length, width and height
function smd_led_lens(type) = type[2]; //! Lens length width and height
function smd_led_height(type) =        //! Total height
    smd_led_size(type).z + smd_led_lens(type).z;

function smd_100th(x) = //! Convert dimension to 1/100" notation
    let(s = str(round(x / inch(0.01))))
        len(s) < 2 ? str("0", s) : s;

function smd_size(size) = //! Convert size to 1/100" notation
    str(smd_100th(size.x), smd_100th(size.y));

module smd_led(type, colour, cutout) { //! Draw an SMD LED with specified `colour`
    size = smd_led_size(type);
    vitamin(str("smd_led(", type[0], ", ", colour, "): SMD LED ", smd_size(size), " ", colour));

    lens = smd_led_lens(type);
    r = size.y * 0.32;
    $fn = 32;

    if(cutout)
        poly_drill(r = 2.85 / 2, h = 100, center = false); // For lightguide made from transparent PLA filament
    else {
        color("white")
            linear_extrude(size.z)
                difference() {
                    square([size.x, size.y], center = true);

                    for(end = [-1, 1])
                        translate([end * size.x / 2, 0])
                            circle(r);
                }

        color(gold)
             linear_extrude(size.z)
                intersection() {
                    square([size.x, size.y], center = true);

                    union()
                        for(end = [-1, 1])
                            translate([end * size.x / 2, 0])
                                ring(or = r, ir = r / 2);
                }

        color(colour, 0.9)
            translate_z(size.z)
                hull() {
                    cube([lens.x, lens.y, eps], center = true);

                    slant = lens.z * tan(15);
                    translate_z(lens.z / 2)
                        cube([lens.x - slant, lens.y - slant, lens.z], center = true);
                }
    }
}

function smd_res_size(type)    = type[1]; //! Body length, width and height
function smd_res_end_cap(type) = type[2]; //! End cap width
function smd_res_power(type)   = type[3]; //! Power rating in Watts

module smd_resistor(type, value) { //! Draw an SMD resistor with specified value
    size = smd_res_size(type);
    vitamin(str("smd_resistor(", type[0], ", ", value, "): SMD resistor ", smd_size(size), " ", value, " ", smd_res_power(type), "W"));

    t = 0.04;
    cap = smd_res_end_cap(type);
    color("white")
        translate_z(size.z / 2)
            cube([size.x - 2 * t, size.y, size.z - 2 * t], center = true);

    color(grey(20))
        translate_z(size.z - t)
            cube([size.x - 2 * cap, size.y, eps], center = true);

    color(silver)
        for(end = [-1, 1])
            translate([end * (size.x / 2 - cap / 2), 0, size.z / 2])
                cube([cap, size.y - 2 * eps, size.z], center = true);

    color("white")
        translate([0, 0, size.z])
            linear_extrude(eps)
                resize([(size.x - 2 * cap) * 0.75, size.y / 2])
                    text(value, halign = "center", valign = "center");
}
