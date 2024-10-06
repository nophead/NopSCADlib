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
include <../utils/core/core.scad>
use <../utils/layout.scad>

include <../vitamins/ht_pipes.scad>

module ht_pipes()
    color("grey")
    layout([for(p = ht_pipes) 40 + pipe_od(p)]) let(p = ht_pipes[$i], len = pipe_length(p)) {
        if(len <= 34)
             translate_z(len)
                ht_cap(p);

        if(len >= 101)
            ht_pipe(p);

        if(len == 100)
            ht_tpipe(p);
    }

if($preview)
    ht_pipes();
