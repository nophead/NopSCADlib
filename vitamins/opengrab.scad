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
//! Nicodrone OpenGrab V3 electro-permananet magnet, see <https://nicadrone.com/products/epm-v3>.
//!
//! A permanent magnet that can be magnatized and de-magnatized electronically.
//
include <../utils/core/core.scad>
use <../utils/thread.scad>
use <pcb.scad>
include <smds.scad>

pitch = 33.8 / 2;
width = 40;
depth = 18;
magnet = 4.3;
pillar = 6;
target = 1;
pole_w = 2;
pole_l = 36;
poles = 15;

pcb = ["", "",        width, width, 0.8, 0, 3.5, 0, "darkgreen", false, [],
    [     [ 3.45,   19,   0, "button_4p5mm"],
          [ 2.75,   24.5, 0, "smd_led", LED0805, "green"],
          [ 2.75,   28.0, 0, "smd_led", LED0805, "red"],
          [ 28.5,   13,   0, "2p54header", 3, 1, false, undef, true],
     ]];


module opengrab_hole_positions()    //! Position children at the screw positions
    let($d = 3.2)
        for($x = [-pitch, pitch], $y = [-pitch, pitch])
            translate([$x, $y])
                children();

module opengrab_side_hole_positions() //! Position children at the two 4mm hole
    let($d = 4, pitch = width / 2 - 3.5)
        for($x = [-pitch, pitch])
            translate([$x, 0])
                children();

function opengrab_width() = width;                               //! Module width
function opengrab_depth() = depth;                               //! Module height
function opengrab_target_thickness() = target;                   //! Target sheet thickness
function opengrab_pcb() = pcb;                                   //! The PCB
function opengrab_pcb_z() = depth - pillar - pcb_thickness(pcb); //! PCB offset from the front
function opengrab_screw_depth() = 4;                             //! Max screw depth in pillars

module opengrab() { //! Draw OpenGrab module
    vitamin("opengrab(): OpenGrab V3 electro permanent magnet");

    color("grey")
        translate_z(magnet / 2 + eps)
            cube([width, width, magnet - eps], center = true);

    color(grey(80)) {
        gap = (width - poles * pole_w + 3 * eps) / (poles - 1);
        pitch = pole_w + gap;
        for(i = [0 : poles - 1])
            translate([(i - floor(poles / 2)) * pitch - eps, 0, 0.5])
                cube([pole_w, pole_l, 1], center = true);
    }

    not_on_bom()
        translate_z(opengrab_pcb_z())
            pcb(pcb);

    translate_z(1)
        opengrab_hole_positions() {
            color(brass)
                linear_extrude(depth - 1)
                    difference() {
                            circle(d = 4.7 / cos(30), $fn = 6);

                            circle(r = 3/2);
                    }

            if(show_threads)
                female_metric_thread(3, metric_coarse_pitch(3), depth - 1, center = false, colour = brass);
        }
}

module opengrab_target() { //! Draw OpenGrab target
    vitamin("opengrab_target(): OpenGrab silicon steel target plate");

     color(grey(80))
        linear_extrude(target)
            difference() {
                square([width, width], center = true);

                opengrab_hole_positions()
                    circle(d = $d);

                opengrab_side_hole_positions()
                    circle(d = $d);
        }
}
