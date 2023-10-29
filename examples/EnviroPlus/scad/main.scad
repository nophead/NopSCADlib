//
//! Environmental monitor using Enviro+ sensor board and a Raspberry Pi Zero.
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Top level model
//
$explode = 0; // [0, 1]
assembly = "main"; // [main, back, RPI, case, enviro_case, RPI_case]

/* [Hidden] */

show_box = true;
show_enviroplus = true;
$pp1_colour = "grey";
$extrusion_width = 0.5;

include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/pin_headers.scad>
include <NopSCADlib/vitamins/pcbs.scad>
include <NopSCADlib/vitamins/fans.scad>

use <NopSCADlib/vitamins/insert.scad>
use <NopSCADlib/vitamins/veroboard.scad>
use <NopSCADlib/utils/round.scad>
use <NopSCADlib/utils/pcb_utils.scad>
use <NopSCADlib/printed/foot.scad>
use <NopSCADlib/printed/printed_box.scad>
use <fan_controller.scad>

rpi = RPI0;
pcb = EnviroPlus;
fan = fan17x8;
foot = Foot(d = 13, h = 5, t = 2, r = 1, screw = M3_pan_screw);
module foot_stl() foot(foot);

rpi_offset = [0, -pcb_width(pcb) / 2 + 0.5, pcb_width(rpi) / 2 + 8.6];
rpi_holes = [0, 1];
wall = 2;
top_thickness = 2;
base_thickness = 2;
case_inner_rad = 8;

width = pcb_length(pcb) + 9 + 10;
pcb_x = -(width - pcb_length(pcb) - 9) / 2;
depth = pcb_width(pcb) + 9;
height = pcb_width(rpi) / 2 + rpi_offset.z + 9;
bulkhead_outset = 2;
bulkhead_inset = 0.5;
bulkhead_t = 2;
clearance = 0.1;
pcb_screw = alternate_screw(hs_pan, pcb_screw(pcb));

box = pbox(name = "enviro_plus_case", wall = wall, top_t = top_thickness, base_t = base_thickness, screw = M2_cap_screw, radius = case_inner_rad, ridges = [8, 1],
    size = [width,  depth, height]);

pms5003 = [50, 38, 21];
pms5003_wall = 1;
pms5003_pos = [width / 2 - pms5003.x / 2 - pms5003_wall - pbox_screw_inset(box) - insert_boss_radius(screw_insert(pbox_screw(box)), wall) - 0.5,
               depth / 2 - pms5003.z / 2 - wall - 1,
               height + top_thickness - pms5003.y / 2];


fan_duct_t = 1.7;
foam_t = 0;
fan_pos = [pms5003_pos.x - pms5003.x / 2 - pms5003_wall - fan_width(fan) / 2 - fan_duct_t, 1 + foam_t, 12 + top_thickness + fan_depth(fan) / 2];
fan_socket = 8;

module fan_shape() {
    w = fan_width(fan);
    p = fan_hole_pitch(fan);
    r = w / 2 - p;

    rounded_square([w, w], r);
}

module fan_duct_stl() {
    module frame(z, offset, y = -fan_pos.y)
        translate([0, y, z])
            linear_extrude(height = eps)
                offset(offset)
                    fan_shape();

    z = height + top_thickness - fan_pos.z + fan_depth(fan) / 2 - fan_socket;

    translate([0, -fan_pos.y, z])
        linear_extrude(height = fan_socket)
            difference() {
                fan_shape();

                round(1)
                    offset(-fan_duct_t)
                        fan_shape();
            }

    stl("fan_duct") union() {
        difference() {
            hull() {
                frame(z, 0);

                frame(fan_depth(fan), fan_duct_t + foam_t, 0);
            }
            hull() {
                frame(z, -fan_duct_t);

                frame(fan_depth(fan), foam_t -extrusion_width / 2, 0);
            }
        }

        linear_extrude(height = fan_depth(fan))
            difference() {
                offset(fan_duct_t + foam_t)
                    fan_shape();

                offset(foam_t)
                    fan_shape();
            }
    }
}

module pms5003() {
    vitamin("pms5003(): PMS5003 particle detector");

