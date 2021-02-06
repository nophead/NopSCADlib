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
//! A parametric flat hinge. A piece of filament can be used for the hinge pin.
//!
//! The width, depth, thickness, number and type of screws, number of knuckles, knuckle diameter, pin diameter and clearance can all be varied.
//! A margin between the screws and the knuckle edge can be enforced to allow the hinge to bend all the way back to 270&deg; from closed.
//!
//! Opening the test in OpenSCAD with its customiser enabled allows these parameters to be played with.
//!
//! Note setting `thickness1` or `thickness2` to zero in the `hinge_fastened_assembly()` removes the screws from one side or the other and
//! setting `show_hinge` to false removes the hinge.
//! This allows the hinges and one set of screws to belong to one assembly and the other set of screws to another assembly.
//
include <../core.scad>

function hinge_width(type)       = type[1]; //! Width
function hinge_depth(type)       = type[2]; //! Depth of each leaf
function hinge_thickness(type)   = type[3]; //! Thickness of the leaves
function hinge_pin_dia(type)     = type[4]; //! The pin diameter
function hinge_knuckle_dia(type) = type[5]; //! The knuckle diameter
function hinge_knuckles(type)    = type[6]; //! How many knuckles
function hinge_screw(type)       = type[7]; //! Screw type to mount it
function hinge_screws(type)      = type[8]; //! How many screws
function hinge_clearance(type)   = type[9]; //! Clearance between knuckles
function hinge_margin(type)      = type[10]; //! How far to keep the screws from the knuckes

function flat_hinge(name, size, pin_d, knuckle_d, knuckles, screw, screws, clearance, margin) = //! Construct the property list for a flat hinge.
 [name, size.x, size.y, size.z, pin_d, knuckle_d, knuckles, screw, screws, clearance, margin];

function hinge_radius(type)      = washer_radius(screw_washer(hinge_screw(type))) + 1;

module hinge_screw_positions(type) { //! Place children at the screw positions
    screws = hinge_screws(type);
    w = hinge_width(type);
    d = hinge_depth(type);
    r = hinge_radius(type);
    m = hinge_margin(type);
    assert(screws > 1, "must be at least two screws");
    w_pitch = (w - 2 * r) / (screws - 1);
    d_pitch = d - 2 * r - m;
    wr = washer_radius(screw_washer(hinge_screw(type)));
    assert(w_pitch >= wr && norm([w_pitch, d_pitch]) >= 2 * wr && d_pitch >= 0, "not enough room for screws");

    for(i = [0 : screws - 1])
        translate([-w / 2 + r + i * w_pitch, r + m + (i % 2) * d_pitch])
            children();
}

module hinge_male(type, female = false) {       //! The half with the stationary pin
    r = hinge_radius(type);
    w = hinge_width(type);
    t = hinge_thickness(type);
    kr = hinge_knuckle_dia(type) / 2;
    pr = hinge_pin_dia(type) / 2;
    assert(kr > pr, "knuckle diameter must be bigger than the pin diameter");

    n = hinge_knuckles(type);
    assert(n >= 3, "must be at least three knuckes");
    mn = ceil(n / 2);                           // Male knuckles
    fn = floor(n / 2);                          // Female knuckles
    gap = hinge_clearance(type);
    mw = (w - (n - 1) * gap) / 2 / mn;          // Male knuckle width
    fw = (w - (n - 1) * gap) / 2 / fn;          // Female knuckle width

    teardrop_r = kr / cos(22.5);                // The corner on the teardrop
    inset = sqrt(sqr(teardrop_r + gap) - sqr(kr - t)) - kr;

    stl(str("hinge_", female ? "fe": "", "male_", type[0]))
        union() {
            linear_extrude(t)
                difference() {
                    hull() {
                        for(side = [-1, 1])
                            translate([side * (w / 2 - r), hinge_depth(type) - r])
                                circle4n(r);

                        translate([-w / 2, inset])
                            square([w, eps]);
                    }
                    hinge_screw_positions(type)
                        poly_circle(screw_clearance_radius(hinge_screw(type)));
                }

            pitch = mw + gap + fw + gap;
            dir = female ? -1 : 1;
            translate([0, -kr, kr])
                rotate([90, 0, -90])
                    for(z = [0 : (female ? fn : mn) - 1])
                        translate_z(-dir * w / 2 + z * dir * pitch + (female ? -fw - mw - gap : 0))
                            linear_extrude(female ? fw : mw)
                                difference() {
                                    hull() {
                                        rotate(180)
                                            teardrop(r = kr, h = 0);

                                        translate([-kr - 1, -kr])
                                            square(1);
                                    }
                                    teardrop_plus(r = pr + (female ? gap : 0), h = 0);
                                }
        }
}

module hinge_female(type) hinge_male(type, true);

module hinge_both(type) { //! Both parts together for printing
    hinge_male(type);

    translate([0, -hinge_knuckle_dia(type)])
        rotate(180)
             hinge_female(type);
}

module hinge_assembly(type, angle = 0)
assembly(str("hinge_", type[0]), ngb = true) { //! Assembled hinge
    kr = hinge_knuckle_dia(type) / 2;
    hr = hinge_pin_dia(type) / 2;
    w = hinge_width(type);

    vitamin(str(": Hinge pin ", w, " x ", 2 * hr, "mm"));

    stl_colour(pp1_colour) hinge_male(type);

    translate([0, -kr, kr]) {
        rotate([0, 90, 0])
            explode(w + 10)
                stl_colour("silver") cylinder(r = hr , h = w, center = true);

        rotate([-angle, 0, 0])
            translate([0, -kr, -kr])
                rotate(180)
                     stl_colour(pp2_colour) hinge_female(type);
    }
}

module hinge_fastened_assembly(type, thickness1, thickness2, angle, show_hinge = true) { //! Assembled hinge with its fasteners
    if(show_hinge)
        hinge_assembly(type, angle);

    screw = hinge_screw(type);
    nut = screw_nut(screw);
    t = hinge_thickness(type);
    kr = hinge_knuckle_dia(type) / 2;

    module fasteners(thickness)
        if(thickness)
            hinge_screw_positions(type) {
                translate_z(t)
                    screw_and_washer(screw, screw_length(screw, t + thickness, 2, nyloc = true));

                translate_z(-thickness)
                    vflip()
                        nut_and_washer(nut, true);
            }

    fasteners(thickness1);

    translate([0, -kr, kr])
        rotate([-angle, 0, 0])
            translate([0, -kr, - kr])
                rotate(180)
                     fasteners(thickness2);
}
