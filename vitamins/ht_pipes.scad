//
// NopSCADlib Copyright Jan Giebels 2024
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

//                 definition           name                diameter    wall    length
HT_40_pipe_250   = ["HT_40_pipe_250",    "HT 40 pipe 250 mm",    40,     2.1,    250];
HT_50_cap        = ["HT_50_cap",         "HT 50 cap",            50,     2.1,    34];
HT_50_pipe_250   = ["HT_50_pipe_250",    "HT 50 pipe 250 mm",    50,     2.1,    250];
HT_50_pipe_500   = ["HT_50_pipe_500",    "HT 50 pipe 500 mm",    50,     2.1,    500];
HT_50_pipe_1000  = ["HT_50_pipe_1000",   "HT 50 pipe 1000 mm",   50,     2.1,    1000];
HT_50_pipe_2000  = ["HT_50_pipe_2000",   "HT 50 pipe 2000 mm",   50,     2.1,    2000];
HT_50_tpipe      = ["HT_50_tpipe",       "HT 50 T pipe",         50,     2.1,    100];
HT_50_40_tpipe   = ["HT_50_40_tpipe",    "HT 50/40 T pipe",      50,     2.1,    100];

ht_pipes = [HT_50_cap, HT_50_pipe_250, HT_50_pipe_500, HT_50_pipe_1000, HT_50_pipe_2000, HT_50_tpipe, HT_50_40_tpipe, HT_40_pipe_250];

use <ht_pipe.scad>