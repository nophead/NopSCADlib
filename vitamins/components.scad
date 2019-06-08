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
// Resistor model for hot end
//
RWM04106R80J   = [ "RWM04106R80J",   "Resistor RWM04106R80J 6R8 3W vitreous enamel",    12,     5, 0.8,  30,  5.5, "green",               false, false];
RIE1212UB5C5R6 = [ "RIE1212UB5C5R6", "Resistor UB5C 5R6F 5R6 3W vitreous enamel",       13,   5.9, 0.96, 35,  6.0, "gray",                false, false];
//
// Thermistors
//
Honewell       = [ "Honewell",  "Thermistor Honeywell 135-104LAC-J01 100K 1%",   4.75, 1.8, 0.5,  28.6,  2, "red",                        false];
Epcos          = [ "Epcos",     "Thermistor Epcos B57560G104F 100K 1%",          4.6,  2.5, 0.3,  67,  2.5, [0.8, 0.8, 0.8, 0.25], true,  false];
EpcosBlue      = [ "EpcosBlue", "Thermistor Epcos B57861S104F40 100K 1%",        6.5,  2.41,0.25, 43.5,2.5, "black",               true,  true];

resistors = [Honewell, Epcos, EpcosBlue, RWM04106R80J, RIE1212UB5C5R6];
//
// Aluminium clad resistors used for heated beds and dummy loads.
//
//                  l    w    tab  hp    vp    t    hd   clr   h  wire
THS10 = [ "THS10", 17,   17,  4.8, 11.3, 12.4, 2.5, 2.4, 1.9,  9, 30.0];
THS15 = [ "THS15", 21,   21,  6.0, 14.3, 15.9, 3.2, 2.4, 1.9, 11, 36.5];
THS25 = [ "THS25", 29,   28,  9.4, 18.3, 19.8, 3.2, 3.3, 2.8, 15, 47];
THS50 = [ "THS50", 51,   30, 10.7, 39.7, 21.4, 3.2, 3.3, 2.8, 17, 72.5];

al_clad_resistors = [ THS10, THS15, THS25, THS50];
//
// Thermal cutout used on heated beds.
//
TC = ["TC", 31.4, 9.13, 0.8, 3.9, 24, 14.56, 11.3, 14.13, 2, 25, 10];

thermal_cutouts = [ TC ];

use <component.scad>
