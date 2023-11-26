//
// NopSCADlib Copyright Chris Palmer 2023
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
//! Faston receptacles to mate with spade connectors
//
include <../utils/core/core.scad>
include <../utils/sector.scad>

function faston_width(type)         = type[1];  //! Width of matching spade
function faston_size(type)          = type[2];  //! Size of the receptacle part
function faston_d_top(type)         = type[3];  //! Radius of the clips
function faston_d_bot(type)         = type[4];  //! Radius of bottom corners
function faston_t(type)             = type[5];  //! Thickness
function faston_wire_crimp_l(type)  = type[6];  //! Length of the wire crimp
function faston_wire_crimp_d(type)  = type[7];  //! Outside diameter of the wire crimp
function faston_wire_crimp_p(type)  = type[8];  //! Position of the tip of the wire crimp
function faston_fillet_d(type)      = type[9];  //! Fillets at the transition
function faston_wall_h(type)        = type[10]; //! Height of transition web wall
function faston_insul_crimp_l(type) = type[11]; //! Length of the insulation crimp
function faston_insul_crimp_d(type) = type[12]; //! Outside diameter of the insulation crimp
function faston_insul_crimp_p(type) = type[13]; //! Position of the tip of the insulation crimp
function faston_insul_crimp_o(type) = type[14]; //! Offset of insulation crimp
function faston_length(type) = //! Total length of crimp
    faston_insul_crimp_p(type).z + faston_insul_crimp_l(type);

function faston_insul_stop(type) = //! Position where insulation stops
   faston_wire_crimp_p(type).z + faston_wire_crimp_l(type);

module faston(type, closed = false) { //! Draw specified faston
    vitamin(str("faston(", type[0], "): Faston part no ", type[0], " to fit ", faston_width(type), "mm spade"));
    s = faston_size(type);
    r_top = faston_d_top(type) / 2;
    r_bot = faston_d_bot(type) / 2;
    t =  faston_t(type);
    wc_l = faston_wire_crimp_l(type);
    wc_r = faston_wire_crimp_d(type) / 2;
    wc_p = faston_wire_crimp_p(type);
    fillet_r = faston_fillet_d(type) / 2;
    wall_h = faston_wall_h(type);

    ic_l = faston_insul_crimp_l(type);
    ic_r = faston_insul_crimp_d(type) / 2;
    ic_p = faston_insul_crimp_p(type);
    ic_o = faston_insul_crimp_o(type);

    $fa = fa; $fs = fs;
    // Receptical
    module reciptical_shape()
        for(side = [-1, 1]) mirror([side < 0 ? 1 : 0, 0]) {
            translate([s.x / 2  - r_top, s.y - r_top])
                difference() {
                    sector(r_top, 0, 180);
                    sector(r_top - t, 0, 180);
                }

            translate([s.x / 2 - r_bot, r_bot])
                difference() {
                    sector(r_bot, -90, 0);
                    sector(r_bot - t, -90, 0);
                }

            translate([s.x / 2 - t, r_bot])
                square([t, s.y - r_top - r_bot]);

            square([s.x / 2 - r_bot, t]);
        }


    module crimp_shape(p, r, offset = 0) {
        hpot = norm([p.x, p.y] - [0, r + offset]);
        opp = sqrt(sqr(hpot) - sqr(r));
        angle = atan((p.y - (r + offset)) / p.x) - acos(r / hpot);
        r_crimp = r / 2 - eps;
        lift = -0.1;
        z = (opp - r * 2 * PI / -angle / 360 - PI * r_crimp) / 2 + lift / 2;

        for(side = [-1, 1]) mirror([side < 0 ? 1 : 0, 0])
            translate([0, r + offset]) {
                difference() {
                    sector(r, 270, 360 + (closed ? 0 : angle));

                    circle(r - t);
                }

                if(!closed)
                    rotate(angle)
                        translate([r - t, -eps])
                            square([t, opp]);
                else {
                    translate([r - r_crimp, z])
                        difference() {
                            sector(r_crimp, 0, 180);

                            circle(r_crimp - t);
                        }
                    translate([r - t, 0])
                        square([t, z]);

                    translate([r - 2 * r_crimp, lift])
                        square([t, z - lift]);

                }
           }
    }

    // Wire crimp
    module wire_crimp_shape() crimp_shape(wc_p, wc_r);

    // Insulation crimp
    module insul_crimp_shape() crimp_shape(ic_p, ic_r, ic_o);

    module crop(z = 0)
        intersection() {
            children();

            square([s.x, 2 * (wall_h + fillet_r + z)], center = true);
        }

    color(silver) translate([0, -t]) {
        // Transition from reciptical to wire crimp
        render() difference() {
           hull() {
                translate_z(s.z)
                    linear_extrude(eps)
                        crop()
                            reciptical_shape();

                translate_z(wc_p.z - eps)
                    linear_extrude(eps)
                        crop()
                            wire_crimp_shape();
            }
            translate([0, s.y, (s.z + wc_p.z) / 2])
                rotate([0, 90, 0])
                    rounded_rectangle([wc_p.z - s.z, 2 * (s.y - wall_h), s.x + 1], fillet_r, center = true);

            hull() {
                translate_z(s.z - eps)
                    linear_extrude(eps)
                        offset(-t)
                            crop(t)
                                hull()
                                    reciptical_shape();

                translate_z(wc_p.z + eps / 8)
                    linear_extrude(eps / 8)
                        offset(-t)
                            crop(t)
                                hull()
                                    wire_crimp_shape();
            }
        }
        // Transition from wire crimp to insulation crimp
        render() difference() {
           hull() {
                translate_z(wc_p.z + wc_l)
                    linear_extrude(eps)
                         wire_crimp_shape();

                translate_z(ic_p.z - eps)
                    linear_extrude(eps)
                         insul_crimp_shape();
            }

            gap = ic_p.z - wc_p.z - wc_l;
            d = gap * 2 / 3;
            translate([0, wall_h + fillet_r - gap / 2, ic_p.z - d / 2])
                hull() {
                    rotate([0, 90, 0])
                        cylinder(d = d, h = 10, center = true);

                    translate([-5, d / 2, d / 2 - gap])
                        cube([10, 10, gap]);
                }

            hull() {
                translate_z(wc_p.z + wc_l - eps)
                    linear_extrude(eps)
                        offset(-t)
                            hull()
                                wire_crimp_shape();

                translate_z(ic_p.z + eps / 8)
                    linear_extrude(eps / 8)
                        offset(-t)
                             hull()
                                insul_crimp_shape();
            }
        }

        linear_extrude(s.z)
            reciptical_shape();

        translate_z(wc_p.z)
            linear_extrude(wc_l)
                wire_crimp_shape();

        translate_z(ic_p.z)
            linear_extrude(ic_l)
                insul_crimp_shape();
    }
}
