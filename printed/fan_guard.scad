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
//! Pintable fan finger guard to match the specified fan. To be `include`d, not `use`d.
//!
//! The ring spacing as well as the number of spokes can be specified, if zero a gasket is generated instead of a guard.
//
use <../utils/tube.scad>

function fan_guard_thickness() = 2; //! Default thickness

function fan_guard_wall() = extrusion_width - layer_height / 2 + nozzle / 2 + extrusion_width / 2;
function fan_guard_corner_r(type) = washer_diameter(screw_washer(fan_screw(type))) / 2 + 0.5; //! Corner radius of the guard
function fan_guard_width(type) = max(2 * (fan_hole_pitch(type) + fan_guard_corner_r(type)), fan_bore(type) + 4 * fan_guard_wall()); //! Width of the guard

module fan_guard(type, name = false, thickness = fan_guard_thickness(), spokes = 4, finger_width = 7, grill = false) { //! Generate the STL
    if(thickness)
        stl(name ? name : str("fan_guard_", fan_width(type)));
    hole_pitch = fan_hole_pitch(type);
    corner_radius =  fan_guard_corner_r(type);
    wall = grill ? 2 : fan_guard_wall();
    spoke = grill ? 3 : wall;
    width = fan_guard_width(type);

    hole = fan_aperture(type) / 2;
    max_ring_pitch = finger_width + wall;
    inner_ring = max_ring_pitch / 2;
    gap = hole + wall / 2 - inner_ring;
    rings = ceil(gap / max_ring_pitch);
    ring_pitch = gap / rings;
    spoke_end = grill && fan_aperture(type) > fan_bore(type) ? hole - ring_pitch : hole;
    spoke_start = grill && rings > 1 ? inner_ring + ring_pitch : inner_ring;
    rounding = grill ? 1.5 : 0;

    extrude_if(thickness, center = false) {
        difference() {
            offset(-rounding) offset(rounding) {
                difference() {
                    rounded_square([width, width], r = width / 2 - hole_pitch);

                    fan_holes(type, !grill, !grill, h = 0);
                }
                if(spokes) {
                    intersection() {
                        union() {
                            for(i = [(grill ? 1 : 0) : 1 : rings - 1]) {
                                r = inner_ring + i * ring_pitch;

                                ring(or = r + wall / 2, ir = r - wall / 2);
                            }
                            for(i = [0 : spokes - 1])
                                rotate(i * 360 / spokes + 45)
                                    translate([spoke_start, -spoke / 2])
                                        square([spoke_end - spoke_start + eps, spoke]);
                        }
                        square(width - eps, center = true);
                    }
                }
            }
            if(grill)
                fan_hole_positions(type, z = 0)
                    drill(screw_clearance_radius(fan_screw(type)), 0);

        }
        if(grill)
            difference() {
                r = min(inner_ring + ring_pitch, fan_hub(type) / 2);
                circle(r);

                for(a = [45 : 90 : 360])
                    rotate(a)
                        translate([r / 2, 0])
                            circle(wall);
            }
    }
}
