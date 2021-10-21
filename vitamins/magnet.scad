//
// NopSCADlib Copyright Chris Palmer 2020
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
//! Cylindrical and ring magnets.
//
include <../utils/core/core.scad>

function magnet_name(type)  = type[1]; //! Name
function magnet_od(type)    = type[2]; //! Outer diameter
function magnet_id(type)    = type[3]; //! Inside diameter if a ring
function magnet_h(type)     = type[4]; //! Height
function magnet_r(type)     = type[5]; //! Corner radius

module magnet(type) { //! Draw specified magnet
    od = magnet_od(type);
    id = magnet_id(type);
    h = magnet_h(type);
    r = magnet_r(type);

    vitamin(str("magnet(", type[0], "): ", magnet_name(type), ", ", od, "mm diameter, ", h, "mm high", id ? str(", ", id, "mm bore") : "" ));

    or = od / 2;
    ir = id / 2;
    color(silver)
        rotate_extrude()
            union() {
                translate([ir, 0])
                    rounded_square([or - ir, h], r, center = false);
                if(!ir)
                    square([r, h]);
            }

}
