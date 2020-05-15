// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

// Fabrication variables

pcb_thickness = 1.6;
pcb_slot_clearance_xy = 0.25;
pcb_slot_clearance_z = 0.4;
pcb_slot_overlap = 1;

plate_thickness = 1.2;
plate_switch_clearance = 0.25;
plate_switch_r = 0.3;

base_clip_overlap = 0.55;
base_clearance_xy = 0.3;
base_clearance_z = 0.2;
base_clearance_back_z = 0.8;
base_rest_chamfer = base_clearance_z * 4;
base_usb_port_width = 12;

base_clip_neg_ty = 0; // 0.5;
base_clip_neg_inset_y = 0.5;  // From each side
base_clip_neg_inset_z = 0;  // Only from top

rest_chamfer_x = 2; // Prevents sharp edges on top layer.
rest_chamfer_z = 0.2; // Layer height x2
case_chamfer_z = 0; // Prevent the last print layer being a single line if necessary.

support_block_xy_start = 0.975;
support_block_xy_end = 1.625;
support_block_z = 0.5;


// Constants

unit = 19.05;  // Standard key pitch; equal to 3/4 inch
switch_base_height = 5;  // Height from MX switch base to top of plate
switch_cutout_xy = 14;
switch_pin_height = 3.25;  // Extension of switch pins below base
overlap = 0.1;  // An arbitrary small constant used for Boolean operations


// Design variables

ergo_dist_x = 14.85;  // Space between center keys (before ergo rotation)
ergo_angle = 15;

typing_angle = 8;

case_height = 20.44;
case_point = false;  // `true` for a sharp point; `false` for a chiselled point
case_bezel = 4;
case_bevel = 1;
case_side_wall_thickness = 4;
case_slot_thickness_front = 1.73966;  // Minimum thickness of front of case at PCB slot.

integrated_plate = true;

key_cutaway_xy = 20;
key_cutaway_bevel = 0.5;
key_cutaway_depth = 7.5;

rest_gap = 0.5;
rest_length = 22;

base_rest = false;
base_height = 1;
base_clip_ty = -10.3;
base_clip_size = 1;  // rename to step;
base_clip_length = 11;

base_back_thickness = 1.6;
base_slot_clearance_back = 0.43766 + base_back_thickness;

$fn = 16;


// Derived values

pcb_inner = case_bezel - case_side_wall_thickness;
pcb_border = pcb_inner + pcb_slot_overlap;
pcb_outer = pcb_border + pcb_slot_clearance_xy;
pcb_top_depth = -switch_base_height;
pcb_bottom_depth = pcb_top_depth - pcb_thickness;
pcb_depth_front = key_cutaway_depth - pcb_top_depth;
pcb_depth_back = key_cutaway_depth - pcb_bottom_depth;

pcb_dy_front = (
     -(case_bezel - pcb_border)
     -sin(typing_angle) * pcb_depth_front
     + case_slot_thickness_front
     );
pcb_dy_back = (
     +(case_bezel - pcb_border)
     -sin(typing_angle) * pcb_depth_back
     - base_slot_clearance_back
     );
plate_dy_front = -1;

key_x1 = ergo_dist_x / 2 + unit * 1.5;
hull_x1 = ergo_dist_x / 2 + unit * 1.5 + key_cutaway_xy * 0.5;
hull_y1 = key_cutaway_xy * 0.5;
hull_x2 = hull_x1 + case_bezel;
hull_y2 = hull_y1 + case_bezel;

sina = sin(typing_angle);
cosa = cos(typing_angle);

y_align = -sina * key_cutaway_depth;

case_y_max = cosa * (hull_y2 + y_align);
case_z_max = cosa * key_cutaway_depth + sina * hull_y2;
case_z_min = case_z_max - case_height;
case_extrusion_depth = case_height - case_z_max + sina * y_align;


// Debug variables

section = false;
/* section = "mid-y"; */
/* section = "key-0"; */
/* section = "join"; */

