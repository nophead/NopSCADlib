//
// NopSCADlib Copyright Chris Palmer 2023
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
//! Radial components for PCBs.
//
include <../utils/core/core.scad>
use <../utils/sweep.scad>
use <../utils/rounded_polygon.scad>
use <../utils/rounded_cylinder.scad>
use <../utils/round.scad>
use <../utils/pcb_utils.scad>
use <../utils/bezier.scad>

function rd_xtal_size(type)   = type[1]; //! Crystal length, width and height and optional corner radius
function rd_xtal_flange(type) = type[2]; //! Crystal flange width and thickness
function rd_xtal_pitch(type)  = type[3]; //! Crystal lead pitch
function rd_xtal_lead_d(type) = type[4]; //! Crystal lead diameter

module lead_positions(p, z) {
    if(is_list(p))
        for($x = [-1, 1], $y = [-1, 1])
            translate([$x * p.x / 2, $y * p.y / 2, z])
                children();
    else
        for($x = [-1, 1])
            translate([$x * p / 2, 0, z])
                children();
}

module radial_lead(start, end, z, tail, lead) {
    $fn = fn;
    profile = is_list(lead) ? rectangle_points(lead.x , lead.y) : circle_points(lead / 2);
    color(silver)
        if(start == end)
            translate([start.x, start.y, -tail])
                linear_extrude(tail + z)
                    polygon([for(p = profile) [p.x, p.y]]);
        else {
            dz = 2 * [0, 0, is_list(lead) ? norm(lead) : lead];

            top = [start.x, start.y, z];
            bot = [end.x,   end.y,   0];

            path = [top, top - dz, bot + dz, bot];
            rpath = concat(bezier_path(path, 20), [bot - [0, 0, tail]]);
            sweep(rpath, profile);
        }
    translate(end)
        solder((is_list(lead) ? min(lead) : lead) / 2);
}

module radial_leads(ap, p, z, d, tail)
    color(silver) {
        $fn = fn;
        lead_positions(p, 0)
            solder(d / 2);

        if(p != ap) {
            assert(!is_list(p), "Bending four leads not supported yet");
            dz = d;
            dx = p / 2 - ap / 2;
            path = [[0, z, 0], [0, z - dz, 0], [dx, dz, 0], [dx, 0, 0]];
            rpath = concat(bezier_path(path, 20), [[dx, -tail, 0]]);
            lead_positions(ap, 0)
                rotate([90, 0, 90 * -$x + 90])
                    sweep(rpath, circle_points(d / 2));
        }
        else
            lead_positions(p, -tail)
                 rotate(90)
                    cylinder(d = d, h = tail + z);
    }

module rd_xtal(type, value, z = 0, pitch = undef, tail = 3) { //! Draw a crystal
    vitamin(str("rd_xtal(", type[0], ", \"", value, "\"): Crystal ", type[0], " ", value));
    s = rd_xtal_size(type);
    r = len(s) < 4 ? s.y / 2 - eps : s[3];
    f = rd_xtal_flange(type);
    cp = rd_xtal_pitch(type);
    p = is_undef(pitch) ? cp : pitch;
    d = rd_xtal_lead_d(type);
    r2 = 0.2;

    $fs = fs; $fa = fa;
    color(silver) {
        translate_z(z) {
            if(s.y) {
                rounded_rectangle([s.x, s.y, s.z - r2], r);

                translate_z(s.z - r2)
                    rounded_top_rectangle([s.x, s.y, r2], r, r2);
            }
            else
                rounded_cylinder(r = s.x / 2, h = s.z, r2 = r2);

            if(f) {
                rounded_rectangle([s.x + 2 * f.x, s.y + 2 * f.x, f[1]], r + f.x);

                if(is_list(cp))
                    translate([-s.x / 2 - f.x, -s.y / 2 - f.x])
                        cube([r + f.x, r + f.x, f[1]]); // Pin 1 marked by sharp corner on 4 pin packages
            }
        }
        radial_leads(cp, p, z, d, tail);
    }

