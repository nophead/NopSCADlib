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



//sh is horizontal positions of the screw holes, expressed in %/100 of the nut arm
//sv is vertical positions of the screw holes, expressed in %/100 of the nut arm
//                                                                              sdia   nd   nt  nnt nsx  nty1 nty2   sh     sv
corner_3d_connector_2020 = ["corner_3d_connector_2020", 20,    5,   13,     2.5,    4,  6,  3.5,5,  15.5,10,    6,   [0.5], [0.5]];
corner_3d_connector_3030 = ["corner_3d_connector_3030", 29.6,6.2,   22,     2.5,    6,  8,  4.2,6.2,24.9,16,    11,   [0.25,0.75], [0.65]];
corner_3d_connector_4040 = ["corner_3d_connector_4040", 40,9.5,     25,     2.5,    6,  8,  5,  9.5,34.0,19.5,  14,   [0.25,0.75], [0.65]];

corner_3d_connectors = [corner_3d_connector_2020,corner_3d_connector_3030,corner_3d_connector_4040];

use <corner_3d_connector.scad>

corner_3d_connector(corner_3d_connector_2020);
translate([50,0,0])
corner_3d_connector(corner_3d_connector_3030, grub_screws=true);
translate([120,0,0])
corner_3d_connector(corner_3d_connector_4040);