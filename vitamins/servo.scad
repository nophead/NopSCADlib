//
// NopSCADlib Copyright Niclas Hedhman 2018
// niclas@hedhman.org
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


include <../utils/core/core.scad>

function servo_diameter(type) = type[2];
function servo_length(type) = type[3];
function servo_shaft(type) = type[4];
function servo_mount(type) = type[5];

function mount_width(type) = type[2];
function mount_thick1(type) = type[3];
function mount_thick2(type) = type[4];
function mount_hole_dist(type) = type[5];
function mount_hole_dia(type) = type[6];
function mount_flange(type) = type[7];

function shaft_type(type) = type[2];
function shaft_diameter(type) = type[3];
function shaft_length(type) = type[4];
function shaft_key_size(type) = type[5];
function shaft_key_length(type) = type[6];

module servo(type) {
  mtype=servo_mount(type);

  vitamin(str("Servo(", type[0], ") : Servo ", type[5][1], " ", round(servo_diameter(type)), " x ", servo_length(type), "mm"));
  
  translate([0,0,-(servo_length(type)/2 + mount_thick1(mtype) + mount_thick2(mtype))]) {
    body(type);
    t1 = mount_thick1(servo_mount(type));
    t2 = mount_thick2(servo_mount(type));
    color("silver") {
      translate([0,0,servo_length(type)/2 + t1 + t2]) 
        shaft(servo_shaft(type));
  
      translate([0,0,servo_length(type)/2+t1/2])
        mount(servo_mount(type));
    }
  }
}

module body(type) {
  color("#101010")
    cylinder(h=servo_length(type),d=servo_diameter(type), center=true);
}

module corner(r) {
    if(r > 0)
        translate([r, -r])
            circle4n(r);
    else
        if(r < 0)
            translate([-r, r])
                rotate(45)
                    square(-r * sqrt(2), -r * sqrt(2), center = true);
        else
            translate([0.5, -0.5])
                square(1, center = true);
}

module shaft(type) {
  diameter = shaft_diameter(type);
  depth = shaft_key_size(type)[1];
  length = shaft_length(type);
  
  
  if( shaft_type(type) == "keyed" ) {
    difference() {
      cylinder(h=length,d=diameter);
      translate([(diameter-depth)/2,0, length/2 + length-shaft_key_length(type)]) {
        cube([depth, 
              shaft_key_size(type)[0],
              shaft_key_length(type) - shaft_key_size(type)[0]/2],
              center=true
        );
        translate([-depth/2,0,-(shaft_key_length(type)-shaft_key_size(type)[0]/2)/2])
          rotate([0,90,0])
            cylinder(h=depth, d=shaft_key_size(type)[0] );  
      }
    }
  } 
}

module mount(type) {
  w = mount_width(type);
  t1 = mount_thick1(type);
  t2 = mount_thick2(type);
  hdist = mount_hole_dist(type);
  hdia = mount_hole_dia(type);
  flange = mount_flange(type);
  
  difference() {
    linear_extrude(t1, center = true) {
      hull() {
        translate([-w/2,  w/2])
          corner(5);

        translate([ w/2,  w/2])
          rotate(-90)
            corner(5);

        translate([ w/2, -w/2])
          rotate(-180)
            corner(5);

        translate([-w/2, -w/2])
          rotate(-270)
            corner(5);
      }
    }
      
    translate([hdist/2,hdist/2,0])
      cylinder(h=t1+0.1, d=hdia, center=true);
    translate([hdist/2,-hdist/2,0])
      cylinder(h=t1+0.1, d=hdia, center=true);
    translate([-hdist/2,hdist/2,0])
      cylinder(h=t1+0.1, d=hdia, center=true);
    translate([-hdist/2,-hdist/2,0])
      cylinder(h=t1+0.1, d=hdia, center=true);
  }
  translate([0,0,t1/2 + t2/2])
    cylinder(h=t2, d=flange, center=true);
}
