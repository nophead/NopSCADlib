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

//! Redefines `sphere()` to always have a vertex on all six half axes I.e. vertices at the poles and the equator and `$fn` a multiple of four.
//! This ensures `hull` and `minkowski` results have the correct dimensions when spheres are placed at the corners.

module sphere(r = 1, d = undef) {                   //! Override `sphere` so that has vertices on all three axes. Has the advantage of giving correct dimensions when hulled
    R = is_undef(d) ? r : d / 2;
    rotate_extrude($fn = r2sides4n(R))
        rotate(-90)
            semi_circle(R);
}
