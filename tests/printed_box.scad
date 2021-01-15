//
// NopSCADlib Copyright Chris Palmer 2020
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
use <../printed/foot.scad>
use <../printed/printed_box.scad>

foot = Foot(d = 13, h = 5, t = 2, r = 1, screw = M3_pan_screw);
module foot_stl() foot(foot);

wall = 2;
top_thickness = 2;
base_thickness = 2;
inner_rad = 8;

width = 80;
depth = 45;
height = 40;

box1 = pbox(name = "box1",       wall = wall, top_t = top_thickness, base_t = base_thickness, radius = inner_rad, size = [width, depth, height], screw = M2_cap_screw, ridges = [8, 1]);
box2 = pbox(name = "smooth_box", wall = wall, top_t = top_thickness, base_t = base_thickness, radius = inner_rad, size = [width, depth, height], foot = foot);

module box1_feet_positions() {
    clearance = 2;
    foot_r = foot_diameter(foot) / 2;
    x_inset = inner_rad + foot_r - pbox_ridges(box1).y;
    z_inset = foot_r + clearance;
    h = height + base_thickness;

    for(p = [[-1, -1], [1, -1], [0, 1]])
        translate([p.x * (width / 2 - x_inset), depth / 2 + wall + pbox_ridges(box1).y, top_thickness + h / 2 + p.y * (h / 2 - z_inset)])
            rotate([90, 0, 0])
                children();
}

module box1_internal_additions() {
    d = washer_diameter(screw_washer(foot_screw(foot))) + 1;
    h = pbox_ridges(box1).y;
    box1_feet_positions()
        translate_z(wall - eps)
            cylinder(d2 = d, d1 = d + 2 * h, h = h);

}

module box1_external_additions() {
    amp = pbox_ridges(box1).y + eps;
    d = foot_diameter(foot) + 1;
    box1_feet_positions()
        cylinder(d1 = d, d2 = d + 2 * amp, h = amp);
}

module box1_holes() {
    box1_feet_positions()
        teardrop_plus(r = screw_pilot_hole(foot_screw(foot)), h = 10, center = true);
}


module box1_case_stl() {
     pbox(box1) {
        box1_internal_additions();
        box1_holes();
        box1_external_additions();
     }
}

module box1_base_additions() {
}

module box1_base_holes() {
}

module box1_base_stl()
    pbox_base(box1) {
        box1_base_additions();
        box1_base_holes();
    }

module box1_assembly()
assembly("box1") {
    stl_colour(pp1_colour) render() box1_case_stl();

    pbox_inserts(box1);

    pbox_base_screws(box1);

    box1_feet_positions() {
        foot_assembly(0, foot);

        vflip()
            translate_z(foot_thickness(foot))
                screw_and_washer(foot_screw(foot), 6);
    }

    translate_z(height + top_thickness + base_thickness + 2 * eps) vflip()
         %render() box1_base_stl();
}

module box2_internal_additions() {
}

module box2_holes() {
}

module box2_external_additions() {
}

module box2_case_stl() {
    pbox(box2) {
        box2_internal_additions();
        box2_holes();
        box2_external_additions();
    }
}

module box2_base_additions() {
}

module box2_base_holes() {
}

module box2_base_stl()
    pbox_base(box2) {
        box2_base_additions();
        box2_base_holes();
    }

module box2_assembly()
assembly("box2") {
    stl_colour(pp1_colour) render() box2_case_stl();

    pbox_inserts(box2);

    pbox_base_screws(box2);

    translate_z(height + top_thickness + base_thickness + eps) vflip()
         %render() box2_base_stl();
}


module printed_boxes() {
    rotate(180)
        box1_assembly();

    translate([100, 0])
        box2_assembly();

}

if($preview)
    printed_boxes();
