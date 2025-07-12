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
//! Default is steel but can be drawn as brass or nylon. A utility for making nut traps included.
//!
//! 3D corner connector with t-nut 
//!
//! The following diagram shows you the parameters for the nut parameters:
//!
//! ![](docs/sliding_t_nut.png)
//

include <NopSCADlib/core.scad>
include <NopSCADlib/utils/thread.scad>



function outer_side_length(type) = type[1]; //! The length of the base cuboid sides
function outer_height(type) = type[2]; //! The height of the cuboid 
function inner_side_length(type)= type[3]; //! The length of the dip in the cuboid sides
function inner_height(type) = type[4]; //! The depth offset of the dip in the cuboid

function nut_screw_dia(type) = type[5]; //! The diameter of the screw
function nut_dia(type) = type[6]; //! The width of bottom part of the nut
function nut_thickness(type) = type[7]; //! The thickness of the top part of the nut
function nut_nyloc_thickness(type) = type[8]; //! The total thickness of the nut
function nut_sx(type) = type[9]; //! The lenght of the nuts
function nut_ty1(type) = type[10]; //! The total width of the nut
function nut_ty2(type) = type[11]; //! The width of the top edge of the nut
function nut_screws_hor(type)=type[12]; //! The positions of the screw holes on the horizontal arms, expressed in %/100 of the nut arm
function nut_screws_ver(type)=type[13]; //! The positions of the screw holes on the vertical arms, expressed in %/100 of the nut arm


module corner_3d_connector (type, thread = false) {
    nut_screw_dia = nut_screw_dia(type);
    nut_dia = nut_dia(type);
    nut_thickness = nut_thickness(type);
    nut_nyloc_thickness = nut_nyloc_thickness(type);
    nut_sx = nut_sx(type);
    nut_ty1 = nut_ty1(type);
    nut_ty2= nut_ty2(type);

    

nut_profile = [
    [0, nut_dia/2],
    [nut_nyloc_thickness-nut_thickness, nut_dia/2],
    [nut_nyloc_thickness-nut_thickness, nut_ty1/2],
    [nut_nyloc_thickness-nut_thickness + (nut_ty1-nut_ty2)/2, nut_ty1/2],
    [nut_nyloc_thickness, nut_ty2/2],
    [nut_nyloc_thickness, -nut_ty2/2],
    [nut_nyloc_thickness-nut_thickness + (nut_ty1-nut_ty2)/2, -nut_ty1/2],
    [nut_nyloc_thickness-nut_thickness, -nut_ty1/2],
    [nut_nyloc_thickness-nut_thickness, -nut_dia/2],
    [0, -nut_dia/2]
];


    outer_side_length = outer_side_length(type);
    outer_height = outer_height(type);
    inner_side_length= inner_side_length(type);
    inner_height = inner_height(type);
    inner_offset_z = outer_height-inner_height+0.01;
    r=1;
    color("lightgray")
    union() {
    
    //create the base
    difference () {
        rounded_cube_xy([outer_side_length, outer_side_length, outer_height], r=r);
        translate([(outer_side_length-inner_side_length)/2,(outer_side_length-inner_side_length)/2,inner_offset_z])
        rounded_cube_xy([inner_side_length, inner_side_length, inner_height], r=r);
    }
    
    //position the nuts on the base
    positions_horizontal = [
        [outer_side_length/2,0.001,nut_nyloc_thickness,0,90,270],
        [outer_side_length-0.001,outer_side_length/2,nut_nyloc_thickness, 0,90,0]
    ];
    positions_vertical = [
        [0,outer_side_length/2,inner_offset_z,0,0,0],
        [outer_side_length/2,outer_side_length,inner_offset_z,0,0,270],
    ];
    

     for (pos = positions_horizontal) {
        translate([pos[0],pos[1],pos[2]])
        rotate([pos[3],pos[4],pos[5]])
            difference() {
            linear_extrude(nut_sx)
            polygon(nut_profile);
            //create the screw holes
            for ( dist = nut_screws_hor(type) ){
            translate([-0.01,0,nut_sx*dist])
                rotate([0,90,0])
                difference() {
                    cylinder(h = nut_nyloc_thickness+0.02, d=nut_screw_dia, center = false);
                    if(thread)
                    female_metric_thread(nut_screw_dia, metric_coarse_pitch(nut_screw_dia), nut_nyloc_thickness, center = false);
                }
            }
        }
     }
     for (pos = positions_vertical) {
        translate([pos[0],pos[1],pos[2]])
        rotate([pos[3],pos[4],pos[5]])
            difference() {
            linear_extrude(nut_sx)
            polygon(nut_profile);
            //create the screw holes
            for ( dist = nut_screws_ver(type) ){
            translate([-0.01,0,nut_sx*dist])
                rotate([0,90,0])
                difference() {
                    cylinder(h = nut_nyloc_thickness+0.02, d=nut_screw_dia, center = false);
                    if(thread)
                    female_metric_thread(nut_screw_dia, metric_coarse_pitch(nut_screw_dia), nut_nyloc_thickness, center = false);
                }
            }
        }
     }
}
}