//
// NopSCADlib Copyright Chris Palmer 2024
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
use <../utils/layout.scad>

include <../vitamins/rod_ends.scad>


module rod_ends(list = rod_ends) {
    diameters = [for(b = list) rod_end_bearing_od(b)];
    max = max(diameters);
    layout(diameters) let(b = list[$i])
        rod_end_bearing(list[$i]);
}

if($preview)
    rod_ends();
