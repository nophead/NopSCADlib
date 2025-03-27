//
// NopSCADlib Copyright Chris Palmer 2025
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
//! Modules for adding dimensions to assembly views.
//!
//! ![](docs/sliding_t_nut_small.png)
//!
//! * If `text` is empty, will display the measured distance.
//! * `offset` will determine how much space is between the measured point and the dimension.
//! * `thickness` is the thickness of the lines, and size of the arrows, if 0, will use 0.5% of the length of the dim.
//! * `text_size` will determine the size of the text, if 0, will use percentage of the length of the dim.

include <../utils/core/core.scad>
include <../utils/maths.scad>

module dimension(startpoint, endpoint, text = "", thickness = 0, text_size = 0 , rot_around_dim = 0) { //! Creates a 3D dimension between two points.
    // Compute vector between points
    direction = endpoint - startpoint;
    length = norm(direction);
    midpoint = (startpoint + endpoint) / 2;
    thickness = (thickness == 0? length/200:thickness);

    // Ensure nonzero values for calculations
    dir_xy = norm([direction.x, direction.y]);

    // Compute rotation angles
    azimuth = atan2(direction.y, direction.x);
    elevation = -atan2(direction.z, dir_xy);

    //end triangle size
    etr_width = thickness *10;
    etr_height = thickness *4;

    // Draw measurement line as a thin cylinder
    translate(midpoint)
    rotate([0, elevation, azimuth])
    rotate([0, 90, 0])
    resize([thickness, thickness, length - etr_width+0.01 ])
    cube(center = true);

    //do some vector calculations
    dir = (length > 0) ? (direction / length) * thickness * 4 : [1, 0, 0];

    // Draw endpoint markers
    translate(startpoint)
    rotate([0, elevation, azimuth])
    rotate([rot_around_dim,0,0])
    translate([0,0,-thickness/2])
    linear_extrude(thickness)
    polygon([[etr_width, etr_height/2],[0,0],[etr_width, -etr_height/2]],[[0,1,2]]);

    translate(endpoint)
    rotate([0, elevation, azimuth])
    rotate([rot_around_dim,0,0])
    translate([0,0,-thickness/2])
    linear_extrude(thickness)
    polygon([[-etr_width, etr_height/2],[0,0],[-etr_width, -etr_height/2]],[[0,1,2]]);


    // Draw the text/distance
    translate(midpoint)
    rotate([0, elevation, azimuth])
    rotate([rot_around_dim,0,0])
    translate([0,thickness,-thickness/2])
    linear_extrude(thickness)
    text(text == "" ? str(length) : text, size = (text_size == 0? length/15:text_size), valign = "bottom", halign = "center");
}


module dimension_x(startpoint, endpoint, offset = 1, text = "", thickness = 0, text_size = 0 , plane = "xy") { //! Creates a dimension in the x direction. Plane options : xy, xz
    length = norm(endpoint - startpoint);
    thickness = (thickness == 0? length/200:thickness);

    y = offset > 0 ? max(startpoint.y, endpoint.y) + (plane=="xy"?offset:0) : min(startpoint.y, endpoint.y) + (plane=="xy"?offset:0);
    z = offset > 0 ? max(startpoint.z, endpoint.z) + (plane=="xz"?offset:0) : min(startpoint.z, endpoint.z) + (plane=="xz"?offset:0);

    dimension([startpoint.x, y, z], [endpoint.x, y, z], text, thickness, text_size, rot_around_dim=(plane=="xz"?90:0));

    v1= [startpoint.x, y, z]-startpoint;
    h1 = norm(v1);
    axis1 = cross([0,0,1], v1);
    angle1 = atan2(norm(axis1), v1.z);
    translate(startpoint)
    rotate(angle1, axis1)
        cylinder( h= h1+thickness*2, d=thickness);


    v2= [endpoint.x, y, z]-endpoint;
    h2 = norm(v2);
    axis2 = cross([0,0,1], v2);
    angle2 = atan2(norm(axis2), v2.z);

    translate(endpoint)
    rotate(angle2, axis2)
        cylinder( h= h2+thickness*2, d=thickness);
}


module dimension_y(startpoint, endpoint, offset = 1, text = "", thickness = 0, text_size = 0 , plane = "xy") { //! Creates a dimension in the y direction. Plane options : xy, yz
    length = norm(endpoint - startpoint);
    thickness = (thickness == 0? length/200:thickness);


    x = offset > 0 ? max(startpoint.x, endpoint.x) + (plane=="xy"?offset:0) : min(startpoint.x, endpoint.x) + (plane=="xy"?offset:0);
    z = offset > 0 ? max(startpoint.z, endpoint.z) + (plane=="yz"?offset:0) : min(startpoint.z, endpoint.z) + (plane=="yz"?offset:0);
    dimension([x, startpoint.y, z], [x, endpoint.y, z], text, thickness, text_size, rot_around_dim=(plane=="yz"?90:0));

    v1= [x, startpoint.y, z]-startpoint;
    h1 = norm(v1);
    axis1 = cross([0,0,1], v1);
    angle1 = atan2(norm(axis1), v1.z);

    translate(startpoint)
    rotate(angle1, axis1)
    rotate([offset>0?0:180,0,0])
        cylinder( h= h1+thickness*2, d=thickness);


    v2= [x, endpoint.y, z]-endpoint;
    h2 = norm(v2);
    axis2 = cross([0,0,1], v2);
    angle2 = atan2(norm(axis2), v2.z);

    translate(endpoint)
    rotate(angle2, axis2)
    rotate([offset>0?0:180,0,0])
        cylinder( h= h2+thickness*2, d=thickness);
}

module dimension_z(startpoint, endpoint, offset = 1, text = "", thickness = 0, text_size = 0 , plane = "xz") { //! Creates a dimension in the z direction. Plane options : xz, yz
    length = norm(endpoint - startpoint);
    thickness = (thickness == 0? length/200:thickness);


    x = offset > 0 ? max(startpoint.x, endpoint.x) + (plane=="xz"?offset:0) :  min(startpoint.x, endpoint.x) + (plane=="xz"?offset:0);
    y = offset > 0 ? max(startpoint.y, endpoint.y) + (plane=="yz"?offset:0) : min(startpoint.y, endpoint.y) + (plane=="yz"?offset:0);
    dimension([x, y, startpoint.z], [x, y, endpoint.z], text, thickness, text_size, rot_around_dim=(plane=="xz"?90:0));

    v1= [x, y, startpoint.z]-startpoint;
    h1 = norm(v1);
    axis1 = cross([0,0,1], v1);
    angle1 = atan2(norm(axis1), v1.z);

    translate(startpoint)
    rotate(angle1, axis1)
        cylinder( h= h1+thickness*2, d=thickness);


    v2= [x, y, endpoint.z]-endpoint;
    h2 = norm(v2);
    axis2 = cross([0,0,1], v2);
    angle2 = atan2(norm(axis2), v2.z);

    translate(endpoint)
    rotate(angle2, axis2)
        cylinder( h= h2+thickness*2, d=thickness);
}
