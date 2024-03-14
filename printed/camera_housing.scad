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

//
//! Housings for PCB cameras.
//
include <../core.scad>
include <../vitamins/cameras.scad>
use <../vitamins/pcb.scad>

wall = 1.75;
min_wall = 2 * extrusion_width;
clearance = 0.2;

connector_size = [23, 6, 2.65]; // Worst case size of flat flex connector

cam_back_clearance = round_to_layer(1.5);    // Clearance for components on the back of the pcb
cam_back_overlap = 1;                        // How much the back overlaps the edge of the pcb
cam_back_wall = min_wall;

function cam_front_clearance(cam) = round_to_layer(camera_connector_size(cam).z + clearance);

function cam_back_size(cam) = let(
    pcb = camera_pcb(cam),
    pcb_size = pcb_size(pcb),
    nut = screw_nut(pcb_screw(pcb)),
    holes = [for(h = pcb_holes(pcb)) pcb_coord(pcb, h).x],
    pitch = max(holes) - min(holes),
    length = pitch + 2 * (nut_radius(nut) + min_wall),
    width = pcb_size.y + (length - pcb_size.x) * cos(30)
    ) [length, width, wall + max(connector_size.z, cam_back_clearance + nut_trap_depth(nut))];


function cam_front_size(cam) = cam_back_size(cam) + [ //! Outside dimensions of the case
    2 * (wall + clearance),
    2 * (wall + clearance),
    pcb_thickness(camera_pcb(cam)) + cam_front_clearance(cam) + wall
];

hinge_screw = M2_cap_screw;
hinge_nut = screw_nut(hinge_screw);
hinge_screw_length = 12;

hinge_r = nut_trap_radius(hinge_nut) + 3 * extrusion_width;
hinge_h = wall + nut_trap_depth(hinge_nut);
hinge_offset = hinge_r + 1;

bracket_screw = M3_dome_screw;

function cam_screw_length(cam) = let(
    front = cam_front_size(cam),
    screw = pcb_screw(camera_pcb(cam)),
    nut = screw_nut(screw)
    ) screw_length(screw, front.z - nut_trap_depth(nut), 1, nyloc = true);

function hinge_z(cam) = cam_screw_length(cam) - hinge_r;

module cam_holes(cam) {
    pcb = camera_pcb(cam);
    lens_y = camera_lens_offset(cam).y;
    two_holes = !!len([for (h = pcb_holes(pcb)) if(abs(pcb_coord(pcb, h).y - lens_y) < 1) true]);
    pcb_screw_positions(pcb)                                                    // screw holes
        if($i > 1 || !two_holes)
            children();
}

module rpi_camera_focus_ring_stl() { //! Focus ring the glue onto RPI lens

    rad = 15 / 2;
    hole_r1 = 2.5 / 2;
    hole_r2 = 5 / 2;
    thickness = 3;
    flutes = 8;
    angle = 180 / flutes;
    x = rad / (sin(angle / 2) + cos(angle / 2));
    r = x * sin(angle / 2);

    stl("rpi_camera_focus_ring")
        difference() {
            linear_extrude(height = thickness, convexity = 5)
                difference() {
                    union() {
                        circle(x);
                        for(i = [0 : flutes - 1])
                            rotate([0, 0, 2 * angle * i])
                                translate([x, 0])
                                    circle(r);
                    }
                    for(i = [0 : flutes - 1])
                        rotate([0, 0, 2 * angle * i + angle])
                            translate([x, 0])
                                circle(r);
                }
            hull() {
                poly_cylinder(r = hole_r1, h = 0.1, center = true);

                translate([0, 0, thickness])
                    poly_cylinder(r = hole_r2, h = 0.1, center = true);
            }
        }
}

module camera_back(cam) { //! Make the STL for a camera case back
    pcb = camera_pcb(cam);
    back = cam_back_size(cam);
    screw = pcb_screw(pcb);
    nut = screw_nut(screw);

    stl(str("camera_back_", cam[0]))
        translate_z(back.z)
            hflip()
                difference() {
                    translate_z(back.z / 2)
                        cube(back, center = true);

                    translate([0, -cam_back_overlap])
                        cube([pcb_length(pcb) - 2 * cam_back_overlap, pcb_width(pcb), 2 * cam_back_clearance], center = true);

                    translate([0, -pcb_width(pcb) / 2])
                        cube([connector_size.x + 2 * clearance, 2 * connector_size.y + 1, 2 * round_to_layer(connector_size.z + clearance)], center = true);

                    translate_z(back.z)
                        cam_holes(cam)
                            hflip()
                                nut_trap(screw, nut, supported = true);
                }
}

