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
//! SCSnUU and SCSnLUU bearing blocks
//


include <../utils/core/core.scad>
use <screw.scad>
use <nut.scad>
use <washer.scad>
use <linear_bearing.scad>
use <circlip.scad>

function scs_size(type)                 = [type[4],type[6],type[5]]; //! Size of scs bracket bounding block
function scs_hole_offset(type)          = type[2]; //! Offset of bearing hole from base of block
function scs_block_center_height(type)  = type[6];  //! Height of the center of the block
function scs_block_side_height(type)    = type[7];  //! Height of the side of the block, this determines the minimum screw length
function scs_screw(type)                = type[11]; //! Screw type
function scs_screw_separation_x(type)   = type[8];  //! Screw separation in X direction
function scs_screw_separation_z(type)   = type[9];  //! Screw separation in Z direction
function scs_bearing(type)              = type[14]; //! Linear bearing used
function scs_circlip(type)              = type[15]; //! Circlip used
function scs_spacer(type)               = type[16]; //! Spacer used in long bearings


function sbr_size(type)                 = [type[4],type[6],type[5]]; //! Size of SBR bracket bounding block
function sbr_hole_offset(type)          = type[2]; //! Offset of bearing hole from base of *rail*
function sbr_side_height(type)          = type[3]; //! Height of side above *rail*
function sbr_screw(type)                = type[10]; //! Screw type
function sbr_screw_separation_x(type)   = type[7];  //! Screw separation in X direction
function sbr_screw_separation_z(type)   = type[8];  //! Screw separation in Z direction
function sbr_bearing(type)              = type[12]; //! Linear bearing used
function sbr_circlip(type)              = type[13]; //! Circlip used
function sbr_spacer(type)               = type[14]; //! Spacer used in long bearings


sks_bearing_block_colour = grey(90);

module scs_bearing_block(type) { //! Draw the specified SCS bearing block
    vitamin(str("scs_bearing_block(", type[0], "): ", type[0], " bearing block"));

    T = type[1];
    h = scs_hole_offset(type);
    E = type[3];
    W = scs_size(type)[0];
    assert(W == 2 * E, str("W or E wrong for scs_bearing_block", type[0]));
    L = scs_size(type)[2];
    F = scs_block_center_height(type);
    G = scs_block_side_height(type);
    B = scs_screw_separation_x(type);
    C = scs_screw_separation_z(type);
    K = type[10];
    S1 = scs_screw(type);
    S2 = type[12];
    L1 = type[13];
    bearing = scs_bearing(type);
    clip = scs_circlip(type);

    boltHoleRadius = screw_clearance_radius(S1);
    footHeight = min(0.75, (G - bearing_dia(bearing) - 1.5) / 2); // estimate, not specified on drawings

