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
//! Axial components for PCBs.
//
include <../utils/core/core.scad>
include <../utils/round.scad>

module wire_link(d, l, h = 1, tail = 3) { //! Draw a wire jumper link.
    vitamin(str("wire_link(", d, ", ", l, arg(h, 1, "h"), arg(tail, 3, "tail"),  "): Wire link ", d, "mm x ", l / inch(1), "\""));
    r = d;
    $fn = 32;

    color("silver") {
        for(side = [-1, 1]) {
            translate([side * l / 2, 0, -tail])
                cylinder(d = d, h = tail + h - r);

            translate([side * (l / 2 - r), 0, h - r])
                rotate([90, 0, side * 90 - 90])
                    rotate_extrude(angle = 90)
                        translate([r, 0])
                            circle(d = d);
        }

        translate_z(h)
            rotate([0, 90, 0])
                cylinder(d = d, h = l - 2 * r, center = true);
    }
}

function ax_res_wattage(type) = type[1]; //! Power rating
function ax_res_length(type)  = type[2]; //! Body length
function ax_res_diameter(type)= type[3]; //! Body diameter
function ax_res_end_d(type)   = type[4]; //! End cap diameter
function ax_res_end_l(type)   = type[5]; //! End cap length
function ax_res_wire(type)    = type[6]; //! Wire diameter
function ax_res_colour(type)  = type[7]; //! Body colour

module orientate_axial(length, height, pitch, wire_d) { // Orient horizontal or vertical and add the wires
    min_pitch = ceil((length + 1) / inch(0.1)) * inch(0.1);
    lead_pitch = pitch ? pitch : min_pitch;
    if(lead_pitch >= min_pitch) {
        not_on_bom()
            wire_link(wire_d, lead_pitch, height);

        translate_z(height)
            rotate([0, 90, 0])
                children();
    }
    else {
        not_on_bom()
            wire_link(wire_d, lead_pitch, length + 0.7 + wire_d);

        translate([-pitch / 2, 0, length / 2 + 0.2])
            children();
   }
}

module ax_res(type, value, tol = 5, pitch = 0) { //! Through hole axial resistor. If `pitch` is zero the minimum is used. If below the minimum the resistor is placed vertical.
    vitamin(str("ax_res(", type[0], ", ", value, arg(tol, 5, "tol"), "): Resistor ", value, " Ohms ", tol, "% ",ax_res_wattage(type), "W"));

    wire_d =  ax_res_wire(type);
    end_d = ax_res_end_d(type);
    end_l = ax_res_end_l(type);
    body_d = ax_res_diameter(type);
    length = ax_res_length(type);
    h = end_d / 2;
    $fn = 32;
    r = 0.3;

    colours = ["gold", "silver", "black", "brown", "red", "orange", "yellow", "green", "blue", "violet", "grey", "white"];

    exp = floor(log(value) + eps);
    mult = exp - (len(str(value / pow(10, exp - 1))) > 2 ? 2 : 1);
    digits = str(value / pow(10, mult));
    bands = [
        for(d = digits)
            colours[ord(d) - ord("0") + 2],
        colours[mult + 2],
        tol == 1  ? "brown"  :
        tol == 2  ? "red"    :
        tol == 5  ? "gold"   :
        tol == 10 ? "silver" : "error"
    ];

    module profile(o = 0)
        intersection() {
            offset(o) round(r)
                union(){
                    translate([0, -length / 2])
                        square([body_d / 2, length]);

                    for(end = [-1, 1])
                        hull() {
                            translate([0, end * (length - end_l) / 2 - end_l / 2])
                                square([end_d / 2, end_l]);

                            translate([0, end * length / 2])
                                square([wire_d, 2 * r], center = true);
                        }
                    translate([-5, 0])
                        square([10 + wire_d, length + 4 * r], center = true);
                }

            translate([0, -50])
                square([50, 100]);
    }

    orientate_axial(length, h, pitch, wire_d) {
        color(ax_res_colour(type))
            rotate_extrude()
                profile();

        for(i = [0 : len(bands) - 1])
            color(bands[i])
                rotate_extrude()
                    intersection() {
                        profile(eps);

                        translate([0, length / 2 - end_l / 2 - i * (length - end_l) / (len(bands) - 1)])
                            square([end_d + 1, (length - end_l) / len(bands) / 2], center = true);
                    }
    }
}
