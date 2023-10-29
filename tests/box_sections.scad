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
include <../utils/core/core.scad>
use <../utils/layout.scad>

include <../vitamins/box_sections.scad>

module box_sections() {
    woven = [for(b = box_sections) if(box_section_is_woven(b)) b];
    plain = [for(b = box_sections) if(!box_section_is_woven(b)) b];
    layout([for(b = woven) box_section_size(b).x * 0], 10)
        box_section(box_sections[$i], 100 - $i * 20);

    translate([50, 0])
        for(i = [0 : len(plain) - 1])
            box_section(plain[i], 100 - i * 20);

}

if($preview)
    box_sections();
