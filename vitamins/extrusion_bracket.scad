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

//! Brackets for joining extrusions at a corner.

include <../core.scad>
include <../utils/thread.scad>

use <extrusion.scad>

function extrusion_inner_corner_bracket_size(type)          = type[1]; //! Size of inner bracket
function extrusion_inner_corner_bracket_tnut(type)          = type[2]; //! The sliding t-nut it is based on
function extrusion_inner_corner_bracket_extrusion(type)     = type[3]; //! Default extrusion this bracket is for
function extrusion_inner_corner_bracket_screw_offsets(type) = type[4]; //! Screw offsets from the ends

module extrusion_inner_corner_bracket(type, grub_screws = true, backwards = false, extrusion = undef) {  //! Inner corner bracket for extrusion
  extrusion = is_undef(extrusion) ? extrusion_inner_corner_bracket_extrusion(type) : extrusion;
  vitamin(str("extrusion_inner_corner_bracket(", type[0], "): Extrusion inner corner bracket for ", extrusion[0]));

  size = extrusion_inner_corner_bracket_size(type);
  tnut = extrusion_inner_corner_bracket_tnut(type);
  screw_offsets = extrusion_inner_corner_bracket_screw_offsets(type);
  bottomTabOffset = 4;
  topTabOffset = 10;
  sizeBottom = [size.y - bottomTabOffset, nut_square_width(tnut), size.z];
  sizeTop = [size.x - topTabOffset, nut_square_width(tnut), size.z];
  tab = t_nut_tab(tnut);
  tabSizeZ = nut_thickness(tnut);
  screw = find_screw(hs_grub, nut_size(tnut));
  holeRadius = screw_pilot_hole(screw);
  depth = (extrusion_width(extrusion) - extrusion_center_square(extrusion)) / 2;

  offset = extrusion_tab_thickness(extrusion) + tabSizeZ;
  offset2 = extrusion_tab_thickness(extrusion) - nut_thickness(tnut, true) + nut_thickness(tnut);
  translate([backwards ? offset2 : -offset, -offset])
    rotate([-90, 0, 0]) {
      color("silver") {
        translate([(size.y + bottomTabOffset) / 2, 0, tabSizeZ])
          rotate([0, 180, 0])
            extrusionSlidingNut(sizeBottom, tab[0], tab[1], tabSizeZ, holeRadius, (bottomTabOffset - size.y) / 2 + screw_offsets.y);

        translate([tabSizeZ, 0, (size.x + topTabOffset) / 2])
          rotate([0, -90, 0])
            extrusionSlidingNut(sizeTop, tab[0], tab[0], tabSizeZ, holeRadius, -(topTabOffset - size.x) / 2 - screw_offsets.x);

        translate([0, -tab[1] / 2]) {
          cube([bottomTabOffset, tab[1], size.z]);
          cube([size.z, tab[1], topTabOffset]);
        }
      }
      if (grub_screws)
        not_on_bom() no_explode() {
            screw_len = screw_shorter_than(depth);
            gap = depth - screw_len;
            screw_z = offset - gap;

            rotate([0, -90, 180]) if (backwards)
              translate([size.x - screw_offsets.x, 0, -offset2 + gap])
                vflip()
                  screw(screw, screw_len);
            else
              translate([size.x - screw_offsets.x, 0, screw_z])
                screw(screw, screw_len);

            translate([size.y - screw_offsets.y, 0, screw_z])
              screw(screw, screw_len);
          }
    }
}

function extrusion_corner_bracket_size(type)           = type[1]; //! Size of bracket
function extrusion_corner_bracket_base_thickness(type) = type[2]; //! Thickness of base of bracket
function extrusion_corner_bracket_side_thickness(type) = type[3]; //! Thickness of side of bracket
function extrusion_corner_bracket_hole_offset(type)    = type[4]; //! Hole offset from corner
function extrusion_corner_bracket_tnut(type)           = type[5]; //! The sliding t-nut to use in the assembly
function extrusion_corner_bracket_extrusion(type)      = type[6]; //! Default extrusion this bracket is for

