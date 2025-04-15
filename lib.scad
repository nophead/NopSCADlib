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
// Include this file to use the library
//
include <core.scad>

include <vitamins/psus.scad>
include <vitamins/displays.scad> // Includes pcbs.scad

include <vitamins/antennas.scad>
include <vitamins/batteries.scad>
include <vitamins/bearing_blocks.scad>
include <vitamins/blowers.scad>
include <vitamins/bldc_motors.scad>
include <vitamins/box_sections.scad>
include <vitamins/bulldogs.scad>
include <vitamins/cameras.scad>
include <vitamins/components.scad>
include <vitamins/extrusions.scad>
include <vitamins/extrusion_brackets.scad>
include <vitamins/fastons.scad>
include <vitamins/gear_motors.scad>
include <vitamins/geared_steppers.scad>
include <vitamins/hot_ends.scad>
include <vitamins/ht_pipes.scad>
include <vitamins/inserts.scad>
include <vitamins/ldrs.scad>
include <vitamins/leadnuts.scad>
include <vitamins/led_meter.scad>
include <vitamins/light_strips.scad>
include <vitamins/magnets.scad>
include <vitamins/mains_sockets.scad>
include <vitamins/modules.scad>
include <vitamins/panel_meters.scad>
include <vitamins/photo_interrupters.scad>
include <vitamins/pillars.scad>
include <vitamins/pillow_blocks.scad>
include <vitamins/pin_headers.scad>
include <vitamins/pulleys.scad>
include <vitamins/ring_terminals.scad>
include <vitamins/rails.scad>
include <vitamins/rod.scad>
include <vitamins/rod_ends.scad>
include <vitamins/servo_motors.scad>
include <vitamins/shaft_couplings.scad>
include <vitamins/sheets.scad>
include <vitamins/sk_brackets.scad>
include <vitamins/spools.scad>
include <vitamins/ssrs.scad>
include <vitamins/stepper_motors.scad>
include <vitamins/swiss_clips.scad>
include <vitamins/terminal.scad>
include <vitamins/toggles.scad>
include <vitamins/transformers.scad>
include <vitamins/tubings.scad>
include <vitamins/variacs.scad>
include <vitamins/zipties.scad>

use <vitamins/jack.scad>
use <vitamins/fuseholder.scad>
use <vitamins/hygrometer.scad>

use <vitamins/opengrab.scad>
use <vitamins/wire.scad>
use <vitamins/sealing_strip.scad>
use <vitamins/cable_strip.scad>
use <vitamins/veroboard.scad>
use <vitamins/o_ring.scad>
use <vitamins/microview.scad>

use <utils/maths.scad>
use <utils/bezier.scad>
use <utils/sweep.scad>
use <utils/rounded_cylinder.scad>
use <utils/dogbones.scad>
use <utils/tube.scad>
use <utils/quadrant.scad>
use <utils/gears.scad>
use <utils/hanging_hole.scad>
use <utils/fillet.scad>
use <utils/rounded_polygon.scad>
use <utils/rounded_triangle.scad>
use <utils/splines.scad>
use <utils/layout.scad>
use <utils/round.scad>
use <utils/offset.scad>
use <utils/pcb_utils.scad>
use <utils/sector.scad>
use <utils/thread.scad>
use <vitamins/photo_interrupter.scad>
