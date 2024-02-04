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
// Include this file to use the minimum library
//
include <../../global_defs.scad>
//
// Global functions and modules
//
use <global.scad>

module use_stl(name) {               //! Import an STL to make a build platter
    stl(name);
    path = is_undef($target) ? "../stls/" : str($cwd, "/", $target, "/stls/");
    import(str(path, name, ".stl"));
}

module use_dxf(name) {               //! Import a DXF to make a build panel
    dxf(name);
    path = is_undef($target) ? "../dxfs/" : str($cwd, "/", $target, "/dxfs/");
    import(str(path, name, ".dxf"));
}

module use_svg(name) {               //! Import an SVG to make a build panel
    svg(name);
    path = is_undef($target) ? "../svgs/" : str($cwd, "/", $target, "/svgs/");
    import(str(path, name, ".svg"));
}
