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
// Flat sheets
//

//
//         [ Code, Description, Thickness, Color, Soft, Warp, Weft, Color2]
//
mdf_colour = "#BEA587"; // sampled from a photo

MDF6      = [ "MDF6",      "Sheet MDF",               6, mdf_colour,             true];    // ~1/4"
MDF10     = [ "MDF10",     "Sheet MDF",              10, mdf_colour,             true];    // ~3/8"
MDF12     = [ "MDF12",     "Sheet MDF",              12, mdf_colour,             true];    // ~1/2"
MDF18     = [ "MDF18",     "Sheet MDF",              18, mdf_colour,             true];
MDF19     = [ "MDF19",     "Sheet MDF",              19, mdf_colour,             true];    // ~3/4"
PMMA2     = [ "PMMA2",     "Sheet acrylic",           2, [1,   1,   1,   0.5  ], false];
PMMA3     = [ "PMMA3",     "Sheet acrylic",           3, [1,   1,   1,   0.5  ], false];   // ~1/8"
PMMA6     = [ "PMMA6",     "Sheet acrylic",           6, [1,   1,   1,   0.5  ], false];   // ~1/4"
PMMA8     = [ "PMMA8",     "Sheet acrylic",           8, [1,   1,   1,   0.5  ], false];   // ~5/16"
PMMA10    = [ "PMMA10",    "Sheet acrylic",          10, [1,   1,   1,   0.5  ], false];   // ~3/8"
glass2    = [ "glass2",    "Sheet glass",             2, [1,   1,   1,   0.25 ], false];
DiBond    = [ "DiBond",    "Sheet DiBond",            3, [0.2, 0.2, 0.2, 1    ], false];
DiBond6   = [ "DiBond6",   "Sheet DiBond",            6, [0.2, 0.2, 0.2, 1    ], false];
Cardboard = [ "Cardboard", "Corrugated cardboard",    5, [0.8, 0.6, 0.3, 1    ], false];
FoilTape  = [ "FoilTape",  "Aluminium foil tape",   0.05,[0.9, 0.9, 0.9, 1    ], false];
Foam20    = [ "Foam20",    "Foam sponge",             20,[0.3, 0.3, 0.3, 1    ], true];
AL6       = [ "AL6",       "Aluminium tooling plate", 6, [0.9, 0.9, 0.9, 1    ], false];
AL8       = [ "AL8",       "Aluminium tooling plate", 8, [0.9, 0.9, 0.9, 1    ], false];
Steel06   = [ "Steel06",   "Sheet mild steel",       0.6,"silver"              , false];
Spring05  = [ "Spring05",  "Bi-metal saw blade",     0.5,"#FBC300",              false];
Silicone3 = [ "Silicone3", "Sheet silicone",          3, [0.9, 0.9, 0.9, 0.95 ], false];
CF1 =       [ "CF1",       "Sheet carbon fiber",      1, grey(35),               false,  2,  2,  grey(20)];
CF2 =       [ "CF2",       "Sheet carbon fiber",      2, grey(35),               false,  2,  2,  grey(20)];
CF3 =       [ "CF3",       "Sheet carbon fiber",      3, grey(35),               false,  2,  2,  grey(20)];


sheets = [CF1, CF2, CF3, MDF6, MDF10, MDF12, MDF19, PMMA2, PMMA3, PMMA6, PMMA8, PMMA10,
         glass2, DiBond, DiBond6, Cardboard, FoilTape, AL6, AL8, Steel06, Spring05, Silicone3, Foam20];

use <sheet.scad>
