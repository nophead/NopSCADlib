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
//
rr_green = [0, 146/255, 0];                                               // RepRap logo colour
crimson  = [220/255, 20/255, 60/255];

layer_height    = is_undef($layer_height)    ? 0.25   : $layer_height;    // layer height when printing
layer_height0   = is_undef($layer_height0)   ? layer_height : $layer_height0; // height of first layer if different
extrusion_width = is_undef($extrusion_width) ? 0.5    : $extrusion_width; // filament width when printing
nozzle          = is_undef($nozzle)          ? 0.45   : $nozzle;          // 3D printer nozzle
cnc_bit_r       = is_undef($cnc_bit_r)       ? 1.2    : $cnc_bit_r;       // minimum tool radius when milling 2D objects
show_rays       = is_undef($show_rays)       ? false  : $show_rays;       // show camera sight lines and light direction
show_threads    = is_undef($show_threads)    ? false  : $show_threads;    // show screw threads
show_plugs      = is_undef($show_plugs)      ? false  : $show_plugs;      // plugs on headers
teardrop_angle  = is_undef($teardrop_angle)  ? 45     : $teardrop_angle;  // teardrop angle
pp1_colour      = is_undef($pp1_colour)      ? rr_green     : $pp1_colour;// printed part colour 1, RepRap logo colour
pp2_colour      = is_undef($pp2_colour)      ? crimson      : $pp2_colour;// printed part colour 2
pp3_colour      = is_undef($pp3_colour)      ? "SteelBlue"  : $pp3_colour;// printed part colour 3
pp4_colour      = is_undef($pp4_colour)      ? "darkorange" : $pp4_colour;// printed part colour 4
manifold        = is_undef($manifold)        ? false  : $manifold;        // Manifold library being used instead of cgal

// Minimum wall is about two filaments wide but we extrude it closer to get better bonding
squeezed_wall = $preview ? 2 * extrusion_width - layer_height * (1 - PI / 4)
                         : extrusion_width - layer_height / 2 + nozzle / 2 + extrusion_width / 2;

inf = 1e10;       // very big
big = manifold ? 1e3 : inf;     // Not too big for manifold
eps = 1/128;     // small fudge factor to stop CSG barfing on coincident faces.

fa = is_undef($vitamin_fa) ? 6    : $vitamin_fa;          // Used for drawing vitamins, rather than printing.
fs = is_undef($vitamin_fs) ? 0.25 : $vitamin_fs;
fn = 32;

$fa = $fa == 12 ? 6 : $fa;          // Defaults for printing
$fs = $fs == 2 ? extrusion_width / 2 : $fs;


// Some additional named colours
silver           = [0.75, 0.75, 0.75];
gold             = [255, 215,   0] / 255;
brass            = [255, 220, 100] / 255;
copper           = [230, 140,  51] / 255;

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
// Face enumeration
//
f_bottom = 0;
f_top    = 1;
f_left   = 2;
f_right  = 3;
f_front  = 4;
f_back   = 5;
