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
//! Powersupplies. Can be a simple cube or can be defined by a list of six faces, each with thickness, holes, cutouts, etc.
//!
//! Face order is bottom, top, left, right, front, back.
//
include <../core.scad>
include <../printed/fan_guard.scad>
use <../utils/maths.scad>
use <../utils/sector.scad>
use <../utils/round.scad>
use <fan.scad>
use <iec.scad>
use <rocker.scad>

function psu_face_holes(type)        = type[0];     //! List of screw hole positions
function psu_face_thickness(type)    = type[1];     //! The thickness
function psu_face_cutouts(type)      = type[2];     //! List of polygons to remove
function psu_face_grill(type)        = type[3];     //! Is this face a grill
function psu_face_fan(type)          = type[4];     //! Fan x,y position and type
function psu_face_iec(type)          = type[5];     //! IEC connector x,y, rotation and type
function psu_face_switch(type)       = type[6];     //! Rocker switch x,y, rotation and type
function psu_face_vents(type)        = type[7];     //! Vents array position x,y, rotation, size and corner radius

function psu_name(type)              = type[1];     //! The part name
function psu_length(type)            = type[2];     //! Length
function psu_width(type)             = type[3];     //! Width
function psu_height(type)            = type[4];     //! Height
function psu_size(type)              = [psu_length(type), psu_width(type), psu_height(type)]; //! Size
function psu_screw(type)             = type[5];     //! Screw type
function psu_screw_hole_radius(type) = type[6];     //! Clearance hole for screw, bigger than normal on ATX
function atx_psu(type)               = type[7];     //! True if an ATX style PSU
function psu_left_bay(type)          = type[8];     //! Bay for terminals
function psu_right_bay(type)         = type[9];     //! Bay for heatsink
function psu_terminals(type)         = type[10];    //! How many terminals and the y offset from the back
function psu_faces(type)             = type[11];    //! List of face descriptions
function psu_accessories(type)       = type[12];    //! Accessories to add to BOM, e.g. mains lead

function terminal_block_pitch(type)   = type[0];    //! Pitch between screws
function terminal_block_divider(type) = type[1];    //! Width of the dividers
function terminal_block_height(type)  = type[2];    //! Height of the dividers
function terminal_block_depth(type)   = type[3];    //! Total depth
function terminal_block_height2(type) = type[4];    //! Height under the contacts
function terminal_block_depth2(type)  = type[5];    //! Depth of contact well

function terminal_block_length(type, ways) = terminal_block_pitch(type) * ways + terminal_block_divider(type); //! Total length of terminal block

module terminal_block(type, ways) { //! Draw a power supply terminal block
    tl = terminal_block_length(type, ways);
    depth = terminal_block_depth(type);
    depth2 = terminal_block_depth2(type);
    div = terminal_block_divider(type);
    h = terminal_block_height(type);
    h2 = terminal_block_height2(type);
    pitch = terminal_block_pitch(type);
    back_wall = depth - depth2;
    contact_depth = depth2 - back_wall;
    contact_width = pitch - div;
    contact_h = 0.4;
    washer_t = 1.2;
    translate([0, -tl]) {
        color(grey(20)) {
            cube([depth, tl, h2]);

            translate([depth2, 0])
                cube([depth - depth2, tl, h]);

            for(i = [0 : ways])
                translate([0, i * pitch + div])
                    rotate([90, 0, 0])
                        linear_extrude(div)
                            hull() {
                                r = 2;
                                square([depth, eps]);

                                translate([depth - eps, 0])
                                    square([eps, h]);

                                translate([r, h - r])
                                    circle4n(r);
                            }
        }
        color("silver")
            for(i = [0 : ways - 1]) translate([0, i * pitch + div, h2]) {
                translate([back_wall, 1])
                    cube([contact_depth, contact_width - 2, contact_h]);

                translate([back_wall + contact_depth / 2 - contact_width / 2, 0])
                    cube([contact_width, contact_width, contact_h + washer_t]);

                translate([back_wall + contact_depth / 2, contact_width / 2, contact_h + washer_t])
                    not_on_bom() no_explode()
                        screw(M3_pan_screw, 8);
            }
    }
}

