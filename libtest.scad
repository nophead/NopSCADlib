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
// This file shows all the parts in the library.
//
include <lib.scad>

use <tests/ball_bearings.scad>
use <tests/batteries.scad>
use <tests/belts.scad>
use <tests/blowers.scad>
use <tests/bulldogs.scad>
use <tests/buttons.scad>
use <tests/cable_strips.scad>
use <tests/components.scad>
use <tests/d_connectors.scad>
use <tests/displays.scad>
use <tests/fans.scad>
use <tests/fuseholder.scad>
use <tests/hot_ends.scad>
use <tests/iecs.scad>
use <tests/inserts.scad>
use <tests/jack.scad>
use <tests/leadnuts.scad>
use <tests/leds.scad>
use <tests/light_strips.scad>
use <tests/linear_bearings.scad>
use <tests/meter.scad>
use <tests/microswitches.scad>
use <tests/modules.scad>
use <tests/nuts.scad>
use <tests/o_ring.scad>
use <tests/opengrab.scad>
use <tests/pcbs.scad>
use <tests/pillars.scad>
use <tests/psus.scad>
use <tests/pulleys.scad>
use <tests/rails.scad>
use <tests/ring_terminals.scad>
use <tests/rockers.scad>
use <tests/rod.scad>
use <tests/screws.scad>
use <tests/sealing_strip.scad>
use <tests/sheets.scad>
use <tests/spades.scad>
use <tests/springs.scad>
use <tests/ssrs.scad>
use <tests/stepper_motors.scad>
use <tests/toggles.scad>
use <tests/transformers.scad>
use <tests/tubings.scad>
use <tests/veroboard.scad>
use <tests/washers.scad>
use <tests/variacs.scad>
use <tests/zipties.scad>

use <tests/box.scad>
use <tests/butt_box.scad>
use <tests/cable_grommets.scad>
use <tests/carriers.scad>
use <tests/corner_block.scad>
use <tests/door_hinge.scad>
use <tests/door_latch.scad>
use <tests/fan_guard.scad>
use <tests/fixing_block.scad>
use <tests/foot.scad>
use <tests/handle.scad>
use <tests/ribbon_clamp.scad>
use <tests/screw_knob.scad>
use <tests/socket_box.scad>
use <tests/strap_handle.scad>
use <tests/ssr_shroud.scad>
use <tests/psu_shroud.scad>
use <tests/flat_hinge.scad>

x5 = 800;

cable_grommets_y = 0;

translate([x5, cable_grommets_y])
    cable_grommets();

translate([x5, cable_grommets_y + 50])
    feet();

translate([x5, cable_grommets_y + 75])
    fixing_blocks();

translate([x5, cable_grommets_y + 100])
    corner_blocks();

translate([x5, cable_grommets_y + 150])
    ribbon_clamps();

translate([x5 + 70, cable_grommets_y + 150])
    screw_knobs();

translate([x5, cable_grommets_y + 470]) {
    door_hinges()
        door_latches();

    translate([120, 0])
        flat_hinges();
}

translate([x5, cable_grommets_y + 370])
    no_explode() socket_boxes();

translate([x5 + 60, cable_grommets_y + 200])
    strap_handles();

translate([x5, cable_grommets_y + 250])
    handle();

translate([900, 600])
    box_test();

translate([850, 1170])
    bbox_test();

x0 = 0;
inserts_y = 0;
nuts_y = inserts_y + 20;
washers_y = nuts_y + 60;
screws_y = washers_y + 120;
o_rings_y = screws_y + 130;
springs_y = o_rings_y + 20;
sealing_strip_y = springs_y + 20;
tubings_y = sealing_strip_y + 20;
pillars_y = tubings_y + 20;
leadnuts_y = pillars_y + 40;
pulleys_y = leadnuts_y +40;
hot_ends_y = pulleys_y + 60;
linear_bearings_y = hot_ends_y + 50;
sheets_y = linear_bearings_y + 50;
pcbs_y = sheets_y + 40;
displays_y = pcbs_y + 150;
fans_y = displays_y + 100;
transformers_y = fans_y + 120;
psus_y = transformers_y + 190;

