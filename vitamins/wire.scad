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
//! Utilities for adding wires to the BOM and optionally drawing them and cable bundle size functions for holes, plus cable ties.
//
include <../utils/core/core.scad>
use <../utils/sweep.scad>
use <../utils/maths.scad>
include <zipties.scad>

module wire(colour, strands, length, strand = 0.2, d = 0, path = []) {  //! Add stranded wire to the BOM and draw it if diameter and path specified
    vitamin(str(": Wire ", colour, " ", strands, "/", strand, "mm strands, length ", ceil(length + path_length(path)), "mm"));

    if(path && d)
         color(colour) sweep(path, circle_points(r = d / 2));
}

module ribbon_cable(ways, length)                   //! Add ribbon cable to the BOM
    vitamin(str(": Ribbon cable ", ways, " way ", length, "mm"));

//
// Cable sizes
//
function cable_wires(cable)     = cable[0]; //! Number of wires in a bundle
function cable_wire_size(cable) = cable[1]; //! Size of each wire in a bundle
function cable_is_ribbon(cable) = len(cable) > 2 && cable[2]; //! Is a ribbon cable?
function cable_wire_colours(cable) = assert(len(cable[3]) >= cable_wires(cable)) cable[3]; //! Individual wire colours
function cable_tlen(cable)      = cable[4]; //! Twisted cable twist length
function cable(wires, size, colours, ribbon = false, tlen = 25) = [wires, size, ribbon, colours, tlen]; //! Cable constructor

// numbers from http://mathworld.wolfram.com/CirclePacking.html
function cable_radius(cable) = [0, 1, 2, 2.15, 2.41, 2.7, 3, 3, 3.3][cable_wires(cable)] * cable_wire_size(cable) / 2; //! Radius of a bundle of wires, see <http://mathworld.wolfram.com/CirclePacking.html>.

function wire_hole_radius(cable) = ceil(4 * cable_radius(cable) + 1) / 4; //! Radius of a hole to accept a bundle of wires, rounded up to standard metric drill size

function cable_bundle(cable) = //! Dimensions of the bounding rectangle of a bundle of wires in a flat cable clip
    (cable_is_ribbon(cable) ? [cable_wires(cable), 1] :
    [[0,0], [1,1], [2,1], [2, 1 + sin(60)], [2,2], [3, 1 + sin(60)], [3,2]][cable_wires(cable)]) * cable_wire_size(cable);

function cable_bundle_positions(cable) = let( //! Positions of wires in a bundle to go through a cable strip
        wires = cable_wires(cable),
        bottom = cable_is_ribbon(cable) ? wires : wires < 3 ? wires : ceil(wires / 2),
        top = wires - bottom
    )
    [for(i = [0 : 1 : bottom - 1]) [i - (bottom - 1) / 2, 0.5],
     for(i = [top - 1 : -1 : 0])   [i - (top - 1) / 2, top == bottom ? 1.5 : 0.5 + sin(60)]
    ] * cable_wire_size(cable);

function cable_width(cable)  = cable_bundle(cable).x; //! Width in flat clip
function cable_height(cable) = cable_bundle(cable).y; //! Height in flat clip

function cable_twisted_radius(cable) = let( //! Approximate radius of a cable when twisted
        tlen = cable_tlen(cable),               // Twist length
        a = cable_wire_size(cable) / 2,         // Ellipse minor axis
        R = cable_radius(cable) - a,            // Radius of wire centres when not twisted
        angle = atan2(tlen, 2 * PI * R),        // Slope angle of the spiral
        b = a / sin(angle),                     // Ellipse major axis
        grad = tan(180 / cable_wires(cable)),   // Gradient at contact point between elipses
        x = a^2 / sqrt(a^2 + (b / grad)^2),     // Contact point of the ellipse tangent
        y = b * sqrt(1 - x^2 / a^2)
    ) R ? x + y / grad + a : a;                 // Where the tangent meets the X axis plus radius

function twisted_cable(cable, path, irot = 0, frot = 0) = let(      //! Return the paths for a twisted cable, `irot` is the initial rotation and frot the final rotation
        tlen = cable_tlen(cable),               // Twist length
        r = cable_wire_size(cable) / 2,
        pitch = cable_twisted_radius(cable) - r,
        wires = cable_wires(cable),
        bottom = wires > 4 ? 3 : 2,
        irot = irot + 90 - 180 * (bottom - 1) / wires
    )
    spiral_paths(path, wires, pitch, round(path_length(path) / tlen) - frot / 360, irot);

module cable(cable, paths) {                    //! Draw a cable, given a list of paths
    wires = cable_wires(cable);
    assert(len(paths) == wires);
    r = cable_wire_size(cable) / 2;
    for(i = [0 : wires - 1])
        color(cable_wire_colours(cable)[i])
            sweep(paths[i], circle_points(r), convexity = 5);
}

module mouse_hole(cable, h = 100, teardrop = false) { //! A mouse hole to allow a panel to go over a wire bundle.
    r = wire_hole_radius(cable);

    if(teardrop)
        vertical_tearslot(r = r, l = 2 * r, h = h, plus = true);
    else
        rotate(90)
            slot(r, 2 * r, h = h);
}

module cable_tie_holes(cable_r, h = 100) { //! Holes to thread a ziptie through a panel to make a cable tie.
    r = cnc_bit_r;
    l = 3;
    extrude_if(h)
        for(side = [-1, 1])
            translate([0, side * (cable_r + ziptie_thickness(small_ziptie) / 2)])
                hull()
                    for(end = [-1, 1])
                        translate([end * (l / 2 - r), 0])
                            drill(r, 0);
}

module cable_tie(cable_r, thickness) { //! A ziptie threaded around cable radius `cable_r` and through a panel with specified `thickness`.
    translate_z(cable_r)
        rotate([-90, 0, 90])
            ziptie(small_ziptie, cable_r, thickness);
}
