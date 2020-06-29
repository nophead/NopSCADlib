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

function camera_pcb(type)         = type[2]; //! The PCB part of the camera
function camera_lens_offset(type) = type[3]; //! Offset of the lens center from the PCB centre
function camera_lens(type)        = type[4]; //! Stack of lens parts, can be round, rectanular or rounded rectangular, with optional tapered aperture
function camera_connector(type)   = type[5]; //! The flex connector block for the camera itself

module camera(type) {           //! Draw specified PCB camera
    vitamin(str("camera(", type[0], "): ", type[1]));
    pcb = camera_pcb(type);

    not_on_bom()
        pcb(pcb);

    translate_z(pcb_thickness(pcb)) {
        color(grey(20))
            translate(camera_lens_offset(type))
                for(p = camera_lens(type)) {
                    size = p[0];
                    r = p[1];
                    app = p[2];
                    if(size.x)
                        rounded_rectangle(size, r, center = false);
                    else
                        translate_z(size.y)
                            rotate_extrude()
                                difference() {
                                    square([r, size.z]);

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
        conn = camera_connector(type);
        if(conn) {
            color(grey(20))
                translate(conn[0])
                    rounded_rectangle(conn[1], 0.5, center = false);

            flex = [5, 0.1];
            color("orange")
                hull() {
                    translate_z(flex.y /2)
                        translate(camera_lens_offset(type) + [0, camera_lens(type)[0][0].y / 2])
                            cube([flex.x, eps, flex.y], center = true);

                    translate_z(conn[1].z - flex.y)
                        translate(conn[0] - [0, conn[1].y / 2])
                             cube([flex.x, eps, flex.y], center = true);
                }
        }
    }
}