    color(grey(10)) {
        if(!is_undef(value))
            if(s.y)
                translate_z(z + s.z)
                    linear_extrude(eps)
                        resize([s.x * 0.75, s.y / 2])
                            text(value, halign = "center", valign = "center");
            else
                translate_z(z + s.z / 2)
                    let($fn = 32)
                        cylindrical_wrap(s.x / 2)
                            rotate(-90)
                               resize([s.z * 0.9, s.x * PI / 4])
                                    text(value, halign = "center", valign = "center");
        if(s.y)
            lead_positions(cp, z)
                cylinder(d = d * 4, h = 2 * eps, center = true);
        else
            translate_z(z)
                cylinder(d = (s.x + cp) / 2, h = 2 * eps, center = true);
    }
}

function rd_module_kind(type)      = type[1]; //! Relay, PSU, etc.
function rd_module_size(type)      = type[2]; //! Size
function rd_module_radius(type)    = type[3]; //! Corner radius
function rd_module_colour(type)    = type[4]; //! Colour
function rd_module_pin_size(type)  = type[5]; //! Pin size
function rd_module_pin_posns(type) = type[6]; //! list of pin positions

module rd_module(type, value) { //! Draw a PCB mounted potted module, e.g. PSU or relay
    vitamin(str("rd_module(", type[0], ", \"", value, "\"): ", rd_module_kind(type), " ", type[0], " / ", value));

    $fs = fs; $fa = fa;
    r = rd_module_radius(type);
    size = rd_module_size(type);
    pin = rd_module_pin_size(type);

    color(rd_module_colour(type))
        rounded_top_rectangle(size, r, r);

    color(silver)
        for(pos = rd_module_pin_posns(type))
            translate(pos) {
                translate_z(-pin.z / 2)
                    if(pin.y)
                        cube(pin, center = true);
                    else
                        cylinder(d = pin.x, h = pin.z, center = true);

                solder();
            }

    color("white")
        translate([0, -size.y / 2])
            rotate([90, 0, 0])
                linear_extrude(eps) {
                    translate([0, size.z * 0.9])
                        resize([size.x * 0.5, size.z / 9])
                            text(type[0], halign = "center", valign = "top");

                    translate([-size.x * 0.45, size.z * 0.75])
                         resize([size.x * 0.4, size.z / 12])
                            text(value, halign = "left", valign = "top");

            }
}

function rd_disc_kind(type)    = type[1]; //! Capacitor, etc
function rd_disc_size(type)    = type[2]; //! Diameter, thickness and height
function rd_disc_pitch(type)   = type[3]; //! Lead pitch X & Y
function rd_disc_lead_d(type)  = type[4]; //! Lead diameter and sleeve diameter
function rd_disc_colours(type) = type[5]; //! Colours of body and text

module rd_disc(type, value, pitch = undef, z = 0, tail = 3) { //! Draw a radial disc component
    vitamin(str("rd_disc(", type[0], ", \"", value, "\"): ", rd_disc_kind(type), ", ", type[0], " ", value));

    size = rd_disc_size(type);
    colours = rd_disc_colours(type);
    opitch = rd_disc_pitch(type);
    pitch = is_undef(pitch) ? opitch : pitch;
    lead_d = rd_disc_lead_d(type);

    $fs = fs; $fa = fa;
    lead_positions = [for(side = [-1,1]) [-side * opitch.x / 2, side * opitch.y / 2]];

    r = size / 2;
    v = [[0, r.y], [r.x, r.y], [r.x, r.y * pow((r.y / r.x), 4)], [r.x, 0]];
    bez = bezier_path(v, 20);

    path = concat(bez, [for(p = reverse(bez)) [p.x, - p.y]]);

