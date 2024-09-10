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

//
// D-connectors
//
DCONN9  = ["DCONN9",  30.81, [18,    16.92], 24.99, [9.26, 8.38], 12.55, 10.72, 6.693, 1.12,  9];
DCONN15 = ["DCONN15", 39.14, [26.25, 25.25], 33.32, [9.26, 8.38], 12.55, 10.72, 6.693, 1.12, 15];
DCONN25 = ["DCONN25", 53.04, [40,    38.96], 47.04, [9.26, 8.38], 12.55, 10.72, 6.693, 1.12, 25];
DCONN37 = ["DCONN37", 69.50, [56.42, 55.42], 63.50, [9.26, 8.38], 12.55, 10.72, 6.693, 1.12, 37];

d_connectors = [DCONN9, DCONN15, DCONN25, DCONN37];

use <d_connector.scad>
