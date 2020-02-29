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
include <../utils/core/core.scad>
use <../printed/pcb_mount.scad>

PI_IO = ["PI_IO", "PI_IO V2",       35.56, 25.4, 1.6, 0,    0,   0, "green", true, [],
    [[(3.015 - 2.7) * 25.4 - 3.5 /2, (4.5 - 3.685) * 25.4, 90, "term35", 2],
     [(3.46  - 2.7) * 25.4 - 3.5 /2, (4.5 - 3.69)  * 25.4, 90, "term35", 2],
     [(3.91  - 2.7) * 25.4 - 3.5 /2, (4.5 - 3.69)  * 25.4, 90, "term35", 2],
     [(3.4   - 2.7) * 25.4,          (4.5 - 4.15)  * 25.4,  0, "2p54socket", 13, 2],
    ], []];

module pcb_mounts()
    if($preview)
        pcb_mount_assembly(PI_IO, 3);
    else
        pcb_mount(PI_IO);

pcb_mounts();
