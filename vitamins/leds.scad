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
//                    d     r    r     h     p    l
//                    i     i    i     e     i    e
//                    a     m    m     i     t    a
//                                     g     c    d
//                          d    t     h     h
//                                     t          t
//
LED3mm  = ["LED3mm",   3,  3.1, 1.0,  4.5, 2.54, 0.4];
LED5mm  = ["LED5mm",   5,  5.6, 0.9,  8.5, 2.54, 0.4];
LED10mm = ["LED10mm", 10, 11.0, 2.0, 13.5, 2.54, 0.4];

LEDs = [LED3mm, LED5mm, LED10mm];

use <led.scad>
