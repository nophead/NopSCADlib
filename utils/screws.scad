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

include <../vitamins/screws.scad>

screw_lists = [
[ M2_cap_screw,    M2p5_cap_screw, M3_cap_screw,    M4_cap_screw,    M5_cap_screw,    M6_cap_screw, M8_cap_screw],
[ 0,               0,              M3_low_cap_screw],
[ M2_cs_cap_screw, 0,              M3_cs_cap_screw, M4_cs_cap_screw, M5_cs_cap_screw, M6_cs_cap_screw, M8_cs_cap_screw],
[ M2_dome_screw,   M2p5_dome_screw,M3_dome_screw,   M4_dome_screw,   M5_dome_screw],
[ 0,               0,              M3_hex_screw,    M4_hex_screw,    M5_hex_screw,    M6_hex_screw, M8_hex_screw],
[ 0,               M2p5_pan_screw, M3_pan_screw,    M4_pan_screw,    M5_pan_screw,    M6_pan_screw, No632_pan_screw],
[ No2_screw,       0,              No4_screw,       No6_screw,       No8_screw,       No6_cs_screw],
[ 0,               0,              M3_grub_screw,   M4_grub_screw,   M5_grub_screw,   M6_grub_screw]
];

screws = [for(list = screw_lists) each list];

function find_screw(type, size, i = 0) =
    i >= len(screws) ? undef
                     : screw_head_type(screws[i]) == type && screw_radius(screws[i]) == size / 2 ? screws[i]
                                                                                                 : find_screw(type, size, i + 1);

function alternate_screw(type, screw) =
    let(alt_screw = find_screw(type, screw_radius(screw) * 2))
        alt_screw ? alt_screw :screw;
