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
//! Annotation used in this documentation
//

include <../utils/core/core.scad>

module label(str, scale = 0.25, valign = "baseline", halign = "left") //! Draw text that always faces the camera
    color("black")
        %rotate($vpr != [0, 0, 0] ? $vpr : [70, 0, 315])
            linear_extrude(eps)
                scale(scale)
                    text(str, valign = valign, halign = halign);

module arrow(length = 20) { //! Draw an arrow that faces downwards
    d = length / 20;
    head_r = 1.5 * d;

    $fs = fs; $fa = fa;
    color("grey") %union() {
        translate_z(head_r)
            cylinder(d = d, h = length - head_r);

        cylinder(r1 = 0, r2 = head_r, h = head_r);
    }
}
