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
//! Mini LCD Celsius Digital Thermometer Hygrometer Temperature Humidity Meter Gauge on eBay
//
include <../utils/core/core.scad>
use <../utils/round.scad>

od = 40.9;
h = 14;
flange_d = 45.5;
flange_t = 1.5;
flange_d2 = 32;
flange_t2 = 2;
aperture_d = 24.7;
hygrometer_hole_r = 21.3;
slot_w = 5.5;

module hygrometer_hole(h = 0) { //! Drill the hole for a hygrometer
    extrude_if(h)
        round(cnc_bit_r) {
            intersection() {
                drill(hygrometer_hole_r, 0);

                rotate(30)
                    square([slot_w + 2 * cnc_bit_r, 100], center = true);
            }
            drill((od + 0.2) / 2, 0);
        }
}

function hygrometer_or() = flange_d / 2; //! The outside radius of a hygrometer

module hygrometer() { //! Draw a hygrometer
    vitamin("hygrometer(): Mini LCD Digital Thermometer / Hygrometer");

    $fa = fa; $fs = fs;

    explode(40) {
        color(grey(30))
            rotate_extrude()
                polygon([
                    [0,                0],
                    [aperture_d / 2,   0],
                    [aperture_d / 2,   flange_t],
                    [flange_d2 / 2,    flange_t2],
                    [flange_d / 2,     flange_t],
                    [flange_d / 2,     0],
                    [od / 2,           0],
                    [od / 2,          -h],
                    [0,               -h]
                ]);

        color("#94A7AB")
            cylinder(d = aperture_d, h = eps);

        color("black")
            linear_extrude(0.2, center = true) {
                translate([0, 3])
                    text("20_4", font = "7 segment", valign = "bottom", halign = "center", size = aperture_d / 6);

                translate([7, 3])
                    text("C", font = "7 segment", valign = "bottom", halign = "center", size = aperture_d / 8);

                translate([-1.9, 0.5])
                    text("50", font = "7 segment", valign = "top", halign = "center", size = aperture_d / 2.7);

                translate([0, -aperture_d / 6])
                    text("          %", font = "Arial", valign = "center", halign = "center", size = aperture_d / 6);
            }

    }
}
