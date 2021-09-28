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
//! Hot end models. The E3D models were originally contributed to Mendel90 by Philippe LUC @philfifi
//!
//! Needs updating as mostly obsolete versions.
//
function hot_end_style(type)              = type[1];    //! Basic type, jhead or e3d
function hot_end_part(type)               = type[2];    //! Description
function hot_end_total_length(type)       = type[3];    //! Length from nozzle tip to the top
function hot_end_inset(type)              = type[4];    //! The length that goes into the mounting
function hot_end_insulator_diameter(type) = type[5];    //! Outside diameter
function hot_end_insulator_length(type)   = type[6];    //! Length of the insulator
function hot_end_insulator_colour(type)   = type[7];    //! Colour of the insulator
function hot_end_groove_dia(type)         = type[8];    //! Groove internal diameter
function hot_end_groove(type)             = type[9];    //! Groove length
function hot_end_duct_radius(type)        = type[10];   //! Require radius to clear the heater block
function hot_end_duct_offset(type)        = type[11];   //! Offset of circular duct centre from the nozzle
function hot_end_need_cooling(type)       = hot_end_style(type) != "e3d"; //! Has own fan so don't need cooling hole in the duct
function hot_end_duct_height_nozzle(type) = type[12];   //! Duct height at nozzle end
function hot_end_duct_height_fan(type)    = type[13];   //! Duct height at fan end

function hot_end_length(type) = hot_end_total_length(type) - hot_end_inset(type); //! The amount the hot end extends below its mounting

use <jhead.scad>
use <e3d.scad>

module hot_end(type, filament, naked = false, resistor_wire_rotate = [0,0,0], bowden = false) { //! Draw specified hot end
    if(hot_end_style(type) == "jhead")
        jhead_hot_end_assembly(type, filament, naked);
    else if(hot_end_style(type) == "e3d")
        e3d_hot_end_assembly(type, filament, naked, resistor_wire_rotate, bowden);
    else
        assert(false, "Invalid hotend style");
}
