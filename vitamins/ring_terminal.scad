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
//! Ring terminals and earth assemblies for DiBond panels.
//
include <../utils/core/core.scad>
use <screw.scad>
use <nut.scad>
use <washer.scad>
use <../utils/tube.scad>

function ringterm_od(type)           = type[1];    //! Outside diameter
function ringterm_id(type)           = type[2];    //! Inside diameter
function ringterm_length(type)       = type[3];    //! Length of the tail including the ring
function ringterm_width(type)        = type[4];    //! Width of the tail
function ringterm_hole(type)         = type[5];    //! Wire hole diameter
function ringterm_thickness(type)    = type[6];    //! Metal thickness
function ringterm_screw(type)        = type[7];    //! Screw type
function ringterm_crimp_length(type) = type[8];    //! If non-zero the length of the crimp tube
function ringterm_extent(type)    = ringterm_length(type) / sqrt(2); //! Space to leave

module ring_terminal(type) { //! Draw specifeid ring terminal
    screw = ringterm_screw(type);
    d = 2 * screw_radius(screw);
    crimp = ringterm_crimp_length(type);
    vitamin(str("ring_terminal(", type[0], "): Ring terminal ", crimp ? "crimp " : "", d, "mm"));

    t = ringterm_thickness(type);
    w = ringterm_width(type);
    od = ringterm_od(type);
    id = ringterm_id(type);
    l = ringterm_length(type);
    angle = crimp ? 0 : 45;
    transition = 1;
    bend = crimp ? l - od / 2 - crimp - transition : washer_radius(screw_washer(screw)) + t * tan(angle / 2);
    hole_d = ringterm_hole(type);

    module hull_if_crimp()
        if(crimp)
            hull()
                children();
        else
            children();

    color("silver") union() {
        linear_extrude(t)
            difference() {
                hull_if_crimp() {
                    circle(d = od);

                    translate([-w / 2, -bend, 0])
                        square([w, bend - id / 2]);
                }
                circle(d = id);
            }

        if(crimp) {
            translate([0, -bend, w / 2])
                rotate([90, 0, 0]) {
                    render() difference() {
                        union() {
                            translate_z(transition)
                                cylinder(d = w, h = crimp);

                            hull() {
                                translate_z(transition)
                                    cylinder(d = w, h = eps);

                                translate([-w / 2, -w / 2])
                                    cube([w, t, eps]);
                            }
                        }
                        hull() {
                            translate_z(-eps)
                                cylinder(d = w - 2 * t, h = crimp + transition + 2 * eps);

                            translate([-w / 2 + t,  -w / 2 + t])
                                cube([w - 2 * t, w / 2 - t, eps]);
                         }
                         translate([0, w / 2])
                            cube([0.1, w, 100], center = true);
                    }
                }
            }
        else
            translate([0, -bend])
                rotate([-angle, 0, 0])
                    linear_extrude(t)
                        difference() {
                            length = l - od / 2 - bend;
                            hull() {
                                translate([-w / 2, -eps])
                                    square([w, eps]);

                                translate([0, -length + w / 2])
                                    circle(d = w);
                            }
                            if(hole_d)
                                translate([0, -length + w / 2])
                                    circle(d = hole_d);
                        }
    }
    translate_z(ringterm_thickness(type))
        children();
}

module ring_terminal_hole(type, h = 0)  //! Drill hole for the screw
    drill(screw_clearance_radius(ringterm_screw(type)), h);

module ring_terminal_assembly(type, thickness, top = false) { //! Earthing assembly for DiBond twin skins
    screw = ringterm_screw(type);
    washer = screw_washer(screw);
    nut = screw_nut(screw);
    screw_length = screw_length(screw, thickness + ringterm_thickness(type), 2, nyloc = true);

    explode(10, true) star_washer(washer)
        if(top)
            ring_terminal(type) screw(screw, screw_length);
        else
            screw(screw, screw_length);

    vflip()
        translate_z(thickness)
            explode(10, true) star_washer(washer)
                if(!top)
                    explode(10,true) ring_terminal(type) nut(nut, true);
                else
                    nut(nut, true);
}
