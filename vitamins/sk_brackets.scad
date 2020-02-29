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
// SK shaft support brackets
//

//               d   h   E   W   L   F    G   P   B    S  bolthole
SK8  = ["SK8",   8, 20, 21, 42, 14, 32.8, 6, 18, 32, 5.5, M5_clearance_radius];
SK10 = ["SK10", 10, 20, 21, 42, 14, 32.8, 6, 18, 32, 5.5, M5_clearance_radius];
SK12 = ["SK12", 12, 23, 21, 42, 14, 37.5, 6, 18, 32, 5.5, M5_clearance_radius];
SK16 = ["SK16", 16, 27, 24, 48, 16, 44.0, 8, 25, 38, 5.5, M5_clearance_radius];

sk_brackets = [SK8,  SK10, SK12, SK16];
use <sk_bracket.scad>