    color(sks_bearing_block_colour) {
        linear_extrude(L, center = true) {
            bearingRadius = bearing_dia(bearing) / 2;
            // center section with bearing hole
            difference() {
                union() {
                    translate([-(B - 2 * boltHoleRadius) / 2, -h + footHeight])
                        square([B - 2 * boltHoleRadius, G - footHeight]);
                    for(m = [0, 1])
                        mirror([m, 0, 0])
                            translate([0 , G - h])
                                right_trapezoid(bearingRadius, bearingRadius -F + G, F - G);
                }
                circle(r = bearingRadius);
            }
            // add the sides
            for(m = [0, 1])
                mirror([m, 0, 0]) {
                    trapezoidX = boltHoleRadius - 0.5; // estimate, not specified on drawings
                    sideX = 2 * (K - boltHoleRadius - trapezoidX);
                    chamfer = 0.5;
                    assert(sideX > chamfer, "trapezoidX too large in scs_bearing_block");
                    translate([B / 2 + boltHoleRadius, -h]) {
                        square([sideX - chamfer, G]);
                        translate([sideX, 0])
                            rotate(90)
                                right_trapezoid(G - chamfer, G, chamfer);
                        translate([sideX, 0]) {
                            right_trapezoid(trapezoidX - footHeight, trapezoidX, footHeight);
                            translate([trapezoidX, footHeight])
                                rotate(90)
                                    right_trapezoid(T - footHeight, L1 - footHeight, trapezoidX);
                        }
                    }
                    translate([B / 2 - boltHoleRadius, -h])
                        mirror([1, 0, 0])
                            right_trapezoid(boltHoleRadius,  boltHoleRadius + footHeight, footHeight);
                }
        }
        // side blocks with bolt holes
        for(x = [-B / 2, B / 2])
            translate([x, G / 2 - h, 0])
                rotate([90, 0, 0])
                    linear_extrude(G, center = true)
                        difference() {
                            square([boltHoleRadius * 2, L], center = true);
                            for (y = [-C / 2, C / 2])
                                translate([0, y])
                                    circle(r = boltHoleRadius);
                        }
    }
    not_on_bom() no_explode() {
        spacer = scs_spacer(type);
        for(end = spacer ? [-1, 1] : 0)
            translate_z(end * (bearing_length(bearing) + spacer) / 2)
                    linear_bearing(bearing);

        for(end = [-1, 1])
            translate_z(end * ((spacer ? 2 * bearing_length(bearing) + spacer : bearing_length(bearing)) + circlip_thickness(clip)) / 2)
                rotate(180)
                    internal_circlip(clip);
    }
}

module scs_bearing_block_hole_positions(type) { //! Place children at hole positions
    screw_separation_x = scs_screw_separation_x(type);
    screw_separation_z = scs_screw_separation_z(type);
    G = scs_block_side_height(type);
    h = scs_hole_offset(type);

    for(x = [-screw_separation_x, screw_separation_x], z = [-screw_separation_z, screw_separation_z])
        translate([x / 2, G - h, z / 2])
            rotate([-90, 0, 0])
                children();
}

module scs_bearing_block_assembly(type, part_thickness, screw_type, nut_type) { //! Assembly with screws and nuts in place

    scs_bearing_block(type);

    screw_type = is_undef(screw_type) ? scs_screw(type) : screw_type;
    nut_type = is_undef(nut_type) ? screw_nut(screw_type) : nut_type;
    washer_type = nut_washer(nut_type);
    washer_thickness = washer_type ? washer_thickness(washer_type) : 0;

    G = scs_block_side_height(type);
    nut_offset = G + part_thickness + nut_thickness(nut_type) + washer_thickness;
    screw_length = screw_longer_than(nut_offset);

    scs_bearing_block_hole_positions(type) {
        screw(screw_type, screw_length);

        translate_z(-nut_offset)
            nut(nut_type)
                if (washer_type)
                    washer(washer_type);
    }
}

/* SBR bearing blocks */

module sbr_bearing_block(type) { //! Draw the specified SBR bearing block
    vitamin(str("sbr_bearing_block(", type[0], "): ", type[0], " bearing block"));

    T = type[1];
    h = sbr_hole_offset(type);
    H = sbr_side_height(type);

    W = sbr_size(type)[0];
    G = sbr_size(type)[1];
    M = sbr_size(type)[2];
    J = sbr_screw_separation_x(type);
    K = sbr_screw_separation_z(type);
    S1 = sbr_screw(type);
    I = type[11];           // screw length

    S2 = type[15];
    S2L = type[16];

    bearing = sbr_bearing(type);
    clip = sbr_circlip(type);
    chamfer = 1.5;
    A = type[9];            // size of chamfered overhang - vertical
    Ah = A + chamfer * 2;   // size of chamfered overhand - horizontal - not given in drawings

    width = W - (2 * chamfer);
    height = G - chamfer;

    boltHoleRadius = screw_radius(S1);
    setScrewRadius = screw_radius(S2);

