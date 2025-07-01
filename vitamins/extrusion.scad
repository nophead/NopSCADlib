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
//! Aluminium  extrusion.
//
include <../utils/core/core.scad>

function extrusion_width(type)                  = type[1];  //! Width of extrusion
function extrusion_height(type)                 = type[2];  //! Height of extrusion
function extrusion_center_hole_wd(type)         = type[3];  //! Diameter of center hole if -ve or square side if +ve
function extrusion_corner_hole_wd(type)         = type[4];  //! Diameter of corner hole if -ve or square side if +ve
function extrusion_center_square_wd(type)       = type[5];  //! Size of center square if +ve or tube diameter if -ve
function extrusion_channel_width(type)          = type[6];  //! Channel width
function extrusion_channel_width_internal(type) = type[7];  //! Internal channel width
function extrusion_tab_thickness(type)          = type[8];  //! Tab thickness
function extrusion_spar_thickness(type)         = type[9];  //! Spar thickness
function extrusion_fillet(type)                 = type[10]; //! Radius of corner fillet
function extrusion_channel_recess(type)         = type[11]; //! Channel recess width and depth or false in none

function extrusion_center_hole(type)            = abs(extrusion_center_hole_wd(type));  //! Diameter of center hole or side if square
function extrusion_corner_hole(type)            = abs(extrusion_corner_hole_wd(type));  //! Diameter of corner hole or side if square
function extrusion_center_square(type)          = abs(extrusion_center_square_wd(type)); //! Size of center square or tube

module extrusion_cross_section(type, cornerHole=true) {
    width = extrusion_width(type);
    height = extrusion_height(type);
    centerSquare = extrusion_center_square(type);
    tabThickness = extrusion_tab_thickness(type);
    sparThickness = extrusion_spar_thickness(type);
    channelWidth = extrusion_channel_width(type);
    recess = extrusion_channel_recess(type);
    cornerSquare = (width - extrusion_channel_width_internal(type)) / 2;

    module squircle(d) // Draw a square if positive else a circle
        if(d > 0)
            square([d, d], center = true);
        else
            if(d < 0)
                circle(d = -d);

    module extrusion_corner(type) {
        fillet = extrusion_fillet(type);
        cornerSize = (width - channelWidth) / 2;
        cornerHoleDiameter = abs(extrusion_corner_hole(type));

        translate([-width / 2, -width / 2]) {
            difference() {
                union() {
                    translate([fillet, 0])
                        square([cornerSize - fillet, tabThickness]);

                    translate([0, fillet])
                        square([tabThickness, cornerSize - fillet]);

                    translate([fillet, fillet])
                        circle(fillet);

                    translate([fillet, fillet])
                        square([cornerSquare - fillet, cornerSquare - fillet]);
                }
                if(cornerHole && cornerHoleDiameter)
                    translate([cornerSquare / 2, cornerSquare / 2])
                        squircle(extrusion_corner_hole_wd(type));
             }
        }
    }

    module extrusion_center_section(type) {
        for(side = [-1, 1]) {
            translate([side * (width / 2 - tabThickness / 2), 0])
                square([tabThickness, width - channelWidth], center = true);

            l = cornerSquare + sparThickness * tan(22.5) - sparThickness / sqrt(2);
            for(end = [-1, 1])
                translate([side * (width / 2 - l / 2), end * (cornerSquare - sparThickness / 2)])
                    square([l, sparThickness], center = true);
        }
    }


    count = height / width - 1;

    difference() {
        union() {
            for(i = [0 : count])
                translate([0, i * width + (width - height) / 2]) {
                    difference() {
                        union() {
                            squircle(extrusion_center_square_wd(type));

                            for(j = [0 : 3])
                                rotate(45 + 90 * j)
                                    translate([centerSquare / 2 - sparThickness / 2, -sparThickness / 2])
                                        square([width / sqrt(2) - cornerSquare * sqrt(2) - centerSquare / 2 + sparThickness *(1 + tan(22.5)), sparThickness]);
                        }
                        squircle(d = extrusion_center_hole_wd(type));
                    }
                }

            for(side = [-1, 1])
                translate([0, side * (width - height) / 2])
                    for(angle = [0, 90])
                        rotate(angle + (side < 0 ? 180 : 0))
                            extrusion_corner(type);

            if(count >= 1)
                for(i = [1 : count])
                    translate([0, i * width - height / 2])
                        extrusion_center_section(type);
        }
        if(recess)
            for(i = [0 : count], j = [0 : 3])
                translate([0, i * width + (width - height) / 2])
                    rotate(j * 90)
                        translate([width / 2, 0])
                            square([recess.y * 2, recess.x], center = true);
    }
}

module extrusion(type, length, center = true, cornerHole = true) { //! Draw the specified extrusion

    vitamin(str("extrusion(", type[0], ", ", length, arg(cornerHole, false, "cornerHole"), "): Extrusion ", type[0], " x ", length, "mm"));

    color(grey(90))
        linear_extrude(length, center = center, convexity = 8)
            extrusion_cross_section(type, cornerHole);
}
