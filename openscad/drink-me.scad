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

// User variables

pcb_thickness = 2;
pcb_slot_clearance_xy = 0.25;
pcb_slot_clearance_z = 0.4;
pcb_slot_overlap = 1;

base_bump_clearance_xy = 0.25;


// Debug variables

section = false;
/* section = "mid-y"; */
/* section = "key-0"; */
/* section = "join"; */


// Constants

unit = 19.05;
overlap = 0.1;


// Design variables

key = 18.05;

center_dist = 16;
ergo_angle = 15;
pcb_border = 1.75;
border_case = 5;
bevel_case = 1;

case_angle = 8;
rest_gap = 0.5;
rest_length = 25;

height_case = 8;
plate_height = 1.2;
profile_xy = 20;
profile_bevel = 0.5;
base_height = 1;

_depth_profile = 7.5;
_thick_plate = 1.2;
_depth_switch = 5;

pcb_outer = pcb_border + pcb_slot_clearance_xy;
pcb_inner = pcb_border - pcb_slot_overlap;

_low_switch = 6.5;
_height_case = 20; // ?

extrude_down = 11;


// Manual update variables

pcb_dy_lo = -3;
pcb_dy_hi = -1;

base_bump_dy = 1.3;
base_bump_h = 1.5;
base_back_height = 12.25;
base_back_thickness = 3;


// KiCAD variables

origin_x = 74;
origin_y = 74;


module _profile_2d(); // Key cutaways
module _switch_2d(); // Switch cutouts
module _case_inner_2d(); // Outer size of PCB minus shelf groove depth


depth = key + border_case * 2;
ex_height = depth * tan(case_angle);



total_x = center_dist + unit * 3 + key + border_case * 2;
echo("");
echo(str("Total width: ", total_x));



module centered_square (s, t=[-0.5, -0.5]) {
     scale(s) {
          translate(t) {
               square(1);
          }
     }
}


