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
//! Light dependent resistors.
//!
//! Larger ones seem to have both a higher dark resistance and a lower bright light resistance.
//
include <../utils/core/core.scad>

function ldr_description(type) = type[1]; //! Description
function ldr_diameter(type)    = type[2]; //! The diameter of the round bit
function ldr_width(type)       = type[3]; //! Across the flats
function ldr_thickness(type)   = type[4]; //! Thickness
function ldr_pitch(type)       = type[5]; //! Pitch between the leads
function ldr_active(type)      = type[6]; //! The active width
function ldr_lead_d(type)      = type[7]; //! The lead diameter

module LDR(type, lead_length = 3) { //! Draw an LDR, can specify the lead length
    vitamin(str("ldr(", type[0], "): Light dependent resistor - ", ldr_description(type)));

    module shape()
        intersection() {
            circle(d = ldr_diameter(type));

            square([100, ldr_width(type)], center = true);
        }

    function serpentine_t() = let(w = ldr_width(type), n = floor(w / 0.5) + 0.5) w / (n * 2);

    module serpentine() {
        w = ldr_width(type);

        t = serpentine_t();
        pitch = 2 * t;
        l = ldr_active(type);
        lines = ceil(w / pitch);

        for(i = [0 : lines - 1])
            translate([0, i * pitch - w / 2 + t / 2]) {
                square([l - 3 * t, t], center = true);

                end = i % 2 ? 1 : -1;
                $fn = 16;
                translate([end * (l / 2 - 1.5 * t), t])
                    rotate(-end * 90)
                    difference() {
                        semi_circle(1.5 * t);

                        semi_circle(t / 2);
                    }
            }
    }

    t = ldr_thickness(type);

    color("white")
        linear_extrude(t - 0.4)
            shape();

    color("orange")
        translate_z(t - 0.4)
            linear_extrude(0.1)
                shape();

    color([0.9, 0.9, 0.9])
        translate_z(t - 0.3)
            linear_extrude(0.1)
                difference() {
                    offset(-serpentine_t())
                        shape();

                serpentine();
            }

    color("silver")
        for(side = [-1, 1])
            translate([side * ldr_pitch(type) / 2, 0]) {
                translate_z(-lead_length)
                    cylinder(d = ldr_lead_d(type), h = lead_length, $fn = 16);

                translate_z(t - 0.3)
                    cylinder(d = 1.5 * ldr_lead_d(type), h = 0.2, $fn = 16);
            }
    color([1, 1, 1, 0.25])
        translate_z(t - 0.3 + eps)
            linear_extrude(0.3)
                shape();
}
