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
//! Random screw down modules. Currently just DROK buck converters.
//
include <../core.scad>

function mod_part(type)   = type[1];        //! Description
function mod_length(type) = type[2];        //! Body length
function mod_width(type)  = type[3];        //! Body width
function mod_height(type) = type[4];        //! Body height
function mod_screw(type)  = type[5];        //! Screw type
function mod_screw_z(type)= type[6];        //! Thickness of screw lug
function mod_hole_r(type) = type[7] / 2;    //! Screw hole radius
function mod_holes(type)  = type[8];        //! Screw hole positions

module mod(type) {  //! Draw specified module
    vitamin(str("mod(", type[0], "): ", mod_part(type)));

    module drok_buck() {
        l = mod_length(type);
        w = mod_width(type);
        h = mod_height(type);
        body_l = 31;
        end_t = 1.5;
        chamfer = 2;
        lug_l = (l - body_l) / 2 - end_t;
        lug_w = 19;
        lug_w2 = 10;
        lug_t = 2;
        lug_r = 2.5;
        hole_r = mod_hole_r(type);
        vane_t = 1;
        vane_h = 5;
        vane_l = 7;
        vane_p = 10;
        boss_od = 7.5;
        boss_id = 5;
        boss_h = 2.3;
        boss_chamfer = 1;


        module profile()
            hull() {
                translate([-w / 2, 0])
                    square([w, h - chamfer]);

                translate([-w / 2 + chamfer, 0])
                    square([w - 2 * chamfer, h]);
            }

        module lug()
            difference() {
                hull() {
                    for(side = [-1, 1])
                        translate([side * lug_w2 / 2, lug_l - lug_r])
                            circle(lug_r);

                    translate([-lug_w / 2, -1])
                        square([lug_w, 1]);
                }
                hull()
                    for(y = [hole_r, 100])
                        translate([0, y])
                            circle(hole_r);
            }

        color("silver")
            rotate([90, 0, 90])
                linear_extrude(body_l, center = true)
                    profile();

        color(grey(20))
            for(end = [-1, 1])
                translate([end * body_l / 2, 0, 0])
                    rotate([90, 0, end * 90])
                        union() {
                            linear_extrude(end_t)              // endcap
                                profile();

                            translate_z(end_t)
                                rotate([90, 0, 180])
                                    linear_extrude(lug_t)      // lug
                                        lug();

                            for(side = [-1, 1]) {
                                translate([side * vane_p / 2, lug_t, end_t]) // buttress vanes
                                    rotate([0, -90, 0])
                                        linear_extrude(vane_t, center = true)
                                            polygon([[0, 0], [0, vane_h - lug_t], [vane_l, 0]]);

                                translate([side * vane_p / 2, h / 2, end_t]) // bosses
                                    rotate_extrude()
                                        difference() {
                                            hull() {
                                                square([boss_od / 2,boss_h - boss_chamfer]);
                                                square([boss_od / 2 - boss_chamfer, boss_h]);
                                            }
                                            translate([0, boss_h - boss_chamfer])
                                                square([boss_id / 2, boss_h]);
                                        }
                            }
                        }
    }
    drok_buck();
}

module mod_screw_positions(type) //! Position children at the screw positions
    for(p = mod_holes(type))
        translate([p.x, p.y])
            children();

module module_assembly(type, thickness) { //! Module with its fasteners in place
    screw = mod_screw(type);
    screw_length = screw_length(screw, thickness + mod_screw_z(type), 2, nyloc = true);

    mod(type);

    mod_screw_positions(type) {
        translate_z(mod_screw_z(type))
            nut_and_washer(screw_nut(screw), true);

        translate_z(-thickness)
            vflip()
                screw_and_washer(screw, screw_length);
    }
}