    color(sks_bearing_block_colour) {
        render() difference() {
            linear_extrude(M, center = true, convexity=2) {
                cutoutheight = 15; // chosen to fit SBR16, may not work with others
                bearingRadius = bearing_dia(bearing) / 2;
                bearingTheta = open_bearing_theta(bearing);
                bearingOpening = open_bearing_width(bearing);
                bearingOpeningBig = bearingOpening + (tan(bearingTheta/2) * cutoutheight);
                // center section with bearing hole
                difference() {
                    translate([-width/2, -(H-h - chamfer)])
                        square([width, height]);
                    circle(r = bearingRadius);
                    for(m = [0, 1])
                        mirror([m, 0, 0])
                            translate([0, h - (cutoutheight/2) - H + G + 0.1])
                                right_trapezoid(bearingOpening/2, bearingOpeningBig/2, cutoutheight/2);
                }
                // add the sides
                for(m = [0, 1])
                    mirror([m, 0, 0]) {
                        translate([-(W/2) + chamfer, -((H-h))]) {
                            difference() {
                                union() {
                                    right_trapezoid(Ah - chamfer,Ah,chamfer);
                                    rotate([0,0,90])
                                        right_trapezoid(A + chamfer,A,chamfer);
                                }
                                translate([-(chamfer +0.1), -0.1,0])
                                    right_trapezoid(chamfer/2 + 0.2, 0, chamfer/2+ 0.2);
                            }
                        }
                    }
            }
            // bolt holes
            for(x = [-J / 2, J / 2])
                translate([x, h - H + I/2 - 0.1, 0])
                    rotate([90, 0, 0])
                        for (y = [-K / 2, K / 2])
                            translate([0, y])
                                cylinder(r = boltHoleRadius, h=I + 0.1, center=true);

            // set screw holes
            translate([-width/2 + S2L/2 - 0.1,0,0])
                rotate([0,90,0])
                    cylinder(r = setScrewRadius, h=S2L, center=true);

            translate([0,-(H-h) + chamfer + S2L/2 -0.1,0])
                rotate([0,90,90])
                    cylinder(r = setScrewRadius, h=S2L, center=true);

        }
    }
    not_on_bom() no_explode() {
        spacer = sbr_spacer(type);
        for(end = spacer ? [-1, 1] : 0)
            translate_z(end * (bearing_length(bearing) + spacer) / 2)
                rotate([0,0,-90])
                    linear_bearing(bearing);

        for(end = [-1, 1])
            translate_z(end * ((spacer ? 2 * bearing_length(bearing) + spacer : bearing_length(bearing)) + circlip_thickness(clip)) / 2)
                rotate(180)
                    internal_circlip(clip);

        translate([-width/2 - 0.1,0,0])
            rotate([0,90,180])
               screw(S2, S2L);
        translate([0,-(H-h) + chamfer - 0.1,0])
            rotate([0,90,270])
                screw(S2, S2L);
    }
}

module sbr_bearing_block_hole_positions(type) { //! Place children at hole positions
    y = sbr_hole_offset(type) - sbr_side_height(type);
    screw_separation_x = sbr_screw_separation_x(type);
    screw_separation_z = sbr_screw_separation_z(type);

    for(x = [-screw_separation_x, screw_separation_x], z = [-screw_separation_z, screw_separation_z])
        translate([x / 2, y, z / 2])
            rotate([-90, 0, 0])
                children();
}

module sbr_bearing_block_assembly(type, part_thickness, screw_type) { //! Assembly with screws in place

    I = type[11]; // screw length
    sbr_bearing_block(type);
    screw_type = is_undef(screw_type) ? sbr_screw(type) : screw_type;
    G = sbr_size(type)[1];

    screw_length = screw_shorter_than(I + part_thickness);

    translate([0,-part_thickness,0])
        sbr_bearing_block_hole_positions(type)
            rotate([0,180,0])
                screw(screw_type, screw_length);
}

/* Generic bearing block functions */

module right_trapezoid(base, top, height, h = 0, center = true) {//! A right angled trapezoid with the 90&deg; corner at the origin. 3D when `h` is nonzero, otherwise 2D
    extrude_if(h, center = center)
        polygon(points = [ [0,0], [base, 0], [top, height], [0, height] ]);
}