    rotate(is_list(opitch) ? atan2(opitch.y, opitch.x): 0) {
        color(colours[0]) {
            translate_z(size.z - size.x / 2 + z)
                rotate([90, 0, 0])
                    color(colours[0])
                        rotate_extrude()
                            polygon(path);

            r = lead_d[1] / 2;
            rl = lead_d[0] / 2;
            h = size.z - size.x / 2;
            for(p = lead_positions)
                translate([p.x, p.y, z + r]) {
                    dy = (size.y / 2 - r - 0.1) * sign(-p.x);

                    path = [[0,        0,        0],
                            [0,        0,        h / 2],
                            [-p.x / 2, dy - p.y, h / 2],
                            [-p.x,     dy - p.y, h]];
                    sweep(concat([[0, 0, - r / 2]],bezier_path(path, 20)), circle_points(r));

                    vflip()
                        rounded_cylinder(r = r, h = r, r2 = r - rl, ir = rl);
                }
        }

        diagonal_pitch = norm(opitch);

        pitch = is_undef(pitch)? diagonal_pitch : pitch;

        rotate(is_list(opitch) ? -atan2(opitch.y, opitch.x): 0)
            radial_leads(diagonal_pitch, pitch, z, lead_d[0], tail);

    }
}

function rd_transistor_size(type)       = type[1]; //! Width / diameter, depth / flat and height
function rd_transistor_colours(type)    = type[2]; //! Body colour and text colour
function rd_transistor_lead(type)       = type[3]; //! Lead diameter or width and depth
function rd_transistor_lead_posns(type) = type[4]; //! List of lead xy coordinates

module rd_transistor(type, value, kind = "Transistor", lead_positions = undef, z = 5, tail = 3) { //! Draw a radial lead transistor
    vitamin(str("rd_transistor(", type[0], ", \"", value, "\"): ", kind, " ", type[0], " ", value));

    size = rd_transistor_size(type);
    colours = rd_transistor_colours(type);

    $fs = fs; $fa = fa;
    translate_z(z) {
        if(type[0] == "TO92") {
            color(colours[0])
                linear_extrude(size.z)
                    difference() {
                        circle(d = size.z);

                        translate([0, size.x / 2])
                            square([size.x + 1, 2 * (size.x - size.y)], center = true);
                    }

            color(colours[1])
                translate([0, -size.x / 2 + size.y, size.z / 2])
                    rotate([0, 90, 90])
                        linear_extrude(eps)
                            resize([size.z * 0.8, 0], auto = true)
                                text(value, valign = "center", halign = "center");
        }

        if(type[0] == "E_LINE") {
            color(colours[0])
                linear_extrude(size.z)
                    hull() {
                        for(side = [-1, 1])
                            translate([side * (size.x - size.y) / 2, 0])
                                circle(d = size.y);

                        translate([-size.x / 2, 0])
                            square([size.x, size.y / 2]);
                    }

            color(colours[1])
                translate([0, size.y / 2, size.z / 2])
                    rotate([-90, 180, 0])
                        linear_extrude(eps)
                            resize([size.x * 0.85, 0], auto = true)
                                text(value, valign = "center", halign = "center");
        }
    }

    lead_positions = is_undef(lead_positions) ? [for(i = [-1:1]) [inch(0.1 * i), 0]] : lead_positions;
    lead_starts = rd_transistor_lead_posns(type);
    lead = rd_transistor_lead(type);

    assert(len(lead_positions) == len(lead_starts), "must give a position for each lead");

    for(i = [0 : len(lead_starts) - 1]) {
        start = lead_starts[i];
        end = lead_positions[i];

        radial_lead(start, end, z, tail, lead);
    }
}

function rd_electrolytic_size(type)    = type[1]; //! Diameter, crimp diameter, height
function rd_electrolytic_radius(type)  = type[2]; //! Corner radius
function rd_electrolytic_crimp(type)   = type[3]; //! Width and height of crimp
function rd_electrolytic_lead_d(type)  = type[4]; //! Lead diameter
function rd_electrolytic_pitch(type)   = type[5]; //! Lead pitch
function rd_electrolytic_colours(type) = type[6]; //! Colour of jacket and stripe

module rd_electrolytic(type, value, pitch = undef, z = 0, tail = 3) { //! Draw a radial electrolytic capcacitor
    vitamin(str("rd_electrolytic(", type[0], ", \"", value, "\"): Electolytic capacitor ", type[0], " ", value));

