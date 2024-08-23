
include <../utils/core/core.scad>
use <../utils/layout.scad>

include <../vitamins/rod_ends.scad>


module do_rod_ends(list) {
    diameters = [for(b = list) rod_end_bearing_od(b)];
    max = max(diameters);
    layout(diameters) let(b = list[$i])
        //translate([0, (max - bb_diameter(b)) / 2])
            rod_end_bearing(list[$i]);
}

if($preview)
    do_rod_ends(rod_ends);