module extrusion_corner_bracket(type) {  //! Corner bracket for extrusion
  vitamin(str("extrusion_corner_bracket(", type[0], "): Extrusion corner bracket ", type[1].z, "mm for ", extrusion_corner_bracket_extrusion(type)[0]));

  eSize = extrusion_corner_bracket_size(type).z;
  cbSize = extrusion_corner_bracket_size(type).x;
  baseThickness = extrusion_corner_bracket_base_thickness(type);
  hole_r = screw_clearance_radius(find_screw(hs_cap, nut_size(extrusion_corner_bracket_tnut(type))));

  module base() {
    linear_extrude(baseThickness)
      difference() {
        translate([0, -eSize / 2])
          square([cbSize, eSize]);

        hull() {
          translate([extrusion_corner_bracket_hole_offset(type) + 1.5, 0])
            circle(hole_r);

          translate([extrusion_corner_bracket_hole_offset(type) - 1.5, 0])
            circle(hole_r);
        }
      }
  }

  color("silver") {
    rotate([90, 0, 90])
      base();

    translate([0, baseThickness])
      rotate([90, 0, 0])
        base();

    sideThickness = extrusion_corner_bracket_side_thickness(type);
    for (z = [-eSize / 2, eSize / 2 - sideThickness]) {
      translate_z(z) {
        right_triangle(cbSize, cbSize, sideThickness, center=false);
        cube([5, cbSize, sideThickness]);
        cube([cbSize, 5, sideThickness]);
      }
    }
  }
}

module extrusion_corner_bracket_hole_positions(type) {
  //! Place children at hole positions
  for (angle = [[0, 90, 0], [-90, -90, 0]])
    rotate(angle)
      translate([0, extrusion_corner_bracket_hole_offset(type), extrusion_corner_bracket_base_thickness(type)])
        children();
}

module extrusion_corner_bracket_assembly(type, part_thickness = undef, screw_type = undef, nut_type = undef, max_screw_depth = undef, extrusion = undef) {  //! Assembly with fasteners in place
  extrusion_corner_bracket(type);
  extrusion = is_undef(extrusion) ? extrusion_corner_bracket_extrusion(type) : extrusion;

  nut = is_undef(nut_type) ? extrusion_corner_bracket_tnut(type) : nut_type;
  screw = is_undef(screw_type) ? find_screw(hs_cap, nut_size(nut)) : screw_type;
  thickness = is_undef(part_thickness) ? extrusion_tab_thickness(extrusion) : part_thickness;
  depth = is_undef(max_screw_depth) ? (extrusion_width(extrusion) - extrusion_center_square(extrusion)) / 2 - eps : max_screw_depth;

  screw_washer_thickness = washer_thickness(screw_washer(screw));
  nut_washer_type = nut_washer(nut);
  nut_washer_thickness = nut_washer_type ? washer_thickness(nut_washer_type) : 0;

  nut_offset = extrusion_corner_bracket_base_thickness(type) + thickness;
  screw_length =
    depth ? screw_shorter_than(extrusion_corner_bracket_base_thickness(type) + screw_washer_thickness + depth)
    : screw_longer_than(nut_offset + screw_washer_thickness + nut_washer_thickness + nut_thickness(nut));

  extrusion_corner_bracket_hole_positions(type) {
    screw_and_washer(screw, screw_length);
    translate_z(-nut_offset)
      vflip() if (nut_washer_type)
        nut_and_washer(nut);
      else
        rotate(90)
          sliding_t_nut(nut);
  }
}

function extrusion_corner_bracket_3D_outer_side_length(type) = type[1];   //! The length of the base cuboid sides
function extrusion_corner_bracket_3D_outer_height(type) = type[2];        //! The height of the cuboid
function extrusion_corner_bracket_3D_inner_side_length(type) = type[3];   //! The length of the dip in the cuboid sides
function extrusion_corner_bracket_3D_inner_height(type) = type[4];        //! The depth offset of the dip in the cuboid

