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
//
//                  p
//                  a
//                  r
//                  t
//
//
//               l     w     t  vp   hp
CK7000_tag = [3.94, 2.03, 0.76, 4.7, 4.83];
CK7000_pin = [6.1,  1.5,  0.76, 4.7, 4.83];
AP5236_pin = [5.2 , 1.0,  0.8,  4.7, 4.83];
MS332F_pin = [4.0 , 1.0,  1.0,  4.7, 4.83];

//                               w     l     d    t    i      c   od  id thread      pv     a    tl     pd    pw
CK7101 = ["CK7101", "CK7101", 6.86, 12.7, 8.89, 0.4, 1.7, "red", 6.1, 4, 8.89, 0, 0, 4.45, 25/2, 10.67, 2.92, 0,   toggle_nut, toggle_washer, 3, CK7000_tag];
CK7105 = ["CK7105", "CK7105", 6.86, 12.7, 8.89, 0.4, 1.7, "red", 6.1, 4, 8.89, 0, 0, 4.45,-25/2, 21.33, 5.08, 2.54,toggle_nut, toggle_washer, 3, CK7000_pin];

AP5236 = ["AP5236", "AP5236", 7.0,  13.6, 11,   0.4, 1.7, "blue",6.1, 4, 8.0 , 8, 1, 3.0 , 25/2, 22.2,  4.90, 2.50,toggle_nut, toggle_washer, 3, AP5236_pin];
MS332F = ["MS332F", "MS332F", 12.6, 13.1, 9.5,  0.4, 1.7, "blue",6.1, 4, 8.0 , 8, 1, 4.0 , 25/2, 14.4,  5.0,  2.2 ,toggle_nut, toggle_washer, 6, MS332F_pin];

toggles = [CK7101, CK7105, AP5236, MS332F];

use <toggle.scad>
