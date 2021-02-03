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
include <../core.scad>
include <../vitamins/rails.scad>

use <../utils/layout.scad>
use <../vitamins/nut.scad>

sheet = 3;
pos = 1; //[-1 : 0.1 : 1]

module rails()
    layout([for(l = carriages) carriage_width(l)], 20)
        rotate(-90) {
            carriage = carriages[$i];
            rail = carriage_rail(carriage);
            length = 200;
            screw = rail_screw(rail);
            nut = screw_nut(screw);
            washer = screw_washer(screw);

            rail_assembly(carriage, length, pos * carriage_travel(carriage, length) / 2, $i<2 ? grey(20) : "green", $i<2 ? grey(20) : "red");

            rail_screws(rail, length, sheet + nut_thickness(nut, true) + washer_thickness(washer));

            rail_hole_positions(rail, length, 0)
                translate_z(-sheet)
                    vflip()
                        nut_and_washer(nut, true);
         }

if($preview)
    rails();
