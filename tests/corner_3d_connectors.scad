//
// NopSCADlib Copyright Chris Palmer 2021
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
include <../vitamins/corner_3d_connectors.scad>
include <../vitamins/extrusions.scad>

module corner_connector(with_profiles = false, corner_connector_type, extrusion_type) {
    extrusion_length = 40;
    corner_3d_connector(corner_connector_type);
    if(with_profiles){
        translate([0,0,extrusion_length/2])
        extrusion(extrusion_type, extrusion_length);
        translate(corner_3d_connector_get_y_offset(corner_connector_type))
        rotate(corner_3d_connector_get_y_rot(corner_connector_type))
        translate([0,0,extrusion_length/2])
        extrusion(extrusion_type, extrusion_length);
        translate(corner_3d_connector_get_x_offset(corner_connector_type))
        rotate(corner_3d_connector_get_x_rot(corner_connector_type))
        translate([0,0,extrusion_length/2])
        extrusion(extrusion_type, extrusion_length);
    }
}

module corner_connectors(with_profiles = false) {
corner_connector(with_profiles, corner_3d_connector_2020, E2020);


translate([100,0,0])
corner_connector(with_profiles, corner_3d_connector_3030, E3030);


translate([220,0,0])
corner_connector(with_profiles, corner_3d_connector_4040, E4040);
}

corner_connectors();
translate ([0,100,0])
corner_connectors(true);