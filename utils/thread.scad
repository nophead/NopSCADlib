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
//! Utilities for making threads with sweep. They can be used to model screws, nuts, studding, leadscrews, etc, and also to make printed threads.
//!
//! The ends can be tapered, flat or chamfered by setting the `top` and `bot` parameters to -1 for tapered, 0 for a flat cut and positive to
//! specify a chamfer angle.
//!
//! Threads are by default solid, so the male version is wrapped around a cylinder and the female inside a tube. This can be suppressed to just get the helix, for
//! example to make a printed pot with a screw top lid.
//!
//! A left hand thread can be made by using mirror([0,1]).
//!
//! Threads with a typical 60 degree angle appear too bright with OpenSCAD's primitive lighting model as they face towards the lights more than the top and sides of
//! a cylinder. To get around this a colour can be passed to thread that is used to colour the cylinder and then toned down to colour the helix.
//!
//! Making the ends requires a CGAL intersection, which make threads relatively slow. For this reason they are generally disabled when using the GUI but can
//! be enabled by setting `$show_threads` to `true`. When the tests are run, by default, threads are enabled only for things that feature them like screws.
//! This behaviour can be changed by setting a `NOPSCADLIB_SHOW_THREADS` environment variable to `false` to disable all threads and `true` to enable all threads.
//! The same variable also affects the generation of assembly diagrams.
//!
//! Threads obey the $fn, $fa, $fs variables.
//
include <../utils/core/core.scad>
use <sweep.scad>
use <maths.scad>
use <tube.scad>

thread_colour_factor = 0.8; // 60 degree threads appear too bright due to the angle facing the light sources

function thread_profile(h, crest, angle, overlap = 0.1) = //! Create thread profile path
    let(base = crest + 2 * (h + overlap) * tan(angle / 2))
        [[-base / 2, -overlap, 0], [-crest / 2, h, 0], [crest / 2, h, 0], [base / 2, -overlap, 0]];

module thread(dia, pitch, length, profile, center = true, top = -1, bot = -1, starts = 1, solid = true, female = false, colour = undef) { //! Create male or female thread, ends can be tapered, chamfered or square
    //
    // Apply colour if defined
    //
    module colour(factor) if(is_undef(colour)) children(); else color(colour * factor) children();
    //
    // Compress the profile to compensate for it being tilted by the helix angle
    //
    scale = cos(atan(pitch / (PI * dia)));
    sprofile = [for(p = profile) [p.x * scale, p.y, p.z]];
    //
    // Extract some properties from the profile, perhaps they should be stored in it.
    //
    h = max([for(p = sprofile) p.y]);
    xs = [for(p = sprofile) p.x];
    maxx = max(xs);
    minx = min(xs);
    crest_xs = [for(p = sprofile) if(p.y == h) p.x];
    crest_xmax = max(crest_xs);
    crest_xmin = min(crest_xs);
    //
    // If the ends don't taper we need an extra half turn past the ends to be cropped horizontally.
    //
    extra_top = top < 0 ? 0 : -minx / pitch;
    extra_bot = bot < 0 ? 0 :  maxx / pitch;
    turns = length / pitch + extra_top + extra_bot;
    //
    // Generate the helix path, possibly with tapered ends
    //
    dir = female ? 1 : -1;
    r = dia / 2;
    sides = r2sides4n(r);
    step_angle = 360 / sides;
    segs = ceil(turns * sides);
    leadin = min(ceil(sides / starts), floor(turns * sides / 2));
    final = floor(turns * sides) - leadin;
    path = [for(i = [0 : segs],
                R = i < leadin && bot < 0 ? r + dir * (h - h * i / leadin)
                  : i > final  && top < 0 ? r + dir * h * (i - final) / leadin : r,
                a = i * step_angle - 360 * extra_bot)
                    [R * cos(a), R * sin(a), a * pitch / 360]];
    //
    // Generate the skin vertices
    //
    facets = len(profile);
    twist  = helical_twist_per_segment(r, pitch, sides);
    //
    // For female threads we need to invert the profile
    //
    iprofile = female ? reverse([for(p = sprofile) [p.x, -p.y, 0]]) : sprofile;
    //
    // If the bottom is tapered then the twist will be greater, so pre-twist the profile to get the straight bit at the correct angle
    //
    rprofile = bot < 0 ? transform_points(iprofile, rotate(-dir * (helical_twist_per_segment(r - h, pitch, sides) - twist) * sides / PI))
                       : iprofile;
    points = skin_points(rprofile, path, false, twist * segs);
    //
    // To form the ends correctly we need to use intersection but it is very slow with the full thread so we just
    // intersect the start and the end and sweep the rest outside of the intersection.
    //
    top_chamfer_h = (top > 0 ? h * tan(top) : 0);
    bot_chamfer_h = (bot > 0 ? h * tan(bot) : 0);
    top_overlap = max( maxx, top_chamfer_h - crest_xmin) / pitch;
    bot_overlap = max(-minx, bot_chamfer_h + crest_xmax) / pitch;
    start =      ceil(sides * (bot_overlap + extra_bot));
    end = segs - ceil(sides * (top_overlap + extra_top));

