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
include <../utils/core/core.scad>
include <../vitamins/ssrs.scad>

use <../utils/layout.scad>
use <../printed/ssr_shroud.scad>

thickness = 3;

module ssr_shrouds()
    layout([for(s = ssrs) ssr_width(s)], 15) let(ssr = ssrs[$i])
        rotate(90) {
            if($preview)
                ssr_shroud_fastened_assembly(ssr, 6, thickness, ssr[0]);
            else
                ssr_shroud(ssr, 6, ssr[0]);
        }

ssr_shrouds();
