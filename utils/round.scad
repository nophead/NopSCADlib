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

//! Round 2D shapes using `offset()`, which is fast and 3D shapes with [`offset_3D()`](#offset), which is very slow.
//!
//! A single radius can be specified or separate internal and external radii.
//! If `chamfer_base` is `true` for `round_3D()` then the bottom edge is made suitable for 3D printing by chamfering once the
//! the angle gets shallower than 45 degrees.
include <../utils/core/core.scad>
use <offset.scad>

module round(r, ir = undef, or = undef) { //! Round a 2D child, single radius or separate inside and outside radii
    IR = is_undef(ir) ? r : ir;
    OR = is_undef(or) ? r : or;
    offset(OR)
        offset(-OR -IR)
            offset(IR)
                children();
}

module round_3D(r, ir = undef, or = undef, chamfer_base = false) { //! Round a 3D child single radius or separate inside and outside radii
    IR = is_undef(ir) ? r : ir;
    OR = is_undef(or) ? r : or;
    offset_3D(OR, chamfer_base)
        offset_3D(-OR -IR, chamfer_base)
            offset_3D(IR, chamfer_base)
                children();
}
