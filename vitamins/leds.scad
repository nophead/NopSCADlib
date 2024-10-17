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
//                          d       r        r      h    p     l
//                          i       i        i      e    i     e
//                          a       m        m      i    t     a
//                                                  g    c     d
//                                  d        t      h    h
//                                                  t          t
//
LED3mm  = ["LED3mm",        3,     3.15,    1.15,  4.6, 2.54, 0.4];
LED5mm  = ["LED5mm",        5,     5.9,     1.1,   9.0, 2.54, 0.4];
LED8mm  = ["LED8mm",        8,     9.2,     1.95, 11.0, 2.54, 0.4];
LED10mm = ["LED10mm",      10,    11.0,     2.0,  13.5, 2.54, 0.4];

LED5x2mm = ["LED5x2mm", [5,2], [5,2.7],     0.7,   7.0, 2.54, 0.5];

LEDs = [LED3mm, LED5mm, LED8mm, LED10mm, LED5x2mm];

use <led.scad>
