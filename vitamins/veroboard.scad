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
//! Veroboard with mounting holes, track breaks, removed tracks, solder points and components.
//
include <../core.scad>
use <pcb.scad>
use <../utils/pcb_utils.scad>

function vero_assembly(type)       = type[1];   //! Name of the assembly
function vero_holes(type)          = type[2];   //! Number of holes in each strip
function vero_strips(type)         = type[3];   //! Number of strips
function vero_pitch(type)          = type[4];   //! Hole pitch
function vero_fr4(type)            = type[5];   //! True if FR4 rather than SRBP
function vero_screw(type)          = type[6];   //! Mounting screw type
function vero_mounting_holes(type) = type[7];   //! Positions of the mounting holes
function vero_breaks(type)         = type[8];   //! Breaks in the tracks
function vero_no_track(type)       = type[9];   //! Missing tracks
function vero_components(type)     = type[10];  //! List of named components and their positions
function vero_joints(type)         = type[11];  //! List of solder joints
function vero_solid_tracks(type)   = type[12];  //! List of solid copper tracks (at the edges of some boards)

function vero_thickness(type)      = 1.6;       //! Thickness of the substrate
function vero_track_thickness(type)= 0.035;     //! Thickness of the tracks
function vero_track_width(type)    = vero_pitch(type) * 0.8; //! The width of the tracks
function vero_length(type) = vero_holes(type) * vero_pitch(type); //! Length of the board
function vero_width(type) = vero_strips(type) * vero_pitch(type); //! Width of the board

function vero(name, assembly, holes, strips, pitch = 2.54, fr4 = false, screw = M3_cap_screw, mounting_holes = [], breaks = [], no_tracks = [], components = [], joints = [], solid = []) = //! Constructor
    [ name, assembly, holes, strips, pitch, fr4, screw, mounting_holes, breaks, no_tracks, components, joints, solid ];

function vero_size(type) = [vero_length(type), vero_width(type), vero_thickness(type)]; //! Board size

function vero_grid_pos(type, x, y) = //! Convert grid position to offset from the centre
    let(holes = vero_holes(type), strips = vero_strips(type))
        [((x + holes) % holes)    - holes / 2 + 0.5,
         ((y + strips) % strips) - strips / 2 + 0.5] * vero_pitch(type);

module vero_grid_pos(type, x, y) //! Convert grid position to offset from the centre
    translate(vero_grid_pos(type, x, y))
        children();

module vero_mounting_hole_positions(type) //! Positions children at the mounting holes
    for(p = vero_mounting_holes(type))
        vero_grid_pos(type, p.x, p.y)
            children();

module vero_mounting_holes(type, h = 100) //! Drill mounting holes in a panel
    vero_mounting_hole_positions(type)
        drill(screw_clearance_radius(vero_screw(type)), h);

module veroboard(type) { //! Draw specified veroboard with missing tracks and track breaks
    holes = vero_holes(type);
    strips = vero_strips(type);
    pitch = vero_pitch(type);
    length = holes * pitch;
    width = strips * pitch;
    hole_d = 1;
    tw = vero_track_width(type);
    colour = vero_fr4(type) ? "#BEB564" : "goldenrod";
    tc = vero_fr4(type) ? "silver" : copper;
    no_track = vero_no_track(type);
    solid = vero_solid_tracks(type);

    vitamin(str("veroboard(", type[0], "): Veroboard ", holes, " holes x ", strips, " strips"));

    $fs = fs; $fa = fa;

    color(colour) linear_extrude(vero_thickness(type))
        difference() {
            rounded_square([length, width], r = 0.5, center = true);

            for(y = [0 : strips - 1])
                if(!in(solid, y))
                    for(x = [0 : holes - 1])
                        vero_grid_pos(type, x, y)
                            circle(d = hole_d);

            vero_mounting_hole_positions(type)
                circle(r = screw_radius(vero_screw(type)));
        }

    color(tc) vflip() linear_extrude(vero_track_thickness(type))
        difference() {
            vflip()
                for(y = [0 : strips -1])
                    translate([0, y * pitch - (strips - 1) * pitch / 2])
                        if(!in(no_track, y))
                            difference() {
                                square([length - (pitch - tw), tw], center = true);

                                if(!in(solid, y))
                                    for(x = [0 : holes - 1])
                                        translate([x * pitch - (holes - 1) * pitch / 2, 0])
                                            circle(d = hole_d);
                            }
            vflip() {
                vero_mounting_hole_positions(type)
                    for(y = [-1 : 1])
                        hull()
                            for(x = [-1, 1])
                                translate([x, y] * pitch)
                                    circle(d = pitch * 1.1);

                for(p = vero_breaks(type))
                    hull() {
                        for(x = p.x)
                            vero_grid_pos(type, x, p.y)
                                if(ceil(x) == x)
                                    circle(d = pitch * 1.1);
                                else
                                    square([pitch * 0.3, pitch], center = true);
                    }
            }
        }
}

module vero_components(type, cutouts = false, angle = undef)
    for(comp = vero_components(type))
        vero_grid_pos(type, comp.x, comp.y)
            if(comp[3][0] == "-")
                vflip()
                    pcb_component(comp, cutouts, angle);
            else
                translate_z(vero_thickness(type))
                    pcb_component(comp, cutouts, angle);

module vero_cutouts(type, angle = undef) //! Make cutouts to clear components
    vero_components(type, true, angle);

module veroboard_assembly(type, ngb = false) //! Draw the assembly with components
pose_vflip(exploded = true)
assembly(vero_assembly(type), ngb = ngb, big = true) {
    veroboard(type);

    let($solder = [vero_track_width(type) / 2, 0, vero_thickness(type) + vero_track_thickness(type)])
        vero_components(type);

    let($solder = [vero_track_width(type) / 2, 0, vero_track_thickness(type)])
        for(r = vero_joints(type))
            for(x = r.x, y = r.y)
                vero_grid_pos(type, x, y)
                    solder();
}

module veroboard_fasteners(type, height, thickness, flip = false) { //! Draw the fasteners in place
    screw = vero_screw(type);
    nut = screw_nut(screw);
    screw_length = screw_length(screw, height + thickness + vero_thickness(type), 2, nyloc = true);

    vero_mounting_hole_positions(type) {
        translate_z(height + vero_thickness(type))
            if(flip)
                nut_and_washer(nut, true);
            else
                screw_and_washer(screw, screw_length);

        stl_colour(pp1_colour) pcb_spacer(screw, height);

        translate_z(-thickness)
            vflip()
                if(flip)
                    screw_and_washer(screw, screw_length);
                else
                    nut_and_washer(nut, true);
    }
}

module veroboard_base(type, height, thickness, wall = 2, tapped = false) { //! Generate STL for a base with PCB spacers
    screw = vero_screw(type);
    ir = tapped ? screw_pilot_hole(screw) : screw_clearance_radius(screw);
    or = corrected_radius(ir) + wall;

    union() {
        linear_extrude(thickness)
            difference() {
                hull()
                    vero_mounting_hole_positions(type)
                        poly_ring(or, ir);

                vero_mounting_hole_positions(type)
                    poly_circle(ir);
            }

        linear_extrude(height)
            vero_mounting_hole_positions(type)
                poly_ring(or, ir);
    }
}

module veroboard_fastened_assembly(type, height, thickness, flip = false, ngb = false) { //! Draw the assembly with components and fasteners in place

    translate_z(height)
        veroboard_assembly(type, ngb = ngb);

    veroboard_fasteners(type, height, thickness, flip);
}
