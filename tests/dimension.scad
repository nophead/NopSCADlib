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
include <../utils/core/core.scad>
use <../utils/dimension.scad>


module dimensions_3d_xy() {
    dimension([0,0,0], [10,10,0], "", 0.2);
    dimension([0,0,0], [10,-10,0], "", 0.2);
    dimension([0,0,0], [-10,10,0], "");
    dimension([0,0,0], [-10,-10,0], "");


    dimension([0,0,0], [0,10,0], "");
    dimension([0,0,0], [0,-10,0], "");
    dimension([0,0,0], [10,0,0], "",rot_around_dim=0);
    dimension([0,0,0], [-10,0,0], "", rot_around_dim=90);
}

module dimensions_3d_xyz() {
    dimension([0,0,0], [10,10,10], "");
    dimension([0,0,0], [10,-10,10], "");
    dimension([0,0,0], [-10,10,10], "");
    dimension([0,0,0], [-10,-10,10], "");

    dimension([0,0,0], [10,10,-10], "");
    dimension([0,0,0], [10,-10,-10], "");
    dimension([0,0,0], [-10,10,-10], "");
    dimension([0,0,0], [-10,-10,-10], "", rot_around_dim=45);

    dimension([0,0,0], [-3,0,10], "");
    dimension([0,0,0], [0,0,-10], "");

    dimension([0,0,0], [0,2,10], "");
    dimension([0,0,0], [0,2,-10], "");

}

module dimension_1d_x() {
    dimension_x([12,0,0], [18,0,0]);
    dimension_x([12,5,0], [18,10,0], offset = -1);
    dimension_x([12,0,-5], [18,0,0], plane= "xz");
    dimension_x([12,5,0], [18,10,5]);
}

module dimension_1d_y() {
    dimension_y([12,0,0], [12,-5,0]);
    dimension_y([12,-8,0], [18,-10,0]);
    dimension_y([12,-5,0], [18,-10,5], offset = -1, plane= "yz");
}

module dimension_1d_z() {
    dimension_z([20,0,5], [20,0,0]);
    dimension_z([20,0,10], [20,0,0]);
    dimension_z([20,0,0], [20,10,10],plane= "yz");
}

if($preview)
    dimensions_3d_xy();
    dimensions_3d_xyz();
    dimension_1d_x();
    dimension_1d_y();
    dimension_1d_z();