    w = pms5003.x;
    d = pms5003.y;
    h = pms5003.z;
    t = 0.1;
    color("silver")
        difference() {
            linear_extrude(height = h, center = true)
                difference() {
                    square([w, d], center = true);

                    for(x = [-1, 1], y = [-1, 1])
                        translate([x * w / 2, y * d / 2])
                            square(2, center = true);
                }
            cube([w + 2 * eps, d + 2 * eps, t * 2], center = true);
         }

    color("black")
        rounded_rectangle([w - 2 * t, d - 2 * t, h - 2 * t], r = 1, center = true);
}

module pcb_shape(offset)
    rounded_square([pcb_length(pcb) + 2 * offset, pcb_width(pcb) + 2 * offset], pcb_radius(pcb) + offset);

module gap() {
    gap = pcb_component_position(pcb, "-chip");

    translate([gap.x, -gap.y])
        square([17.5, 20], center = true);
}

module rpi_holes()
    for(i = rpi_holes) {
        hole = pcb_coord(rpi, pcb_holes(rpi)[i]);
        translate([hole.x, rpi_offset.y, -hole.y + rpi_offset.z + top_thickness])
            rotate([90, 0, 0])
                children();
    }

module feet_positions() {
    clearance = 2;
    foot_r = foot_diameter(foot) / 2;
    x_inset = case_inner_rad + foot_r - pbox_ridges(box).y;
    z_inset = foot_r + clearance;
    h = height + base_thickness;

    for(p = [[-1, -1], [1, -1], [0, 1]])
        translate([p.x * (width / 2 - x_inset), depth / 2 + wall + pbox_ridges(box).y, top_thickness + h / 2 + p.y * (h / 2 - z_inset)])
            rotate([90, 0, 0])
                children();
}

module slots(h = 10, expand = 0) {
    for(comp = [["uSD", 2, 11, 0.7], ["flat_flex", 1, 12, 0.5]]) {
        p = pcb_component_position(rpi, comp[0]);
        translate([sign(p.x) * (width / 2 + wall / 2 + pbox_ridges(box).y / 2), rpi_offset.y + pcb_thickness(rpi) + comp[3], top_thickness + rpi_offset.z - p.y])
            rotate([90, 0, 90])
                hull() {
                    vertical_tearslot(r = comp[1] + expand, l = comp[2], h = h);

                    if(expand)
                         vertical_tearslot(r = comp[1] + expand + h / 2, l = comp[2], h = eps);
                }
     }
}

module box_internal_additions() {
    translate([pcb_x, 0]) {
        linear_extrude(height = top_thickness + bulkhead_t)
            difference() {
                pcb_shape(bulkhead_outset + wall + pbox_ridges(box).y + eps);

                gap();

                pcb_shape(bulkhead_outset + clearance);
            }

        rpi_holes()
            hull() {
                wall = 1.8;
                r =  screw_radius(pcb_screw) + wall;
                z = depth / 2 + rpi_offset.y + pbox_ridges(box).y + eps;
                offset = max(r, z);
                cylinder(r =r, h = z);

                translate([0, -offset - r, z])
                    cube(eps);
            }
    }
    d = washer_diameter(screw_washer(foot_screw(foot))) + 1;
    h = pbox_ridges(box).y;
    feet_positions()
        translate_z(wall - eps)
            cylinder(d2 = d, d1 = d + 2 * h, h = h);

    slots(wall + pbox_ridges(box).y + eps, 1);
}

module box_external_additions() {
    amp = pbox_ridges(box).y + eps;
    d = foot_diameter(foot) + 1;
    feet_positions()
        cylinder(d1 = d, d2 = d + 2 * amp, h = amp);

    slots(wall + pbox_ridges(box).y + eps, 1);
}


module box_holes() {
    translate([pcb_x, 0]) {
        linear_extrude(height = top_thickness + eps)
            pcb_shape(clearance);

        rpi_holes()
            teardrop_plus(r = screw_pilot_hole(pcb_screw), h = 7 - 1.6, center = false);
    }
    feet_positions()
        teardrop(r = screw_pilot_hole(foot_screw(foot)), h = 10, center = true);