debug_measurements = false;


// KiCAD variables

origin_x = 74;
origin_y = 74;


// Utility modules


module centered_square (s, t=[-0.5, -0.5]) {
     scale(s) {
          translate(t) {
               square(1);
          }
     }
}


module key_copy (outside=true, inside=true, left=true, right=true, verbose=false) {
     x1 = key_x1;
     y1 = 0;
     x2r = ergo_dist_x / 2 + unit;
     y2r = unit * -0.5;
     x2d = unit * 0.5;
     y2d = unit * 0.5;

     if (verbose) {
          // Remember Y is inverted for KiCAD
          x2 = x2r - cos(ergo_angle) * x2d - sin(ergo_angle) * y2d;
          y2 = -y2r + sin(ergo_angle) * x2d - cos(ergo_angle) * y2d;
          echo("");
          echo("Key positions");
          echo(str("    (at ", origin_x + x1, " ", origin_y + y1, ")"));
          echo(str("    (at ", origin_x + x2, " ", origin_y + y2, " ", ergo_angle, ")"));
          echo(str("    (at ", origin_x - x2, " ", origin_y + y2, " ", -ergo_angle, ")"));
          echo(str("    (at ", origin_x - x1, " ", origin_y + y1, ")"));
          echo("");
     }
     if (outside) {
          if (left) {
               translate([-x1, y1]) {
                    children();
               }
          }
          if (right) {
               translate([x1, y1]) {
                    children();
               }
          }
     }
     if (inside) {
          if (left) {
               translate([-x2r, y2r]) {
                    rotate(-ergo_angle) {
                         translate([x2d, y2d]) {
                              children();
                         }
                    }
               }
          }
          if (right) {
               translate([x2r, y2r]) {
                    rotate(ergo_angle) {
                         translate([-x2d, y2d]) {
                              children();
                         }
                    }
               }
          }
     }
}


module case_extrude (offset=0) {
     difference() {
          translate([0, -sina * key_cutaway_depth, 0]) {
               rotate([-typing_angle, 0, 0]) {
                    translate([0, 0, -case_extrusion_depth - offset]) {
                         linear_extrude(100) {
                              scale([1, cosa]) {
                                   children();
                              }
                         }
                    }
               }
          }
          translate([0, 0, key_cutaway_depth]) {
               linear_extrude(100) {
                    centered_square(200);
               }
          }
     }
}


module case_transform () {
     translate([0, case_y_max, case_z_min]) {
          children();
     }
}



module base_transform () {
     case_transform() {
          translate([0, 0, -base_height - base_clearance_z]) {
               scale([1, cosa]) {
                    translate([0, -hull_y1 - case_bezel, 0]) {
                         children();
                    }
               }
          }
     }
}


// Debug modules


module cross_section () {
     if (section) {
          intersection() {
               children();
               if (section == "mid-y") {
                    translate([-50, 0, -50]) {
                         linear_extrude(100) {
                              centered_square(100);
                         }
                    }
               } else if (section == "key-0") {
                    translate([-65, 0, -50]) {
                         linear_extrude(100) {
                              centered_square(100);
                         }
                    }
               } else if (section == "join") {
                    translate([
                                   -ergo_dist_x / 2 - unit * 2,
                                   -unit * .5,
                                   -case_extrusion_depth - base_height
                                   ]) {
                         linear_extrude(5) {
                              centered_square([20, 30]);
                         }
                    }
               }
          }
     } else {
          children();
     }
}


module present () {
     cross_section () {
          children();
     }
}


module echo_measurements() {
     keys_width = hull_x1 * 2;
     total_case_width = keys_width + case_bezel * 2;
     total_pcb_width = keys_width + pcb_border * 2;

     total_base_length = key_cutaway_xy + 2 * case_bezel + rest_length;

     echo();
     echo(str("Case width: ", total_case_width));
     echo(str("PCB width:  ", total_pcb_width));
     echo(str("Base length:  ", total_base_length));