translate([x0 + 30, inserts_y])
    inserts();

translate([x0, inserts_y])
    ring_terminals();

translate([x0, nuts_y])
    nuts();

translate([x0, washers_y])
    washers();

translate([x0, screws_y])
    screws();

translate([x0, o_rings_y])
    o_rings();

translate([x0, springs_y])
    springs();

translate([x0 + 50, sealing_strip_y])
    sealing_strip_test();

translate([x0, tubings_y])
    tubings();

translate([x0, pillars_y])
    pillars();

translate([x0, leadnuts_y ])
    leadnuts();

translate([x0 + 80, leadnuts_y])
    ball_bearings();

translate([x0, pulleys_y])
    pulleys();

translate([x0, linear_bearings_y]) {
    linear_bearings();
    rods();
}

translate([x0 + 10, hot_ends_y])
    hot_ends();

translate([x0, sheets_y])
    sheets();

translate([x0, pcbs_y])
    pcbs();

translate([x0, displays_y])
    displays();

translate([x0, fans_y]) {
    fans();

    translate_z(3)
        fan_guards();
}

translate([x0, transformers_y])
    variacs();

translate([x0, psus_y]) {
    psus();

    psu_shrouds();
}

x1 = x0 + 100;
zipties_y = 0;
bulldogs_y = zipties_y + 40;

translate([x1, zipties_y])
    zipties();

translate([x1, bulldogs_y])
    bulldogs();

x2 = x1 + 90;
leds_y = 0;
carriers_y = leds_y + 40;
spades_y = carriers_y + 40;
buttons_y = spades_y + 40;
jacks_y = buttons_y + 40;
microswitches_y = jacks_y + 40;
rockers_y = microswitches_y + 40;
toggles_y = rockers_y + 40;
components_y = toggles_y + 40;

translate([x2, leds_y])
    leds();

translate([x2 + 8, carriers_y])
    carriers();

translate([x2+ 38, carriers_y])
    meters();

translate([x2 + 68, carriers_y])
    fuseholders();

translate([x2, spades_y])
    spades();

translate([x2,  buttons_y])
    buttons();

translate([x2, jacks_y])
    jacks();

translate([x2, microswitches_y])
    microswitches();

translate([x2, rockers_y])
    rockers();

translate([x2, toggles_y])
    toggles();

translate([x2, components_y])
    components();


x3 = x2 + 150;
veroboard_y = 0;
d_connectors_y = veroboard_y + 110;
iecs_y = d_connectors_y + 80;
modules_y = iecs_y + 60;
ssrs_y = modules_y + 80;
blowers_y = ssrs_y + 60;
batteries_y = blowers_y + 100;
steppers_y = batteries_y + 70;

translate([x3, veroboard_y])
    veroboard_test();

translate([x3, d_connectors_y])
    d_connectors();

translate([x3, iecs_y])
    iecs();

translate([x3 + 15, modules_y])
    microview();

translate([x3 + 40, modules_y])
    modules();

translate([x3, ssrs_y]) {
    ssrs();

    ssr_shrouds();
}

translate([x3, blowers_y])
    blowers();

translate([x3, batteries_y])
    batteries();

translate([x2, steppers_y])  // interloper
    stepper_motors();

translate([x3, transformers_y])
    transformers();


x4 = x3 + 220;
belts_y = 0;
rails_y = belts_y + 200;
cable_strips_y = rails_y + 300;

translate([x4 + 112, belts_y + 58]) {
    belt_test();

    translate([0, 60])
        opengrab_test();
}

translate([x4, rails_y + 130])
    rails();

translate([x4, cable_strips_y])
    cable_strips();

x6 = x5 + 150;
translate([x6, 125])
    light_strips();
