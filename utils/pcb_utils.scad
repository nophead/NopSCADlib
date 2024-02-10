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

//
//! Utilities for making PCBs and components
//
include <../utils/core/core.scad>

module solder_meniscus(ir = 0.3, r = 1, h = 0.7) { //! Draw a solder meniscus
    $fn = fn;
    color("silver") rotate_extrude()
        difference() {
            square([r, h]);

            translate([r + eps, h + eps])
                ellipse(r - ir + eps, h);
        }
}

module solder(ir = 0.3) { //! Maybe add solder meniscus if $solder is set
    if(!is_undef($solder))
        vflip()
            translate_z($solder.z)
                solder_meniscus(ir = ir, r = $solder.x);
}

module cylindrical_wrap(r, h = eps) { //! Wrap a 2D child extruded to height `h` around a cylinder with radius `r`.
    sides = r2sides(r);
    dx = 2 * r * tan(180 / sides);
    for(i = [0 : sides - 1])
        rotate((i - 0.5) * 360 / sides)
            translate([0, r])
                 rotate([-90, 0, 0])
                    linear_extrude(h, center = true)
                        intersection() {
                            translate([(sides / 2 - i) * -dx, 0])
                                children();

                            square([dx, big], center = true);
                        }
}
