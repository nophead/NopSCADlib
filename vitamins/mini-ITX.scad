difference() {
	translate([-10.16, 6.35-170, 0])cube([170,170,1.58]); // The datum is the C mount point.
	translate([0,0,-5])cylinder(d=3.81, h=10); // Mount hole C   holes are 0.15in
	translate([157.48,-22.86,-5])cylinder(d=3.81, h=10); // Mount hole F
	translate([0,-154.94,-5])cylinder(d=3.81, h=10); // Mount hole H
	translate([157.48,-154.94,-5])cylinder(d=3.81, h=10); // Mount hole J
};
color("grey")translate([7.52,10.16,7.3-9.53])cube([159,1,44.7]); // IO cutout