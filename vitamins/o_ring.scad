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
//! Nitrile rubber O-rings.
//!
//! Just a black torus specified by internal diameter, `id` and `minor_d` plus a BOM entry.
//! Can be shown stretched by specifying the `actual_id`.
//
include <../utils/core/core.scad>

module O_ring(id, minor_d, actual_id = 0) { //! Draw O-ring with specified internal diameter and minor diameter. `actual_id` can be used to stretch it around something.
    vitamin(str("O_ring(", id, ", ", minor_d, "): O-ring nitrile ", id, "mm x ", minor_d, "mm"));

    D = actual_id > id ? actual_id : id;            // allow it to be stretched
    //
    // assume volume conserved when stretched. It is proportional to major diameter and square of minor diameter
    //
    r = (minor_d / 2) * sqrt(id / D);
    R = D / 2 + r / 2;
    color([0.2, 0.2, 0.2]) rotate_extrude()
        translate([R, 0])
            circle(r = r);
}
