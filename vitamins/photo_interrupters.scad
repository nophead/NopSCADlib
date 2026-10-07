//
// NopSCADlib Copyright Chris Palmer 2023
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
PH1 =     ["PH1",      6.4, 25.9 , 3.5, 8.6, 4.1, 5.9, 3, grey(20), [22, 20, 1.6, true, 11-3.2, 0, "blue",[[8.3, -7.5], [8.3, 7.5]], 3]];
ITR9608 = ["ITR-9608", 6, 12, 2, 8,  3.8,   5, 0, grey(20)];

photo_interrupters = [PH1, ITR9608];

use <photo_interrupter.scad>
