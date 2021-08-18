//
// NopSCADlib Copyright Chris Palmer 2021
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
//! Customisable pocket handle
//
include <../core.scad>

function pocket_handle(hand_size = [90, 40, 40], slant = 35, screw = M3_cs_cap_screw, panel_t = 3, wall = 4, rad = 4) = //! Construct a pocket_handle property list
    [hand_size, slant, screw, panel_t, wall, rad];

function pocket_handle_hand_size(type) = type[0]; //! Size of the hole for the fingers
function pocket_handle_slant(type)     = type[1]; //! Upward slant of the hand hole
function pocket_handle_screw(type)     = type[2]; //! Screw type, can be countersunk or not
function pocket_handle_panel_t(type)   = type[3]; //! Thickness of the panel it is mounted in
function pocket_handle_wall(type)      = type[4]; //! Wall thickness
function pocket_handle_rad(type)       = type[5]; //! Min corner rad

function pocket_handle_flange(type) = //! Size of the flange
    let(w = pocket_handle_wall(type),
        f = washer_diameter(screw_washer(pocket_handle_screw(type))) + 2 + w,
        s = pocket_handle_hand_size(type))
             [s.x + 2 * f, s.y + 2 * f, w];

module pocket_handle_hole_positions(type) { //! Place children at screw hole positions
    f = pocket_handle_flange(type);
    h = pocket_handle_hand_size(type);
    x_pitch = (f.x + h.x) / 4;
    y_pitch = (f.y + h.y) / 4;

    for(x = [-1, 1], y = [-1, 1])
        translate([x * x_pitch, y * y_pitch])
            children();
}

module pocket_handle_holes(type, h = 0) { //! Panel cutout and screw holes
    hand = pocket_handle_hand_size(type);
    w = pocket_handle_wall(type);
    slot = [hand.x + 2 * w, hand.y + 2 * w];
    t = pocket_handle_panel_t(type);
    clearance = norm([slot.y, t]) - slot.y + 0.2; // has to be enough clearance for the diagonal to swing it in

    extrude_if(h) {
        pocket_handle_hole_positions(type)
            drill(screw_clearance_radius(pocket_handle_screw(type)), 0);

        rounded_square([slot.x  + clearance, slot.y + clearance], pocket_handle_rad(type) + w + clearance / 2);
    }
}

module pocket_handle(type) { //! Generate STL for pocket_handle
    f = pocket_handle_flange(type);
    r = pocket_handle_rad(type);
    s = pocket_handle_slant(type);
    o = f.z * tan(s);
    h = pocket_handle_hand_size(type);
    t = pocket_handle_panel_t(type);
    w = pocket_handle_wall(type);
    screw = pocket_handle_screw(type) ;

    stl("pocket_handle")
        union() {
            difference() {
                hull() {
                    rounded_rectangle(f, r);

                    translate_z(f.z - eps)
                        rounded_rectangle([f.x + 2 * o, f.y + 2 * o, eps], r + o);
                }
                hull() {
                    rounded_rectangle([h.x, h.y, f.z + eps], r);

                    translate_z(-eps)
                        rounded_rectangle([h.x + 2 * o, h.y + 2 * o, eps], r + o);
                }
                pocket_handle_hole_positions(type) {
                    if(screw_head_height(screw))
                        translate_z(-eps)
                            poly_cylinder(r = screw_clearance_radius(screw), h = f.z + 2 * eps, center = false);
                    else
                        screw_polysink(screw, h = 2 * f.z + eps, alt = true);
                }
            }

            translate_z(f.z)
                linear_extrude(t)
                    difference() {
                        rounded_square([h.x + 2 * w, h.y + 2 * w], r + w);

                        rounded_square([h.x, h.y], r);
                    }

            translate_z(f.z + t)
                difference() {
                    height = h.z - f.z - t;
                    hull() {
                        rounded_rectangle([h.x + 2 * w, h.y + 2 * w, eps], r + w);

                        translate((height + w) * [0, sin(s), cos(s)])
                            rounded_rectangle([h.x + 2 * w, h.y + 2 * w, eps], r + w);
                    }

                    hull() {
                        translate_z(-eps)
                            rounded_rectangle([h.x, h.y, eps], r);

                        translate(height * [0, sin(s), cos(s)])
                            rounded_rectangle([h.x, h.y, eps], r);
                    }
                }
        }
}

module pocket_handle_assembly(type) { //! Assembly with fasteners in place
    f = pocket_handle_flange(type);
    screw = pocket_handle_screw(type);
    nut = screw_nut(screw);
    t = pocket_handle_panel_t(type);
    washers = screw_head_height(screw) ? 2 : 1;
    screw_length = screw_length(screw, f.z + t, washers, nyloc = true);

    translate_z(f.z + t / 2) hflip() {
        stl_colour(pp1_colour)
            pocket_handle(type);

        pocket_handle_hole_positions(type) {
            translate_z(f.z + t)
                explode(15, true)
                    nut_and_washer(nut, true);

            vflip()
                if(washers == 2)
                    screw_and_washer(screw, screw_length);
                else
                    screw(screw, screw_length);
        }
    }
}
