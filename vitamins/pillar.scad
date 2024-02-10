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
include <../utils/core/core.scad>
use <../utils/thread.scad>
use <nut.scad>

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
function pillar_chamfered(type)  = type[12];    //! True if pillar is chamfered

module pillar(type) { //! Draw specified pillar
    function sex(thread) = thread > 0 ? "M" : "F";
    function fn(n) = n ? n : $fn;

    sex = str(sex(pillar_bot_thread(type)),"/", sex(pillar_top_thread(type)));
    height = pillar_height(type);
    thread_d = pillar_thread(type);
    bot_thread_l = pillar_bot_thread(type);
    top_thread_l = pillar_top_thread(type);
    thread_colour = pillar_i_colour(type);
    pitch = metric_coarse_pitch(thread_d);

    vitamin(str("pillar(", type[0], "): Pillar ", pillar_name(type), " ", sex, " M", thread_d, "x", height));

    $fa = fa; $fs = fs;

    if(bot_thread_l > 0)
        translate_z(-bot_thread_l + eps)
            if(show_threads)
                male_metric_thread(thread_d, pitch, bot_thread_l, false, top = 0, colour = thread_colour);
            else
                color(thread_colour)
                    cylinder(h = bot_thread_l, d = thread_d);

    if(top_thread_l > 0)
        translate_z(height - eps)
            if(show_threads)
                male_metric_thread(thread_d, pitch, top_thread_l, false, bot = 0, colour = thread_colour);
            else
                color(thread_colour)
                    cylinder(h = top_thread_l, d = thread_d);

    color(thread_colour)  {
        if(pillar_chamfered(type))
            draw_nut(pillar_id(type), thread_d, height, 0, thread_colour, false);
        else
            linear_extrude(height)
                difference() {
                    circle(d = pillar_id(type), $fn = fn(pillar_ifn(type)));
                    circle(d = thread_d);
                }

        top = height + min(top_thread_l, 0);
        bot = -min(bot_thread_l, 0);

        translate_z(bot)
            cylinder(h = top - bot,  d = thread_d + eps);
    }

    if(show_threads) {
        if(top_thread_l < 0)
            translate_z(height)
                vflip()
                    female_metric_thread(thread_d, pitch, -top_thread_l, bot = 1, false, colour = thread_colour);

        if(bot_thread_l < 0)
            female_metric_thread(thread_d, pitch, -bot_thread_l, false, bot = 1, colour = thread_colour);
    }

    if(pillar_od(type) > pillar_id(type))
        color(pillar_o_colour(type)) linear_extrude(height)
            difference() {
                circle(d = pillar_od(type), $fn = fn(pillar_ofn(type)));

                circle(d = pillar_id(type), $fn = fn(pillar_ifn(type)));
            }

}
