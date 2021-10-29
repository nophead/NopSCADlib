//
// NopSCADlib Copyright Chris Palmer 2021
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
z = 1; // [0: 5]
thickness = 3; // [0: 5]
shaft_length = 10;

include <../core.scad>
use <../printed/knob.scad>
use <../utils/layout.scad>

include <../vitamins/potentiometers.scad>

knobs = [for(i = [0 : len(potentiometers) - 1]) let(p = potentiometers[i])
     knob_for_pot(p, thickness, z, shaft_length = pot_shaft(p).z > 20 ? shaft_length : undef,
                  top_d   = [10,    12,      20,    16,        16       ][i],
                  bot_d   = [10,    15,      20,    20,        20       ][i],
                  skirt   = [false, [20, 2], false,      [27, 1.5], [27, 1.5]][i],
                  pointer = [false, false,   [14, [1, 5], 2], [13.5, [1, 1], 3], [13.5, [1, 3], 3]][i],
                  screw = let(s = pot_shaft(p)) s.y > s.x / 2 ? M3_grub_screw : false
                 )];


module knobs(show_pot = false)
    layout([for(p = potentiometers) pot_size(p).x], 5) let(p = potentiometers[$i])
        if($preview) {
            translate_z(z)
                knob_assembly(knobs[$i]);

            if(show_pot)
                translate_z(-thickness)
                    vflip() {
                        potentiometer(p, shaft_length = shaft_length);

                        translate_z(-thickness)
                            pot_nut(p);
                    }
        }
        else
            knob(knobs[$i]);


knobs(true);
