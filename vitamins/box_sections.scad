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

//
// Box sections
//
AL12x8x1 =  ["AL12x8x1",  "Aluminium rectangular box section 12mm x 8mm x 1mm",     [12, 8],  1, 0.5, silver, undef];
AL20x20x2 = ["AL20x20x2", "Aluminium rectangular box section 20mm x 20mm x 2mm",    [20, 20], 2, 0.5, silver, undef];
CF10x10x1 = ["CF10x10x1", "Carbon fiber rectangular box section 10mm x 10mm x 1mm", [10, 10], 1, 0.5, grey(35), grey(20)];


box_sections = [AL12x8x1, AL20x20x2, CF10x10x1];

use <box_section.scad>
