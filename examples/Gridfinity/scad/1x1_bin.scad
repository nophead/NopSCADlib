include <NopSCADlib/core.scad>

use <NopSCADlib/printed/gridfinity.scad>

box = gridfinity_bin("1x1_bin", 1, 1, 5);

module 1x1_bin_stl()
    gridfinity_bin(box)
        gridfinity_partition(box, 1, 1);
