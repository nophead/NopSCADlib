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
//! Parameterised Core XY implementation. Draws the belts and provides utilities for positioning the pulleys.
//!
//! The belts are positioned according the bottom left "anchor" pulley and the top right drive pulley.
//! Implementation has the following features:
//!
//! 1. The drive and idler pulleys may be different sizes.
//! 2. The belt separation is parameterised.
//! 3. The separation of the plain and toothed pulleys on the Y carriages is parameterised, in both the X and the Y direction.
//! 4. The drive pulleys may be offset in the X and Y directions. If this is done, extra idler pulleys are added. This
//! allows flexible positioning of the motors.
//
include <../core.scad>
include <../vitamins/belts.scad>
include <../vitamins/pulleys.scad>


coreXY_GT2_20_20 = ["coreXY_20_20", GT2x6, GT2x20ob_pulley, GT2x20_toothed_idler, GT2x20_plain_idler, [0, 0, 1], [0, 0, 0.5, 1], [0, 1, 0], [0, 0.5, 0, 1] ];
coreXY_GT2_20_16 = ["coreXY_20_16", GT2x6, GT2x20ob_pulley, GT2x16_toothed_idler, GT2x16_plain_idler, [0, 0, 1], [0, 0, 0.5, 1], [0, 1, 0], [0, 0.5, 0, 1] ];
coreXY_GT2_16_16 = ["coreXY_16_16", GT2x6, GT2x16_pulley,   GT2x16_toothed_idler, GT2x16_plain_idler, [0, 0, 1], [0, 0, 0.5, 1], [0, 1, 0], [0, 0.5, 0, 1] ];

function coreXY_belt(type)                  = type[1]; //! Belt type
function coreXY_drive_pulley(type)          = type[2]; //! Drive pulley type
function coreXY_toothed_idler(type)         = type[3]; //! Toothed idler type
function coreXY_plain_idler(type)           = type[4]; //! Plain idler type
function coreXY_upper_belt_colour(type)     = type[5]; //! Colour of the upper belt
function coreXY_upper_tooth_colour(type)    = type[6]; //! Colour of the upper belt's teeth
function coreXY_lower_belt_colour(type)     = type[7]; //! Colour of the lower belt
function coreXY_lower_tooth_colour(type)    = type[8]; //! Colour of the lower belt's teeth

// used to offset the position of the drive pulley and the y-carriage plain idler pulley
// relative to the anchor pulley so that the belts align properly
function coreXY_drive_pulley_x_alignment(type) = //! Belt alignment offset of the drive pulley relative to the anchor pulley
    (pulley_od(coreXY_drive_pulley(type)) - pulley_od(coreXY_toothed_idler(type))) / 2;

function coreXY_coincident_separation(type) = //! Value of x, y separation to make y-carriage pulleys coincident
    [ -coreXY_plain_idler_offset(type).x, -(pulley_od(coreXY_plain_idler(type)) + pulley_od(coreXY_toothed_idler(type)))/2, 0 ];

function coreXY_plain_idler_offset(type)    = //! Offset of y-carriage plain idler
    [ (pulley_od(coreXY_plain_idler(type)) + pulley_od(coreXY_drive_pulley(type))) / 2 + coreXY_drive_pulley_x_alignment(type), pulley_od(coreXY_plain_idler(type))/2, 0 ];

function coreXY_toothed_idler_offset(type)  = //! offset of y-carriage toothed idler
    [ 0, -pulley_pr(coreXY_toothed_idler(type)), 0 ];

// helper functions for positioning idlers when the stepper motor drive pulley is offset
function coreXY_drive_toothed_idler_offset(type) = //! Offset of toothed drive idler pulley
    [ 0, coreXY_drive_pulley_x_alignment(type), 0 ];

function coreXY_drive_plain_idler_offset(type) = //! Offset of plain drive idler pulley
    [ coreXY_plain_idler_offset(type).x, -(pulley_od(coreXY_plain_idler(type)) + pulley_od(coreXY_drive_pulley(type))) / 2, 0 ];


module coreXY_half(type, size, pos, separation_y = 0, x_gap = 0, plain_idler_offset = 0, drive_pulley_offset = [0, 0], show_pulleys = false, lower_belt = false, hflip = false) { //! Draw one belt of a coreXY setup

    // y-carriage toothed pulley
    p0_type = coreXY_toothed_idler(type);
    p0 = [ size.x / 2, -size.y / 2 - pulley_od(p0_type) / 2 + pos.y - separation_y / 2 ];

    // bottom right toothed idler pulley
    p1_type = p0_type;
    p1 = [ size.x / 2, -size.y / 2 ];

    // bottom left anchor toothed idler pulley
    p2_type = p0_type;
    p2 = [ -size.x / 2, -size.y / 2 ];

    // stepper motor drive pulley
    p3d_type = coreXY_drive_pulley(type);
    p3d = [ -size.x / 2 + coreXY_drive_pulley_x_alignment(type) + drive_pulley_offset.x,
             size.y / 2 + drive_pulley_offset.y
    ];

    // toothed idler for offset stepper motor drive pulley
    p3t_type = coreXY_toothed_idler(type);
    p3t = [ -size.x / 2 + (drive_pulley_offset.x > 0 ? 0 : 2 * coreXY_drive_pulley_x_alignment(type)),
            size.y / 2 + coreXY_drive_pulley_x_alignment(type) + drive_pulley_offset.y
    ];

