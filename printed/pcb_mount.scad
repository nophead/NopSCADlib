//
// NopSCADlib Copyright Chris Palmer 2019
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
//! A frame to mount a PCB by its corners when it has no mounting holes.
//! The stl must be given a parameterless wrapper in the project that uses it.
//
include <../core.scad>
use <../vitamins/pcb.scad>

clearance = 0.2;
min_wall = extrusion_width * 2;
wall = 2;

overlap = 2;

screw = M3_cap_screw;
screw_clearance_r = 3.1 / 2;
pillar_r = corrected_radius(screw_clearance_r) + wall;

function pillar_x_pitch(pcb) = pcb_length(pcb) + 2 * clearance + 2 * (pillar_r - overlap) / sqrt(2); //! x pitch of screw pillars
function pillar_y_pitch(pcb) = pcb_width(pcb)  + 2 * clearance + 2 * (pillar_r - overlap) / sqrt(2); //! y pitch of screw pillars

function pcb_mount_length(pcb) = pillar_x_pitch(pcb) + 2 * pillar_r; //! Outside length of the mount
function pcb_mount_width(pcb)  = pillar_y_pitch(pcb) + 2 * pillar_r; //! Outside width of the mount

frame_w = 3;
frame_t = 2;

washer_thickness = 1.25;

module pcb_mount_screw_positions(pcb) //! Positions of the screws and pillars
    for(x = [-1, 1], y = [-1, 1])
        translate([x * pillar_x_pitch(pcb) / 2, y * pillar_y_pitch(pcb) / 2])
            children();

module pcb_mount_holes(pcb, h = 0)          //! Drill holes for PCB mount
    pcb_mount_screw_positions(pcb)
        drill(screw_clearance_radius(screw), h);

module pcb_mount_ring()
    difference() {
        circle(pillar_r);

        poly_circle(screw_clearance_r);
    }

module pcb_mount_washer_stl() //! A plastic washer to clamp a PCB
    linear_extrude(washer_thickness)
        pcb_mount_ring();

module pcb_mount(pcb, height = 5, washers = true) { //! Make the STL of a pcb mount for the specified PCB.
    y_pitch = pcb_width(pcb) > 4 * pillar_r + 4 ? pillar_r + 1
                                                : pcb_width(pcb) / 2 + frame_w + 1 + pillar_r;

    stl(str("pcb_mount_", pcb[0], "_", height)) union() {
        if(washers)
            for(x = [-1, 1], y = [-1, 1])
                translate([x * (pillar_r + 1), y * y_pitch, 0])
                    pcb_mount_washer_stl();

        for(x = [-1, 1])
            translate([x * pillar_x_pitch(pcb) / 2, 0, frame_t / 2])
                cube([frame_w, pillar_y_pitch(pcb) - 2 * wall, frame_t], center = true);

        for(y = [-1, 1])
            translate([0, y * pillar_y_pitch(pcb) / 2, frame_t / 2])
                cube([pillar_x_pitch(pcb) - 2 * wall, frame_w, frame_t], center = true);

        pcb_mount_screw_positions(pcb)
            linear_extrude(height)
                pcb_mount_ring();

        linear_extrude(height + pcb_thickness(pcb) - layer_height)
            difference() {
                pcb_mount_screw_positions(pcb)
                    pcb_mount_ring();

                square([pcb_length(pcb) + 2 * clearance, pcb_width(pcb) + 2 * clearance], center = true);
            }
    }
}

module pcb_mount_assembly(pcb, thickness, height = 5) { //! A PCB mount assembly with fasteners
    translate_z(height)
        pcb(pcb);

    stl_colour(pp1_colour) pcb_mount(pcb, washers = false);

    nut = screw_nut(screw);
    t = pcb_thickness(pcb);
    screw_length = screw_length(screw, height + t + washer_thickness + thickness, 1, nyloc = true);

    pcb_mount_screw_positions(pcb) {
        translate_z(height + t) {
            stl_colour(pp2_colour) pcb_mount_washer_stl();

            translate_z(washer_thickness)
                screw(screw, screw_length);
        }

        translate_z(-thickness)
            vflip()
                nut_and_washer(nut, true);
    }
}
