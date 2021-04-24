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

//!# NopSCADlib
//! An ever expanding library of parts modelled in OpenSCAD useful for 3D printers and enclosures for electronics, etc.
//!
//! It contains lots of vitamins (the RepRap term for non-printed parts), some general purpose printed parts and some utilities.
//! There are also Python scripts to generate Bills of Materials (BOMs),
//! STL files for all the printed parts, DXF files for CNC routed parts in a project and a manual containing assembly
//! instructions and exploded views by scraping markdown embedded in OpenSCAD comments, [see scripts](scripts/readme.md).
//!
//! A simple example project can be found [here](examples/MainsBreakOutBox/readme.md).
//!
//! For more examples of what it can make see the [gallery](gallery/readme.md).
//!
//! The license is GNU General Public License v3.0, see [COPYING](COPYING).
//!
//! See [usage](docs/usage.md) for requirements, installation instructions and a usage guide.
//!
//! A list of changes classified as breaking, additions or fixes is maintained in [CHANGELOG.md](CHANGELOG.md).
//!
//! <img src="libtest.png" width="100%"/>
//
// This file shows all the parts in the library.
//
include <lib.scad>

use <tests/ball_bearings.scad>
use <tests/batteries.scad>
use <tests/bearing_blocks.scad>
use <tests/belts.scad>
use <tests/blowers.scad>
use <tests/box_sections.scad>
use <tests/bulldogs.scad>
use <tests/buttons.scad>
use <tests/cable_strips.scad>
use <tests/cameras.scad>
use <tests/camera_housing.scad>
use <tests/circlips.scad>
use <tests/components.scad>
use <tests/d_connectors.scad>
use <tests/displays.scad>
use <tests/drag_chain.scad>
use <tests/extrusions.scad>
use <tests/extrusion_brackets.scad>
use <tests/fans.scad>
use <tests/fuseholder.scad>
use <tests/geared_steppers.scad>
use <tests/hot_ends.scad>
use <tests/IECs.scad>
use <tests/inserts.scad>
use <tests/jack.scad>
use <tests/leadnuts.scad>
use <tests/LDRs.scad>
use <tests/LEDs.scad>
use <tests/light_strips.scad>
use <tests/linear_bearings.scad>
use <tests/LED_meters.scad>
use <tests/magnets.scad>
use <tests/microswitches.scad>
use <tests/modules.scad>
use <tests/nuts.scad>
use <tests/o_ring.scad>
use <tests/opengrab.scad>
use <tests/panel_meters.scad>
use <tests/PCBs.scad>
use <tests/pillars.scad>
use <tests/pillow_blocks.scad>
use <tests/press_fit.scad>
use <tests/PSUs.scad>
use <tests/pulleys.scad>
use <tests/rails.scad>
use <tests/ring_terminals.scad>
use <tests/rockers.scad>
use <tests/rod.scad>
use <tests/screws.scad>
use <tests/sealing_strip.scad>
use <tests/shaft_couplings.scad>
use <tests/sheets.scad>
use <tests/SK_brackets.scad>
use <tests/spades.scad>
use <tests/springs.scad>
use <tests/SSRs.scad>
use <tests/stepper_motors.scad>
use <tests/Swiss_clips.scad>
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
use <tests/flat_hinge.scad>
use <tests/foot.scad>
use <tests/handle.scad>
use <tests/PCB_mount.scad>
use <tests/pocket_handle.scad>
use <tests/printed_box.scad>
use <tests/printed_pulleys.scad>
use <tests/ribbon_clamp.scad>
use <tests/screw_knob.scad>
use <tests/socket_box.scad>
use <tests/strap_handle.scad>
use <tests/SSR_shroud.scad>
use <tests/PSU_shroud.scad>

x0 = 0;
x1 = x0 + 110;
x2 = x1 + 90;
x3 = x2 + 130;
x4 = x3 + 200;
x5 = 850;
x6 = x5 + 150;

cable_grommets_y = 0;

translate([x5, cable_grommets_y])
    cable_grommets();

translate([x5 + 50, cable_grommets_y])
    ribbon_clamps();

translate([x5 + 95, cable_grommets_y])
    press_fits();

translate([x5, cable_grommets_y + 60])
    fixing_blocks();

translate([x5, cable_grommets_y + 90])
    corner_blocks();

translate([x5, cable_grommets_y + 150])
    feet();

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

translate([640, cable_grommets_y + 200])
    printed_pulley_test();

translate([x5, cable_grommets_y + 250])
    handle();

translate([950, 600])
    box_test();

translate([830, 770])
    pocket_handles();

translate([950, 750])
    printed_boxes();

translate([850, 1330])
    bbox_test();


