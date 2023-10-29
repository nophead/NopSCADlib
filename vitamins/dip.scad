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
//! Dual inline IC packages and sockets
//
include <../utils/core/core.scad>
use <../utils/pcb_utils.scad>

pdip_pin = [0.25, 2.54, 0.5, 3.0, 1.524, 1];

function pdip_pin_t(type) = type[0]; //! Pin thickness
function pdip_pin_s(type) = type[1]; //! Height above seating plane
function pdip_pin_w(type) = type[2]; //! Pin width
function pdip_pin_h(type) = type[3]; //! Pin height
function pdip_pin_W(type) = type[4]; //! Pin shoulder width
function pdip_pin_n(type) = type[5]; //! Pin neck

module pdip_pin(type, l, end) { //! Draw a pin
    w = pdip_pin_w(type);
    t = pdip_pin_t(type);
    h = pdip_pin_h(type);
    W = pdip_pin_W(type);
    s = pdip_pin_s(type);
    n = pdip_pin_n(type);
    slope = (W - n);
    r = t;
    x0 = end < 0 ? -w / 2 : -W / 2;
    n0 = end < 0 ? -w / 2 : -n / 2;
    W1 = end != 0 ? W / 2 + w / 2 : W;
    n1 = end != 0 ? n / 2 + w / 2 : n;
    color("silver") {
        translate([x0, -r - t / 2 - l, s - t / 2])
            cube([W1, l, t]);

        translate([x0, -r - t / 2, s - r - t / 2])
            rotate([90, 0, 90])
                rotate_extrude(angle = 90, $fn = 32)
                    translate([r, 0])
                        square([t, W1]);

        translate_z(-h)
            rotate([90, 0, 0])
                linear_extrude(t, center = true) {

                    translate([-w / 2, 0])
                        square([w, h]);

                    hull() {
                        translate([x0, h + slope])
                            square([W1, s - t / 2 - r - slope]);

                        translate([n0, h])
                            square([n1, eps]);
                    }

                }
    }
}

module dil_pin_positions(rows, w, pitch)
    for(i = [0 : rows - 1], $side = [-1, 1], $x = i * pitch - (rows - 1) * pitch / 2)
        translate([0, $x])
            rotate($side * 90)
                translate([0, w / 2])
                    children();

module dil_socket(rows, w, pitch = inch(0.1)) {
    vitamin(str("dil_socket(", rows, ", ", w, arg(pitch, inch(0.1), "pitch"), "): DIL socket ", rows * 2, " x ", w / inch(1), "\""));

    h = 4;
    h2 = 6;
    t = 0.8;
    length = rows * pitch;
    width = w + pitch;
    hole = [0.8, 0.5];
    pin_l = 3;

    $fa = fa; $fs = fs;

    color(grey(20)) {
        linear_extrude(h)
            difference() {
                square([width, length], center = true);

                square([w - pitch, length - 2 * pitch], center = true);

                dil_pin_positions(rows, w, pitch)
                    square(hole, center = true);

                translate([0, rows * pitch / 2])
                    circle(d = 1.5);
            }
        rotate([90, 0, 0])
            linear_extrude(length, center = true)
                for(side = [-1, 1])
                    hull() {
                        t2 = pitch / 2 - hole.y / 2;
                        translate([side * (width / 2 - t / 2) - t / 2, 0])
                            square([t, h2]);

                        translate([side * (width / 2 - t2 / 2) - t2 / 2, 0])
                            square([t2, h]);
                    }
    }
    color("silver")
        dil_pin_positions(rows, w, pitch)
            translate_z(-pin_l / 2)
                cube([0.5, 0.25, pin_l], center = true);

    translate_z(h)
        children();
}

module dip(n, part, size, w, pitch, pin) { //! Draw DIP package
    D = [3, 0.6];

    translate_z(pdip_pin_s(pin)) {
        color(grey(20)) {
            rotate([90, 0, 0])
                linear_extrude(size.x, center = true)
                    difference() {
                        hull() {
                            square([size.y, pdip_pin_t(pin)], center = true);

                            square([size.y - 1, size.z], center = true);
                        }
                        square([D.x + 1, size.z + 1], center = true);
                    }

            translate_z(-D.y / 2)
                cube([D.x + 1 + eps, size.x, size.z - D.y], center = true);

            linear_extrude(size.z / 2)
                difference() {
                    square([D.x + 1 + eps, size.x], center = true);

                    translate([0, size.x / 2])
                        circle(d = D.x);
                }
        }

        color("white")
            translate([0, -D.x / 4, size.z / 2])
                rotate(-90)
                    linear_extrude(eps)
                        resize([(size.x - D.x / 2) * 0.75, size.y / 3])
                            text(part, halign = "center", valign = "center");
    }

    l = size.x / 2 - pdip_pin_W(pin) / 2;
    dil_pin_positions(n, w, pitch)
        pdip_pin(pin, w / 2, $side * (abs($x) > l ? sign($x) : 0));
}

module pdip(pins, part, socketed, w = inch(0.3), pitch = inch(0.1)) { //! Draw standard 0.1" PDIP IC package
    vitamin(str("pdip(", pins, ", ", part, arg(w, inch(0.3), "w"), arg(pitch, inch(0.1), "pitch"),"): IC ", part, " PDIP", pins));
    n = ceil(pins / 2);
    k = in([4, 8], n) ? n - 1 : n;
    length = k * pitch + pitch / 2;
    width = w - pitch / 2;
    height = 3;
    $fa = fa; $fs = fs;

    if(socketed)
        dil_socket(n, w, pitch)
            dip(n, part, [length, width, height], w, pitch, pdip_pin);
        else
            dip(n, part, [length, width, height], w, pitch, pdip_pin);
    dil_pin_positions(n, w, pitch)
        solder();
}
