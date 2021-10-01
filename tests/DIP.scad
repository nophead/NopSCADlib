//
// NopSCADlib Copyright Chris Palmer 2020
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
include <../utils/core/core.scad>
use <../vitamins/dip.scad>

dips = [[6, "OPTO"], [8, "NE555"], [14, "74HC00"], [16, "ULN2003"], [18, "ULN2803"], [20, "74HC245"], [28, "ATMEGA328"]];

module dips()
    for(i = [0 : len(dips) - 1]) let(dip = dips[i])
        translate([i * inch(0.5), 0])
            pdip(dip[0], dip[1], dip[0] > 20);

if($preview)
    dips();
