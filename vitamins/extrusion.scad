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

function extrusion_width(type)          = type[1];   //! Width of extrusion
function extrusion_height(type)         = type[2];   //! Height of extrusion
function extrusion_center_hole(type)    = type[3];   //! Diameter of center hole
function extrusion_corner_hole(type)    = type[4];   //! Diameter of corner hole
function extrusion_center_square(type)  = type[5];   //! Size of center square
function extrusion_channel_width(type)  = type[6];   //! Channel width
function extrusion_channel_width_internal(type)  = type[7];   //! Internal channel width
function extrusion_tab_thickness(type)  = type[8];   //! Tab thickness
function extrusion_spar_thickness(type) = type[9];   //! Spar thickness
function extrusion_fillet(type)         = type[10];  //! Radius of corner fillet

module extrusion_cross_section(type, cornerHole) {

    module extrusion_corner(type, cornerHole) {
        width = extrusion_width(type);
        tabThickness = extrusion_tab_thickness(type);
        sparThickness = extrusion_spar_thickness(type);
        centerSquare = extrusion_center_square(type);
        channelWidth = extrusion_channel_width(type);
        fillet = extrusion_fillet(type);
        cornerSize = (width-channelWidth)/2;
        cornerSquare = (width-extrusion_channel_width_internal(type))/2;
        cornerHoleDiameter = extrusion_corner_hole(type);

        translate([-width/2,-width/2]) {
            difference() {
                union() {
                    translate([fillet,0])
                        square([cornerSize-fillet,tabThickness]);
                    translate([0,fillet])
                        square([tabThickness,cornerSize-fillet]);
                    translate([fillet,fillet])
                        circle(fillet);
                    translate([fillet,fillet])
                        square([cornerSquare-fillet,cornerSquare-fillet]);
                }
                if(cornerHole && cornerHoleDiameter > 0)
                    translate([cornerSquare/2,cornerSquare/2])
                        circle(d=cornerHoleDiameter);
            }
        }
        rotate(-135) translate([centerSquare/2,-sparThickness/2]) square([sqrt(2)*(width-centerSquare-cornerSquare)/2,sparThickness]);
    }

    module extrusion_center_section(type) {
        width = extrusion_width(type);
        tabThickness = extrusion_tab_thickness(type);
        sparThickness = extrusion_spar_thickness(type);
        centerSquare = extrusion_center_square(type);
        channelWidth = extrusion_channel_width(type);

        translate([0,width/2])
            for(angle=[225,315])
                rotate(angle)
                    translate([centerSquare/2,-sparThickness/2])
                        square([sqrt(2)*(width-centerSquare)/2,sparThickness]);
        translate([0,-width/2])
            for(angle=[45,135])
                rotate(angle)
                    translate([centerSquare/2,-sparThickness/2])
                        square([sqrt(2)*(width-centerSquare)/2,sparThickness]);

        centerHeight = width-channelWidth;
        translate([-width/2,-centerHeight/2])
            square([tabThickness,centerHeight]);
        translate([width/2-tabThickness,-centerHeight/2])
            square([tabThickness,centerHeight]);
    }


    centerSquare = extrusion_center_square(type);

    width = extrusion_width(type);
    height = extrusion_height(type);
    count = (height-width)/width;

    for(i=[0:count])
        translate([0,i*width+(width-height)/2])
            difference() {
                square([centerSquare,centerSquare],center=true);
                if(extrusion_center_hole(type)>0)
                    circle(d=extrusion_center_hole(type));
            }
    translate([0,(width-height)/2])
        for(angle=[0,90])
            rotate(angle)
                extrusion_corner(type, cornerHole);
    translate([0,-(width-height)/2])
        for(angle=[180,270])
            rotate(angle)
                extrusion_corner(type, cornerHole);
    if(count>=1)
        for(i=[1:count])
            translate([0,i*width-height/2])
                extrusion_center_section(type);
}

module extrusion(type, length, center = true, cornerHole = false) { //! Draw the specified extrusion

    vitamin(str("extrusion(", type[0], ", ", length, arg(cornerHole, false, "cornerHole"), "): Extrusion ", type[0], " x ", length, "mm"));

    color(grey(90))
        linear_extrude(length, center = center)
            extrusion_cross_section(type, cornerHole);
}
