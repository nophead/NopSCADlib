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
//! Parametric cable drag chain to limit the bend radius of a cable run.
//!
//! Each link has a maximum bend angle of 45&deg;, so the mininium radius is proportional to the link length.
//!
//! The travel property is how far it can move in each direction, i.e. half the maximum travel if the chain is mounted in the middle of the travel.
//!
//! The ends can have screw lugs with four screw positions to choose from, specified by a list of two arrays of four bools.
//! If none are enabled then a child object is expected to customise the end and this gets unioned with the blank end.
//! If both ends are customised then two children are expected.
//! Each child is called twice, once with `$fasteners` set to 0 to augment the STL and again with `$fasteners` set to 1 to add
//! to the assembly, for example to add inserts.
//

include <../core.scad>
use <../utils/horiholes.scad>
use <../utils/maths.scad>

clearance = 0.1;

function drag_chain_name(type)        = type[0]; //! The name to allow more than one in a project
function drag_chain_size(type)        = type[1]; //! The internal size and link length
function drag_chain_travel(type)      = type[2]; //! X travel
function drag_chain_wall(type)        = type[3]; //! Side wall thickness
function drag_chain_bwall(type)       = type[4]; //! Bottom wall
function drag_chain_twall(type)       = type[5]; //! Top wall
function drag_chain_screw(type)       = type[6]; //! Mounting screw for the ends
function drag_chain_screw_lists(type) = type[7]; //! Two lists of four bools to say which screws positions are used

function drag_chain_clearance() = clearance; //! Clearance around joints.

function drag_chain_radius(type) = //! The bend radius at the pivot centres
    let(s = drag_chain_size(type))
        s.x / 2 / sin(360 / 16);

function drag_chain_z(type) = //! Outside dimension of a 180 bend
    let(os = drag_chain_outer_size(type), s = drag_chain_size(type))
        2 * drag_chain_radius(type) + os.z;

function drag_chain(name, size, travel, wall = 1.6, bwall = 1.5, twall = 1.5, screw = M2_cap_screw, screw_lists = [[1,0,0,1],[1,0,0,1]]) = //! Constructor
    [name, size, travel, wall, bwall, twall, screw, screw_lists];

function drag_chain_outer_size(type) = //! Link outer dimensions
    let(s = drag_chain_size(type), z = s.z + drag_chain_bwall(type) + drag_chain_twall(type))
        [s.x + z, s.y + 4 * drag_chain_wall(type) + 2 * clearance, z];

function screw_lug_radius(screw) = //! Radius of a screw lug
    corrected_radius(screw_clearance_radius(screw)) + 3.1 * extrusion_width;

module screw_lug(screw, h = 0) //! Create a D shaped lug for a screw
    extrude_if(h, center = false)
        difference() {
            r = screw_lug_radius(screw);
            hull() {
                circle4n(r);

                translate([-r, -r])
                    square([2 * r, eps]);
            }
            poly_circle(screw_clearance_radius(screw));
        }

function bool2int(b) = b ? 1 : 0;

module drag_chain_screw_positions(type, end) { //! Place children at the screw positions, end = 0 for the start, 1 for the end
    r = screw_lug_radius(drag_chain_screw(type));
    s = drag_chain_size(type);
    os = drag_chain_outer_size(type);
    R = os.z / 2;
    x0 = end ? R + norm([drag_chain_cam_x(type), R - drag_chain_twall(type)]) + clearance + r : r;
    x1 = end ? os.x - r : os.x - 2 * R - clearance - r;
    for(i = [0 : 3], x = [x0, x1, x0, x1][i], y = [-1, -1, 1, 1][i])
        if(drag_chain_screw_lists(type)[bool2int(end)][i])
            translate([x, y * (s.y / 2 + r)])
                let($a = [180, 0, 180, 0][i])
                    children();
}

function drag_chain_cam_x(type) = // how far the cam sticks out
    let(s = drag_chain_size(type),
        r =  drag_chain_outer_size(type).z / 2,
        wall =  drag_chain_wall(type),
        cam_r = s.x - 2 * clearance - wall - r,  // inner_x_normal - clearance - r
        twall = drag_chain_twall(type)
    )   min(sqrt(max(sqr(cam_r) - sqr(r - twall), 0)), r);

