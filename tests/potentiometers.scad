//
// NopSCADlib Copyright Chris Palmer 2021
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
//! Potentiometers and rotary encoders
include <../core.scad>
include <../utils/layout.scad>
include <../vitamins/potentiometers.scad>

module potentiometers()
    layout([for(p = potentiometers) pot_size(p).x])
        hflip() {
            potentiometer(potentiometers[$i], shaft_length = 30);

            translate_z(-3)
                pot_nut(potentiometers[$i]);
        }

if($preview)
    let($show_threads = true)
        potentiometers();
