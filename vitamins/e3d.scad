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
// E3D hot ends
//
include <../core.scad>
include <hot_ends.scad>
include <tubings.scad>
include <zipties.scad>
include <fans.scad>

use <../utils/rounded_cylinder.scad>
use <../utils/thread.scad>
use <../utils/tube.scad>

rad_dia = 22; // Diam of the part with ailettes
rad_nb_ailettes = 11;
rad_len = 26;

nozzle_h = 5;

module e3d_nozzle(type) {
    color(brass) {
        rotate_extrude()
            polygon([
                [0.2,  0],
                [0.2,  2],
                [1.5,  2],
                [0.65, 0]
            ]);

        translate_z(2)
            cylinder(d = 8, h = nozzle_h - 2, $fn=6);
    }
}

resistor_len = 22;
resistor_dia = 6;

heater_width  = 16;
heater_length = 20;
heater_height = 11.5;

heater_x = 4.5;
heater_y = heater_width / 2;

fan_x_offset = rad_dia / 2 + 4;

module e3d_resistor(type, naked = false, resistor_wire_rotate = [0,0,0]) {
    translate([11 - heater_x, -3 - heater_y, heater_height / 2 + nozzle_h]) {
        color("grey")
            rotate([-90, 0, 0])
                cylinder(r = resistor_dia / 2, h = resistor_len);

        if(!naked)
            color("red")
                translate([0, resistor_len + 3.5/2 + 1, 0]) {
                rotate(resistor_wire_rotate) {
                    translate([-3.5/2, 0, 0]) {
                        cylinder(d = 3.5, h = 36);

                        translate([3.5, 0, 0])
                            cylinder(r = 3.5 / 2, h = 36);
                    }
                }
            }
    }
}

module heater_block(type, naked = false, resistor_wire_rotate = [0,0,0]) {
    translate_z(-hot_end_length(type))  {
        translate_z(nozzle_h)
            color("lightgrey")
                translate([-heater_x, -heater_y, 0])
                    cube([heater_length, heater_width, heater_height]);

        e3d_resistor(type, naked, resistor_wire_rotate);
        e3d_nozzle(type);
    }
}

module bowden_connector(cap_colour = grey(20)) {
    ir = 4.25 / 2;
    body_colour = silver;

    color(body_colour) {
        translate_z(-4.5) {
            tube(or = 2.5, ir = ir, h = 4.5, center = false);
            male_metric_thread(6, metric_coarse_pitch(5), length = 4.5, center = false, solid = false, colour = body_colour);
        }
        tube(or = 7.7 / 2, ir = ir, h = 2, center = false);
        translate_z(2)
            linear_extrude(6.5)
                difference() {
                    circle(d = 11.55, $fn = 6);
                    circle(r = ir);
                }
        translate_z(8.5)
            rounded_cylinder(r = 9.8 / 2, h = 2, r2 = 1.5, ir = ir);
        translate_z(10.5)
            tube(or = 3.5, ir = ir, h = 0.5, center = false);
    }
    color(cap_colour) {
        translate_z(11)
            tube(or = 3, ir = ir, h = 1, center = false);
        translate_z(12)
            tube(or = 5.5, ir = ir, h = 1.75, center = false);
    }
}

module e3d_fan_duct(type) {
    color("DeepSkyBlue")
    render() difference() {
        hull() {
            translate([-8, -23 / 2, 0])
                cube([eps, 23, 26]);

            translate([fan_x_offset, -30 / 2, 0])
                cube([eps, 30, 30]);
        }
        cylinder(h = 70, d = rad_dia + 0.1, center = true); // For rad

        translate_z(15)
            rotate([0, 90, 0])
                cylinder(d = rad_dia, h = 50);
    }
}

module e3d_fan(type) {
    e3d_fan_duct(type);

    translate([fan_x_offset + 5 + eps, 0, 15])
        rotate([0, 90, 0])
             not_on_bom()
                fan(fan30x10);
}

module e3d_hot_end(type, filament, naked = false, resistor_wire_rotate = [0,0,0], bowden = false) {
    insulator_length = hot_end_insulator_length(type);
    inset = hot_end_inset(type);
    h_ailettes = rad_len / (2 * rad_nb_ailettes - 1);

    vitamin(str("e3d_hot_end(", type[0], ", ", filament, "): Hot end ", hot_end_part(type), " ", filament, "mm"));

    $fa = fa; $fs = fs;

    translate_z(inset - insulator_length)
        color(hot_end_insulator_colour(type))
            rotate_extrude()
                difference() {
                    union() {
                        for (i = [0 : rad_nb_ailettes - 1])
                            translate([0, (2 * i) * h_ailettes])
                                square([rad_dia / 2, h_ailettes]);

                        square([hot_end_insulator_diameter(type) / 2,  insulator_length]);

                        translate([0, -10])
                            square([2, 10]);
                    }
                    square([3.2 / 2, insulator_length]);  // Filament hole

                    translate([hot_end_groove_dia(type) / 2, insulator_length - inset - hot_end_groove(type)])
                        square([100, hot_end_groove(type)]);
            }

    if(bowden)
        translate_z(inset)
            bowden_connector();

    rotate(90)
        heater_block(type, naked, resistor_wire_rotate);

    if(!naked)
        translate_z(inset - insulator_length)
            e3d_fan();
}

module e3d_hot_end_assembly(type, filament, naked = false, resistor_wire_rotate = [0,0,0], bowden = false) {
    bundle = 3.2;

    e3d_hot_end(type, filament, naked, resistor_wire_rotate, bowden);

    // Wire and ziptie
    if(!naked)
        rotate(10) {
            dia =  hot_end_insulator_diameter(type);
            scale([1, (bundle + dia) / dia])
                translate([0, -bundle / 2, -7])
                    rotate(-110)
                        ziptie(small_ziptie, dia / 2);

            translate([0, -dia / 2 - bundle / 2, 20])
                scale([0.7, bundle / 6.4])
                    difference() {
                        tubing(HSHRNK64, 60);

                        translate_z(20)
                            cube([10, 10, 60], center = true);
                    }
    }

}
