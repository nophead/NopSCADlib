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
include <../utils/core/core.scad>
use <../printed/press_fit.scad>

module press_fits()
{
    thickness = 2;
    width = 20;
    vthickness = 4;

    translate([0, width + 2])
        difference() {
            cube([width, width, thickness]);

            for(x = [0.25, 0.75])
                for(y = [0.25, 0.75])
                    translate([x * width, y * width])
                        press_fit_socket();
        }

    union() {
        cube([width, width, thickness]);

        for(x = [0.25, 0.75])
            for(y = [0.25, 0.75])
                translate([x * width, y * width, thickness])
                    press_fit_peg(h = thickness);
    }

    translate([width + 2, width + 2])
        difference() {
            cube([width, vthickness, width]);

            for(x = [0.25, 0.75])
                for(y = [0.25, 0.75])
                    translate([x, 0, y] * width)
                        rotate([90, 0, 0])
                            press_fit_socket();
        }

    translate([width + 2, 0])
        union() {
            cube([width, width, thickness]);

            for(x = [0.25, 0.75])
                for(y = [0.25, 0.75])
                    translate([x * width, y * width, thickness])
                        press_fit_peg(h = vthickness, horizontal = true);
        }

}


press_fits();
