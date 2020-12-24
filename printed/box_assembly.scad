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
// The assembly is `include`d so the panel definitions can be overridden to add holes and components.
// The _box_module also needs to be wrapped in the file that uses it so it can be called without
// parameters to make the assembly views. E.g. module box_assembly() _box_assembly(box);
//
module _box_assembly(type, top = true, base = true, left = true, right = true, back = true, front = true, bezels = true, corners = 4)
assembly("box") {
    echo("Box:", box_width(type), box_depth(type), box_height(type));

    t = sheet_thickness(box_sheets(type));

    for(corner = [0 :  corners - 1]) {
        x = [-1,1,1,-1][corner];
        y = [-1,-1,1,1][corner];
        translate([x * (box_width(type) / 2 + 25 * exploded()), y * (box_depth(type) / 2 + 25 * exploded())])
            rotate(corner * 90) {
                stl_colour(pp2_colour) render()
                    box_corner_profile(type);

                translate([box_hole_inset(type), box_hole_inset(type)])
                    for(z = [-1, 1])
                        rotate([z * 90 -90, 0, 0])
                            translate_z(box_height(type) / 2 - box_margin(type))
                                 insert(box_insert(type));
            }
    }

    for(z = [-1, 1]) {
        sheet_thickness = sheet_thickness(z > 0 ? box_top_sheet(type) : box_base_sheet(type));

        translate_z(z * (box_height(type) / 2 - box_corner_gap(type) + 50 * exploded()))
            rotate([z * 90 - 90, 0, 0])
                if(bezels && (z > 0 ? top : base))
                    stl_colour(pp1_colour) render() box_bezel(type, z < 0);

        translate_z(z * (box_height(type) / 2 + sheet_thickness + 50 * exploded()))
            box_screw_hole_positions(type)
                rotate([z * 90 -90, 0, 0])
                    explode(50, true)
                        screw_and_washer(box_screw(type), box_screw_length(type, z > 0), true);
    }
    for(x = [-1, 1])
        translate([x * (box_width(type) / 2 + t / 2 + 25 * exploded()), 0])
            rotate([90, 0, x * 90])
                if(x > 0) {
                    if(right)
                        box_right(type);
                }
                else
                    if(left)
                        box_left(type);

    for(y = [-1, 1])
        translate([0, y * (box_depth(type) / 2 + t / 2 + 25 * exploded())])
            rotate([90, 0, y * 90 + 90])
                if(y < 0) {
                    if(front)
                        box_front(type);
                }
                else
                    if(back)
                        box_back(type);

    for(z = [-1, 1]) {
        sheet_thickness = sheet_thickness(z > 0 ? box_top_sheet(type) : box_base_sheet(type));
        translate_z(z * (box_height(type) / 2 + sheet_thickness / 2 + eps + 100 * exploded()))
            if(z > 0) {
                if(top)
                    box_top(type);
            }
            else
                if(base)
                    box_base(type);
    }
}
