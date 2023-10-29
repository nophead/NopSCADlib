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
//                            shaft                 shaft boss                offset     gearbox                          screw          depth, screw boss motor                                       hub         motor boss tags
FIT0492_A   = ["FIT0492_A",   [6, 5.5, 14.7, 12],   [12,  -0.5, 6, grey(60)], [0, 7],    [37, 0, 24.5, 0.6, grey(90)],    M3_dome_screw, 10,    [0, 0],   [[0, 0, 0],        35.6, 32, 2, "#ECDCBB"], [10, 3, 1], [],         [0.6, 2.8, 5.8, 23],
                [for(a = [0 : 60 : 300]) 15.5 *[cos(a), sin(a)] ]];    // DF-ROBOT FIT0492-A Metal DC Geared Motor - 12V 50RPM
GMAG_404327 = ["GMAG_404327", [6, 4.0, 17.6, 15.8], [14.9, 1, 4.7, grey(20)], [5.85, 0], [36.4, 24.5, 26.7, 2, grey(20)], M3_dome_screw, 10,    [5.9,0.5],[[2.3, -6.25, -5], 27.5, 38, 2, silver],    [10, 3, 1], [27, 7, 1], [0.5, 2.8, 5.8, 23],
                [for(x=[14.7, -13.8], y = [-1,1])[x, y * 8.75]]];      // Nidec Brushed Geared, 2.84 W, 24 V dc, 50 Ncm, 65 rpm

gear_motors = [FIT0492_A, GMAG_404327];

use <gear_motor.scad>
