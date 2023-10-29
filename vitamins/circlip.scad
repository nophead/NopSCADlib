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
//! Circlips aka tapered retaining rings.
//
include <../utils/core/core.scad>
use <../utils/sector.scad>
use <../utils/round.scad>
use <../utils/maths.scad>

function circlip_d1(type)        = type[1];     //! Nominal OD, i.e. diameter of tube
function circlip_d2(type)        = type[2];     //! Groove diameter, i.e. OD when installed
function circlip_d3(type)        = type[3];     //! Relaxed OD when not installed
function circlip_thickness(type) = type[4];     //! Thickness
function circlip_a(type)         = type[5];     //! Size of the lugs
function circlip_b(type)         = type[6];     //! Widest part of the taper
function circlip_d5(type)        = type[7];     //! Plier hole diameter
function circlip_closed_angle(type)    = is_undef(type[8]) ? 25 : type[8];     //! Closed angle

circlip_colour = grey(20);

module internal_circlip(type, open = 0) { //! Draw specified internal circlip, open = 0, for nominal size installed, 1 for relaxed uninstalled, -1 for squeezed to install
    d1 = circlip_d1(type);
    wide = is_undef(type[8]) ? "" : " (wide opening)";
    vitamin(str("circlip(", type[0], "): Circlip internal ", d1, "mm",wide));
    d3 = circlip_d3(type);
    d2 = circlip_d2(type);
    a = circlip_a(type);
    b = circlip_b(type);
    d5 = circlip_d5(type);

    od = lookup(open, [[-1, d1], [0, d2], [1, d3]]);
    or = od / 2;
    c = (d3 - d1);

    angle = (od - d1) / d1 * 360 + circlip_closed_angle(type);
    tab_angle = 360 * a / PI / od;
    p = [0, -or + b / 2, 1] * rot3_z(angle / 2 + tab_angle);
    pitch = (or - a / 2);
    y_offset = (sqr(p.x) + sqr(p.y) - sqr(or - b)) / (or - b - p.y) / 2;
    ir = or - b + y_offset;
    color(circlip_colour)
        linear_extrude(circlip_thickness(type), center = true)
            round((a - d5) / 5)
            union() {
                difference() {
                    circle(or);

                    translate([0, -y_offset])
                        circle(ir);

                    sector(d3 / 2 + 1, 270 - angle / 2 - tab_angle, 270 + angle / 2 + tab_angle);

                }
                for(side = [-1, 1])
                    intersection() {
                        circle(or);

                        rotate(side * (angle + tab_angle) / 2)
                            difference() {
                                hull() {
                                    translate([0, -pitch])
                                        circle(d = a);

                                    translate([0, -pitch - a])
                                        circle(d = 1.5 * a);
                                }
                                translate([0, -pitch])
                                    circle(d = d5);
                            }
                    }
            }
}
