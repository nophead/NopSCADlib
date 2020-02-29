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
include <../utils/core/core.scad>
use <../printed/door_hinge.scad>

include <../vitamins/sheets.scad>
use <../vitamins/screw.scad>

door_w = 50;
door_h = 50;
sheet = PMMA6;

module door_hinges() {
    translate([door_hinge_stat_length() / 2 - door_hinge_pin_x(), 0])
        if($preview) {
            for(side = [-1, 1])
                translate_z(side * door_h / 2) {
                    door_hinge_assembly(side > 0, sheet_thickness(sheet));

                    door_hinge_static_assembly(side > 0, 3);
                }

            translate([door_w / 2 + eps, door_hinge_pin_y() - eps])
                rotate([90, 0, 0])
                    render_2D_sheet(sheet)
                        difference() {
                            sheet_2D(sheet, door_w, door_h, 3);

                            for(z =[-1, 1])
                                translate([-door_w / 2, z * door_h / 2])
                                    door_hinge_hole_positions(z)
                                        drill(screw_pilot_hole(door_hinge_screw()), 0);
                        }
            translate([door_w, 0])
                children();
        }
        else
            door_hinge_parts_stl();
}

door_hinges();
