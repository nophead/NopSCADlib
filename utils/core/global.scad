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
//! Global constants, functions and modules. This file is used directly or indirectly in every scad file.
//! See [global_defs.scad](../../global_defs.scad) for a list of global constants.
//
include <../../global_defs.scad>

function inch(x) = x * 25.4;                                                        //! Inch to mm conversion (For fractional inches, 'inch(1 + 7/8)' will work as expected.)
function foot(x) = inch(x) * 12;                                                    //! Foot to mm conversion
function yard(x) = foot(x) * 3;                                                     //! Yard to mm conversion
function mm(x)   = x;                                                               //! Explicit mm specified
function cm(x)   = x * 10.0;                                                        //! cm to mm conversion
function m(x)    = cm(x) * 100.0;                                                   //! m to mm conversion

function sqr(x) = x * x;                                                            //! Returns the square of `x`
function echoit(x) = echo(x) x;                                                     //! Echo expression and return it, useful for debugging
function no_point(str) = chr([for(c = str(str)) if(c == ".") ord("p") else ord(c)]);//! Replace decimal point in string with 'p'
function in(list, x) = !!len([for(v = list) if(v == x) true]);                      //! Returns true if `x` is an element in the `list`
function Len(x) = is_list(x) ? len(x) : 0;                                          //! Returns the length of a list or 0 if `x` is not a list
function r2sides(r) = $fn ? $fn : ceil(max(min(360/ $fa, r * 2 * PI / $fs), 5));    //! Replicates the OpenSCAD logic to calculate the number of sides from the radius
function r2sides4n(r) = floor((r2sides(r) + 3) / 4) * 4;                            //! Round up the number of sides to a multiple of 4 to ensure points land on all axes
function limit(x, min, max) = max(min(x, max), min);                                //! Force x in range min <= x <= max

function round_to_layer(z) =  //! Round up to a layer boundary using `layer_height0` for the first layer and `layer_height` for subsequent layers.
    z <= 0 ? 0 :
    z <= layer_height0 ? layer_height0 :
    ceil((z -layer_height0) / layer_height) * layer_height + layer_height0;

function grey(n) = [0.01, 0.01, 0.01] * n;                                          //! Generate a shade of grey to pass to color().

module translate_z(z)                                                               //! Shortcut for Z only translations
    translate([0, 0, z]) children();

module vflip(flip=true)                                                             //! Invert children by doing a 180&deg; flip around the X axis
    rotate([flip ? 180 : 0, 0, 0]) children();

module hflip(flip=true)                                                             //! Invert children by doing a 180&deg; flip around the Y axis
    rotate([0, flip ? 180: 0, 0]) children();

module ellipse(xr, yr)                                                              //! Draw an ellipse
    scale([1, yr / xr]) circle4n(xr);

function slice_str(str, start, end, s ="") = start >= end ? s : slice_str(str, start + 1, end, str(s, str[start])); // Helper for slice()

function slice(list, start = 0, end = undef) = let( //! Slice a list or string with Python type semantics
        len = len(list),
        start = limit(start < 0 ? len + start : start, 0, len),
        end   = is_undef(end) ? len : limit(end   < 0 ? len + end : end, 0, len)
    ) is_string(list) ? slice_str(list, start, end) : [for(i = [start : 1 : end - 1]) list[i]];


module render_if(render = true, convexity = 2)      //! Renders an object if `render` is true, otherwise leaves it unrendered
    if (render)
        render(convexity = convexity)
            children();
    else
        children();

module extrude_if(h, center = true)                 //! Extrudes 2D object to 3D when `h` is nonzero, otherwise leaves it 2D
    if(h)
        linear_extrude(h, center = center, convexity = 5) // 3D
            children();
    else
        children();                                 // 2D

module circle4n(r, d = undef) {                     //! Circle with multiple of 4 vertices
    R = is_undef(d) ? r : d / 2;
    circle(R, $fn = r2sides4n(R));
}

module semi_circle(r, d = undef)                    //! A semi circle in the positive Y domain
    intersection() {
        R = is_undef(d) ? r : d / 2;
        circle4n(R);

        sq = R + 1;
        translate([-sq, 0])
            square([2 * sq, sq]);
    }

module right_triangle(width, height, h, center = true) //! A right angled triangle with the 90&deg; corner at the origin. 3D when `h` is nonzero, otherwise 2D
    extrude_if(h, center = center)
        polygon(points = [[0,0], [width, 0], [0, height]]);

include <sphere.scad>
include <bom.scad>
include <polyholes.scad>
include <teardrops.scad>
include <rounded_rectangle.scad>
include <clip.scad>
