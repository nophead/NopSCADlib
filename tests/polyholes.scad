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
use <../vitamins/rod.scad>
include <../vitamins/sheets.scad>

module positions()
    for(i = [1 : 10]) {
        translate([(i * i + i) / 2 + 3 * i , 8])
            let($r = i / 2)
                children();

        let(d = i + 0.5)
            translate([(d * d + d) / 2 + 3 * d, 19])
                let($r = d / 2)
                    children();
    }

module polyhole_stl() {
    stl("polyhole");

    linear_extrude(3, center = true)
        difference() {
            square([100, 27]);

            positions()
                poly_circle(r = $r);
        }
}

module alt_polyhole_stl() {
    holes = [2.5, 2, 1.5];
    n = len(holes);
    size = [n * 10, 10, 10];
    difference() {
        translate([-size.x / n / 2, $preview ? 0 : -size.y / 2])
            cube($preview ? [size.x, size.y / 2, size.z] : size);

        for(i = [0 : n - 1])
            translate([i * 10, 0])
                if(i % 2)
                    translate_z(size.z)
                        poly_cylinder(r = holes[i] / 2, h = 2 * size.z, center = true, twist = i + 1);
                else
                    poly_cylinder(r = holes[i] / 2, h = size.z, center = false, twist = i + 1);
    }
}

module polyholes() {
    stl_colour(pp1_colour)
        polyhole_stl();

    positions()
        rod(d = 2 * $r, l = 8 * $r + 5);
    //
    // Alternating polyholes
    //
    translate([30, -40])
        render_manifold() alt_polyhole_stl();
    //
    // Poly rings
    //
    ir = 3 / 2;
    cir = corrected_radius(ir);
    sizes = [1.5, 2, 3, 4];
    for(i = [0 : len(sizes) - 1])
        translate([i * 10, -10]) {
            stl_colour(pp1_colour)
                poly_tube(ir = ir, or = cir + sizes[i] * extrusion_width, h = 1);

            rod(2 * ir, 3);
       }
    //
    // Drill and slot
    //
    sheet = Steel06;
    translate([10, -30])
        render_2D_sheet(sheet)
            difference() {
                sheet_2D(sheet, 20, 20, 1);

                translate([0, 5])
                    slot(1.5, 6, 0);

                translate([0, -5])
                    drill(2, 0);
            }
}

if($preview)
    polyholes();
else {
    polyhole_stl();

    translate([50, -20])
        alt_polyhole_stl();
}
