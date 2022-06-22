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
//! Knob with embedded hex head screw.
//!
//! Most aspects can be customised, e.g. the flange thickness and radius. It can also be solid or just a wall and be wavey edged or fluted.
//
include <../core.scad>
use <../utils/hanging_hole.scad>

function screw_knob_screw(type)    = type[0]; //! The hex screw
function screw_knob_wall(type)     = type[1]; //! Wall thickness
function screw_knob_stem_h(type)   = type[2]; //! The stem height below the flange
function screw_knob_flange_t(type) = type[3]; //! The thickness of the flange
function screw_knob_flange_r(type) = type[4]; //! The flange outside radius
function screw_knob_solid(type)    = type[5]; //! Is the flange solid or just a wall
function screw_knob_waves(type)    = type[6]; //! Number of waves around the flange edge
function screw_knob_wave_amp(type) = type[7]; //! Wave amplitude
function screw_knob_fluted(type)   = type[8]; //! Fluted instead of sine wave

function screw_knob(screw, wall = 2, stem_h = 6, flange_t = 4, flange_r = 9, solid = true, waves = 5, wave_amp = 2, fluted = false) = //! Constructor
    [screw, wall, stem_h, flange_t, flange_r, solid, waves, wave_amp, fluted];

function knob_nut_trap_depth(screw) = round_to_layer(screw_head_height(screw));
function knob_height(type) = //! Total height of the knob
    let(type = !is_list(type[0]) ? screw_knob(type) : type)
        screw_knob_stem_h(type) + screw_knob_flange_t(type);

module screw_knob(type) { //! Generate the STL for a knob to fit the specified hex screw
    type = !is_list(type[0]) ? screw_knob(type) : type;         // Allow just the screw to be specified for backwards compatibility
    screw = screw_knob_screw(type);
    wall = screw_knob_wall(type);
    trap_r = nut_trap_radius(screw_nut(screw));
    stem_r = trap_r + wall;
    amp = screw_knob_wave_amp(type);
    flange_r = max(screw_knob_flange_r(type), stem_r + amp);
    flange_t = screw_knob_flange_t(type);
    knob_h = knob_height(type);
    waves = screw_knob_waves(type);

    function wave(a) = flange_r - amp / 2 + sin(a * waves) * amp / 2;
    fn = r2sides(flange_r);
    points = [for(i = [0 : fn - 1], a = i * 360 / fn) wave(a) * [sin(a), cos(a)]];
    solid = screw_knob_solid(type);

    module shape()
        if(screw_knob_fluted(type))
            difference() {
                circle4n(flange_r);

                c = flange_r * sin(90 / waves);            // Flute half chord
                d = flange_r - flange_r * cos(90 / waves); // Distance from chord to perimeter
                b = amp - d;                               // Distance from chord to flute bottom
                flute_r = (b^2 + c^2) / b / 2;
                for(i = [0 : waves - 1])
                    rotate(360 * i / waves)
                        translate([0, flange_r - amp + flute_r])
                            circle4n(flute_r);
            }
        else
            polygon(points);

    stl(str("screw_knob_M", screw_radius(screw) * 20))
        union() {
            render() difference() {
                cylinder(r = stem_r, h = knob_h);

                hanging_hole(knob_nut_trap_depth(screw), screw_clearance_radius(screw))
                    rotate(45)
                        circle(r = trap_r, $fn = 6);
            }
            for(i = [0 : 1])
                linear_extrude(i ? flange_t : round_to_layer(wall), convexity = 3)
                    difference() {
                        shape();

                        if(i && ! solid)
                            offset(-wall)
                                shape();

                        circle(stem_r - eps);
                    }
        }
}

//! Place the screw through the printed part
module screw_knob_assembly(type, length) { //! Assembly with the screw in place
    type = !is_list(type[0]) ? screw_knob(type) : type;
    screw = screw_knob_screw(type);
    knob_h = knob_height(type);

    assembly(str("screw_knob_M", 20 * screw_radius(screw), "_", length), ngb = true) {
        translate_z(knob_h)
            vflip()
                stl_colour(pp1_colour) screw_knob(type);

        translate_z(knob_h - knob_nut_trap_depth(screw))
            rotate(-45)
                screw(screw, length);
    }
}

module screw_knob_M30_stl() screw_knob(M3_hex_screw);
module screw_knob_M40_stl() screw_knob(M4_hex_screw);

//! * Press the M3 x 16 hex screw into the knob
module screw_knob_M30_16_assembly() screw_knob_assembly(M3_hex_screw, 16);

//! * Press the M4 x 16 hex screw into the knob
module screw_knob_M40_16_assembly() screw_knob_assembly(M4_hex_screw, 16);