    // y-carriage plain pulley
    p4_type = coreXY_plain_idler(type);
    p4 = [ -size.x / 2 + pulley_od(p4_type) / 2 + pulley_od(p3d_type) / 2 + coreXY_drive_pulley_x_alignment(type) + plain_idler_offset,
           -size.y / 2 + pulley_od(p4_type) / 2 + pos.y + separation_y / 2
    ];

    // plain idler for offset stepper motor drive pulley
    p3p_type = p4_type;
    p3p = [ drive_pulley_offset.x > 0 ? p4.x : -p0.x - pulley_od(p0_type),
            size.y / 2 - pulley_od(p3p_type) / 2 - pulley_od(p3d_type) / 2 + drive_pulley_offset.y
    ];

    // Start and end points
    start_p = [ pos.x - size.x / 2 + x_gap / 2, -size.y / 2 + pos.y - separation_y / 2, 0 ];
    end_p   = [ pos.x - size.x / 2 - x_gap / 2, -size.y / 2 + pos.y + separation_y / 2, 0 ];

    //p6_type = p0_type;

    module show_pulleys(show_pulleys) {// Allows the pulley colour to be set for debugging
        if (is_list(show_pulleys))
            color(show_pulleys)
                children();
        else if (show_pulleys)
            children();
    }

    show_pulleys(show_pulleys) {
        translate(p0)
            pulley_assembly(p0_type); // y-carriage toothed pulley

        translate(p1)
            pulley_assembly(p1_type); // bottom right toothed idler pulley

        translate(p2)
            pulley_assembly(p2_type); // bottom left anchor toothed idler pulley

        translate(p3d)
            hflip(hflip)
                pulley_assembly(p3d_type); // top left stepper motor drive pulley

        if (drive_pulley_offset.x) { // idler pulleys for offset stepper motor drive pulley
            translate(p3t)
                pulley_assembly(p3t_type); // toothed idler

            translate(p3p)
                pulley_assembly(p3p_type); // plain idler
        }
        translate(p4)
            pulley_assembly(p4_type); // y-carriage plain pulley
    }

    path0a = [
        [ p0.x, p0.y, pulley_od(p0_type) / 2 ],
        [ p1.x, p1.y, pulley_od(p1_type) / 2 ],
        [ p2.x, p2.y, pulley_od(p2_type) / 2 ]
    ];
    path0b = [
        [ p3d.x, p3d.y, pulley_od(p3d_type) / 2 ],
        [ p4.x, p4.y, -pulley_od(p4_type) / 2 ]
    ];
    path0c = [
        [ p3t.x, p3t.y, pulley_od(p3t_type) / 2 ],
        [ p3d.x, p3d.y, pulley_od(p3d_type) / 2 ],
        [ p3p.x, p3p.y, -pulley_od(p3p_type) / 2 ],
        [ p4.x, p4.y, -pulley_od(p4_type) / 2 ]
    ];
    path0d = [
        [ p3p.x, p3p.y, -pulley_od(p3p_type) / 2 ],
        [ p3d.x, p3d.y, pulley_od(p3d_type) / 2 ],
        [ p3t.x, p3t.y, pulley_od(p3t_type) / 2 ],
        [ p4.x, p4.y, -pulley_od(p4_type) / 2 ]
    ];

    belt = coreXY_belt(type);

    path0 = drive_pulley_offset.x == 0 ? concat(path0a, path0b) : drive_pulley_offset.x > 0 ? concat(path0a, path0c) : concat(path0a, path0d);
    path = concat([start_p], path0, [end_p]);

    belt(type = belt,
        points = path,
        open = true,
        belt_colour  = lower_belt ? coreXY_lower_belt_colour(type) : coreXY_upper_belt_colour(type),
        tooth_colour = lower_belt ? coreXY_lower_tooth_colour(type) : coreXY_upper_tooth_colour(type));
}

module coreXY(type, size, pos, separation, x_gap, plain_idler_offset = 0, upper_drive_pulley_offset, lower_drive_pulley_offset, show_pulleys = false, left_lower = false) { //! Wrapper module to draw both belts of a coreXY setup
    translate([size.x / 2 - separation.x / 2, size.y / 2, -separation.z / 2]) {
        // lower belt
        hflip(!left_lower)
            explode(25)
                coreXY_half(type, size, [size.x - pos.x - separation.x/2 - (left_lower ? x_gap : 0), pos.y], separation.y, x_gap, plain_idler_offset, [-lower_drive_pulley_offset.x, lower_drive_pulley_offset.y], show_pulleys, lower_belt = true, hflip = true);

        // upper belt
        translate([separation.x, 0, separation.z])
            hflip(left_lower)
                explode(25)
                    coreXY_half(type, size, [pos.x + separation.x/2 + (left_lower ? x_gap : 0), pos.y], separation.y, x_gap, plain_idler_offset, upper_drive_pulley_offset, show_pulleys, lower_belt = false, hflip = false);
    }
}

module coreXY_belts(type, carriagePosition, coreXYPosBL, coreXYPosTR, separation, x_gap = 20, upper_drive_pulley_offset = [0, 0], lower_drive_pulley_offset = [0, 0], show_pulleys = false, left_lower = false) { //! Draw the coreXY belts
    assert(coreXYPosBL.z == coreXYPosTR.z);

    coreXYSize = coreXYPosTR - coreXYPosBL;
    translate(coreXYPosBL)
        coreXY(type, coreXYSize, [carriagePosition.x - coreXYPosBL.x, carriagePosition.y - coreXYPosBL.y], separation = separation, x_gap = x_gap, plain_idler_offset = 0, upper_drive_pulley_offset = upper_drive_pulley_offset, lower_drive_pulley_offset = lower_drive_pulley_offset, show_pulleys = show_pulleys, left_lower = left_lower);
}