     key_copy(verbose=true);
}


// 2D modules


module hull_keys (border, inside=true, outside=true) {
     // A 2D expanded hull around the keys.
     // See global variable `case_point`.

     // Axis
     xa = ergo_dist_x / 2 + unit;
     ya = unit * -0.5;

     // Corners
     d1 = key_cutaway_xy / 2 + border;
     x1 = key_x1 + d1;
     y1 = d1;

     // Point on diagonal edge
     d2 = (key_cutaway_xy - unit) / 2 + border;
     y2 = ya - cos(ergo_angle) * d2;
     x2 = xa + sin(ergo_angle) * d2;

     // 3/4 intersection
     y3 = -y1;
     x3 = x2 + (y3 - y2) / tan(ergo_angle);

     // Lowest extended key cutaway point
     d4x = (unit + key_cutaway_xy) / 2;
     d4y = (key_cutaway_xy - unit) / 2;
     y4 = ya - d4x * sin(ergo_angle) - d4y * cos(ergo_angle) - border;
     x4 = x2 + (y4 - y2) / tan(ergo_angle);

     // Point

     x5 = 0;
     y5 = y2 + (x5 - x2) * tan(ergo_angle);

     back = outside ? [[x1, -y1], [x1, y1], [-x1, y1], [-x1, -y1]] : [[0, 0]];
     extremity = case_point ? [[x5, y5]] : [[-x4, y4], [x4, y4]];
     front = inside ? concat([[-x3, y3]], extremity, [[x3, y3]]) : [];

     polygon(concat(back, front));
}


module hull_rest () {
     // The 2D bevelled outline of the rest
     // without the case nose subtracted
     // as seen from `typing_angle`.

     // Case total width and height
     x1 = hull_x1 * 2 + 2 * case_bezel;
     y1 = hull_y1 * 2 + 2 * case_bezel;

     translate([0, -y1 / 2 - rest_length + case_bevel]) {
          minkowski() {
               centered_square([x1 - 2 * case_bevel,
                                rest_length - rest_gap - 2 * case_bevel], [-0.5, 0]);
               circle(r=case_bevel);
          }
     }
}


module case_2d (border=case_bezel, bevel=case_bevel) {
     minkowski() {
          hull_keys(border - bevel);
          circle(r=bevel);
     }
}


module rest_2d () {
     border = case_bezel + rest_gap;
     bevel = case_bevel + rest_gap;

     difference() {
          hull_rest();
          case_2d(border=border, bevel=bevel);
     }
}


module base_2d () {
     hull() {
          hull_rest();
          case_2d();
     }
}


module snout_2d (border=case_bezel, bevel=case_bevel) {
     minkowski() {
          intersection() {
               hull_keys(border - bevel);
               translate([0, -(hull_y1 + border - bevel)]) {
                    centered_square([(hull_x1 + border - bevel) * 2, 100], [-0.5, -1]);
               }
          }
          circle(bevel);
     }
}


module pcb_slot_2d (border, dy=0, inside=true, outside=true) {
     union() {
          translate([0, dy]) {
               hull_keys(border, inside=inside, outside=outside);
          }
          translate([0, 10]) {
               hull_keys(border, inside=inside, outside=outside);
          }
     }
}


module pcb_2d (border) {
     union() {
          translate([0, pcb_dy_front]) {
               hull_keys(border);
          }
          translate([0, pcb_dy_back]) {
               hull_keys(border);
          }
     }
}


module plate_2d (border) {
     union() {
          translate([0, plate_dy_front]) {
               hull_keys(border);
          }
          translate([0, 0]) {
               hull_keys(border);
          }
     }
}


module switch_cutout() {
     if (integrated_plate) {
          minkowski() {
               centered_square(switch_cutout_xy + plate_switch_clearance - 2 * plate_switch_r);
               circle(plate_switch_r, $fn=8);
          }
     } else {
          centered_square(switch_cutout_xy);
          for (a = [0, 180]) {
               rotate(a) {
                    translate([0, -switch_cutout_xy / 2 + 1]) {
                         centered_square([15.6, 3.1], [-0.5, 0]);
                    }
               }
          }
     }
}