module camera_front(cam, hinge = 0) { //! Make the STL for a camera case front
    front = cam_front_size(cam);
    back = cam_back_size(cam);
    pcb = camera_pcb(cam);
    pcb_size = pcb_size(pcb);
    lens_offset = camera_lens_offset(cam);
    screw = pcb_screw(pcb);

    shelf = front.z - back.z;

    connector_slot = connector_size + 2 * [clearance, 0, layer_height];
    rad = wall;
    led_hole_r = 1;
    led_clearance = [5,   2, 1 * 2];
    res_clearance = [3.5, 2, 1 * 2];

    conn_pos = camera_connector_pos(cam);
    conn = camera_connector_size(cam);
    sensor_length = conn_pos.y + conn.y / 2 - lens_offset.y + clearance;

    module hinge_pos()
        if(!is_undef(hinge))
            rotate(hinge * 90)
                translate([0, (hinge ? front.x * hinge : front.y) / 2 + hinge_offset, hinge_r])
                    children();

    stl(str("camera_front_", cam[0]))
        difference() {
            union() {
                hull()
                    for(x = [-1, 1], y = [-1, 1])
                        translate([x * (front.x / 2 - rad), y * (front.y / 2 - rad)])
                            hull() {    // 3D truncated teardrop gives radiused edges without exceeding 45 degree overhang
                                translate_z(front.z - 1)
                                    cylinder(r = rad, h = 1);

                                translate_z(rad)
                                    sphere(rad);

                                cylinder(r = rad * (sqrt(2) - 1), h = eps);
                            }

                hinge_pos()
                    hull() {
                        rotate([-90, 0, -90])
                            teardrop(r = hinge_r, h = hinge_h, center = false);

                        translate([0, -10, -hinge_r])
                            cube([hinge_h, eps, 2 * hinge_r]);
                    }
            }

            hinge_pos()
                rotate([90, 0, 90])
                    teardrop_plus(r = screw_clearance_radius(hinge_screw), h = 100, center = true);

            translate_z(front.z / 2 + shelf - layer_height)                                 // recess for the back
                cube([back.x + 2 * clearance, back.y + 2 * clearance, front.z], center = true);

            translate_z(front.z / 2 + shelf - pcb_size.z)                                   // recess for PCB
                cube([pcb_size.x + 2 * clearance, pcb_size.y + 2 * clearance, front.z], center = true);

            translate_z(shelf)
                hflip() {
                    pcb_component_position(pcb, "smd_led")                                  // clearance for LED
                        cube(led_clearance, center = true);

                    pcb_component_position(pcb, "smd_res")                                  // clearance for resistor
                        cube(res_clearance, center = true);
                }

            translate([conn_pos.x, lens_offset.y + sensor_length / 2, shelf - pcb_size.z])  // clearance for sensor connector
                cube([conn.x + 2 * clearance, sensor_length, 2 * cam_front_clearance(cam)], center = true);

            translate([0, -front.y / 2, shelf + front.z / 2])                               // slot for connector
                cube([connector_slot.x, connector_slot.y, front.z], center = true);

            translate_z(cam_back_clearance + layer_height)
                cam_holes(cam)
                    rotate(90)
                        poly_cylinder(r = screw_clearance_radius(screw), h = 100, center = true);

            translate_z(shelf - pcb_size.z)
                hflip()
                    camera_lens(cam, clearance);

            hflip()
                pcb_component_position(pcb, "smd_led")
                    rotate(45)
                        poly_cylinder(r = led_hole_r, h = 100, center = true);              // hole for led
        }
}

function bracket_thickness(cam) = max(wall, min(3.5, hinge_z(cam) - hinge_r - 1));

module camera_bracket_screw_positions(cam) { //! Position children at the bracket screw positions
    r = washer_radius(screw_washer(bracket_screw)) + 0.5;
    wide = bracket_thickness(cam) == wall;
    pitch = wide ? cam_front_size(cam).x / 2 - r : hinge_h + 1 + r;

    for(side = [-1, 1])
        translate([side * pitch, 0])
            children();
}

module camera_bracket_position(cam) //! Position children at the bracket position
    translate([0,  cam_front_size(cam).y / 2 + hinge_offset])
        children();

module camera_bracket(cam) { //! Make the STL for the camera bracket
    t = bracket_thickness(cam);
    z = hinge_z(cam);