    size = rd_electrolytic_size(type);
    crimp = rd_electrolytic_crimp(type);
    colours = rd_electrolytic_colours(type);
    opitch = rd_electrolytic_pitch(type);
    pitch = is_undef(pitch) ? opitch : pitch;
    lead_d = rd_electrolytic_lead_d(type);
    jacket_t = 0.2;
    jacket_ir = size.x * 5 / 16;
    cross = 0.2 / sqrt(2);

    $fs = fs; $fa = fa;
    radial_leads(opitch, pitch, z + jacket_t, lead_d, tail);

    x = (size.x - size.y) / 2;
    h = crimp[0] / 2;
    r = (h / x - x) / 2;

    stripe_angle = 50;

    module profile()
        difference() {
            round(rd_electrolytic_radius(type))
                difference() {
                    square([size.x / 2, size.z]);

                    translate([size.x / 2 - x + r, crimp.y])
                        circle(r);
                }

            square([jacket_ir, size.z]);
        }

    translate_z(z) {
        color(colours[0])
            rotate(stripe_angle / 2)
                rotate_extrude(angle = 360 - stripe_angle)
                    profile();

        color(colours[1]) {
            rotate(-stripe_angle / 2)
                rotate_extrude(angle = stripe_angle)
                    profile();

                z0 = crimp.y + crimp.x / 2;
                translate_z((size.z + z0) / 2)
                    cylindrical_wrap(size.x / 2)
                        rotate(-90)
                           resize([(size.z - z0) * 0.9, 0], auto = true)
                                text(value, halign = "center", valign = "center");

        }

        color(silver)
            translate_z(size.z - 1)
                render() difference() {
                    cylinder(r = jacket_ir, h = 1 - jacket_t);

                    translate_z(1 - jacket_t)
                        for(a = [0, 90])
                            rotate([45, 0, a])
                                cube([size.x, cross, cross], center = true);

                }

        color(grey(30))
            translate_z(jacket_t)
                cylinder(r = jacket_ir, h = eps);
    }
}

function rd_boxc_size(type)    = type[1]; //! Overall size and corner radius
function rd_boxc_z(type)       = type[2]; //! Height of inner base above PCB.
function rd_boxc_skirt(type)   = type[3]; //! Skirt slot, thickness, height
function rd_boxc_leads(type)   = type[4]; //! Lead pitch, diameter and length
function rd_boxc_colours(type) = type[5]; //! Case colour and resin fill colour

module rd_box_cap(type, kind, value) { //! Draw radial boxed film capacitor
    vitamin(str("rd_boxc(", type[0], ", \"", kind, "\", \"", value, "\" ): ", kind, " ", value));

    size = rd_boxc_size(type);
    r = size[3];
    skirt = rd_boxc_skirt(type);
    inset = skirt.y * 2;
    leads = rd_boxc_leads(type);
    c = rd_boxc_colours(type);
    z = rd_boxc_z(type);
    $fn = fn;

    color(c[0]) {
        translate_z(z)
            rounded_top_rectangle([size.x, size.y, size.z - z], r, r);

        for(i = [0, 1])
            translate_z(i * skirt.z)
                linear_extrude(z)
                    difference() {
                        rounded_square([size.x, size.y], r);

                        square([size.x - inset, size.y - inset], center = true);

                        if(!i)
                            square([skirt.x, size.y], center = true);
                    }
    }

    color(c[1])
        translate_z(z)
            cube([size.x - inset, size.y - inset, 2 * eps], center = true);

    color(silver)
        for(end = [-1, 1])
            translate([end * leads.x / 2, 0]) {
                translate_z(- leads.z)
                    cylinder(d = leads.y, h = leads.z + z);

                solder(leads.y / 2);
            }

    color("black")
        translate([0, -size.y / 2])
            rotate([90, 0, 0])
                linear_extrude(eps)
                    translate([-size.x * 0.45, size.z * 0.75])
                         resize([size.x * 0.9, size.z / 6])
                            text(value, halign = "left", valign = "top");
}

function rd_cm_choke_core(type) = type[1]; //! Core OD, ID, width, corner radius
function rd_cm_choke_seam(type) = type[2]; //! Overlapping semicircular seams to join the two halves of the core width and thickness
function rd_cm_choke_slot(type) = type[3]; //! Slot to hold central separator width, height, thickness
function rd_cm_choke_csep(type) = type[4]; //! Central separator thickness in slot, total thickness, height
function rd_cm_choke_wire(type) = type[5]; //! Wire positions, length and diameter

