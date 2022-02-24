//
// NopSCADlib Copyright Chris Palmer 221
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
//! Parametric knobs for potentiometers and encoders.
//!
//! A knob can be constructed by specifying all the parameters or the potentiometer can be specified to customise it for its shaft with a recess to clear the nut, washer and thread.
//! An optional skirt and / or a pointer can be specified.
//!
//! The STL includes a support membrane that needs to be cut out and a thread needs to be tapped for the grub screw.
//

include <../core.scad>
use <../utils/hanging_hole.scad>
use <../utils/rounded_polygon.scad>
use <../vitamins/potentiometer.scad>

clearance = 0.2;

function knob_name(type)     = type[0]; //! Name for the stl maker
function knob_top_d(type)    = type[1]; //! Diameter at the top
function knob_bot_d(type)    = type[2]; //! Diameter at the bottom
function knob_height(type)   = type[3]; //! Height
function knob_corner_r(type) = type[4]; //! Rounded top corner
function knob_shaft_d(type)  = type[5]; //! Shaft diameter
function knob_shaft_len(type)= type[6]; //! Shaft length
function knob_flat_d(type)   = type[7]; //! The shaft diameter at the flat
function knob_flat_h(type)   = type[8]; //! The length of the flat
function knob_screw(type)    = type[9]; //! The grub screw type
function knob_skirt(type)    = type[10]; //! Skirt diameter and thickness
function knob_recess(type)   = type[11]; //! Recess diameter and thickness to clear nut and thread, diameter, nut height, thread height
function knob_pointer(type)  = type[12]; //! Pointer outside radius, [point width, back width] and height height

function knob(name = "knob", top_d = 12, bot_d = 15, height = 18, shaft_length, skirt = [20, 2], pointer = false, corner_r = 2, screw = M3_grub_screw, shaft_d, flat_d, flat_h, recess) = //! Constructor
[
    name, top_d, bot_d, height, corner_r, shaft_d, shaft_length, flat_d, flat_h, screw, skirt, recess, pointer
];

function knob_for_pot(pot, thickness, z = 1, washer = true, top_d = 12, bot_d = 15, height = 0, shaft_length = undef, skirt = [20, 2], pointer = false, corner_r = 2, screw = M3_grub_screw) =  //! Construct a knob to fit specified pot
    let(s = pot_shaft(pot),
        washer = washer && pot_washer(pot) ? pot_washer(pot) : [0, 0],
        nut = pot_nut(pot) ? pot_nut(pot) : [pot_thread_d(pot) * cos(30), pot_thread_h(pot) - thickness],
        shaft_length = is_undef(shaft_length) ? s.z : min(shaft_length, s.z),
        h = round_to_layer(shaft_length + pot_thread_h(pot) - thickness - z),
        height = max(height, h + 1),
        recess = [(z > washer.y ? nut.x / cos(30) : washer.x) + 0.4, round_to_layer(nut.y + washer.y - z + layer_height), round_to_layer(pot_thread_h(pot) - z - thickness + 2 * layer_height)],
        flat_d = s.y + 0.06,
        flat_h = min(s[3], shaft_length)
    )
    knob(name = str(pot[0], "_knob"),
         top_d = top_d,
         bot_d = bot_d,
         height = height,
         corner_r = corner_r,
         screw = screw,
         skirt = skirt,
         pointer = pointer,
         shaft_d = s.x,
         shaft_length = h,
         flat_d = flat_d,
         flat_h = flat_h,
         recess = recess);

function knob_screw_z(type) = knob_shaft_len(type) - knob_flat_h(type) / 2;

module knob(type, supports = true) { //! Generate the STL for a knob
    r_top = knob_top_d(type) / 2;
    r_bot = knob_bot_d(type) / 2;
    h = knob_height(type);
    r = knob_corner_r(type);
    screw = knob_screw(type);
    sr = knob_shaft_d(type) / 2 + (screw ? clearance : 0);
    top_wall = h - knob_shaft_len(type);
    fr = knob_flat_d(type) - sr + 2 * clearance;
    fh = knob_flat_h(type);
    skirt = knob_skirt(type);
    recess = knob_recess(type);
    pointer = knob_pointer(type);

    stl(knob_name(type))
    {
        difference() {
            union() {
                rotate_extrude() {
                    rounded_polygon([
                        [0, h, 0],
                        [r_top - r, h - r, r],
                        [r_bot, 0, 0],
                        [0, 0, 0],
                    ]);

                    if(skirt)
                        square([skirt.x / 2, skirt.y]);
                }
                if(pointer)
                    linear_extrude(pointer.z)
                        rotate(-90)
                            hull() {
                                translate([pointer.x, 0])
                                    square([eps, pointer.y[0]], center = true);

                                translate([r_bot, 0])
                                    square([eps, pointer.y[1]], center = true);
                            }
            }
            shaft_z = recess ? recess.z + (supports ? layer_height : -eps) : -eps;
            translate_z(shaft_z) {
                h = h - top_wall - shaft_z;
                linear_extrude(h)
                    difference() {
                        poly_circle(sr);

                        if(fr > 0)
                            translate([-sr, fr])
                                square([2 * sr, sr]);
                    }

                if(h > fh)
                    poly_cylinder(sr, round_to_layer(h - fh), center = false);
            }

            if(recess)
                translate_z(-eps)
                    hull() {
                        poly_cylinder(r = recess.x / 2, h = recess.y + eps, center = false);

                        linear_extrude(recess.z + eps)
                            offset(min(-(recess.z - recess.y), 0))
                                poly_circle(recess.x / 2);
                    }

            if(screw)
                translate_z(knob_screw_z(type))
                    rotate([90, 0, 180])
                        teardrop_plus(r = screw_pilot_hole(screw), h = max(r_top, r_bot) + eps, center = false);
        }
    }
}

//! Knob with grub screw in place
module knob_assembly(type) explode(40, explode_children = true) { //! Assembly with the grub screw in place
    sr = knob_shaft_d(type) / 2;
    fr = knob_flat_d(type) < sr ? knob_flat_d(type) - sr : sr;
    r_top = knob_top_d(type) / 2;
    r_bot = knob_bot_d(type) / 2;
    screw_length = screw_shorter_than(min(r_top, r_bot) - fr);
    screw = knob_screw(type);

    stl_colour(pp1_colour) render() knob(type, supports = false);

    if(screw)
        translate([0, (fr + screw_length), knob_screw_z(type)])
            rotate([90, 0, 180])
                screw(screw, screw_length);
}
