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
//! Utility for making printed press fit connectors to join printed parts.
//!
//! Add solvent or glue to make a permanent fixture.
//
include <../utils/core/core.scad>

interference = 0.0;

bridge_droop = layer_height; //sqrt(4 * layer_height * filament_width / PI) - layer_height;

module press_fit_socket(w = 5, h = 50, horizontal = false) { //! Make a square hole to accept a peg
    h = horizontal ? h : h + bridge_droop;

    cube([w, w, 2 * h], center = true);
}

module press_fit_peg(h, w = 5, horizontal = false) {    //! Make a rounded chamfered peg for easy insertion
    module chamfered_square(w, horizontal) {
        h = horizontal ? w - bridge_droop : w;
        rounded_square([w, h], 1);
    }

    translate_z(-eps)
        linear_extrude(height = h + eps - layer_height)
            chamfered_square(w + interference, horizontal);

    translate_z(h - layer_height - eps)
        linear_extrude(height = layer_height + eps)
            chamfered_square(w - layer_height, horizontal);
}
