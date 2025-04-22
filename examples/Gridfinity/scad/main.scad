//
//! Gridfinity examples
//
include <NopSCADlib/core.scad>

use <lathe_tool_stand.scad>
use <MT2_stand.scad>
use <chuck_stand.scad>
use <chuck_jaw_bin.scad>
use <1x1_bin.scad>
use <123_block_stand.scad>
use <faceplate_stand.scad>


//! Show all the Gridfinity parts
module main_assembly()
    assembly("main") {
        $manifold = true;

        lathe_tool_stand_stl();

        translate([42, 63])
            MT2_stand_stl();

        translate([42 * 2, -42 / 2])
            chuck_stand_stl();

        translate([-21, -42])
            chuck_jaw_bin_stl();

        translate([21, -42])
            1x1_bin_stl();

        translate([42 * 4, -42 / 2])
            123_block_stand_stl();

         translate([42 * 6.5, 0])
            faceplate_stand_stl();
    }


main_assembly();
