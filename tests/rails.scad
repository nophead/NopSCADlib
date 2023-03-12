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

length = 200;
sheet = 3;
pos = 1; //[-1 : 0.1 : 1]

rails = [MGN5, MGN7, MGN9, MGN12, MGN15, SSR15, HGH15CA, HGH20CA];
carriages = [MGN5C_carriage, MGN7C_carriage, MGN7H_carriage, MGN9C_carriage, MGN9H_carriage, 
            MGN12C_carriage, MGN12H_carriage, MGN12H_carriage, MGN15C_carriage, SSR15_carriage,
            HGH15CA_carriage, HGH20CA_carriage
            ];


function rail_carriages(rail) = [for(c = carriages) if(carriage_rail(c) == rail) c];

module rails()
    layout([for(r = rails) carriage_width(rail_carriages(r)[0])], 10)
        rotate(-90) {
            rail = rails[$i];
            carriages = rail_carriages(rail);
            carriage = carriages[0];
            screw = rail_screw(rail);
            nut = screw_nut(screw);
            washer = screw_washer(screw);

            rail_assembly(carriage, length, pos * carriage_travel(carriage, length) / 2, $i<2 ? grey(20) : "green", $i<2 ? grey(20) : "red");

            if(len(carriages) > 1)
                translate([-carriage_travel(carriages[1], length) / 2, 0])
                    carriage(carriages[1]);

            rail_screws(rail, length, sheet + nut_thickness(nut, true) + washer_thickness(washer));

            rail_hole_positions(rail, length, 0)
                translate_z(-sheet)
                    vflip()
                        nut_and_washer(nut, true);
         }

if($preview)
    rails();
