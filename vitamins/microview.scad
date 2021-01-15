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
//! Microview OLED display with on board AVR by geekammo / Sparkfun.
//!
//! `microview()` generates the model. `microview(true)` makes an object to cut out a panel aperture for it.
//!
//! Uses STL files copyright geekammo and licenced with MIT license, see [microview/LICENSE.txt](vitamins/microview/LICENSE.txt).
//
include <../utils/core/core.scad>
include <pin_headers.scad>

panel_clearance = 0.2;

module microview(cutout = false) {  //! Draw microview or generate a panel cutout for it
    rotate([0, 0, -90])
        if(cutout)
            linear_extrude(100)
                offset(panel_clearance)
                    projection()
                         hull()
                            import("microview/GKM-003_R05_CHIP_LOWER_HOUSING.stl");
        else {
            vitamin("microview(): Microview OLED display");

            translate_z(8.35) {

                color("black")
                    import("microview/GKM-002_R05_CHIP_UPPER_HOUSING-1.STL", convexity = 2);

                translate([-2, 0, 0])
                    color("dimgray")
                        cube([12.5, 15.5, 4.41], center = true);
            }
            color("dimgray")
                import("microview/GKM-003_R05_CHIP_LOWER_HOUSING.STL", convexity = 2);

            for(side = [-1, 1], i = [0 : 7])
                translate([side * inch(0.35), (i - 3.5) * inch(0.1)])
                    pin(2p54header);
        }
}
