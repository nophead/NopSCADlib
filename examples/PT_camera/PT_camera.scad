include <../../vitamins/geared_steppers.scad>
include <../../core.scad>
include <../../vitamins/cameras.scad>
use <../../vitamins/pcb.scad>

module ptc(ang2) {
  rotate([180,0,0])
    union(){
      geared_stepper(28BYJ_48,ang2);
      rotate([90,0,180-ang2])
        translate([9.8,-16.5,1.7])
          rotate([0,0,90])
            camera(cameras[0]);
    }
}

module pt(ang,ang2) {
  rotate([180,0,0]) geared_stepper(28BYJ_48,ang);
  rotate([0,0,ang]) rotate([270,0,0]) translate([0,-29.0,-1.5]) ptc(ang2);
}

deg=90;
c=90;

if($t<0.125){
  a=180+$t/0.125*deg;
  pt(a,c);
}else if ($t<0.25){
  a=180+deg-($t-0.125)/0.125*deg;
  pt(a,c);
}else if ($t<0.375){
  b=c+($t-0.25)/0.125*deg;
  pt(180,b);
}else if ($t<0.5){
  b=c+deg-($t-0.375)/0.125*deg;
  pt(180,b);
}   
else if($t<0.625){
  a=180+($t-0.5)/0.125*deg;
  b=c+deg-90+($t-0.5)/0.125*deg;
  pt(a,b);
}else if ($t<0.75){
  a=180+deg-($t-0.625)/0.125*deg;
  b=c+deg-($t-0.625)/0.125*deg;
  pt(a,b);
}else if ($t<0.875){
  a=180-($t-0.75)/0.125*deg;
  b=c-($t-0.75)/0.125*deg;
  pt(a,b);
}else{
  a=90+($t-0.875)/0.125*deg;
  b=c+deg-180+($t-0.875)/0.125*deg;
  pt(a,b);
}   
