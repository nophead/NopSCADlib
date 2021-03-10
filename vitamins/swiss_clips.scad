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
//! Swiss picture clip.
//! Used for holding glass on 3D printer beds.
//

UKPFS1008_10 = ["UKPFS1008_10", 39, 13, 13, 0.75, 1.5, 4, [3.5, 2.2, 4.4], [5.25, 4.12], 9, 37 - 9, 11];

swiss_clips = [ UKPFS1008_10 ];

use <swiss_clip.scad>