function extrusion_corner_bracket_3D_nut_screw(type) = type[5];           //! The screw (most likely Mx_grub_screw from <NopSCADlib/vitamins/screws.scad>)
function extrusion_corner_bracket_3D_nut_dia(type) = type[6];             //! The width of bottom part of the nut
function extrusion_corner_bracket_3D_nut_thickness(type) = type[7];       //! The thickness of the top part of the nut
function extrusion_corner_bracket_3D_nut_nyloc_thickness(type) = type[8]; //! The total thickness of the nut
function extrusion_corner_bracket_3D_nut_sx(type) = type[9];              //! The length of the nuts
function extrusion_corner_bracket_3D_nut_ty1(type) = type[10];            //! The total width of the nut
function extrusion_corner_bracket_3D_nut_ty2(type) = type[11];            //! The width of the top edge of the nut
function extrusion_corner_bracket_3D_nut_screws_hor(type) = type[12];     //! The positions of the screw holes on the horizontal arms, expressed in %/100 of the nut arm
function extrusion_corner_bracket_3D_nut_screws_ver(type) = type[13];     //! The positions of the screw holes on the vertical arms, expressed in %/100 of the nut arm

function extrusion_corner_bracket_3D_get_y_offset(type) = [0, -extrusion_corner_bracket_3D_outer_side_length(type) / 2, extrusion_corner_bracket_3D_nut_nyloc_thickness(type)]; //! helper function to position the y beam
function extrusion_corner_bracket_3D_get_y_rot(type) = [90, 0, 0]; //! helper function to rotate the y beam
function extrusion_corner_bracket_3D_get_x_offset(type) = [extrusion_corner_bracket_3D_outer_side_length(type) / 2, 0, extrusion_corner_bracket_3D_nut_nyloc_thickness(type)]; //! helper function to position the x beam
function extrusion_corner_bracket_3D_get_x_rot(type) = [0, 90, 0]; //! helper function to rotate the y beam

module extrusion_corner_bracket_3D(type, grub_screws = true) {  //! draw the specified extrusion_corner_bracket_3D
    vitamin(str("extrusion_corner_bracket_3D(", type[0], "): Extrusion corner bracket 3D mm for E", slice(type[0], -4)));


  nut_screw_dia = screw_radius(extrusion_corner_bracket_3D_nut_screw(type) * 2);
  nut_dia = extrusion_corner_bracket_3D_nut_dia(type);
  nut_thickness = extrusion_corner_bracket_3D_nut_thickness(type);
  nut_nyloc_thickness = extrusion_corner_bracket_3D_nut_nyloc_thickness(type);
  nut_sx = extrusion_corner_bracket_3D_nut_sx(type);
  nut_ty1 = extrusion_corner_bracket_3D_nut_ty1(type);
  nut_ty2 = extrusion_corner_bracket_3D_nut_ty2(type);

  nut_profile = [
    [0, nut_dia / 2],
    [nut_nyloc_thickness - nut_thickness, nut_dia / 2],
    [nut_nyloc_thickness - nut_thickness, nut_ty1 / 2],
    [nut_nyloc_thickness - nut_thickness + (nut_ty1 - nut_ty2) / 2, nut_ty1 / 2],
    [nut_nyloc_thickness, nut_ty2 / 2],
    [nut_nyloc_thickness, -nut_ty2 / 2],
    [nut_nyloc_thickness - nut_thickness + (nut_ty1 - nut_ty2) / 2, -nut_ty1 / 2],
    [nut_nyloc_thickness - nut_thickness, -nut_ty1 / 2],
    [nut_nyloc_thickness - nut_thickness, -nut_dia / 2],
    [0, -nut_dia / 2],
  ];

  grub_screw = extrusion_corner_bracket_3D_nut_screw(type);

