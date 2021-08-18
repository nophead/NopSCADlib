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
//!Iron core transformers. The grey shaded area is the keep out region where the terminals are.
//
include <../utils/core/core.scad>
use <screw.scad>

function tx_part(type)              = type[1];  //! Part description
function tx_width(type)             = type[2];  //! Bounding width of the core
function tx_depth(type)             = type[3];  //! Bounding depth of the bobbin
function tx_height(type)            = type[4];  //! Bounding height of the transformer
function tx_x_pitch(type)           = type[5];  //! Screw hole x pitch
function tx_y_pitch(type)           = type[6];  //! Screw hole y pitch when four screws
function tx_screw(type)             = type[7];  //! Screw type
function tx_foot_thickness(type)    = type[8];  //! Thickness of the foot
function tx_foot_width(type)        = type[9];  //! Width of the foot
function tx_foot_depth(type)        = type[10]; //! Depth of the foot
function tx_lamination_depth(type)  = type[11]; //! Lamination depth
function tx_lamination_height(type) = type[12]; //! Lamination height
function tx_bobbin_offset(type)     = type[13]; //! Vertical offset of the bobbin from the centre of the laminations
function tx_bobbin_width(type)      = type[14]; //! Bobbin width
function tx_bobbin_height(type)     = type[15]; //! Bobbin height
function tx_bobbin_radius(type)     = type[16]; //! Bobbin corner radius

module transformer(type) { //! Draw specified transformer
    vitamin(str("transformer(", type[0], "): Transformer ", tx_part(type)));

    color("silver") {
        linear_extrude(tx_foot_thickness(type))
            difference() {
                rounded_square([tx_foot_width(type), tx_foot_depth(type)], r = 2);

                transformer_hole_positions(type)
                    circle(screw_clearance_radius(tx_screw(type)));
            }
        translate_z(tx_lamination_height(type) / 2)
            cube([tx_width(type), tx_lamination_depth(type), tx_lamination_height(type)], center = true);

    }

    color("white")
        translate_z(tx_lamination_height(type) / 2 + tx_bobbin_offset(type) / 2)
            rounded_rectangle([tx_bobbin_width(type), tx_depth(type), tx_bobbin_height(type)], tx_bobbin_radius(type), true);

    terminal_height = tx_height(type) - tx_lamination_height(type);

    if(terminal_height)
        %translate_z(tx_lamination_height(type) + terminal_height / 2) union() {
            cube([tx_width(type), tx_lamination_depth(type), terminal_height], center = true);

            cube([tx_bobbin_width(type), tx_depth(type), terminal_height], center = true);
        }
}

module transformer_hole_positions(type) //! Position children at the mounting hole positions
    for(x = [-1, 1], y = tx_y_pitch(type) ? [-1, 1] : 0)
        translate([x * tx_x_pitch(type) / 2, y * tx_y_pitch(type) / 2])
            children();