module switchplate_cuts_2d () {
     key_copy() {
          switch_cutout();
     }
}


module switch_pins_2d () {
     u = 0.05 * 25.4;  // Unit from Cherry MX datasheet (1.27).

     circle(d=3.85, $fn=4);
     for (xy = [[4, 0], [-4, 0]]) {
          translate([u * xy[0], u * xy[1]]) {
               circle(d=1.65, $fn=4);
          }
     }
     for (xy = [[2, 4], [-3, 2]]) {
          translate([u * xy[0], u * xy[1]]) {
               centered_square([1, 0.5]);
          }
     }
}


// 3D modules


module rest_3d (offset=0) {
     module top_chamfer () {
          border = case_bezel + rest_gap;
          bevel = case_bevel + rest_gap;

          hull () {
               for (c = [-1, 1]) {
                    translate([rest_chamfer_x * c, 0, key_cutaway_depth]) {
                         linear_extrude(1) {
                              snout_2d(border=border, bevel=bevel);
                         }
                    }
               }
               translate([0, 0, key_cutaway_depth - rest_chamfer_z]) {
                    linear_extrude(1) {
                         snout_2d(border=border, bevel=bevel);
                    }
               }
          }
     }

     rotate([typing_angle, 0]) {
          difference() {
               case_extrude(offset=offset) {
                    rest_2d();
               }
               top_chamfer();
          }
     }
}


module base_clip (ty=0, inset_y=0, inset_z=0) {
     // `inset_z` lowers the top of the clip, reducing its height.
     edge_x = hull_x1 + pcb_inner;

     case_transform() {
          translate([-edge_x, base_clip_ty + ty, 0]) {
               hull() {
                    translate([0, 0, base_clip_size]) {
                         linear_extrude(base_clip_size - inset_z) {
                              centered_square([
                                                   base_clip_size,
                                                   base_clip_length - (base_clip_size + inset_y) * 2
                                                   ], [0, -0.5]);
                         }
                    }
                    linear_extrude(base_clip_size * 3 - inset_z) {
                         centered_square([
                                              base_clip_size,
                                              base_clip_length - (inset_y) * 2,
                                              ], [-1, -0.5]);
                    }
               }
          }
     }
}


module cavity_pos(offset_xy = -base_clearance_xy) {
     depth = integrated_plate ? -plate_thickness : 1;
     intersection() {
          rotate([typing_angle, 0]) {
               translate([0, 0, -case_extrusion_depth * 2]) {
                    linear_extrude(case_extrusion_depth * 2 + depth - base_clearance_back_z) {
                         pcb_slot_2d(pcb_inner + offset_xy, dy=pcb_dy_front);
                    }
               }
          }
          case_transform() {
               translate([0, 0, -base_clearance_z - overlap]) {
                    linear_extrude(50) {
                         centered_square(120);
                    }
               }
          }
     }
}


module base_back () {
     edge_x = hull_x1 + pcb_inner - base_clearance_xy;


     // Front position of the slot:
     sldy = -(hull_y1 - pcb_dy_front - base_clearance_xy);
     sldz = -switch_base_height - pcb_thickness - base_clearance_xy;
     sly = cosa * sldy - sina * sldz;
     slz = sina * sldy + cosa * sldz - 1.5;
     ch = 10;
     px = hull_x1 - base_clip_size - base_clearance_xy;
     pz = 2 * base_clip_size + base_clip_overlap * 2 + base_clearance_z * 1.5;

     module back_chamfer () {
          case_transform() {
               translate([0, 0, pz + base_back_thickness]) {
                    rotate([135, 0, 0]) {
                         linear_extrude(ch) {
                              centered_square([px * 2, ch], [-0.5, -1]);
                         }
                    }
               }
          }
     }

