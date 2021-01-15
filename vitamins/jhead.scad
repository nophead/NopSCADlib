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
//! J-Head hot ends from Brian Reifsnider, hotends.com.
//
include <../utils/core/core.scad>
include <hot_ends.scad>
include <components.scad>
include <tubings.scad>
include <zipties.scad>

use <wire.scad>
use <../utils/tube.scad>

MK5_heater = [ 12.76, 12.76, 8.22, (12.76 / 2 - 3.75), (12.76 / 2 - 0.5 - 2.5 / 2), (-12.76 / 2 + 4), 8,   2];

function heater_width(type)  = type[0];
function heater_length(type) = type[1];
function heater_height(type) = type[2];
function resistor_x(type)    = type[3];
function thermistor_y(type)  = type[4];
function nozzle_x(type)      = type[5];
function nozzle_cone(type)   = type[6];
function nozzle_cone_length(type) = type[7];

barrel_tap_dia = 5;

barrel_dia = 6;
insulator_dia = 12;

module heater_block(type, resistor, thermistor) {
    h = heater_height(type);

    color(brass) {
        render() difference() {
            rotate([90, 0, 0])
                linear_extrude(heater_width(type), center = true) difference() {
                    square([heater_length(type), h], center = true);

                    translate([resistor_x(type), 0])
                        circle(resistor_hole(resistor) / 2);
                }

            translate([-heater_length(type) / 2, thermistor_y(type), 0])                     // hole for thermistor
                rotate([0, 90, 0])
                    cylinder(r = resistor_hole(thermistor) / 2, h = 2 * resistor_length(thermistor), center = true);
        }
        //
        // nozzle
        //
        cone_length = nozzle_cone_length(type);
        cone_end_r = 1 / 2;
        cone_start_r = nozzle_cone(type) / 2;
        straight = 1;
        nozzle_r = 0.4 / 2;
        translate([nozzle_x(type), 0, -h / 2]) vflip()
            rotate_extrude()
                polygon([
                    [nozzle_r,     0],
                    [cone_start_r, 0],
                    [cone_start_r, straight],
                    [cone_end_r,   straight + cone_length],
                    [nozzle_r,     straight + cone_length],
                ]);
    }
}

module jhead_hot_end(type, filament) {
    resistor = RIE1212UB5C5R6;
    thermistor = Epcos;
    heater = MK5_heater;

    insulator_length = hot_end_insulator_length(type);
    inset = hot_end_inset(type);
    length = hot_end_total_length(type);
    barrel_length = length - insulator_length;
    vitamin(str("jhead_hot_end(", type[0], ", ", filament, "): Hot end ", hot_end_part(type), " ", filament, "mm"));
    //
    // insulator
    //
    translate_z(inset - insulator_length)
        color(hot_end_insulator_colour(type)) rotate_extrude()
            difference() {
                chamfer = 2;
                hull() {
                    translate([0, chamfer])
                        square([hot_end_insulator_diameter(type) / 2, insulator_length - chamfer]);

                    square([hot_end_insulator_diameter(type) / 2 - chamfer, insulator_length]);
                }
                square([(filament + 0.2) / 2, insulator_length]);

                translate([hot_end_groove_dia(type) / 2, insulator_length - hot_end_inset(type) - hot_end_groove(type)])
                    square([100, hot_end_groove(type)]);
            }
    //
    // heater block
    //
    rotate(90)
        translate([-nozzle_x(heater), 0, inset - insulator_length - heater_height(heater) / 2])
            heater_block(heater, resistor, thermistor);
}

module jhead_hot_end_assembly(type, filament, naked = false) { //! Assembly with resistor, thermistor, tape, sleaving and ziptie
    resistor = RIE1212UB5C5R6;
    thermistor = Epcos;
    heater = MK5_heater;

    insulator_length = hot_end_insulator_length(type);
    inset = hot_end_inset(type);
    length = hot_end_total_length(type);
    barrel_length = length - insulator_length;
    bundle = 3.2;
    tape_width = 25;
    tape_overlap = 10;
    tape_thickness = 0.8;

    jhead_hot_end(type, filament);

    vitamin(": Tape self amalgamating silicone 110mm x 25mm");
    //
    // silcone tape
    //
    if(is_undef(naked) || !naked)
        color("red")
            if(exploded())
                translate([0, max(hot_end_insulator_diameter(type) / 2, heater_length(heater) / 2 - nozzle_x(heater)),
                            -tape_width + tape_overlap + inset - insulator_length])
                    cube([110, tape_thickness, tape_width]);
            else
                hull() {
                    translate_z(+ inset - insulator_length)
                        cylinder(r = hot_end_insulator_diameter(type) / 2 + 2 * tape_thickness, h = tape_overlap);

                    translate([0, -nozzle_x(heater), inset - insulator_length - heater_height(heater) / 2 + eps])
                        cube([heater_width(heater) + 4 * tape_thickness,
                              heater_length(heater) + 4 * tape_thickness, heater_height(heater)], center = true);
                }
    //
    // Zip tie and heatshrink
    //
    if(!naked  && !is_undef(naked))
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
                        if(!exploded())
                            translate_z(20)
                                cube([10, 10, 60], center = true);
                    }

        }
    wire("Red PTFE", 16, 170);
    wire("Red PTFE", 16, 170);
    //
    // heater block
    //
    module heater_components() {
        translate([resistor_x(heater), -exploded() * 15, 0])
            rotate([90, 0, 0])
                 sleeved_resistor(resistor, PTFE20, bare = -10);

        translate([-heater_length(heater) / 2 + resistor_length(thermistor) / 2 - exploded() * 10, thermistor_y(heater), 0])
            rotate([90, 0, -90])
                 sleeved_resistor(thermistor, PTFE07, heatshrink = HSHRNK16);
    }

    rotate(90)
        translate([-nozzle_x(heater), 0, inset - insulator_length - heater_height(heater) / 2])
            if(exploded())
                heater_components();
            else
                if(naked)                       // hide the wires when not exploded
                    intersection() {
                        heater_components();

                        color("grey")
                            cylinder(r = 12, h = 100, center = true);
                    }
                else
                    hidden()                    // hidden by the tape
                        heater_components();
}