module key_copy (outside=true, inside=true, left=true, right=true, verbose=false) {
     x1 = center_dist / 2 + unit * 1.5;
     y1 = 0;
     x2r = center_dist / 2 + unit;
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
                    translate([-75, 0, -50]) {
                         linear_extrude(100) {
                              centered_square(100);
                         }
                    }
               } else if (section == "join") {
                    translate([-center_dist / 2 - unit * 2, -unit * .5 - border_case, -extrude_down - base_height]) {
                         linear_extrude(5) {
                              centered_square(20);
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

module hull_keys (border, point=true, inside=true, outside=true) {
     dist = center_dist / 2 + unit;
     down = dist * sin(ergo_angle) + border * cos(ergo_angle);
     
     union() {
          if (inside) {
               hull() {
                    difference() {
                         key_copy(outside=false) {
                              centered_square(key + border * 2);
                         }
                         centered_square(1000, t=[-0.5, 0]);
                    }
                    if (point) {
                         translate([0, -unit * 0.5 - down]) {
                              rotate(45) {
                                   square(1);
                              }
                         }
                    }
               }
          }
          if (outside) {
               hull() {
                    key_copy(inside=false) {
                         centered_square(key + border * 2);
                    }
               }
          }
     }
}


module hull_rest (border, point=true) {
     y = rest_length - bevel_case * 2 - rest_gap;
     x = center_dist + 3 * unit + key + 2 * border_case - 2 * bevel_case;
     dy = -key / 2 - border_case - bevel_case - rest_gap;
     translate([0, dy]) {
          centered_square([x, y], [-0.5, -1]);
     }
}


module case_2d () {
     minkowski() {
          hull_keys(border_case - bevel_case);
          circle(r=bevel_case, $fn=16);
     }
}


module rest_2d () {
     difference() {
          minkowski() {
               hull_rest(border_case - bevel_case);
               circle(r=bevel_case, $fn=16);
          }
          translate([0, -rest_gap]) {
               case_2d();
          }
     }
}


module base_2d () {
     hull() {
          minkowski() {
               hull_rest(border_case - bevel_case);
               circle(r=bevel_case, $fn=16);
          }
          case_2d();
     }
}


module pcb_slot_2d (border, inside=true, outside=true) {
     union() {
          translate([0, -3]) {
               hull_keys(border, inside=inside, outside=outside);
          }
          translate([0, 15]) {
               hull_keys(border, inside=inside, outside=outside);
          }
     }
}


module pcb_2d (border) {
     union() {
          translate([0, pcb_dy_lo]) {
               hull_keys(border);
          }
          translate([0, pcb_dy_hi]) {
               hull_keys(border);
          }
     }
}


module rest_3d () {
     rotate([case_angle, 0]) {
          case_extrude() {
               rest_2d();
          }
     }
}


module base_3d () {
     dy = -sin(case_angle) * _depth_profile;
     d = 4;
     sy = cos(case_angle);
     edge_x = center_dist / 2 + unit * 1.5 + key * 0.5 + pcb_inner - d / 2 - base_bump_clearance_xy;
     edge_y = key * 0.5 * sy + base_bump_dy - d / 2 - base_bump_clearance_xy;

     difference() {
          translate([0, dy, -extrude_down - base_height]) {
               linear_extrude(base_height) {
                    scale([1, sy]) {
                         hull() {
                              rest_2d();
                              case_2d();
                         }
                    }
               }
               translate([0, (key / 2 + border_case) * sy, 0]) {
                    hull() {
                         linear_extrude(base_back_height) {
                              centered_square([2 * edge_x + d, 1], [-0.5, -1]);
                         }
                         linear_extrude(1) {
                              centered_square([2 * edge_x + d, base_back_thickness], [-0.5, -1]);
                         }
                    }
               }
               
                                   
               for (px = [-1, 1]) {
                    for (py = -1) {
                         translate([px * edge_x, py * edge_y, 0]) {
                              cylinder(d=d, h=base_height + base_bump_h, $fn=16);
                         }
                    }
               }
          }
          usb_3d();
     }
}


module case_extrude (offset=0) {
     difference() {
          translate([0, -sin(case_angle) * _depth_profile, 0]) {
               rotate([-case_angle, 0, 0]) {
                    translate([0, 0, -extrude_down - offset]) {
                         linear_extrude(1000) {
                              scale([1, cos(case_angle)]) {
                                   children();
                              }
                         }
                    }
               }
          }
          translate([0, 0, _depth_profile]) {
               linear_extrude(1000) {
                    centered_square(1000);
               }
          }
     }
}


module switch_holes () {
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


module switches_3d () {
     module switch () {
          linear_extrude(1) {
               centered_square(15.75);
          }
          hull() {
               linear_extrude(1) {
                    centered_square(14);
               }
               translate([0, 0, -_depth_switch]) {
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
          translate([0, 0, -_depth_switch - 3.25]) {
               linear_extrude(_depth_switch) {
                    switch_holes();
               }
          }
     } 

     rotate([case_angle, 0]) {
          key_copy() {
               switch();
          }
     }
}


module keys_3d () {
     rotate([case_angle, 0]) {
          key_copy() {
               translate([0, 0, 6]) {
                    hull () {
                         linear_extrude(1) {
                              centered_square(key);
                         }
                         translate([0, 0, 12 - 1]) {
                         rotate([7, 0, 0]) {
                              linear_extrude(1) {
                                   centered_square(12);
                              }
                         }
                         }
                    }
                    
               }
          }
     }
}


module case_3d () {
     out = 0.5;
     swx = 14;
     swy = 13.8;

     module pcb_cavity () {
          translate([0, 0, -extrude_down * 2 - overlap]) {
               linear_extrude(extrude_down * 2 + overlap - _thick_plate) {
                    pcb_slot_2d(pcb_inner);
               }
          }
     }

     module pcb_slot () {
          slot_depth = -_depth_switch - pcb_thickness - pcb_slot_clearance_z;

          // Add Z clearance below only since there is already a chamfer above:
          height = pcb_thickness + pcb_slot_clearance_z;  // Slot height
          chamfer = pcb_outer - pcb_inner;  // Chamfer distance
          
          translate([0, 0, slot_depth]) {
               for (io = [[false, true], [true, false]]) {
                    hull() {
                         linear_extrude(height) {
                              pcb_slot_2d(pcb_outer, inside=io[0], outside=io[1]);
                         }
                         linear_extrude(height + chamfer) {
                              pcb_slot_2d(pcb_inner, inside=io[0], outside=io[1]);
                         }
                    }
               }
          }
     }

     module plate_cuts () {
                    key_copy() {
                         translate([0, 0, -_thick_plate - overlap]) {
                              linear_extrude(_thick_plate + overlap * 2) {
                                   centered_square([swx + out, swy + out]);
                              }
                         }
                    }
     }

     module key_cutaway () {
          linear_extrude(_depth_profile + overlap) {
               key_cutaway_2d(profile_xy, bevel=profile_bevel);
          }
     }
     
     rotate([case_angle, 0]) {
          difference() {
               case_extrude() {
                    case_2d();
               }
               union () {
                    key_cutaway();
                    plate_cuts();
                    pcb_cavity();
                    pcb_slot();
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
               translate([-unit - center_dist / 2, -unit / 2]) {
                    rotate(-ergo_angle) {
                         translate([unit / 2, unit / 2]) {
                              centered_square([unit, s2 / 2], [-1, -1]);
                         }
                    }
               }
               translate([unit + center_dist / 2, -unit / 2]) {
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
          circle(r=bevel, $fn=16);
     }
}


module pcb_3d () {
     rotate([case_angle, 0]) {
          translate([0, 0, -_depth_switch -pcb_thickness]) {
               linear_extrude(pcb_thickness) {
                    pcb_2d(pcb_border);
               }
          }
     }
}


module usb_3d () {
     rotate([case_angle, 0]) {
          translate([0, key / 2 - 2, -_depth_switch -pcb_thickness -4]) {
               rotate([-90, 0, 0]) {
                    linear_extrude(key) {
                         minkowski() {
                              centered_square([8, base_back_height], [-0.5, -1]);
                              circle(r=1, $fn=32);
                         }
                    }
               }
          }
     }
}


