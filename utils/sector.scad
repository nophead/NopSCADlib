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
//! A sector of a circle between two angles.
//
include <../utils/core/core.scad>

module sector(r, start_angle, end_angle) { //! Create specified sector given radius `r`, `start_angle` and `end_angle`
    R = r * sqrt(2) + 1;

    if(end_angle > start_angle)
        intersection() {
            circle4n(r);

            // A 4 triangle fan
            polygon([[0, 0],
                     for(i = [0 : 4], a = start_angle + i * (end_angle - start_angle) / 4) R * [cos(a), sin(a)] ]);
        }
}
