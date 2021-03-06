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

include <../core.scad>
include <../vitamins/pulleys.scad>
include <../vitamins/screws.scad>
include <../vitamins/stepper_motors.scad>
include <../vitamins/washers.scad>

include <../utils/core_xy.scad>


module coreXY_belts_test() {
    coreXY_type = coreXY_GT2_20_16;
    plain_idler = coreXY_plain_idler(coreXY_type);
    toothed_idler = coreXY_toothed_idler(coreXY_type);

    coreXYPosBL = [0, 0, 0];
    coreXYPosTR = [200, 150, 0];
    separation = [0, coreXY_coincident_separation(coreXY_type).y, pulley_height(plain_idler) + washer_thickness(M3_washer)];
    pos = [100, 50];

    upper_drive_pulley_offset = [40, 10];
    lower_drive_pulley_offset = [0, 0];

    coreXY_belts(coreXY_type,
        carriagePosition = pos,
        coreXYPosBL = coreXYPosBL,
        coreXYPosTR = coreXYPosTR,
        separation = separation,
        x_gap = 10,
        upper_drive_pulley_offset = upper_drive_pulley_offset,
        lower_drive_pulley_offset = lower_drive_pulley_offset,
        show_pulleys = true);


    translate([coreXYPosBL.x + separation.x/2, coreXYPosTR.y + upper_drive_pulley_offset.y, separation.z/2]) {
        // add the upper drive pulley stepper motor
        translate([coreXY_drive_pulley_x_alignment(coreXY_type) + upper_drive_pulley_offset.x, 0, -pulley_height(coreXY_drive_pulley(coreXY_type))])
            NEMA(NEMA17M);

        // add the screws for the upper drive offset idler pulleys if required
        if (upper_drive_pulley_offset.x > 0) {
            translate(coreXY_drive_plain_idler_offset(coreXY_type))
                translate_z(-pulley_offset(plain_idler))
                    screw(M3_cap_screw, 20);
            translate(coreXY_drive_toothed_idler_offset(coreXY_type))
                translate_z(-pulley_offset(toothed_idler))
                    screw(M3_cap_screw, 20);
         } else if (upper_drive_pulley_offset.x < 0) {
            translate([-pulley_od(plain_idler), coreXY_drive_plain_idler_offset(coreXY_type).y])
                translate_z(-pulley_offset(plain_idler))
                    screw(M3_cap_screw, 20);
            translate([2*coreXY_drive_pulley_x_alignment(coreXY_type), coreXY_drive_toothed_idler_offset(coreXY_type).y])
                translate_z(-pulley_offset(toothed_idler))
                    screw(M3_cap_screw, 20);
        }
    }

    translate([coreXYPosTR.x - separation.x/2, coreXYPosTR.y + lower_drive_pulley_offset.y, -separation.z/2]) {
        // add the lower drive pulley stepper motor
        translate([-coreXY_drive_pulley_x_alignment(coreXY_type) + lower_drive_pulley_offset.x, 0, -pulley_height(coreXY_drive_pulley(coreXY_type))])
            NEMA(NEMA17M);

        // add the screws for the lower drive offset idler pulleys if required
        if (lower_drive_pulley_offset.x < 0) {
            translate([-coreXY_drive_plain_idler_offset(coreXY_type).x, coreXY_drive_plain_idler_offset(coreXY_type).y])
                translate_z(-pulley_offset(plain_idler))
                    screw(M3_cap_screw, 20);
            translate(coreXY_drive_toothed_idler_offset(coreXY_type))
                translate_z(-pulley_offset(toothed_idler))
                    screw(M3_cap_screw, 20);
        } else if (lower_drive_pulley_offset.x > 0) {
            translate([pulley_od(plain_idler), coreXY_drive_plain_idler_offset(coreXY_type).y])
                translate_z(-pulley_offset(plain_idler))
                    screw(M3_cap_screw, 20);
            translate([-2*coreXY_drive_pulley_x_alignment(coreXY_type), coreXY_drive_toothed_idler_offset(coreXY_type).y])
                translate_z(-pulley_offset(toothed_idler))
                    screw(M3_cap_screw, 20);
        }
    }

    // add the screw for the left upper idler pulley
    translate([coreXYPosBL.x + separation.x/2, coreXYPosBL.y, separation.z])
        screw(M3_cap_screw, 20);

    // add the screw for the right upper idler pulley
    translate([coreXYPosTR.x + separation.x/2, coreXYPosBL.y, separation.z])
        screw(M3_cap_screw, 20);

    if (separation.x != 0) {
        // add the screw for the left lower idler pulley
        translate([coreXYPosBL.x - separation.x/2, coreXYPosBL.y, 0])
            screw(M3_cap_screw, 20);

        // add the screw for the right lower idler pulley
        translate([coreXYPosTR.x - separation.x/2, coreXYPosBL.y, 0])
            screw(M3_cap_screw, 20);
    }

    translate([-separation.x/2, pos.y + coreXYPosBL.y -separation.y/2, -separation.z/2 + pulley_height(plain_idler)/2]) {
        // add the screw for the left Y carriage toothed idler
        translate([coreXYPosBL.x, coreXY_toothed_idler_offset(coreXY_type).y, 0])
            screw(M3_cap_screw, 20);
        // add the screw for the left Y carriage plain idler
        translate([coreXYPosBL.x + separation.x + coreXY_plain_idler_offset(coreXY_type).x, separation.y + coreXY_plain_idler_offset(coreXY_type).y, separation.z])
            screw(M3_cap_screw, 20);
        // add the screw for the right Y carriage toothed idler
        translate([coreXYPosTR.x + separation.x, coreXY_toothed_idler_offset(coreXY_type).y, separation.z])
            screw(M3_cap_screw, 20);
        // add the screw for the right Y carriage plain idler
        translate([coreXYPosTR.x - coreXY_plain_idler_offset(coreXY_type).x, separation.y + coreXY_plain_idler_offset(coreXY_type).y, 0])
            screw(M3_cap_screw, 20);
    }
}

if ($preview)
    coreXY_belts_test();
