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
//                            d1  d2    d3    s    a    b    d5
circlip_12i = ["circlip_12i", 12, 12.5, 13.0, 1.0, 3.4, 1.7, 1.5];
circlip_15i = ["circlip_15i", 15, 15.7, 16.2, 1.0, 3.7, 2.0, 1.7];
circlip_19i = ["circlip_19i", 19, 20.0, 20.5, 1.0, 4.1, 2.2, 2.0];
circlip_21i = ["circlip_21i", 21, 22.0, 22.5, 1.0, 4.2, 2.4, 2.0];
circlip_28i = ["circlip_28i", 28, 29.4, 30.1, 1.2, 4.8, 2.9, 2.0];

circlips = [circlip_12i, circlip_15i, circlip_19i, circlip_21i, circlip_28i];

use <circlip.scad>
