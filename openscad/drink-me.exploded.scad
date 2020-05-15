include <drink-me.scad>

pcb_dist = 40;

present() {
     case_3d();

     translate([0, 0, -30]) {
          rest_3d();
          base_3d();
     }
     
     translate([0, pcb_dist, pcb_dist * sin(typing_angle)]) {
          pcb_3d();
     }
}

