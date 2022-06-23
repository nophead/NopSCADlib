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
show_connection_pos = false;

/* [Hidden] */
include <../core.scad>
include <../vitamins/stepper_motors.scad>

use <../utils/layout.scad>

has_connector = [NEMA17_27, NEMA17_40, NEMA17_40L280, NEMA8_30, NEMA8_30BH];

module stepper_motors()
    layout([for(s = stepper_motors) NEMA_width(s)], 5, no_offset = false) let(m = stepper_motors[$i]) {
        rotate(180) {
            NEMA(m, 0, in(has_connector, m) ? true : show_connection_pos ? undef : false);

            if(show_connection_pos)
                translate(NEMA_connection_pos(m, in(has_connector, m)))
                    sphere();

            translate_z(4)
                NEMA_screws(m, M3_pan_screw, n = $i - 2, earth = $i > 6 ? undef : $i - 3);
        }
    }

if($preview)
    let($show_threads = 1)
        stepper_motors();