module rd_cm_choke(type, value) { //! Draw specified common mode choke.
    vitamin(str("rd_cm_choke(", type[0], " ,\"", value, "\"): Common mode choke ", value));
    core = rd_cm_choke_core(type);
    seam = rd_cm_choke_seam(type);
    slot = rd_cm_choke_slot(type);
    csep = rd_cm_choke_csep(type);
    wire = rd_cm_choke_wire(type);
    or = core.x / 2;
    ir = core.y / 2;
    core_w = core.z;
    core_r = core[3];
    z = seam.y + or;
    wire_r = wire[3] / 2;
    w = or - ir;
    $fs = fs; $fa = fa;

    color(grey(90))
        translate_z(z) {
            rotate([90, 0, 0]) {
                rotate_extrude()
                    translate([(ir + or) / 2, 0])
                        rounded_square([w, core_w], core_r, center = true);

                for(h = [true, false])
                    hflip(h)
                        rotate(-90)
                            rotate_extrude(angle = 180)
                                translate([or, 0])
                                    square([seam.y, seam.x]);
            }
            r = sqrt(sqr(or * cos(180 / r2sides(or))) - sqr(slot.z + csep.x / 2));
            for(x = [-1, 1], z = [-1, 1])
                translate([x * (csep.x / 2 + slot.z / 2), 0, z * (r - slot.y / 2)])
                    rotate([0, 90, 0])
                        rounded_rectangle([slot.y, slot.x, slot.z], core_r, center = true);

            rotate([0, 90, 0]) {
                rounded_rectangle([2 * ir, slot.x, csep.x], core_r, center = true);

                rounded_rectangle([csep.z, slot.x, csep.y], core_r, center = true);
            }
        }

     color(silver)
        for(x = [-1, 1], y = [-1, 1])
            translate([x * wire.x / 2, y * wire.y / 2]) {
                solder(wire_r);

                vflip()
                    cylinder(r = wire_r, h = wire.z, $fn = fn);
            }

     color(copper) {
        wire_d = 2 * wire_r;
        r = ir - wire_r;
        cr = core_r + wire_r;
        points = [
            [-core_w / 2 + core_r, 0, 0],
            [ core_w / 2 + wire_r, 0, 0],                       cr,
            [ core_w / 2 + wire_r, w + wire_r, 0],              cr,
            [ 0,                   w + wire_d + seam.y * 2, 0], 7,
            [-core_w / 2 - wire_r, w + wire_r, 0],              cr,
            [-core_w / 2 - wire_r, 0, 0],                       cr - eps,
            [-core_w / 2 + core_r, 0, 0],
        ];
        profile = segmented_path(rounded_path(points, $fn = fn), fs);
        min_gap_angle = 2 * asin((slot.z + csep.x / 2 + wire_r) / r);
        turns = floor((r * PI * (180 - min_gap_angle) / 180) / wire_d);
        turn_angle = wire_d / (r * PI) * 180;
        //turns = floor(((or + wire_r) * PI * (180 - min_gap_angle) / 180) / wire_d / 2);
        //turn_angle = 2 * asin(wire_d / (or + wire_r));
        gap_angle = 180 - turns * turn_angle;
        path = arc_points(r, a =  [90,  180 + gap_angle / 2, 180], al = 180 - gap_angle, $fn = turns * len(profile));
        spiral = spiral_wrap(path, profile, path_length(path) / turns, turns);
        tail = bezier_join([[wire.x / 2, wire.y / 2, -z - eps], [wire.x / 2, wire.y / 2, -z]], spiral, 1.5);
        tilt = turn_angle * (or + wire_r) / 120;

        outer_points = [
            [ core_w / 2 - core_r - wire_d,    -wire_d, 0],
            [-core_w / 2 - wire_r - wire_d,    -wire_d, 0],              cr + wire_d,
            [-core_w / 2 - wire_r,          w + wire_r, tilt / 2],       cr,
            [ 0,                            w + wire_d + seam.y * 2, -tilt / 4], 7, // No idea why -tilt / 2.5 and not zero.
            [ core_w / 2 + wire_r,          w + wire_r, -tilt / 1.5],    cr,
            [ core_w / 2 + wire_r + wire_d,    -wire_d, 0],              cr + wire_d,
            [ core_w / 2 - core_r - wire_d,    -wire_d, 0],
         ];

        outer_profile = segmented_path(rounded_path(outer_points, $fn = fn), fs);
        outer_path = arc_points(r, a =  [90,  180 + gap_angle / 2 + turn_angle / 2, 180], al = 180 - gap_angle, $fn = (turns - 1) * len(outer_profile));
        outer_spiral = concat(spiral_wrap(outer_path, outer_profile, path_length(outer_path) / turns, turns), [spiral[len(spiral) - 1]]);
        outer_tail = bezier_join([[wire.x / 2, -wire.y / 2, -z - eps], [wire.x / 2, -wire.y / 2, -z]], outer_spiral, 3);

        wire_points = circle_points(wire_r, $fn = fn);
        translate_z(z)
            for(side = [-1, 1]) mirror([side < 0 ? 1 : 0, 0]){
                color(copper)sweep(tail, wire_points);

                sweep(outer_tail, wire_points);
            }
     }
}

