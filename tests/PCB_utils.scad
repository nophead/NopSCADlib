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

include <../utils/core/core.scad>

use <../utils/pcb_utils.scad>

module pcb_utils() {
    let($solder = [1, 0, 1.6])
        solder();

    r = 2;
    h = 10;

    color(grey(20))
        cylinder(r = r, h = h);

    color("silver")
        vflip()
            cylinder(d = 0.6, h = 3, $fs = fs, $fa = fa);

    color("white")
        translate_z(h / 2)
            cylindrical_wrap(r = r)
                resize([0, h * .8], auto = true)
                    rotate(90)
                        text("Hello", halign = "center", valign = "center");
}

if($preview)
    rotate(-45)
        pcb_utils();