     module side_chamfer_angle () {
          translate([-px, sly, slz]) {
               rotate([135, -typing_angle - 9, 90]) {
                    linear_extrude(ch) {
                         translate([0, 0, 0]) {
                              centered_square([key_cutaway_xy * 1.5, ch], [0, -1]);
                         }
                    }
               }
          }
     }

     module side_chamfer_clip () {
          case_transform() {
               translate([-px, 0, pz]) {
                    rotate([135, 0, -90]) {
                         linear_extrude(ch) {
                              centered_square([key_cutaway_xy * 1.5, ch], [0, -1]);
                         }
                    }
               }
          }
     }

     module back_plate (thickness) {
          case_transform() {
               translate([0, 0, -base_clearance_z - overlap]) {
                    linear_extrude(case_extrusion_depth + 3) {
                         centered_square([hull_x1 * 2, thickness], [-0.5, -1]);
                    }
               }
          }
     }


     for (sx = [-1, 1]) {
          scale([sx, 1, 1]) {
               difference() {
                    intersection() {
                         side_chamfer_angle();
                         side_chamfer_clip();
                         cavity_pos();
                    }
                    translate([base_clearance_xy, 0, 0]) {
                         base_clip(
                              ty=base_clip_neg_ty,
                              inset_y=base_clip_neg_inset_y,
                              inset_z=base_clip_neg_inset_z
                              );
                    }
               }
          }
     }
     intersection() {
          back_chamfer();
          back_plate(10);
          cavity_pos();
     }
     intersection() {
          back_plate(base_back_thickness);
          cavity_pos();
     }

}


module base_3d (rest=true) {
     base_rest = rest;

     module rest_plate () {
          base_transform() {
               translate([0, 0, base_height - overlap]) {
                    linear_extrude(overlap) {
                         intersection() {
                              rest_2d();
                              translate([0, -base_rest_chamfer - overlap, 0]) {
                                   rest_2d();
                              }
                         }
                    }
               }
          }
     }


     module rest_chamfered_3 (chamfer) {
          // Back of rest 2D to origin:
          y1 = (hull_y2 + rest_gap);
          // Back of base 3D to back of rest 3D:
          y2 = -(hull_y2 * 2 + rest_gap) * cosa;
          z2 = -base_clearance_z;

          intersection() {
               rest_3d(base_clearance_z + overlap);
               case_transform() {
                    translate([0, y2, z2 + overlap + chamfer]) {
                         rotate([-45, 0, 0]) {
                              scale([1, cos(45) * cosa, 1]) {
                                   translate([0, 0, -50]) {
                                        linear_extrude(100) {
                                             translate([0, y1, 0]) {
                                                  rest_2d();
                                             }
                                             translate([0, -rest_length / 2, 0]) {
                                                  centered_square(100, [-0.5, -1]);
                                             }
                                        }
                                   }
                              }
                         }
                    }
               }
          }
     }


     difference() {
          union () {
               base_back();
               if (base_rest) {
                    base_transform() {
                         linear_extrude(base_height) {
                              base_2d();
                         }
                    }
                    rest_chamfered_3(base_rest_chamfer);
               } else {
                    intersection() {
                         base_transform() {
                              linear_extrude(base_height * 2) {
                                   intersection() {
                                        case_2d();
                                        centered_square(
                                             (key_x1 + pcb_inner - base_clip_size - base_clearance_xy) * 2
                                             + key_cutaway_xy);
                                   }
                              }
                              linear_extrude(base_height * 4.0) {
                                   intersection() {
                                        difference() {
                                             case_2d();
                                             intersection() {
                                             union() {
                                                  case_2d(-1);
                                                  centered_square([24, 100]);
                                                  translate([35, 0]) {
                                                       centered_square([14, 100]);
                                                  }
                                                  translate([-35, 0]) {
                                                       centered_square([14, 100]);
                                                  }
                                                  centered_square([100, 100], [-0.5, 0]);
                                             }
                                                  centered_square([86, 100]);
                                             }
                                        }
                                        centered_square(
                                             (key_x1 + pcb_inner - base_clip_size - base_clearance_xy) * 2
                                             + key_cutaway_xy);
                                   }
                              }
                         }
                         cavity_pos();
                    }
               }
          }
          union() {
          usb_3d();
          translate([0, 0, -0.4]) {
               pcb_3d();
          }
          }
     }

}


