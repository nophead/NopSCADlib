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
include <../utils/core/core.scad>
use <../utils/layout.scad>

include <../vitamins/batteries.scad>

module batteries()
    layout([for(b = batteries) battery_diameter(b)], 5) let(battery=batteries[$i]) {
        battery = batteries[$i];
        rotate(-135)                            // To show Lumintop USB socket and LEDs
            battery(battery);

        contact = battery_contact(battery);
        translate_z(battery_length(battery) / 2 + contact_pos(contact).x)
            rotate([0, 180, 0])
                battery_contact(contact);

        translate_z(-battery_length(battery) / 2 - contact_neg(contact).x)
            battery_contact(contact, false);
    }

if($preview)
    batteries();
