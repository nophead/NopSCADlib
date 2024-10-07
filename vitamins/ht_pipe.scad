//
// NopSCADlib Copyright Jan Giebels 2024
// info@ecosensors.cloud
// ecosensors.cloud
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
//! Parametric PVC HT water pipes commonly found in hardware stores around germany. Great for building weather proof cases for IoT things.
//

include <../utils/core/core.scad>
use <../utils/tube.scad>

function pipe_od(type)     = type[2]; //! Outside diameter
function pipe_wall(type)   = type[3]; //! Wall thickness
function pipe_length(type) = type[4]; //! Pipe length
function pipe_td(type)     = type[5]; //! T-Pipe diameter

module ht_cap(type) { //! Draw specified cap
    vitamin(str("ht_cap(", type[0], "): PVC Waterpipe - ", type[1]));
    tube_id = pipe_od(type) - pipe_wall(type) * 2;

    cylinder(pipe_wall(type), r = tube_id/2 + pipe_wall(type) + 2.6);

    translate_z(-pipe_length(type) - 5)
        tube(or = tube_id/2 + pipe_wall(type), ir = tube_id/2, h = pipe_length(type) + 5, center = false);
}

module ht_pipe(type) { //! Draw specified pipe
    vitamin(str("ht_pipe(", type[0], "): PVC Waterpipe - ", type[1]));
    tube_id = pipe_od(type) - pipe_wall(type) * 2;

    tube(h = pipe_length(type), or = tube_id/2 + pipe_wall(type), ir = tube_id/2, center = false);

    translate_z(pipe_length(type))
        HTpipeFitting(pipe_od(type), tube_id);
}

module ht_tpipe(type) { //! Draw specified T-pipe
    vitamin(str("ht_tpipe(", type[0], "): PVC Waterpipe - ", type[1]));
    tube_id = pipe_od(type) - pipe_wall(type) * 2;
    tube_t_id = pipe_td(type) - pipe_wall(type) * 2;

    translate_z(pipe_length(type))
        HTpipeFitting(pipe_od(type), tube_id);

    render(convexity = 5)
        difference() {
            tube(h = pipe_length(type), or = tube_id/2 + pipe_wall(type), ir = tube_id/2, center = false);

            translate([0, -25, pipe_length(type) - 25]) // Cut the exit hole
                rotate([90, 0, 0])
                    cylinder(h = 50, d = tube_t_id, center = true);
        }

    or = pipe_od(type) / 2;
    translate([0, -or, pipe_length(type) - or])
        rotate ([90, 0, 0]) {
            HTpipeFitting(pipe_td(type), tube_t_id);

            translate_z(-or)
                render(convexity = 5)
                    difference() {  // Notch the T tube to meet the internal bore
                        tube(h = or, or = pipe_td(type) / 2, ir = tube_t_id / 2, center = false);

                        rotate([-90, 0, 0])
                            cylinder(h = pipe_td(type), d = tube_id, center = true);
                    }
        }
}

module HTpipeFitting(tube_od, tube_id) {
    fitting_height = min(55, tube_od * 0.8);

    tube_ir = tube_id / 2;
    fit_ir = tube_od / 2;
    fit_or = fit_ir + (fit_ir - tube_ir);

    rotate_extrude()
        polygon([
                [tube_ir,      0],
                [fit_ir,       10],
                [fit_ir,       fitting_height + 12 + 3.7],
                [fit_or,       fitting_height + 12 + 3.7],
                [fit_or,       fitting_height + 12],
                [fit_ir + 6.5, fitting_height + 12],
                [fit_ir + 6.5, fitting_height],
                [fit_or,       fitting_height],
                [fit_or, 10],
                [fit_ir, 0]
            ]);
}
