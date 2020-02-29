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
//! Compression springs. Can be tapered, have open, closed or ground ends. Ground ends will render a lot slower.
//!
//! By default springs have their origin at the bottom but can be centered.
//
include <../utils/core/core.scad>

use <../utils/sweep.scad>

function spring_od(type)     = type[1]; //! Outside diameter
function spring_gauge(type)  = type[2]; //! Wire gauge
function spring_length(type) = type[3]; //! Uncompressed length
function spring_turns(type)  = type[4]; //! Number of turns
function spring_closed(type) = type[5]; //! Are the ends closed
function spring_ground(type) = type[6]; //! Are the ends ground flat
function spring_od2(type)    = type[7] ? type[7] : spring_od(type); //! Second diameter for spiral springs
function spring_colour(type) = type[8]; //! The colour
function spring_mesh(type)   = type[9]; //! Optional pre-computed mesh

function comp_spring(type, l = 0) = //! Calculate the mesh for spring
    let(wire_d = spring_gauge(type),
        r1 = (spring_od(type) - wire_d) / 2,
        r2 = (spring_od2(type) - wire_d) / 2,
        h = l ? l : spring_length(type),
        H = spring_ground(type) ? h + wire_d * 0.75 : h - wire_d,
        turns = spring_turns(type),
        closed = spring_closed(type),
        open = turns - 2 * closed,
        open_H = H - 2 * closed * wire_d,
        offset = (h - H) / 2,
        sides = r2sides(r1),
        path = [for(i = [0 : sides * turns],
                    t = i / sides,
                    top = t > turns / 2,
                    u = top ? turns - t : t,
                    v = (u < closed ? u < 0.25 ? 0
                                               : u < 1 ? wire_d * (u - 0.25) / 0.75
                                                       : wire_d * u
                                    : wire_d * closed + open_H / open * (u - closed)
                        ) + offset,
                    z = top ? h - v : v,
                    r = t <= closed ? r2
                                    : t >= turns - closed ? r1
                                                          : r2 + (r1 - r2) * (t - closed) / open,
                    a = t * 360
                   ) [r * sin(a), -r * cos(a), z]],
        profile = circle_points(wire_d / 2 - eps, $fn = 16)
       ) concat(type, [concat(sweep(path, profile), [l])]);

module comp_spring(type, l = 0, center = false) { //! Draw specified spring, l can be set to specify the compressed length.
    length = spring_length(type);
    closed = spring_closed(type);
    od = spring_od(type);
    od2 = spring_od2(type);
    gauge = spring_gauge(type);
    ground = spring_ground(type);
    vitamin(str("comp_spring(", type[0], arg(l, 0),
                "): Spring ", od, od != od2 ? str(" - ", od2, "mm spiral") : "mm", " OD, ", gauge, "mm gauge x ",
                length, "mm long, ",
                closed ? "closed" : "open",
                ground ? " ground" : "", " end" ));

    mesh = len(type) > 9 ? spring_mesh(type) : spring_mesh(comp_spring(type, l));
    assert(l == mesh[2], "can't change the length of a pre-generated spring");
    len = l ? l : length;
    translate_z(center ? - len / 2 : 0) {
        color(spring_colour(type))
            if(ground)
                clip(zmin = 0, zmax = h)
                    polyhedron(mesh[0], mesh[1]);
            else
                polyhedron(mesh[0], mesh[1]);

        if($children)
            translate_z(len)
                children();
    }
}
