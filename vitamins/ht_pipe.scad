//
// NopSCADlib Copyright Jan Giebels 2024
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

function pipe_od(type)     = type[2]; //! Outside diameter
function pipe_wall(type)     = type[3]; //! Wall thickness
function pipe_length(type)     = type[4]; //! Pipe length
function pipe_td(type)     = type[5]; //! T-Pipe diameter

module ht_cap(type) { //! Draw specified cap
    vitamin(str("ht_cap(", type[0], "): PVC Waterpipe - ", type[1]));
    tube_id = pipe_od(type) - pipe_wall(type) * 2;
    difference() {
        union() {
            cylinder(pipe_wall(type), tube_id/2 + pipe_wall(type) + 2.6, tube_id/2 + pipe_wall(type) + 2.6);
            translate([0, 0, -pipe_length(type) - 5]) 
                cylinder(pipe_length(type) + 5, tube_id/2 + pipe_wall(type), tube_id/2 + pipe_wall(type));
        }
        translate([0, 0, -pipe_length(type) - 5.01]) 
            cylinder(pipe_length(type) + 5.01, tube_id/2, tube_id/2);
    }
}

module ht_pipe(type) { //! Draw specified pipe
    vitamin(str("ht_pipe(", type[0], "): PVC Waterpipe - ", type[1]));
    tube_id = pipe_od(type) - pipe_wall(type) * 2;
    difference() {
        union() {
            translate([0, 0, pipe_length(type) + tube_id - pipe_wall(type)])
                HTpipeFitting(pipe_od(type));
            cylinder(pipe_length(type), tube_id/2 + pipe_wall(type), tube_id/2 + pipe_wall(type));
        }
        cylinder(pipe_length(type)*2, tube_id/2, tube_id/2);
    }
}

module ht_tpipe(type) { //! Draw specified T-pipe
    vitamin(str("ht_tpipe(", type[0], "): PVC Waterpipe - ", type[1]));
    tube_id = pipe_od(type) - pipe_wall(type) * 2;
    tube_t_id = pipe_td(type) - pipe_wall(type) * 2;
    difference() {
        union() {
            translate([0, 0, pipe_length(type) + tube_id - pipe_wall(type)])
                HTpipeFitting(pipe_od(type));
            cylinder(pipe_length(type), tube_id/2 + pipe_wall(type), tube_id/2 + pipe_wall(type));
            translate([0, -70, pipe_length(type) - 25])
                rotate ([90, 0, 0])
                    HTpipeFitting(pipe_td(type));
        }
        cylinder(pipe_length(type)*2, tube_id/2, tube_id/2);
        translate([0, 0, 75])
            rotate([90, 0, 0])
                cylinder(pipe_length(type), tube_t_id/2, tube_t_id/2);
    }
}

module HTpipeFitting(fit_dia) {
    difference() {
        union() {
            cylinder(12, fit_dia/2 + 5, fit_dia/2 + 5);
            translate([0, 0, 12]) 
                cylinder(3.7, fit_dia/2, fit_dia/2);
            translate([0, 0, -fit_dia + 12]) 
                cylinder(fit_dia, fit_dia/2 + 2.6, fit_dia/2 + 2.6);
            translate([0, 0, -fit_dia + 2]) 
                cylinder(10, fit_dia/2, fit_dia/2 + 2.6);

            translate([0, 0, -fit_dia - 15])
                cylinder(fit_dia, fit_dia/2, fit_dia/2);
        }
    }
}