module switches_3d () {
     module switch () {
          linear_extrude(1) {
               centered_square(15.75);
          }
          hull() {
               linear_extrude(1) {
                    centered_square(14);
               }
               translate([0, 0, -switch_base_height]) {
                    linear_extrude(1) {
                         centered_square(13);
                    }
               }
          }
          hull () {
               linear_extrude(1) {
                    centered_square([10, 13]);
               }
               translate([0, 2, 6.85 - 1])
                    linear_extrude(1) {
                    centered_square(10);
               }
          }
          translate([0, 0, -switch_base_height - switch_pin_height]) {
               linear_extrude(switch_base_height) {
                    switch_pins_2d();
               }
          }
     }

     rotate([typing_angle, 0]) {
          key_copy() {
               switch();
          }
     }
}


module keys_3d () {
     key_xy_base = 18.5;
     key_xy_top = 12;
     key_z = 12;
     key_top_angle = 7;

     rotate([typing_angle, 0]) {
          key_copy() {
               translate([0, 0, 6]) {
                    hull () {
                         linear_extrude(1) {
                              centered_square(key_xy_base);
                         }
                         translate([0, 0, key_z - 1]) {
                              rotate([key_top_angle, 0, 0]) {
                                   linear_extrude(1) {
                                        centered_square(key_xy_top);
                                   }
                              }
                         }
                    }

               }
          }
     }
}


module case_3d () {
     pcb_depth = pcb_top_depth - pcb_thickness;
     plate_depth = -plate_thickness;

     module pcb_cavity () {
          if (integrated_plate) {
               translate([0, 0, -case_extrusion_depth * 2 - overlap]) {
                    linear_extrude(case_extrusion_depth * 2 + overlap - plate_thickness) {
                         pcb_slot_2d(pcb_inner, dy=pcb_dy_front);
                    }
               }
          } else {
               translate([0, 0, plate_depth - case_extrusion_depth]) {
                    linear_extrude(case_extrusion_depth) {
                         pcb_slot_2d(pcb_inner, dy=plate_dy_front);
                    }
               }
               translate([0, 0, pcb_depth - case_extrusion_depth]) {
                    linear_extrude(case_extrusion_depth) {
                         pcb_slot_2d(pcb_inner, dy=pcb_dy_front);
                    }
               }
          }
     }

     module pcb_slot (depth, height, dy, outer, inner) {
          // Add Z clearance below only since there is already a chamfer above:
          total_depth = depth -pcb_slot_clearance_z;
          total_height = height + pcb_slot_clearance_z;  // Slot height
          chamfer = outer - inner;

          translate([0, 0, total_depth]) {
               for (io = [[false, true], [true, false]]) {
                    hull() {
                         linear_extrude(total_height) {
                              pcb_slot_2d(outer, dy=dy,
                                          inside=io[0], outside=io[1]);
                         }
                         linear_extrude(total_height + chamfer) {
                              pcb_slot_2d(inner, dy=dy,
                                          inside=io[0], outside=io[1]);
                         }
                    }
               }
          }
     }

     module plate_cuts () {
          translate([0, 0, -plate_thickness - overlap]) {
               linear_extrude(plate_thickness + overlap * 2) {
                    switchplate_cuts_2d();
               }
          }
     }

     module key_cutaway () {
          linear_extrude(key_cutaway_depth + overlap) {
               key_cutaway_2d(key_cutaway_xy, bevel=key_cutaway_bevel);
          }
     }

