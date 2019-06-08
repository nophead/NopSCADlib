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
//! Threaded pillars. Each end can be male or female.
//
include <../core.scad>

function pillar_name(type)       = type[1];     //! Name of part
function pillar_thread(type)     = type[2];     //! Thread diameter
function pillar_height(type)     = type[3];     //! Body height
function pillar_od(type)         = type[4];     //! Outer diameter of body
function pillar_id(type)         = type[5];     //! Inner diameter of metal part
function pillar_ofn(type)        = type[6];     //! Outer number of sides, 6 for hex, 0 for smooth cylinder
function pillar_ifn(type)        = type[7];     //! Inner number of sides, 6 for hex, 0 for smooth cylinder
function pillar_o_colour(type)   = type[8];     //! Colour of the outer part
function pillar_i_colour(type)   = type[9];     //! Colour of the inner part
function pillar_top_thread(type) = type[10];    //! Top thread length, + for male, - for female
function pillar_bot_thread(type) = type[11];    //! Bottom thread length, + for male, - for female

module pillar(type) { //! Draw specified pillar
    function sex(thread) = thread > 0 ? "M" : "F";
    function fn(n) = n ? n : $fn;

    sex = str(sex(pillar_bot_thread(type)),"/", sex(pillar_top_thread(type)));
    height = pillar_height(type);
    thread_d = pillar_thread(type);

    vitamin(str("pillar(", type[0], "): Pillar ", pillar_name(type), " ", sex, " M", thread_d, "x", height));

    color(pillar_i_colour(type))  {
        if(pillar_bot_thread(type) > 0)
            translate_z(-pillar_bot_thread(type))
                cylinder(h = pillar_bot_thread(type) + eps, d = pillar_thread(type));

        if(pillar_top_thread(type) > 0)
            translate_z(height - eps)
                cylinder(h = pillar_top_thread(type) + eps, d = pillar_thread(type));

        linear_extrude(height = height)
            difference() {
                circle(d = pillar_id(type), $fn = fn(pillar_ifn(type)));
                circle(d = pillar_thread(type));
            }

        top = height + min(pillar_top_thread(type), 0);
        bot = -min(pillar_bot_thread(type), 0);

        translate_z(bot)
            cylinder(h = top - bot,  d = pillar_thread(type) + eps);
    }
    if(pillar_od(type) > pillar_id(type))
        color(pillar_o_colour(type)) linear_extrude(height = height)
            difference() {
                circle(d = pillar_od(type), $fn = fn(pillar_ofn(type)));

                circle(d = pillar_id(type), $fn = fn(pillar_ifn(type)));
            }

}
