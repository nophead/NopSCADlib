//
// NopSCADlib Copyright Chris Palmer 2019
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
//! A utilities for making threads with sweep.
//
include <../core.scad>
use <sweep.scad>
use <maths.scad>

function thread_profile(h, crest, angle) = //! Create thread profile path
    let(base = crest + 2 * h * tan(angle / 2))
        [[-base / 2, 0, 0], [-crest / 2, h, 0], [crest / 2, h, 0], [base / 2, 0, 0]];

module male_thread(pitch, minor_d, length, profile, taper_top = true, center = true, solid = true) { //! Create male thread
    turns = length / pitch + (taper_top ? 0 : 1);
    r = minor_d / 2;
    sides = r2sides(r);
    h = max([for(p = profile) p.y]);
    final = (turns - 1) * sides;
    path = [for(i = [0 : sides * turns],
                R = i < sides ? r - h + h * i / sides
                    : i > final && taper_top ? r - h * (i - final) / sides : r,
                a = i * 360 / sides)
                    [R * sin(-a), R * cos(-a), pitch * a / 360]];
    t = atan(pitch / sides / (r * cos(225 / sides)));
    translate_z(center ? -length / 2 : 0) {
        render() intersection() {
            sweep(path, profile, twist = t * sides * turns);
            cylinder(d = minor_d + 5, h = length);
        }
        if(solid)
            rotate(90)
                cylinder(d = minor_d + eps, h = length);
    }
}

module female_thread(pitch, outer_d, length, profile, taper_top = true, center = true) { //! Create female thread
    turns = length / pitch + (taper_top ? 0 : 1);
    r = outer_d / 2;
    sides = r2sides(r);
    h = max([for(p = profile) p.y]);
    final = (turns - 1) * sides;
    path = [for(i = [0 : sides * turns],
                R = i < sides ? r + h - h * i / sides
                    : i > final && taper_top ? r + h * (i - final) / sides : r,
                a = i * 360 / sides)
                    [R * sin(-a), R * cos(-a), pitch * a / 360]];
    t = atan(pitch / sides / (r * cos(225 / sides)));
    translate_z(center ? -length / 2 : 0) {
        render() intersection() {
            sweep(path, reverse([for(p = profile) [p.x, -p.y, 0]]), twist = t * sides * turns);
            cylinder(d = outer_d + 5, h = length);
        }
    }
}

module male_metric_thread(d, pitch, length, taper_top = true, center = true) { //! Create male thread with metric profile
    h = sqrt(3) / 2 * pitch;
    minor_d = d - 5 * h / 4;
    male_thread(pitch, minor_d, length, thread_profile((d - minor_d) / 2, pitch / 8, 60), taper_top, center);
}

module female_metric_thread(d, pitch, length, taper_top = true, center = true) { //! Create male thread with metric profile
    h = sqrt(3) / 2 * pitch;
    outer_d = d + 5 * h / 4;
    male_thread(pitch, outer_d, length, thread_profile((outer_d - d) / 2, pitch / 8, 60), taper_top, center);
}

function metric_coarse_pitch(d) //! Convert metric diameter to pitch
    = d == 1.6 ? 0.35  // M1.6
               : [0.4, // M2
                  0.45,// M2.5
                  0.5, // M3
                  0.6, // M3.5
                  0.7, // M4
                  0,
                  0.8, // M5
                  0,
                  1.0, // M6
                  0,
                  0,
                  0,
                  1.25, // M8
                  0,
                  0,
                  0,
                  1.5,  // M10
                  0,
                  0,
                  0,
                  1.75, // M12
                 ][d * 2 - 4];

male_metric_thread(3, 0.5, 25);

translate([10, 0])
male_metric_thread(8, 1.25, 30);
