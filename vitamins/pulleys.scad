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
include <belts.scad>
//
//                                               n       t   o      b         w    h  h    b     f    f  s   s    s              s
//                                               a       e   d      e         i    u  u    o     l    l  c   c    c              c
//                                               m       e          l         d    b  b    r     a    a  r   r    r              r
//                                               e       t          t         t            e     n    n  e   e    e              e
//                                                       h                    h    d  l          g    g  w   w    w              w
//                                                                                               e    e                          s
//                                                                                                       l   z
//                                                                                               d    t
//
T5x10_pulley         = ["T5x10_pulley",         "T5",    10, 15,    T5x6,  11.6, 7.9, 7,   5, 19.3, 1.7, 3, 10.7, M3_grub_screw, 1];
T2p5x16_pulley       = ["T2p5x16_pulley",       "T2.5",  16, 12.16, T2p5x6,   8,  16, 5.7, 5, 16.0, 1.0, 6, 3.75, M4_grub_screw, 1];
GT2x20um_pulley      = ["GT2x20um_pulley",      "GT2UM", 20, 12.22, GT2x6,  7.5,  18, 6.5, 5, 18.0, 1.0, 6, 3.75, M3_grub_screw, 2]; //Ultimaker
GT2x20ob_pulley      = ["GT2x20ob_pulley",      "GT2OB", 20, 12.22, GT2x6,  7.5,  16, 5.5, 5, 16.0, 1.0, 6, 3.25, M3_grub_screw, 2]; //Openbuilds
GT2x16_pulley        = ["GT2x16_pulley",        "GT2",   16,  9.75, GT2x6,  7.0,  13, 5,   5, 13.0, 1.0,4.5,3.0,  M3_grub_screw, 2];
GT2x12_pulley        = ["GT2x12_pulley",        "GT2RD", 12,  7.15, GT2x6,  6.5,  12, 5.5, 4, 12.0, 1.0, 4, 3.0,  M3_grub_screw, 2]; //Robotdigg
GT2x20_toothed_idler = ["GT2x20_toothed_idler", "GT2",   20, 12.22, GT2x6,  6.5,  18, 0,   4, 18.0, 1.0, 0, 0,    false,         0];
GT2x20_plain_idler   = ["GT2x20_plain_idler",   "GT2",    0, 12.0,  GT2x6,  6.5,  18, 0,   4, 18.0, 1.0, 0, 0,    false,         0];
GT2x16_toothed_idler = ["GT2x16_toothed_idler", "GT2",   16,  9.75, GT2x6,  6.5,  14, 0,   3, 14.0, 1.0, 0, 0,    false,         0];
GT2x16_plain_idler   = ["GT2x16_plain_idler",   "GT2",    0,  9.63, GT2x6,  6.5,  13, 0,   3, 13.0, 1.0, 0, 0,    false,         0];
GT2x16x7_plain_idler = ["GT2x16x7_plain_idler", "GT2",    0,  9.63, GT2x6,  7.0,  13, 0,   3, 13.0, 1.0, 0, 0,    false,         0];

pulleys = [T5x10_pulley,
           T2p5x16_pulley,
           GT2x20um_pulley,
           GT2x20ob_pulley,
           GT2x16_pulley,
           GT2x12_pulley,
           GT2x20_toothed_idler,
           GT2x20_plain_idler,
           GT2x16_toothed_idler,
           GT2x16_plain_idler,
           GT2x16x7_plain_idler];

use <pulley.scad>