module drag_chain_link(type, start = false, end = false, check_kids = true) { //! One link of the chain, special case for start and end
    stl(str(drag_chain_name(type), "_drag_chain_link", start ? "_start" : end ? "_end" : ""));

    s = drag_chain_size(type);
    wall = drag_chain_wall(type);
    bwall = drag_chain_bwall(type);
    twall = drag_chain_twall(type);
    os = drag_chain_outer_size(type);
    r = os.z / 2;
    pin_r = r / 2;

    socket_x = r;
    pin_x = socket_x + s.x;

    outer_normal_x =  pin_x - r - clearance;     // s.x - clearance
    outer_end_x = end ? os.x : outer_normal_x;

    inner_x = start ? 0 : outer_normal_x - wall; // s.x - clearance - wall

    roof_x_normal = 2 * r - twall;
    roof_x = start ? 0 : roof_x_normal;

    floor_x = start ? 0 : 2 * r;
    cam_x = drag_chain_cam_x(type);
    assert(r + norm([drag_chain_cam_x(type), r - drag_chain_twall(type)]) + clearance <= inner_x || start, "Link must be longer");

    difference() {
        union() {
            for(side = [-1, 1])
                rotate([90, 0, 0]) {
                    // Outer cheeks
                    translate_z(side * (os.y / 2 - wall / 2))
                        linear_extrude(wall, center = true)
                            difference() {
                                hull() {
                                    if(start)
                                        square([eps, os.z]);
                                    else
                                        translate([socket_x, r])
                                            rotate(180)
                                                teardrop(r = r, h = 0);

                                    translate([outer_end_x - eps, 0])
                                        square([eps, os.z]);
                                }
                                if(!start)
                                    translate([socket_x, r])
                                        horihole(pin_r, r);
                            }
                    // Inner cheeks
                    translate_z(side * (s.y / 2 + wall / 2))
                        linear_extrude(wall, center = true)
                            difference() {
                                union() {
                                    hull() {
                                        if(!end) {
                                            translate([pin_x, r])
                                                rotate(180)
                                                    teardrop(r = r, h = 0);

                                            translate([pin_x, twall])
                                                square([cam_x, eps]);
                                        }
                                        else
                                            translate([os.x - eps, 0])
                                                square([eps, os.z]);

                                        translate([inner_x, 0])
                                            square([eps, os.z]);
                                    }
                                }
                                // Cutout for top wall
                                if(!end)
                                    intersection() {
                                        translate([pin_x - r, 0])
                                            square([3 * r, twall]);  // When straight

                                        translate([pin_x, r])
                                             rotate(-45)
                                                translate([-r + roof_x_normal, -r - twall]) // When bent fully
                                                    square(os.z);
                                    }
                            }
                    // Pin
                    if(!end)
                        translate([pin_x, r, side * (s.y / 2 + wall + clearance)])
                            horicylinder(r = pin_r, z = r, h = 2 * wall);

                    // Cheek joint
                    translate([inner_x, 0, side * (s.y / 2 + wall) - 0.5])
                        cube([outer_end_x - inner_x, os.z, 1]);
                }

            // Roof, actually the floor when printed
            roof_end = end ? s.x + 2 * r : s.x + r - twall - clearance;
            translate([roof_x, -s.y / 2 - 0.5])
                cube([roof_end - roof_x , s.y + 1, twall]);

            translate([roof_x, -os.y / 2 + 0.5])
                cube([s.x - clearance - roof_x, os.y - 1, twall]);

            // Floor, actually the roof when printed
            floor_end = end ? s.x + 2 * r : s.x + r;
            translate([floor_x, -s.y / 2 - wall, os.z - bwall])
                cube([floor_end - floor_x, s.y + 2 * wall, bwall]);

            translate([floor_x, -os.y / 2 + 0.5,  os.z - bwall])
                cube([s.x - floor_x - clearance, os.y -1, bwall]);

            if(start || end) {
                drag_chain_screw_positions(type, end)
                    rotate($a)
                        screw_lug(drag_chain_screw(type), os.z);

                if(check_kids) {
                    custom = drag_chain_screw_lists(type)[bool2int(end)] == [0, 0, 0, 0];
                    assert($children == bool2int(custom), str("wrong number of children for ",  end ? "end" : "start", " STL customisation: ", $children));
                }
                children();
            }
        }
        if(start || end)
            translate_z(-eps)
                drag_chain_screw_positions(type, end)
                    rotate($a)
                        poly_cylinder(r = screw_clearance_radius(drag_chain_screw(type)), h = os.z + 2 * eps, center = false);

    }

