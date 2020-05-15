include <drink-me.scad>

translate([origin_x, -origin_y]) {
     scale([-1, 1]) {
          pcb_2d(pcb_inner);
     }
}
