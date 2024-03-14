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
//! PCB cameras.
//
include <../utils/core/core.scad>
use <pcb.scad>

function camera_pcb(type)           = type[2]; //! The PCB part of the camera
function camera_lens_offset(type)   = type[3]; //! Offset of the lens center from the PCB centre
function camera_lens(type)          = type[4]; //! Stack of lens parts, can be round, rectangular or rounded rectangular, with optional tapered aperture
function camera_connector_pos(type) = type[5]; //! The flex connector block for the camera itself's position
function camera_connector_size(type)= type[6]; //! The flex connector block for the camera itself's size
function camera_fov(type)           = type[7]; //! The field of view of the camera lens

function camera_lens_height(type) = //! The height of the lens stack
     let(lenses = camera_lens(type), lens = lenses[len(lenses) - 1][0]) lens.y + lens.z;

module camera_lens(type, offset = 0, show_lens = true) //! Draw the lens stack, with optional offset for making a clearance hole
    color(grey(20))
        translate(camera_lens_offset(type))
            for(p = camera_lens(type)) {
                size = p[0];
                r = p[1] + offset;
                app = p[2];
                if(size.x)
                    rounded_rectangle(size + [2 * offset, 2 * offset, round_to_layer(offset)], r);
                else
                    if (show_lens)
                        translate_z(size.y)
                            rotate_extrude()
                                difference() {
                                    square([r, size.z + round_to_layer(offset)]);

                                    if(app)
                                        translate([0, size.z])
                                            hull() {
                                                translate([0, -eps])
                                                    square([app.y, eps * 2]);

                                                translate([0, -app.z])
                                                    square([app.x, app.z]);
                                            }
                                }
            }

module camera(type, show_lens = true, fov_distance = 0, fov = undef) {           //! Draw specified PCB camera
    vitamin(str("camera(", type[0], "): ", type[1]));
    pcb = camera_pcb(type);

    not_on_bom()
        pcb(pcb);

    translate_z(pcb_thickness(pcb)) {
        camera_lens(type, show_lens = show_lens);
        if (show_lens&& fov_distance > 0) {
            lens = camera_lens(type);
            fov = is_undef(fov) ? camera_fov(type) : fov;
            if (is_list(fov))
                #translate_z(lens[2][0].z) // note: use of # is deliberate, to show highlighted field of view
                    translate(camera_lens_offset(type))
                        hull() {
                            cube([lens[1][1]/2, lens[1][1]/2, eps], center=true);
                            translate_z(fov_distance)
                                cube([2 * fov_distance * tan(fov.x / 2), 2 * fov_distance * tan(fov.y / 2), eps], center=true);
                        }
        }

        conn = camera_connector_size(type);
        if(conn) {
            pos = camera_connector_pos(type);
            color(grey(20))
                translate(pos)
                    rounded_rectangle(conn, 0.5);

            flex = [5, 0.1];
            color("orange")
                hull() {
                    translate_z(flex.y /2)
                        translate(camera_lens_offset(type) + [0, sign(pos.y) * camera_lens(type)[0][0].y / 2, 0])
                            cube([flex.x, eps, flex.y], center = true);

                    translate_z(conn.z - flex.y)
                        translate([camera_lens_offset(type).x, pos.y] - [0, conn.y / 2])
                             cube([flex.x, eps, flex.y], center = true);
                }
        }
    }
}
