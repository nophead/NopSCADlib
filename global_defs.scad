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
// This file included directly or indirectly in every scad file.
//
// This scheme allows the following:
//  bom defaults to 0
//  Setting $bom on the command line or in the main file before including lib.scad overrides it everywhere.
//  Setting $bom after including lib overrides bom in the libs but not in the local file.
//  Setting $_bom in the local file overrides it in the local file but not in the libs.
//
//function is_undef(x) = x == undef;

$_bom           = is_undef($bom)             ? 0      : $bom;             // 0 no bom, 1 assemblies and stls, 2 vitamins as well
$exploded       = is_undef($explode)         ? 0      : $explode;         // 1 for exploded view
layer_height    = is_undef($layer_height)    ? 0.25   : $layer_height;    // layer heigth when printing
extrusion_width = is_undef($extrusion_width) ? 0.5    : $extrusion_width; // filament width when printing
nozzle          = is_undef($nozzle)          ? 0.45   : $nozzle;          // 3D printer nozzle
cnc_bit_r       = is_undef($cnc_bit_r)       ? 1.2    : $cnc_bit_r;       // miniumum tool radius when milling 2D objects
pp1_colour      = is_undef($pp1_colour)      ? "lime" : $pp1_colour;      // printed part colour 1
pp2_colour      = is_undef($pp2_colour)      ? "red"  : $pp2_colour;      // printed part colour 2
pp3_colour      = is_undef($pp3_colour)      ? "blue" : $pp3_colour;      // printed part colour 3
pp4_colour      = is_undef($pp4_colour)      ? "darkorange" : $pp4_colour;// printed part colour 4
show_rays       = is_undef($show_rays)       ? false  : $show_rays;       // show camera sight lines and light direction

// Minimum wall is about two filaments wide but we extrude it closer to get better bonding
squeezed_wall = $preview ? 2 * extrusion_width - layer_height * (1 - PI / 4)
                         : extrusion_width - layer_height / 2 + nozzle / 2 + extrusion_width / 2;

inf = 1e10;      // very big
eps = 1/128;     // small fudge factor to stop CSG barfing on coincident faces.
$fa = 6;
$fs = extrusion_width / 2;

function round_to_layer(z) = ceil(z / layer_height) * layer_height;
// Some additional named colors
grey20                          = [0.2, 0.2, 0.2];
grey30                          = [0.3, 0.3, 0.3];
grey40                          = [0.4, 0.4, 0.4];
grey50                          = [0.5, 0.5, 0.5];
grey60                          = [0.6, 0.6, 0.6];
grey70                          = [0.7, 0.7, 0.7];
grey80                          = [0.8, 0.8, 0.8];
grey90                          = [0.9, 0.9, 0.9];
brass                           = "gold";

/*
 * Enums
 */
//
// Screws
//
hs_cap    = 0;
hs_pan    = 1;
hs_cs     = 2;     // counter sunk
hs_hex    = 3;
hs_grub   = 4;     // pulley set screw
hs_cs_cap = 5;
hs_dome   = 6;
//
// Hot end descriptions
//
jhead   = 1;
e3d     = 2;
//
// Face enumeration
//
f_bottom = 0;
f_top    = 1;
f_left   = 2;
f_right  = 3;
f_front  = 4;
f_back   = 5;
