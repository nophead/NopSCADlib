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
//! Annotation used in this documentation
//

include <../utils/core/core.scad>
include <../utils/maths.scad>



//if text is empty, will display the number value
module dimension(startpoint, endpoint, text = "", thickness = 0.1) {    
    // Compute vector between points
    direction = endpoint - startpoint;
    length = norm(direction);
    midpoint = (startpoint + endpoint) / 2;

    // Ensure nonzero values for calculations
    dir_xy = norm([direction.x, direction.y]);

    // Compute rotation angles
    azimuth = atan2(direction.y, direction.x); 
    elevation = -atan2(direction.z, dir_xy);

    // Draw measurement line as a thin cylinder
    translate(midpoint)
    rotate([0, elevation, azimuth])
    rotate([0, 90, 0]) 
    cylinder(d = thickness, h = length - thickness * 2, center = true);

    // Draw endpoint markers
    translate(startpoint) 
    rotate([0, elevation - 90, azimuth]) 
    translate([0, 0, -thickness * 4]) 
    cylinder(h = thickness * 4, r1 = thickness * 2, r2 = 0);
    
    translate(endpoint) 
    rotate([0, elevation + 90, azimuth]) 
    translate([0, 0, -thickness * 4]) 
    cylinder(h = thickness * 4, r1 = thickness * 2, r2 = 0);

    // Draw the text/distance
    dir = (length > 0) ? (direction / length) * thickness * 4 : [1, 0, 0]; 
    up_dir = rotate_vector_3d([0,1,0], [0,0,1] ,azimuth);
    
    translate(midpoint + up_dir*0.66)
    rotate([0, elevation, azimuth]) 
    linear_extrude(thickness)
    text(text == "" ? str(length) : text, size = thickness * 5, valign = "bottom", halign = "center");
}

//offset will detirmine how much space is between the measured point and the dimension
//for x, this offset will be in the y direction
module dimension_x(startpoint, endpoint, offset = 1, text = "", thickness = 0.1) {
    y = max(startpoint.y, endpoint.y) + offset;
    z = max(startpoint.z, endpoint.z) ;
    dimension([startpoint.x, y, z], [endpoint.x, y, z], text, thickness);
    
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

//offset will detirmine how much space is between the measured point and the dimension
//for y, this offset will be in the x direction
module dimension_y(startpoint, endpoint, offset = 1, text = "", thickness = 0.1) {
    x = max(startpoint.x, endpoint.x) + offset;
    z = max(startpoint.z, endpoint.z) ;
    dimension([x, startpoint.y, z], [x, endpoint.y, z], text, thickness);
    
    v1= [x, startpoint.y, z]-startpoint;
    h1 = norm(v1);
    axis1 = cross([0,0,1], v1);
    angle1 = atan2(norm(axis1), v1.z);
    
    translate(startpoint)
    rotate(angle1, axis1)
        cylinder( h= h1+thickness*2, d=thickness);
        
        
    v2= [x, endpoint.y, z]-endpoint;
    h2 = norm(v2);
    axis2 = cross([0,0,1], v2);
    angle2 = atan2(norm(axis2), v2.z);
    
    translate(endpoint)
    rotate(angle2, axis2)
        cylinder( h= h2+thickness*2, d=thickness);          
}

//offset will detirmine how much space is between the measured point and the dimension
//for z, this offset will be in the x direction
module dimension_z(startpoint, endpoint, offset = 1, text = "", thickness = 0.1) {
    x = max(startpoint.x, endpoint.x) + offset;
    y = max(startpoint.y, endpoint.y) ;
    dimension([x, y, startpoint.z], [x, y, endpoint.z], text, thickness);
    
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




