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
//! Power supplies. Can be a simple cube or can be defined by a list of six faces, each with thickness, holes, cutouts, etc.
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
use <pcb.scad>
use <rocker.scad>
use <terminal.scad>

function psu_face_holes(type)        = type[0];     //! List of screw hole positions
function psu_face_thickness(type)    = type[1];     //! The thickness
function psu_face_cutouts(type)      = type[2];     //! List of polygons to remove
function psu_face_grill(type)        = type[3];     //! Is this face a grill
function psu_face_fan(type)          = type[4];     //! Fan x,y position and type
function psu_face_iec(type)          = type[5];     //! IEC connector x,y, rotation and type
function psu_face_switch(type)       = type[6];     //! Rocker switch x,y, rotation and type
function psu_face_vents(type)        = type[7];     //! Vents array position x,y, rotation, size and corner radius
function psu_face_cutout(type)       = type[8];     //! Panel cutout to accommodate this face, e.g. for ATX

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
function psu_pcb(type)               = type[11];    //! The PCB
function psu_faces(type)             = type[12];    //! List of face descriptions
function psu_accessories(type)       = type[13];    //! Accessories to add to BOM, e.g. mains lead

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

module psu_grill(width, height, grill_hole = 4.5, grill_gap = 1.5, fn = 0, avoid = []) {
    nx = floor(width / (grill_hole + grill_gap)) + 1;
    xpitch = width / nx;
    ny = floor(height / ((grill_hole + grill_gap) * cos(30))) + 1;
    ypitch = height / ny;
    r = grill_hole / 2;
    avoid = avoid ? [for(p = avoid) [[p.x - p[2] / 2 - r, p.y - p[3] / 2 - r], [p.x + p[2] / 2 + r, p.y + p[3] / 2 + r]]] : false;

    function in(regions, x, y) = [for(r = regions) if(x >= r[0].x && x <= r[1].x && y >= r[0].y && y <= r[1].y) true];

    for(y = [0 : ny - 1], x = [0 : nx - 1 - (y % 2)]) {
        x = -width / 2 + (x + 0.5 + (y % 2) / 2) * xpitch;
        y = -height / 2 + (y + 0.5) * ypitch;
        if(!avoid || !in(avoid, x, y))
            translate([x, y])
                rotate(30)
                    circle(r, $fn = fn);
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
    $fa = fa; $fs = fs;

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
                                    translate([h.x, h.y])
                                        hull() {
                                            drill(psu_screw(type) == false ? psu_screw_hole_radius(type) : screw_pilot_hole(psu_screw(type)), 0);
                                            if (is_list(h[2]))
                                                translate([h[2].x, h[2].y])
                                                    drill(psu_screw(type) == false ? psu_screw_hole_radius(type) : screw_pilot_hole(psu_screw(type)), 0);
                                        }

                                g = psu_face_grill(f);
                                if(g) {
                                    list = is_list(g);
                                    hole = list ? g[0] : 4.5;
                                    gap = list ? g[1] : 1.5;
                                    fn = list ? g[2] : 0;
                                    margins = list ? g[3] : [6, 6, 6, 6];
                                    avoid = list ? g[4] : [];
                                    mx1 = margins[0];
                                    mx2 = margins[1];
                                    my1 = i == f_top && psu_face_grill(faces[f_back]) ? 0 : margins[2];
                                    my2 = i == f_back && psu_face_grill(faces[f_top]) ? 0 : margins[3];
                                    translate([(mx1 - mx2) / 2, (my2 - my1) / 2])
                                        psu_grill(xw - mx1 - mx2, yw - my1 - my2, grill_hole = hole, grill_gap = gap, fn = fn, avoid = avoid);
                                }
                                if(fan)
                                    translate([fan.x, fan.y]) intersection() {
                                        fan_holes(fan.z, h = 0);

                                        difference() {
                                            square(big, true);

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
                            translate([iec.x, iec.y, t])
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
    // Special case for lighting type PSUs with terminals at the end
    terminals = psu_terminals(type);
    if(terminals) {
        ft = psu_face_thickness(faces[f_front]);
        bt = psu_face_thickness(faces[f_back]);
        rt = psu_face_thickness(faces[f_right]);
        lt =  psu_face_thickness(faces[f_left]);
        cutout = psu_face_cutouts(faces[f_left])[0];
        z = psu_terminal_block_z(type);
        pcb =  [l - right - rt, w - ft - bt, 1.6];
        heatsink_offset = 13.5;
        color("#FCD67E")
            translate([(-right - rt) / 2, (ft - bt) / 2, z - pcb.z])
                linear_extrude(pcb.z)
                    difference() {
                        square([pcb.x, pcb.y], center = true);

                        translate([-pcb.x / 2, -pcb.y / 2])
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
                    cylinder(d = earth_d, h = z - pcb.z);

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
    // PCB
    pcb = psu_pcb(type);
    if (pcb) {
        translate(pcb[0])
            pcb(pcb[1]);
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
                translate([point.x, point.y])
                    children();
}

module atx_psu_cutout(type, face = f_front) { //! Cut out for the rear of an ATX, which is actually f_front!
    multmatrix(psu_face_transform(type, face))
        linear_extrude(100, center = true)
            round(5)
                polygon(psu_face_cutout(psu_faces(type)[face]));
}