function psu_face_transform(type, face) =           //! Returns a transformation matrix to get to the specified face
    let(l = psu_length(type),
        w = psu_width(type),
        h = psu_height(type),
        f = psu_faces(type)[face],
        left = psu_left_bay(type),
        right = psu_right_bay(type),
        rotations = [[180, 0, 0], [0, 0, 0], [90, 0, -90], [90, 0, 90], [90, 0, 0], [-90, 0, 0]],
        translations = [h / 2, h / 2, l / 2 - left, l / 2 - right, w / 2, w / 2]
    ) translate([0, 0, h / 2]) * rotate(rotations[face]) * translate([0, 0, translations[face]]);

grill_hole = 4.5;
grill_gap = 1.5;
module psu_grill(width, height) {
    nx = floor(width / (grill_hole + grill_gap));
    xpitch = width / nx;
    ny = floor(height / ((grill_hole + grill_gap) * cos(30)));
    ypitch = height / ny;

    for(y = [0 : ny - 1], x = [0 : nx - 1 - (y % 2)]) {
        x = -width / 2 + (x + 0.5 + (y % 2) / 2) * xpitch;
        y = -height / 2 + (y + 0.5) * ypitch;
        translate([x, y])
            circle(d = grill_hole);
    }
}

function psu_terminal_block_z(type) = psu_face_cutouts(psu_faces(type)[f_left])[0][2].y + psu_height(type) / 2;

module psu(type) { //! Draw a power supply
    vitamin(str("psu(", type[0], "): PSU ", psu_name(type)));

    for(part = psu_accessories(type))
        vitamin(part);

