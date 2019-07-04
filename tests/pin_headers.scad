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
include <../core.scad>
use <../utils/layout.scad>

include <../vitamins/pin_headers.scad>

pins = 10;

module pin_headers()
    layout([for(p = pin_headers) hdr_pitch(p) * pins], 15) {
        idc_transition(pin_headers[$i], 10);

        translate([0, 20])
            pin_header(pin_headers[$i], 10, 2);

        translate([0, 40])
            box_header(pin_headers[$i], 10, 2);

        translate([0, 65])
            pin_socket(pin_headers[$i], 10, 2);

        translate([0, 95])
            pin_socket(pin_headers[$i], 10, 2, right_angle = true);

    }

if($preview)
    pin_headers();