    if(show_supports() && !end) {
        for(side = [-1, 1]) {
            w = 2.1 * extrusion_width;
            translate([s.x + r + cam_x - w / 2, side * (s.y / 2 + wall / 2), twall / 2])
                cube([w, wall, twall], center = true);

            h = round_to_layer(r - pin_r / sqrt(2));
            y = s.y / 2  + max(wall + w / 2 + clearance, 2 * wall + clearance - w / 2);
            translate([s.x + r, side * y, h / 2])
                cube([pin_r * sqrt(2), w, h], center = true);

            gap = cam_x - pin_r / sqrt(2) + extrusion_width;
            translate([s.x + r + cam_x - gap / 2, side * (s.y / 2 + wall + clearance / 2), layer_height / 2])
                cube([gap, 2 * wall + clearance, layer_height], center = true);
        }
    }
}

// Need to use a wrapper because can't define nested modules in an assembly
module _drag_chain_assembly(type, pos = 0, render = false) {
    s = drag_chain_size(type);
    x = (1 + exploded()) * s.x;
    r = drag_chain_radius(type) * x / s.x;
    travel = drag_chain_travel(type);
    links = ceil(travel / s.x);
    actual_travel = links * s.x;
    z = drag_chain_outer_size(type).z;

    zb = z / 2;                                     // z of bottom track
    c = [actual_travel / 2 + pos / 2, 0, r + zb];   // centre of bend

    points = [                                      // Calculate list of hinge points
        for(i = 0, p = [0, 0, z / 2 + 2 * r]; i < links + 5;
            i = i + 1,
            dx = p.z > c.z ? x : -x,
            p = max(p.x + dx, p.x) <= c.x ? p + [dx, 0, 0]      // Straight sections
                  : let(q = circle_intersect(p, x, c, r))
                        q.x <= c.x ? [p.x - sqrt(sqr(x) - sqr(p.z - zb)), 0, zb] // Transition back to straight
                                   : q) // Circular section
        p
    ];
    npoints = len(points);

    module link(n)                                  // Position and colour link with origin at the hinge hole
        translate([-z / 2, 0, -z / 2]) {
            stl_colour(n < 0 || n == npoints - 1 ? pp3_colour : n % 2 ? pp1_colour : pp2_colour)
                render_if(render)
                    drag_chain_link(type, start = n == -1, end = n == npoints - 1, check_kids = false)
                        let($fasteners = 0)
                            children();

            let($fasteners = 1) children();
        }

    screws = drag_chain_screw_lists(type);
    custom_start = screws[0] == [0, 0, 0, 0];
    custom_end   = screws[1] == [0, 0, 0, 0];
    assert($children == bool2int(custom_start) + bool2int(custom_end), str("wrong number of children for end customisation: ", $children));

    for(i = [0 : npoints - 2]) let(v = points[i + 1] - points[i])
        translate(points[i])
            rotate([0, -atan2(v.z, v.x), 0])
                link(i);

    translate(points[0] - [x, 0, 0])
        link(-1)
            if(custom_start)
                children(0);

    translate(points[npoints - 1])
        hflip()
            link(npoints - 1)
                if(custom_end)
                    children(custom_start ? 1 : 0);
}

//! 1. Remove the support material from the links with side cutters.
//! 1. Clip the links together with the special ones at the ends.
module drag_chain_assembly(type, pos = 0, render = false)  //! Drag chain assembly
    assembly(str(drag_chain_name(type), "_drag_chain"), big = true, ngb = true)
        if($children == 2)
            _drag_chain_assembly(type, pos, render) {
                children(0);
                children(1);
            }
        else if($children == 1)
            _drag_chain_assembly(type, pos, render)
                children(0);
        else
            _drag_chain_assembly(type, pos, render);