inserts_y = 0;
nuts_y = inserts_y + 20;
washers_y = nuts_y + 120;
screws_y = washers_y + 120;
circlips_y = screws_y + 160;
springs_y = circlips_y + 20;
o_rings_y = springs_y;
sealing_strip_y = springs_y + 20;
tubings_y = sealing_strip_y + 20;
pillars_y = tubings_y + 20;
ball_bearings_y = pillars_y + 40;
pulleys_y = ball_bearings_y +40;
hot_ends_y = pulleys_y + 60;
linear_bearings_y = hot_ends_y + 50;
sheets_y = linear_bearings_y + 90;
pcbs_y = sheets_y + 60;
displays_y = pcbs_y + 170;
fans_y = displays_y + 80;
transformers_y = fans_y + 120;
psus_y = transformers_y + 190;

translate([x0 + 35, inserts_y])
    inserts();

translate([x0, inserts_y])
    ring_terminals();

translate([x0, nuts_y])
    nuts();

translate([x0, washers_y])
    washers();

translate([x0, screws_y])
    screws();

translate([x0, circlips_y])
    circlips();

translate([x0, o_rings_y])
    o_rings();

translate([x0 + 20, springs_y])
    springs();

translate([x0 + 50, sealing_strip_y])
    sealing_strip_test();

translate([x0, tubings_y])
    tubings();

translate([x0, pillars_y])
    pillars();

translate([x0, ball_bearings_y])
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

zipties_y = 0;
bulldogs_y = zipties_y + 30;
swiss_clips_y = bulldogs_y + 35;
leadnuts_y = swiss_clips_y + 50;

translate([x1, zipties_y])
    zipties();

translate([x1, bulldogs_y])
    bulldogs();

translate([x1, swiss_clips_y])
    swiss_clips();

translate([x1, leadnuts_y])
    leadnuts();


leds_y = 0;
carriers_y = leds_y + 40;
magnets_y = carriers_y + 40;
spades_y = magnets_y + 20;
buttons_y = spades_y + 20;
jacks_y = buttons_y + 40;
microswitches_y = jacks_y + 40;
rockers_y = microswitches_y + 40;
toggles_y = rockers_y + 60;
components_y = toggles_y + 40;

translate([x2, leds_y])
    leds();

translate([x2 + 35, leds_y])
    ldrs();

translate([x2 + 8, carriers_y])
    carriers();

translate([x2, magnets_y])
    magnets();

translate([x2 + 20, carriers_y])
    led_meters();

translate([x2 + 70, leds_y])
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

veroboard_y = 0;
d_connectors_y = veroboard_y + 110;
iecs_y = d_connectors_y + 80;
modules_y = iecs_y + 60;
ssrs_y = modules_y + 80;
blowers_y = ssrs_y + 60;
batteries_y = blowers_y + 100;
steppers_y = batteries_y + 55;
panel_meters_y = steppers_y + 70;
extrusions_y = panel_meters_y + 80;

translate([x3, veroboard_y])
    veroboard_test();

translate([x3 + 60, veroboard_y + 20])
    geared_steppers();

translate([x3 + 160, ssrs_y])
    pcb_mounts();

translate([x3 + 170, veroboard_y + 16])
    cameras();

translate([x3, d_connectors_y])
    d_connectors();

translate([x3 + 170, d_connectors_y - 10])
    camera_housings();

translate([x3, iecs_y])
    iecs();

translate([x3 + 15, modules_y])
    microview();

translate([x3 + 60, modules_y])
    hygrometer();

translate([x3 + 90, modules_y])
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

translate([x2, panel_meters_y])
    panel_meters();

translate([x2, extrusions_y])
    extrusions();

translate([x3, transformers_y])
    transformers();


belts_y = 0;
rails_y = belts_y + 200;
extrusion_brackets_y = rails_y + 250;
sk_brackets_y = extrusion_brackets_y + 80;
kp_pillow_blocks_y = sk_brackets_y + 50;
scs_bearing_blocks_y = kp_pillow_blocks_y + 60;
box_sections_y = sheets_y;

translate([x4 + 200, belts_y + 58]) {
    belt_test();

    translate([0, 60])
        opengrab_test();

}

translate([x4 + 175, belts_y, -20])
    drag_chains();

translate([x4, rails_y + 130])
    rails();

translate([770, fans_y + 50])
    cable_strips();

translate([x4, kp_pillow_blocks_y])
    kp_pillow_blocks();

translate([x4, sk_brackets_y])
    sk_brackets();

translate([x4, extrusion_brackets_y])
    extrusion_brackets();

translate([x4 + 120, extrusion_brackets_y])
    shaft_couplings();

translate([x4, scs_bearing_blocks_y])
    scs_bearing_blocks();

translate([x4, box_sections_y])
    box_sections();

translate([x6, 125])
    light_strips();