  outer_side_length = extrusion_corner_bracket_3D_outer_side_length(type);
  outer_height = extrusion_corner_bracket_3D_outer_height(type);
  inner_side_length = extrusion_corner_bracket_3D_inner_side_length(type);
  inner_height = extrusion_corner_bracket_3D_inner_height(type);
  inner_offset_z = outer_height - inner_height + 0.01;

  //position the nuts on the base
  positions_horizontal = [
    [outer_side_length / 2, 0.001, 0, 0, 270, 90],
    [outer_side_length - 0.001, outer_side_length / 2, 0, 0, 270, 180],
  ];
  positions_vertical = [
    [0, outer_side_length / 2, inner_offset_z, 0, 0, 0],
    [outer_side_length / 2, outer_side_length, inner_offset_z, 0, 0, 270],
  ];

  //the radius of the base corners
  r = 1;

  //offset so everything is centered for easy attachment to extrusion
  translate([-outer_side_length / 2, -outer_side_length / 2, -outer_height]) {

    color("silver")
      union() {
        //create the base
        difference() {
          rounded_cube_xy([outer_side_length, outer_side_length, outer_height], r=r);
          translate([(outer_side_length - inner_side_length) / 2, (outer_side_length - inner_side_length) / 2, inner_offset_z])
            rounded_cube_xy([inner_side_length, inner_side_length, inner_height], r=r);
        }

        for (pos = positions_horizontal) {
          translate([pos[0], pos[1], pos[2]])
            rotate([pos[3], pos[4], pos[5]])
              difference() {
                linear_extrude(nut_sx, convexity=3)
                  polygon(nut_profile);
                //create the screw holes
                for (dist = extrusion_corner_bracket_3D_nut_screws_hor(type)) {
                  translate([-0.01, 0, nut_sx * dist])
                    rotate([0, 90, 0])
                      difference() {
                        cylinder(h=nut_nyloc_thickness + 0.02, d=nut_screw_dia, center=false);
                        if (show_threads) {
                          female_metric_thread(nut_screw_dia, metric_coarse_pitch(nut_screw_dia), nut_nyloc_thickness, center=false);
                        }
                      }
                  if (grub_screws) {
                    screw(grub_screw, nut_nyloc_thickness);
                  }
                }
              }
        }
        for (pos = positions_vertical) {
          translate([pos[0], pos[1], pos[2]])
            rotate([pos[3], pos[4], pos[5]]) {
              difference() {
                linear_extrude(nut_sx, convexity=3)
                  polygon(nut_profile);
                //create the screw holes
                for (dist = extrusion_corner_bracket_3D_nut_screws_ver(type)) {
                  translate([-0.01, 0, nut_sx * dist])
                    rotate([0, 90, 0])
                      difference() {
                        cylinder(h=nut_nyloc_thickness + 0.02, d=nut_screw_dia, center=false);
                        if (show_threads) {
                          female_metric_thread(nut_screw_dia, metric_coarse_pitch(nut_screw_dia), nut_nyloc_thickness, center=false);
                        }
                      }
                }
              }
            }
        }
      }

    if (grub_screws) {
      for (pos = positions_horizontal) {
        translate([pos[0], pos[1], pos[2]])
          rotate([pos[3], pos[4], pos[5]]) {
            for (dist = extrusion_corner_bracket_3D_nut_screws_hor(type)) {
              translate([-0.01, 0, nut_sx * dist])
                rotate([180, 90, 0])

                  screw(grub_screw, nut_nyloc_thickness);
            }
          }
      }
      for (pos = positions_vertical) {
        translate([pos[0], pos[1], pos[2]])
          rotate([pos[3], pos[4], pos[5]]) {
            for (dist = extrusion_corner_bracket_3D_nut_screws_ver(type)) {
              translate([-0.01, 0, nut_sx * dist])
                rotate([180, 90, 0])
                  screw(grub_screw, nut_nyloc_thickness);
            }
          }
      }
    }
  }
}
