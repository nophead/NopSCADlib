include <NopSCADlib/core.scad>

*use_stl("socket_box"); // Importing the STL gives a CGAL error although NetFabb finds nothing wrong with it.

use <../scad/bob_main.scad>

render() socket_box_stl();

for(i = [0 : 3])
    translate([i * 25 - 1.5 * 25, -70])
        use_stl("foot");
