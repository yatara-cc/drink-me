include <drink-me.scad>

translate([origin_x, -origin_y]) {
     scale([-1, 1]) {
          difference() {
               pcb_2d(pcb_border);

               key_copy() {
                    /* switch_holes(); */
               }
          }
     }
}
