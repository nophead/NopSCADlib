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
//! UK 13A sockets at the moment.
//

MKLOGIC   = ["MKLOGIC",     86, 86, 86, 86, 3.6, 9,    3.6, [-9, -9], 60.3]; // Screwfix, switched
Contactum = ["Contactum",   84, 84, 80, 80, 4.0, 10.5, 3.6, [ 0,  0], 60.3]; // Old and unswitched

mains_sockets = [MKLOGIC, Contactum];

use <mains_socket.scad>
