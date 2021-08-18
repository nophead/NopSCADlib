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
include <../core.scad>
include <../vitamins/geared_steppers.scad>

use <../utils/layout.scad>

module geared_steppers()
    layout([for(g = geared_steppers) max(gs_diameter(g), gs_pitch(g) + gs_lug_w(g) / 2)], 5)
        geared_stepper(geared_steppers[$i]);

geared_steppers();
