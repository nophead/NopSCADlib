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

include <../vitamins/screws.scad>
include <../vitamins/stepper_motors.scad>

module stepper_motors()
    layout([for(s = stepper_motors) NEMA_width(s)], 5) {
        rotate(180)
            NEMA(stepper_motors[$i]);

        NEMA_screws(stepper_motors[$i], M3_pan_screw);
    }

if($preview)
    stepper_motors();
