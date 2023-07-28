//
//! Environmental monitor using Enviro+ sensor board and a Raspberry Pi Zero.
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Top level model
//
include <NopSCADlib/core.scad>
use <NopSCADlib/vitamins/veroboard.scad>
include <NopSCADlib/vitamins/smds.scad>

fan_vb = vero("fan_vb", "fan_controller", 6, 6, breaks = [[2, 1], [2 + eps, 5]],
    components = [
        [5, 3,    90, "link", inch(0.4), undef, undef, 2.5],
        [0, 5,     0, "link", 0, 4, undef, 2.5],
        [0, 1,     0, "link", 0, 4, undef, 2.5],
        [0, 0,     0, "link", 0, 4, undef, 2.5],
        [2, 5,     0, "-smd_res", RES0805, "3K3"],
        [4, 4.5,  90, "-smd_cap", CAP1206, 1.2, "10uF"],
        [2, 2.5, 180, "-smd_sot", SOT223, "FZT851"],
    ]
 );

//! The fan controller is a single transistor wired as a Miller integrator that effectively multiplies the capacitor value by the gain of the transistor.
//! It converts the PWM signal on GPI4 to a stead DC voltage so that the fan doesn't whine, or stutter.
//!
//! ![Schematic](docs/fan_controller.jpg)
//!
//! ***
//! * Make two track cuts as shown, one wide and the other narrow.
//!
//! ![TrackCuts](docs/cuts.jpg)
//!
//! 1. Add the SMT compeonents and then the wire links.
//! 1. Add more solder around the transistor to act as a heatsink.
//!
//! ![SMT](docs/smt.jpg)
//!
module fan_controller_assembly() rotate(90) vflip() veroboard_fastened_assembly(fan_vb, -vero_thickness(fan_vb) - 1.4, 0);

fan_controller_assembly();