    stl(str("camera_bracket_", cam[0])) union() {
        translate([hinge_h / 2, 0])
            difference() {
                hull() {
                    translate_z(eps / 2)
                        cube([hinge_h, 2 * hinge_r, eps], center = true);

                    translate_z(z)
                        rotate([0, 90, 0])
                            cylinder(r = hinge_r, h = hinge_h, center = true);
                }
                translate([hinge_h / 2, 0, z])
                    rotate([90, 0, 90])
                        nut_trap(hinge_screw, screw_nut(hinge_screw), horizontal = true);
            }

        linear_extrude(t)
            difference() {
                hull()
                    camera_bracket_screw_positions(cam)
                        circle(washer_radius(screw_washer(bracket_screw)) + 0.5);

                camera_bracket_screw_positions(cam)
                    poly_circle(screw_clearance_radius(bracket_screw));
            }
    }
}

module camera_assembly(cam, angle = 0) //! Camera case assembly
assembly(str("camera_", cam[0]), ngb = true) {
    front = cam_front_size(cam);
    screw = pcb_screw(camera_pcb(cam));
    nut = screw_nut(screw);
    screw_length = cam_screw_length(cam);
    hinge_z = hinge_z(cam);
    hinge_pos = [0, front.y / 2  + hinge_offset, -hinge_r];

    camera_bracket_position(cam) {
        nut = screw_nut(hinge_screw);

        stl_colour(pp1_colour) render()
            camera_bracket(cam);

        translate([-hinge_h, 0, hinge_z(cam)])
            rotate([-90, 0, 90]) {
                vflip()
                    translate_z(2 * hinge_h - nut_trap_depth(nut))
                        nut(nut, true);

                screw_and_washer(hinge_screw, screw_longer_than(2 * hinge_h));
            }
    }

    translate_z(hinge_z(cam) + hinge_r)
        translate(hinge_pos)
            rotate([-angle, 0, 0])
                translate(-hinge_pos) {
                    translate_z(cam_back_size(cam).z - front.z)
                        camera(cam);

                    stl_colour(pp1_colour) render()
                        translate_z(-front.z)
                            camera_back(cam);

                    cam_holes(cam) {
                        screw_and_washer(screw, screw_length);

                        translate_z(-front.z + nut_trap_depth(nut))
                            vflip()
                                nut(nut, true);
                    }

                    *translate(camera_lens_offset(cam))
                        translate_z(1.5)
                            stl_colour(pp1_colour) render()
                                rpi_camera_focus_ring_stl();

                    stl_colour(pp2_colour) render()
                        hflip()
                            camera_front(cam, 0);
                }
}

module camera_fastened_assembly(cam, thickness, angle = 0) {
    camera_assembly(cam, angle);

    camera_bracket_position(cam)
        camera_bracket_screw_positions(cam) {
            nut = screw_nut(bracket_screw);
            t = bracket_thickness(cam);
            screw_length = screw_length(bracket_screw, thickness + t, 2, nyloc = true);
            vflip()
                translate_z(thickness)
                    screw_and_washer(bracket_screw, screw_length);

            translate_z(t)
                nut_and_washer(nut, true);
        }
}

module camera_back_rpi_camera_stl()    camera_back(rpi_camera);
module camera_back_rpi_camera_v1_stl() camera_back(rpi_camera_v1);
module camera_back_rpi_camera_v2_stl() camera_back(rpi_camera_v2);

module camera_front_rpi_camera_stl()    camera_front(rpi_camera);
module camera_front_rpi_camera_v1_stl() camera_front(rpi_camera_v1);
module camera_front_rpi_camera_v2_stl() camera_front(rpi_camera_v2);

module camera_bracket_rpi_camera_stl()    camera_bracket(rpi_camera);
module camera_bracket_rpi_camera_v1_stl() camera_bracket(rpi_camera_v1);
module camera_bracket_rpi_camera_v2_stl() camera_bracket(rpi_camera_v2);

module camera_rpi_camera_assembly()    camera_assembly(rpi_camera);
module camera_rpi_camera_v1_assembly() camera_assembly(rpi_camera_v1);
module camera_rpi_camera_v2_assembly() camera_assembly(rpi_camera_v2);

module camera_housing(cam) {
    front = cam_front_size(cam);

    camera_front(cam, 0);

    translate([front.x, 0])
        camera_back(cam);

    translate([-front.x / 2 - 2 - hinge_r, 0])
        rotate(90)
            camera_bracket(cam);
}