    start_skin_faces  = skin_faces(points, start + 1,            facets, false);
    middle_skin_faces = skin_faces(points, end - start + 1,      facets, false, start);
    end_skin_faces    = skin_faces(points, segs - end + 1,       facets, false, end);

    start_faces  = concat([cap(facets)              ], start_skin_faces,  [cap(facets, start)]);
    middle_faces = concat([cap(facets, start, false)], middle_skin_faces, [cap(facets, end)]);
    end_faces    = concat([cap(facets, end,   false)], end_skin_faces,    [cap(facets, segs)]);

    overlap = - profile[0].y;
    translate_z((center ? -length / 2 : 0)) {
        ends_faces = concat(start_faces, end_faces);
        for(i = [0 : starts - 1])
            colour(thread_colour_factor)
                rotate(360 * i / starts + (female ? 180 / starts : 0)) {
                    render() intersection() {
                        polyhedron(points, ends_faces);

                        shorten = !is_undef(colour);
                        len = shorten ? length - 2 * eps : length;
                        offset = shorten ? eps : 0;
                        rotate_extrude()
                            if(female) {
                                difference() {
                                    translate([0, offset])
                                        square([r + h + overlap, len]);

                                    if(top_chamfer_h)
                                        polygon([[0, length], [r, length], [r - h, length - top_chamfer_h], [0, length - top_chamfer_h]]);

                                    if(bot_chamfer_h)
                                        polygon([[0, 0], [r, 0], [r - h, bot_chamfer_h], [0, bot_chamfer_h]]);
                               }
                            }
                            else
                                difference() {
                                    hull() {
                                        translate([0, offset])
                                            square([r, len]);

                                        translate([0, bot_chamfer_h])
                                            square([r + h + overlap, len - top_chamfer_h - bot_chamfer_h]);
                                    }
                                    if(!solid)
                                        square([r - overlap, length]);
                                }
                    }

                    polyhedron(points, middle_faces);
                }

        if(solid)
            colour(1)
                rotate(90)
                    if(female)
                        tube(or = r + (top < 0 || bot < 0 ? h : 0) + 2 * overlap, ir = r, h = length, center = false);
                    else
                        cylinder(d = dia, h = length);
    }
}

module male_metric_thread(d, pitch, length, center = true, top = -1, bot = -1, solid = true, colour = undef) { //! Create male thread with metric profile
    H = pitch * sqrt(3) / 2;
    h = 5 * H / 8;
    minor_d = d - 2 * h;
    thread(minor_d, pitch, length, thread_profile(h, pitch / 8, 60), center, top, bot, solid = solid, colour = colour);
}

module female_metric_thread(d, pitch, length, center = true, top = -1, bot = -1, colour = undef) { //! Create female thread with metric profile
    H = pitch * sqrt(3) / 2;
    h = 5 * H / 8;
    thread(d, pitch, length, thread_profile(h, pitch / 4, 60), center, top, bot, solid = false, female = true, colour = colour);
}

function metric_coarse_pitch(d) //! Convert metric diameter to pitch
    = d == 1.6 ? 0.35  // M1.6
               : [0.4, // M2
                  0.45,// M2.5
                  0.5, // M3
                  0.6, // M3.5
                  0.7, // M4
                  0,
                  0.8, // M5
                  0,
                  1.0, // M6
                  0,
                  0,
                  0,
                  1.25, // M8
                  0,
                  0,
                  0,
                  1.5,  // M10
                  0,
                  0,
                  0,
                  1.75, // M12
                  0,
                  0,
                  0,
                  0,    // M14
                  0,
                  0,
                  0,
                  2.0,  // M16
                 ][d * 2 - 4];