    grills = 7;
    bar = 1.6;
    x = pcb_x + pcb_length(pcb) / 2 + 2 * wall +  pbox_ridges(box).y + 2 * eps;
    w = width / 2 - x;
    d = depth - case_inner_rad;
    pitch = d / (grills - 1);
    for(i = [0 : grills -1])
        let(w = i == 0 || i == grills -1 ? w - 1 : w)
            translate([x + w / 2, -d / 2 + i * pitch])
                rounded_rectangle([w, pitch - bar, 10], 1);

    slots();
}

module bulkhead_stl() {
    holes = pcb_holes(pcb);
    pitch = max([for(h = holes) pcb_coord(pcb, h).x]) - min([for(h = holes)  pcb_coord(pcb, h).x]);
    boss_r = (pitch - 51.4) / 2;

    stl("bulkhead")
        linear_extrude(height = bulkhead_t)
            difference() {
                pcb_shape(bulkhead_outset);

                gap();

                difference() {
                    pcb_shape(-bulkhead_inset);

                    pcb_screw_positions(pcb)
                        rotate($i * 90)
                            hull() {
                                circle(boss_r);

                                translate([boss_r - eps, -boss_r])
                                    square([eps, boss_r]);

                                translate([-boss_r, boss_r - eps])
                                    square([boss_r, eps]);

                                translate([-boss_r, -boss_r])
                                    square(eps);
                            }
                }

                pcb_screw_positions(pcb)
                    poly_circle(screw_clearance_radius(pcb_screw));
            }
}

module enviro_plus_case_stl() {
     pbox(box) {
        box_internal_additions();
        box_holes();
        box_external_additions();
     }
}

module base_additions() {
    w = pms5003.x + clearance;
    d = pms5003.z + clearance;
    wall = pms5003_wall;

    translate([pms5003_pos.x, -pms5003_pos.y])
        linear_extrude(height = base_thickness + pms5003.y)
            difference() {
                square([w + 2 * wall, d + 2 * wall], center = true);
                square([w, d], center = true);
            }

    translate([fan_pos.x, 0])
        linear_extrude(height = top_thickness + fan_socket)
            difference() {
                offset(wall)
                    fan_shape();

                fan_shape();
            }
}

module base_holes() {
    for(i = [0 : 1]) {
        p = pcb_component_position(rpi, "usb_uA", i);
        translate([p.x + pcb_x, -rpi_offset.y - pcb_thickness(rpi) - 1.3])
            rounded_rectangle([11,7, 100], 0.5, true);
    }

    translate([pms5003_pos.x, -pms5003_pos.y])
        rounded_rectangle([pms5003.x - 2 ,pms5003.z - 2, 100], 2, true);

    translate([fan_pos.x, 0])
        linear_extrude(height = 2 * base_thickness + eps, center = true)
            round(1)
                offset(-fan_duct_t)
                    fan_shape();
}

module enviro_plus_case_base_stl()
    pbox_base(box) {
        base_additions();
        base_holes();
    }

//! * Solder a right angle connector to the Raspberry Pi Zero.
module RPI_assembly()
assembly("RPI") {
    pcb(rpi);

    pcb_grid(rpi, 9.5, 0.5, -0.6)
        rotate(180)
            explode(20)
                pin_header(2p54header, 20, 2, right_angle = true);
}

//! 1. Solvent weld or glue the bulkhead into the recess in the bottom of the case.
//! 1. Fit the heatfit inserts with a soldering iron with a conical bit heated to about 200&deg;C.
//! 1. Tap the three holes for the feet with an M3 tap.
//! 1. Screw on the three feet with M3 x 6mm pan screws and washers.
module case_assembly() pose([ 29.60, 0.00, 158.00 ], exploded = true) pose([ 198.00, 0.00, 352.80 ], exploded = false)
assembly("case") {
    if(show_box)
        stl_colour(pp1_colour) render() enviro_plus_case_stl();
    else
        render() difference() {
            enviro_plus_case_stl();

            translate_z(height / 2)
                cube([100, 100, height - 20], center = true);
        }

    pbox_inserts(box);

    translate([pcb_x, 0, top_thickness])
        explode(20)
            stl_colour(pp2_colour) render() bulkhead_stl();

    feet_positions() {
        foot_assembly(0, foot);

        vflip()
            explode(20, explode_children = true)
                translate_z(foot_thickness(foot))
                    screw_and_washer(foot_screw(foot), 6);
    }

}

