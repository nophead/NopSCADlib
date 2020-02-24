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

include <../vitamins/sk_brackets.scad>

module sk_brackets() {
    screws = [M5_cap_screw, M5_cap_screw, M4_cap_screw, M5_cap_screw];
    nuts = [undef, M5_nut, M4_sliding_t_nut, M5_sliding_t_nut];
    layout([for(s = sk_brackets) 1.5 * sk_size(s)[1]])
        sk_bracket_assembly(sk_brackets[$i], screw_type = screws[$i], nut_type = nuts[$i]);
}

if($preview)
    sk_brackets();

