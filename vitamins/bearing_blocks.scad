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

//
// SCS bearing blocks
//

include <linear_bearings.scad>
include <circlips.scad>

//                        T  h   E   W   L   F     G   B     C   K     S1            S2   L1  LB
SCS6UU    = ["SCS6UU",    6,  9, 15, 30, 25, 18,   15, 20,   15, 5,    M4_cap_screw, 3.4,  8, LM6UU,  circlip_12i, 0];
SCS8UU    = ["SCS8UU",    6, 11, 17, 34, 30, 22,   18, 24,   18, 5,    M4_cap_screw, 3.4,  8, LM8UU,  circlip_15i, 0];
SCS10UU   = ["SCS10UU",   8, 13, 20, 40, 35, 26,   21, 28,   21, 6,    M5_cap_screw, 4.3, 12, LM10UU, circlip_19i, 0];
SCS12UU   = ["SCS12UU",   8, 15, 21, 42, 36, 28,   24, 30.5, 26, 5.75, M5_cap_screw, 4.3, 12, LM12UU, circlip_21i, 0];
SCS16UU   = ["SCS16UU",   9, 19, 25, 50, 44, 38.5, 32.5, 36, 34, 7,    M5_cap_screw, 4.3, 12, LM16UU, circlip_28i, 0];

SCS8LUU   = ["SCS8LUU",   6, 11, 17, 34, 58, 22,   18, 24,   42, 5,    M4_cap_screw, 3.4,  8, LM8UU,  circlip_15i, 4];
SCS10LUU  = ["SCS10LUU",  8, 13, 20, 40, 68, 26,   21, 28,   45, 6,    M5_cap_screw, 4.3, 12, LM10UU, circlip_19i, 4];
SCS12LUU  = ["SCS12LUU",  8, 15, 21, 42, 70, 28,   24, 30.5, 50, 5.75, M5_cap_screw, 4.3, 12, LM12UU, circlip_21i, 4];
SCS16LUU  = ["SCS16LUU",  9, 19, 25, 50, 85, 38.5, 32.5, 36, 60, 7,    M5_cap_screw, 4.3, 12, LM16UU, circlip_28i, 4];

//                        T  h   H   W   M   G     J   K   A  S1            I   LB                         S2             S2L
SBR16UU   = ["SBR16UU",  16, 25, 45, 45, 45, 33,   32, 30, 9, M5_cap_screw, 12, LM16UUOP, circlip_28iw, 0, M5_grub_screw, 5];

scs_bearing_blocks = [SCS6UU, SCS8UU,  SCS10UU, SCS12UU, SCS16UU];
scs_bearing_blocks_long = [SCS8LUU,  SCS10LUU, SCS12LUU, SCS16LUU];

sbr_bearing_blocks = [SBR16UU];

use <bearing_block.scad>
