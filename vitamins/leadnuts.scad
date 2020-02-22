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

LSN8x2 = ["LSN8x2", "Leadscrew nut 8 x 2",          8, 10.2, 15, 22,   3.5, 1.5, 4, 3.5, 8,       M3_cap_screw, 2, 2];
LSN8x8 = ["LSN8x8", "Leadscrew nut 8 x 8 RobotDigg",8, 12.75,19, 25.4, 4.1, 0,   3, 3.5, 19.05/2, M3_cap_screw, 2, 8];

leadnuts = [LSN8x2, LSN8x8];

use <leadnut.scad>