//! * Solder the fan_controller to the Enviro+ expansion connector at the 5V, GND and #4 pins.
module enviro_assembly() hflip(exploded())
assembly("enviro") {
    if(show_enviroplus)
        pcb(pcb);

    pcb_grid(pcb, 5.5, 2.5, -pcb_thickness(pcb)) {
        hflip()
            explode(15)
                fan_controller_assembly();
    }
    if(!exploded())
        for(x = [8, 7, 3])
            pcb_grid(pcb, x, 0, 0.05)
                solder_meniscus(0.39, 1);
}

//! * Screw the Enviro+ PCB to the front of the case using M2.5 x 8mm pan screws with washer and nuts on the inside.
module enviro_case_assembly() pose([ 231.40, 0.00, 1.20 ])
assembly("enviro_case") {
    case_assembly();

    translate([pcb_x, 0, top_thickness])
        vflip() explode(20, explode_children = true) {
            t = pcb_thickness(pcb);
            nut = screw_nut(pcb_screw);
            washer = screw_washer(pcb_screw);

            no_explode() enviro_assembly();

            pcb_screw_positions(pcb) {
                translate_z(t)
                    screw(pcb_screw, screw_longer_than(t + bulkhead_t + nut_thickness(nut, true) + washer_thickness(washer)));

                translate_z(-bulkhead_t)
                    vflip()
                        explode(20, explode_children = true)
                            nut_and_washer(nut, true);
            }
        }
}

//! * Plug the RPi into the Enviro+ socket and secure with two screws self tapped into the bosses in the case.
module RPI_case_assembly() pose([ 20.50, 0.00, 153.30 ])
assembly("RPI_case") {
    enviro_case_assembly();

    translate([pcb_x, 0]) {
        translate_z(top_thickness) {

            translate(rpi_offset)
                rotate([-90, 0, 0])
                    RPI_assembly();
        }
        rpi_holes()
            vflip()
                translate_z(pcb_thickness(rpi))
                    screw(pcb_screw, 6.4);
    }
}

//! 1. Print the fan duct in flexible TPE with low infill.
//! 1. Slide the pms5003 into the printed receptacle with the fan to the outside. Secure with tape if it is loose.
//! 1. Slide the fan into the fan duct.
//! 1. Slide the fan duct into the printed recepacle.
module back_assembly() pose([ 228.60, 0.00, 24.30 ])
assembly("back") {
    translate(pms5003_pos)
        explode(-50)
            rotate([90, 0, 0])
                pms5003();

    explode(-20, explode_children = true)
        translate(fan_pos) {
            explode(-20)
                fan(fan);

            translate_z(-fan_depth(fan) / 2)
                stl_colour(pp4_colour)
                    render()
                        fan_duct_stl();
        }

    translate_z(height + top_thickness + base_thickness + eps) vflip()
        stl_colour(show_box ? pp1_colour : pp2_colour) render() enviro_plus_case_base_stl();
}

//! * Solder the fan wires to the veroboard assembly
//!
//! ![FanWires](docs/fan_connection.jpg)
//!
//! * Slide the back assembly into the case and secure with four M2 x 6mm cap screws and washers.
module main_assembly() pose([170, 335, 0], exploded = false) pose([ 42.20, 0.00, 159.60 ], exploded = true)
assembly("main") {
    RPI_case_assembly();

    explode(20, explode_children = true) {
        pbox_base_screws(box);

        back_assembly();
    }
}

if($preview) {
    if(assembly == "main")
        main_assembly();
    else if(assembly == "case")
        case_assembly();
    else if(assembly == "back")
        back_assembly();
    else if(assembly == "RPI")
        RPI_assembly();
    else if(assembly == "RPI_case")
        RPI_case_assembly();
    else if(assembly == "enviro_case")
        enviro_case_assembly();
}
else {
    gap = 5;

    enviro_plus_case_stl();

    translate([0, -depth - gap])
        enviro_plus_case_base_stl();

    translate([0, -2 * (depth + gap)])
        bulkhead_stl();
}
