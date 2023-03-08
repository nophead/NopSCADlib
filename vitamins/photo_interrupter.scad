include <../utils/core/core.scad>

function pi_name(type) = type[0];
function pi_base_height(type) = type[3];
function pi_base_length(type) = type[2];
function pi_base_width(type) = type[1];
function pi_gap_height(type) = type[4];
function pi_gap_width(type) = type[6];
function pi_stem_width(type) = type[5];
function pi_hole_diameter(type) = type[7];
function pi_color(type) = type[8];
function pi_pcb(type) = type[9];

module pi_hole_locations(type) {
    translate([0, -(pi_base_length(type) - pi_base_width(type)) / 2, 0])
        children();
    translate([0, (pi_base_length(type) - pi_base_width(type)) / 2, 0])
        children();
}

module pi_pcb_hole_locations(pcb) {
    for (xy = pcb[7]) {
        translate([xy[0], xy[1], 0])
            children();
    }
}

module pi_pcb(type) {
    pcb = pi_pcb(type);
    color(pcb[6]) {
        difference() {
            union() {
                translate([0, 0, -pcb[2]]){
                    if (pcb[4]) {
                        hull() {
                            pi_hole_locations(type)
                                cylinder(h=pcb[2], d=pi_base_width(type));
                        }
                    }
                }
                translate([pcb[4], 0, -pcb[2]/2]) {
                    cube([pcb[0], pcb[1], pcb[2]], center = true); 
                }
            }
            translate([0, 0, -pcb[2]]) {
                pi_pcb_hole_locations(pcb)
                    cylinder(h=pcb[2]+0.1, d = pcb[8]);
                pi_hole_locations(type)
                    cylinder(h=pcb[2]+0.1, d=pi_hole_diameter(type));
            }
        }
    }
}

module photo_interrupter(type) {
    vitamin(pi_name(type));
    color(pi_color(type))
    difference() {
        union() {
            hull() {
                pi_hole_locations(type) 
                    cylinder(h = pi_base_height(type), d = pi_base_width(type));
            }
            translate([-pi_base_width(type)/2, -(pi_gap_width(type)/2 + pi_stem_width(type)), 0])
                cube([pi_base_width(type), pi_stem_width(type), pi_gap_height(type) + pi_base_height(type)]);
            translate([-pi_base_width(type)/2, pi_gap_width(type)/2, 0])
                cube([pi_base_width(type), pi_stem_width(type), pi_gap_height(type) + pi_base_height(type)]);
        }
        pi_hole_locations(type) 
            cylinder(h = pi_base_height(type), d = pi_hole_diameter(type));    
    }
    pi_pcb(type);
}

module pi_cutout(type) {
    hull() {
        pi_hole_locations(type) 
            cylinder(h = pi_base_height(type), d = pi_base_width(type));
    }
    translate([-pi_base_width(type)/2, -(pi_gap_width(type)/2 + pi_stem_width(type)), 0])
        cube([pi_base_width(type), pi_stem_width(type), pi_gap_height(type) + pi_base_height(type)]);
    translate([-pi_base_width(type)/2, pi_gap_width(type)/2, 0])
        cube([pi_base_width(type), pi_stem_width(type), pi_gap_height(type) + pi_base_height(type)]);
};

PH1 = ["PH1: Photo interrupter", 6.4, 25.9 , 3.5, 8.6, 4.1, 5.9, 3, "black", [22, 20, 1.6, true, 11-3.2, 0, "blue",[[8.3, -7.5], [8.3, 7.5]], 3]];
photo_interrupter(PH1);
