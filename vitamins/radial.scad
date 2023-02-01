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
include <../utils/sweep.scad>
include <../utils/rounded_polygon.scad>
include <../utils/rounded_cylinder.scad>

function rd_xtal_size(type)   = type[1]; //! Crystal length, width and height and optional corner radius
function rd_xtal_flange(type) = type[2]; //! Crystal flange width and thickness
function rd_xtal_pitch(type)  = type[3]; //! Crystal lead pitch
function rd_xtal_lead_d(type) = type[4]; //! Crystal lead diameter

module cylindrical_wrap(r, h = eps) { //! Wrap a 2D child extruded to height `h` around a cylinder with radius `r`.
    sides = r2sides(r);
    dx = 2 * r * tan(180 / sides);
    for(i = [0 : sides - 1])
        rotate((i - 0.5) * 360 / sides)
            translate([0, r])
                 rotate([-90, 0, 0])
                    linear_extrude(h, center = true)
                        intersection() {
                            translate([(sides / 2 - i) * -dx, 0])
                                children();

                            square([dx, inf], center = true);
                        }
}

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

module radial_leads(ap, p, z, d, tail)
    color(silver) {
        assert(p == ap || z > 3 * d, "Must be space to bend the wires");
        zl = tail + (p == ap ? z : 0);
        let($fn = 16) {
            lead_positions(p, -tail)
                 rotate(90)
                    cylinder(d = d, h = zl);


            if(p != ap) {
                assert(!is_list(p), "Bending four leads not supported yet");
                sd = d * sign(p - ap);
                path = [[0, z, 0], [0 + sd, z - d / 2, -sd], [p / 2 - ap / 2 - sd, d / 2, sd], [p / 2 - ap / 2, 0, 0]];
                rpath = let($fn = 32) rounded_polygon(path);
                lead_positions(ap, 0)
                    rotate([90, 0, 90 * -$x + 90])
                        sweep([for(p = rpath) [p.x, p.y, 0]], circle_points(d / 2));
            }
        }
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

    color(silver) {
        translate_z(z) {
            if(s.y) {
                $fn = 32;
                rounded_rectangle([s.x, s.y, s.z - r2], r);

                translate_z(s.z - r2)
                    rounded_top_rectangle([s.x, s.y, r2], r, r2);
            }
            else
                let($fn = 32)
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
