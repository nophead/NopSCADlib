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
//! LCD dispays.
//
include <../utils/core/core.scad>

use <pcb.scad>
use <screw.scad>

function display_width(type)        = type[2];  //! Width of the metal part
function display_height(type)       = type[3];  //! Depth of the metal part
function display_thickness(type)    = type[4];  //! Height of the metal part
function display_pcb(type)          = type[5];  //! PCB mounted on the back
function display_pcb_offset(type)   = type[6];  //! 3D offset of the PCB centre
function display_aperture(type)     = type[7];  //! Size of the aperture including its depth
function display_touch_screen(type) = type[8];  //! Touch screen position and size
function display_threads(type)      = type[9];  //! Length that studs protrude from the PCB holes
function display_ribbon(type)       = type[10]; //! Keep out region for ribbon cable

function display_ts_thickness(type) = let(ts = display_touch_screen(type)) ts ? ts[1].z : 0; //! Touch screen thickness or 0

function display_depth(type) = display_ts_thickness(type) + display_thickness(type) + display_pcb_offset(type).z + pcb_thickness(display_pcb(type)); //! Total thickness including touch screen and PCB

module display_aperture(type, clearance, clear_pcb = false) { //! Make aperture cutout
    aperture = display_aperture(type);
    ts = display_touch_screen(type);
    pcb = display_pcb(type);
    rb = display_ribbon(type);

    translate([aperture[0].x, aperture[0].y, -10])
        cube([aperture[1].x - aperture[0].x, aperture[1].y - aperture[0].y, 20]);

    if(ts)
        translate([ts[0].x - clearance, ts[0].y - clearance, -clearance])
            cube([ts[1].x - ts[0].x + 2 * clearance, ts[1].y - ts[0].y + 2 * clearance, ts[1].z + clearance + eps]);

    if(rb)
        translate([rb[0].x, rb[0].y,0])
            cube([rb[1].x - rb[0].x, rb[1].y - rb[0].y, ts[1].z + display_depth(type) + 2]);

    if(clear_pcb)
        translate([display_pcb_offset(type).x, display_pcb_offset(type).y, display_depth(type) / 2 + 0.5 + display_ts_thickness(type)])
            cube([pcb_length(pcb) + 2 * clearance, pcb_width(pcb) + 2 * clearance, display_depth(type) + 1], center = true);
    else
        translate_z(display_depth(type) / 2 + 0.5)
            cube([display_width(type) + 2 * clearance, display_height(type) + 2 * clearance, display_depth(type) + 1], center = true);
}

module display(type) { //! Draw specified display
    vitamin(str("display(", type[0], "): ", type[1]));

    w = display_width(type);
    h = display_height(type);
    t = display_thickness(type);
    pcb = display_pcb(type);

    gap = display_pcb_offset(type).z;
    aperture = display_aperture(type);
    ts = display_touch_screen(type);

    not_on_bom() {
        translate_z(display_ts_thickness(type)) {
            difference() {
                color("silver")
                    rounded_rectangle([w, h, t], 0.5);

                color("black")
                    translate([aperture[0].x, aperture[0].y, - eps])
                        cube([aperture[1].x - aperture[0].x, aperture[1].y - aperture[0].y, aperture[1].z]);
            }

            if(gap)
                color("black")
                    translate_z(t + gap / 2)
                        cube([w - 1, h - 1, gap], center = true);

            translate([0, 0, display_thickness(type)] + display_pcb_offset(type)) {
                pcb(pcb);

                if(display_threads(type))
                    pcb_screw_positions(pcb)
                        vflip()
                            screw(pcb_screw(pcb), pcb_thickness(pcb) + display_threads(type));
            }
        }
        if(ts)
            color("white", 0.15)
                translate([ts[0].x, ts[0].y, 0])
                    cube([ts[1].x - ts[0].x, ts[1].y - ts[0].y, ts[1].z - eps]);
    }
}