     module top_chamfer () {
          case_transform() {
               translate([0, overlap, case_height - case_chamfer_z]) {
                    linear_extrude(case_chamfer_z + overlap) {
                         centered_square([(hull_x2 + overlap) * 2, 40], [-0.5, -1]);
                    }
               }
          }
     }

     module cavity_neg () {
          key_cutaway();
          pcb_slot(
               depth=pcb_depth,
               height=pcb_thickness,
               dy=pcb_dy_front,
               outer=pcb_outer,
               inner=pcb_outer - 3.4
               );
          pcb_cavity();
          
          if (integrated_plate) {
               plate_cuts();
          } else {
               pcb_slot(
                    depth=plate_depth,,
                    height=plate_thickness,
                    dy=plate_dy_front,
                    outer=pcb_outer,
                    inner=pcb_outer - pcb_slot_clearance_z
                    );
          }
     }
     

     difference() {
          rotate([typing_angle, 0]) {
               difference() {
                    case_extrude() {
                         case_2d();
                    }
                    union () {
                         cavity_neg();
                    }
               }
          }
          top_chamfer();
     }
     for (sx = [-1, 1]) {
          scale([sx, 1, 1]) {
               base_clip();
          }
     }
}


module case_support_block () {
     extend_back = 3;

     intersection() {
          case_transform() {
               linear_extrude(support_block_z) {
                    translate([0, extend_back, 0]) {
                         difference() {
                              centered_square([200, 100], [-0.5, -1]);
                              centered_square([(hull_x1 - support_block_xy_end) * 2, 200], [-0.5, -1]);
                         }
                    }
               }
          }
          union() {
               cavity_pos(offset_xy=-support_block_xy_start);
               case_transform() {
                    linear_extrude(support_block_z) {
                         translate([0, support_block_xy_start]) {
                              centered_square([hull_x2 * 2, extend_back], [-0.5, 0]);
                         }
                    }
               }
          }
     }
}


module key_cutaway_2d (s, bevel) {
     s2 = s - bevel * 2;
     minkowski() {
          union() {
               key_copy(outside=false) {
                    centered_square(s2);
               }
               translate([-unit - ergo_dist_x / 2, -unit / 2]) {
                    rotate(-ergo_angle) {
                         translate([unit / 2, unit / 2]) {
                              centered_square([unit, s2 / 2], [-1, -1]);
                         }
                    }
               }
               translate([unit + ergo_dist_x / 2, -unit / 2]) {
                    rotate(ergo_angle) {
                         translate([unit / 2, unit / 2]) {
                              centered_square([unit, s2 / 2], [-1, -1]);
                         }
                    }
               }
               for (lr = [[true, false], [false, true]]) {
                    hull() {
                         difference() {
                              key_copy(left=lr[0], right=lr[1]) {
                                   centered_square(s2);
                              }
                              translate([0, -s2 / 2, 0]) {
                                   centered_square(1000, t=[-0.5, -1]);
                              }
                         }
                    }
               }
          }
          circle(r=bevel);
     }
}


module pcb_3d () {
     rotate([typing_angle, 0]) {
          translate([0, 0, -switch_base_height -pcb_thickness]) {
               linear_extrude(pcb_thickness) {
                    pcb_2d(pcb_border);
               }
          }
     }
}


module plate_3d () {
     rotate([typing_angle, 0]) {
          translate([0, 0, -plate_thickness]) {
               linear_extrude(plate_thickness) {
                    difference() {
                         plate_2d(pcb_border);
                         switchplate_cuts_2d();
                    }
               }
          }
     }
}


module usb_3d () {
     bevel = 2;
          translate([
                         0,
                         0,
                         -switch_base_height -pcb_thickness + 5.34
                         ]) {
               rotate([-90, 0, 0]) {
                    linear_extrude(20) {
                         minkowski() {
                              centered_square([base_usb_port_width - bevel * 2, 18 - bevel * 2]);
                              circle(r=bevel, $fn=32);
                         }
                    }
               }
          }
}



if (debug_measurements) {
     echo_measurements();
}