    l = psu_length(type);
    w = psu_width(type);
    h = psu_height(type);
    faces = psu_faces(type);
    left = psu_left_bay(type);
    right = psu_right_bay(type);
    if(len(faces) < 2)
        translate_z(h / 2)
            color("silver") cube([l, w, h], center = true);
    else {
        for(i = [0 : 1 : len(faces) - 1]) {
            f = faces[i];
            t = psu_face_thickness(f);
            xw = [l, l - left - right, w, w, l, l - left - right][i];
            yw = [w, w, h, h, h, h][i];
            xo = [0, left / 2 - right / 2, 0, 0, 0, left / 2 - right / 2][i];
            fan = psu_face_fan(f);
            iec = psu_face_iec(f);
            switch = psu_face_switch(f);
            vents = psu_face_vents(f);

            multmatrix(psu_face_transform(type, i))
                translate([xo, 0, -t]) {
                    color("silver") linear_extrude(t)
                        union() {
                            difference() {
                                square([xw, yw], center = true);

                                cutouts = psu_face_cutouts(f);
                                if(cutouts)
                                    for(cutout = cutouts)
                                        polygon([for(p = cutout) p]);

                                for(h = psu_face_holes(f))
                                    translate(h)
                                        drill(screw_pilot_hole(psu_screw(type)), 0);

                                if(psu_face_grill(f)) {
                                    mx = 6;
                                    my1 = i == f_top && psu_face_grill(faces[f_back]) ? 0 : 6;
                                    my2 = i == f_back && psu_face_grill(faces[f_top]) ? 0 : 6;
                                    translate([0, (my2 - my1) / 2])
                                        psu_grill(xw - 2 * mx, yw - my1 - my2);
                                }
                                if(fan)
                                    translate([fan.x, fan.y]) intersection() {
                                        fan_holes(fan.z, h = 0);

                                        difference() {
                                            square(inf, true);

                                            fan_guard(fan.z, thickness = 0, grill = true);
                                        }
                                    }
                                if(iec)
                                    translate([iec.x, iec.y])
                                        rotate(iec.z)
                                            iec_holes(iec[3], 0);
                                if(switch)
                                    translate([switch.x, switch.y])
                                        rotate(switch.z)
                                            rocker_hole(switch[3], 0);
                                if(vents)
                                    for(i = [0 : len(vents) - 1]) {
                                        // vent is of form: [ [pos.x, pos.y, angle], [size.x, size.y], corner radius ]
                                        vent = vents[i];
                                        translate([vent[0].x, vent[0].y])
                                            rotate(vent[0].z)
                                                rounded_square(vent[1], vent[2]-eps, center = true);
                                    }
                             }
                        }

                    not_on_bom() no_explode() {
                        if(fan)
                            translate([fan.x, fan.y, -fan_depth(fan.z) / 2]) {
                                fan(fan.z);

                                screw = alternate_screw(hs_cs_cap, fan_screw(fan.z));
                                fan_hole_positions(fan.z)
                                    translate_z(t + eps)
                                        screw(screw, 8);

                            }

                        if(iec)
                            translate([iec.x, iec.y])
                                rotate(iec.z)
                                    iec_assembly(iec[3], t);

                        if(switch)
                            translate([switch.x, switch.y, t])
                                rotate(switch.z)
                                    rocker(switch[3]);
                    }
                }
        }
    }
    // Special case for lighting type PSUs with teminals at the end
    terminals = psu_terminals(type);
    if(terminals) {
        ft = psu_face_thickness(faces[f_front]);
        bt = psu_face_thickness(faces[f_back]);
        rt = psu_face_thickness(faces[f_right]);
        lt =  psu_face_thickness(faces[f_left]);
        cutout = psu_face_cutouts(faces[f_left])[0];
        z = psu_terminal_block_z(type);
        pw = w -ft - bt;
        pl = l - right - rt;
        pcb_thickness = 1.6;
        heatsink_offset = 13.5;
        color("#FCD67E")
            translate([(-right - rt) / 2, (ft - bt) / 2, z - pcb_thickness])
                linear_extrude(pcb_thickness)
                    difference() {
                        square([pl, pw], center = true);

                        translate([-pl / 2, -pw / 2])
                            square(16, center = true);
                    }

        tab_w = w / 2 + cutout[2].x;
        // if the cutout is too wide, then don't draw earth strap, pillar and screw
        if (tab_w - bt > 0) {
            // earth strap
            color("silver")
                translate([-l / 2, w / 2 - tab_w, z])
                    cube([left, tab_w - bt, lt]);

            // Earth pillar and screw
            earth_inset = 4.5;
            earth_d = 5;
            translate([-l / 2 + earth_inset, w / 2 - tab_w / 2]) {
                color("silver")
                    cylinder(d = earth_d, h = z - pcb_thickness);

                translate_z(z + lt)
                    not_on_bom() no_explode()
                        spring_washer(M3_washer)
                            screw(M3_pan_screw, 8);
            }
        }

        // terminal block
        tb = terminals[2];
        if(tb)
           translate([-l / 2, w / 2 - terminals.y, z])
                terminal_block(tb, terminals[0]);

        // Heatsink
        //
        heatsink_cutout = psu_face_cutouts(faces[f_right])[0];
        if(right && heatsink_cutout) {
            z_top = heatsink_cutout[1].y + h / 2;
            length = heatsink_cutout[2].x + w / 2 - 1.5;

            color("silver")
                translate([l / 2, -w / 2])
                    rotate([90, 0, 180])
                        linear_extrude(length) {
                            translate([right + rt, z_top])
                                rotate(135)
                                    square([rt, right * sqrt(2)]);

                            square([rt,  z_top - right]);

                            translate([rt, z_top - right])
                                sector(rt, 135, 180);
                        }
        }
    }
}

module psu_screw_positions(type, face = undef) { //! Position children at the screw positions on the preferred mounting face, which can be overridden.
    faces = psu_faces(type);
    f = is_undef(face) ? faces && psu_face_holes(faces[f_bottom]) ? f_bottom
                                                                  : f_front
                       : face;
    if(len(psu_faces(type)) > f)
        multmatrix(psu_face_transform(type, f))
            for(point = psu_face_holes(psu_faces(type)[f]))
                translate(point)
                    children();
}

module atx_psu_cutout(type) { //! Cut out for the rear of an ATX
    holes = psu_face_holes(psu_faces(type)[f_front]);
    translate([holes[0].x, -psu_width(type) / 2, psu_height(type) / 2 + holes[0].y])
        rotate([90, 0, 0])
            linear_extrude(100, center = true)
                round(5)
                polygon([ // https://www.techpowerup.com/forums/threads/pc-component-dimensions.157239, tweaked
                    [18.7, -13],
                    [ 5.7,   0],
                    [ 5.7,  54],
                    [18.7,  67],
                    [127,   67],
                    [140,   67 - 13 / tan(52)],
                    [140,   -5 + 11 / tan(52)],
                    [129,   -5],
                    [81.3,  -5],
                    [73.3, -13],
                ]);
}
