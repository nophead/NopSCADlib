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
show_cutout = false;

include <../core.scad>
include <../vitamins/psus.scad>

use <../utils/layout.scad>



module psus()
    layout([for(p = psus) atx_psu(p) ? psu_length(p) : psu_width(p)], 10) let(p = psus[$i])
    rotate(atx_psu(p) ? 0 : 90) {
        psu(p);

        if (psu_screw(p))
            psu_screw_positions(p)
                translate_z(3)
                    screw_and_washer(psu_screw(p), 8);

        if(show_cutout && atx_psu(p))
            #atx_psu_cutout(p);
    }

if($preview) {
    psus();

    for(p = psus_not_shown)
        hidden()
            psu(p);
}