function rd_coil_size(type)   = type[1]; //! OD, ID, height, coil height
function rd_coil_wire(type)   = type[2]; //! Wire pitch, diameter and length
function rd_coil_colour(type) = type[3]; //! Core colour
function rd_coil_turns(type)  = type[4]; //! Number of turns

module rd_coil(type, value, pitch = undef) { //! Draw the specified vertical coil
    size = rd_coil_size(type);
    wire = rd_coil_wire(type);
    pitch = is_undef(pitch) ? wire.x : pitch;
    wire_d = wire.y;
    wire_r = wire_d / 2;
    vitamin(str("rd_coil(", type[0], " ,\"", value, "\"): Radial inductor ", size.z, "x", size.x, " ", value));
    $fs = fs; $fa = fa;
    end = (size.z - size[3]) / 2;
    function sigmoid(x) = 1 / (1 + exp(-x));
    z = end + size[3] / 2;
    h = size[3] - wire_d;
    turns = rd_coil_turns(type);

    color(rd_coil_colour(type)) {
        cylinder(d = size.y, h = size.z);

        for(z = [0, size.z - end])
            translate_z(z)
                cylinder(d = size.x, h = end);
    }

    color(silver)
        for(side = [-1, 1])
            translate([side * pitch / 2, 0]) {
                vflip()
                    cylinder(d = wire_d, h = wire.z, $fn = fn);

                solder(wire.y / 2);
            }

    color(copper) {
        r = size.y / 2 + wire_r;
        sides = r2sides4n(r);
        leadin = sides / 4;
        total = sides * turns;
        shortcut = 3;
        spiral = [
            for(i = [shortcut: total - shortcut])
                let(a = 360 * i / sides,
                    j = i <= leadin ? leadin - i : i >= total - leadin ? i - (total - leadin) : 0,
                    R = r + j * wire_r / leadin
                )
                [R * cos(a), R * sin(a), (size[3] - wire.y) * i / total + end + wire_r]
        ];
        half_spiral = [
            for(i = [sides / 2 - shortcut : -1 : shortcut * 2])
                let(a = 360 * i / sides, R = r + wire_d)
                    [R * cos(a), R * -sin(a), h * sigmoid((i - sides / 4) / 2) + end + wire_r]

        ];
        path = bezier_join([[-pitch / 2, 0, -eps], [-pitch / 2, 0, 0]], bezier_join(bezier_join(half_spiral, spiral, 1), [[pitch / 2, 0, 0], [pitch / 2, 0, -eps]], 3), 3);
        sweep(path, circle_points(wire_r, $fn = fn));
    }

    color("white")
        translate_z(size.z)
            linear_extrude(eps)
                 resize([size.x * 0.9, 0], auto = true)
                    text(value, halign = "center", valign = "center");

}
