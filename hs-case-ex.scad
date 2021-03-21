// All dimensions are in millimeters

// Adjust to account for printer accuracy
allow_h = 0.4; // total horizontal allowance for PCB fit
prong_adjust = -0.3; // adjust prong height by this value for friction fit

enable_led_cutout = true; // disable if not needed

// PCB dimensions
board_w = 14; // width
board_l = 40; // length
board_t = 1.6; // thickness
board_c = 2.5; // chamfer distance from edge
board_e = 0.6; // distance from board top edge to closest component (includes allowance)

// Debug connector dimensions
dbg_h = 3; // height of base
dbg_l = 6; // length of cutout
dbg_w = 30; // width of cutout
dbg_x = 4.3; // center X
dbg_y = 5.5; // center Y

// USB connector dimensions
usb_w = 9 + 0.8; // width + allowance
usb_h = 3 + 0.8; // height + allowance
usb_o = 0.6; // overhang == right wall thickness
//usb_a = 0.8; // hole allowance

// LED dimensions
led_x = 10.5; // center X
led_y = 12.5; // center Y
led_s = 1.6; // cutout size

part_h = usb_h + 1; // height of tallest part on board (includes allowance for droop)

// Case dimensions
wall_t = 1.5; // general wall thickness
corner_r = 0.75; // outside corner radius (more like chamfer) (must be less than wall_t)

// Endcap dimensions
prong_w = 1.5; // width of prongs
prong_l = 35; // length of prongs

prong_c = (prong_w - board_e); // prong cutout width

case_w = board_w + wall_t*2 + prong_c*2; // total case width

E = 0.001; // Tiny size (epsilon)
L = 100; // Huge size (bigger than anything in model)

$fn = 90;

// Reference board (remove * to show, n.b. it's a bit slow)
* color("green")
	translate([0, 0, 2*E])
		scale([25.4, 25.4, 25.4])
			import("hs-probe-pcb.stl");

// Case with solid endcap
module solid_case() {
	module exterior_perimeter(l) {
		// Bottom
		translate([0, 0, -(wall_t - corner_r)])
			rotate(90, [0, 1, 0])
				cylinder(r=corner_r, h=l + usb_o, $fn=4);

		// Top			
		translate([0, 0, board_t + part_h + (wall_t - corner_r)])
			rotate(90, [0, 1, 0])
				cylinder(r=corner_r, h=l + usb_o, $fn=4);
	}
  
  // Text
  translate([14.5, board_w/2, board_t + part_h + wall_t - E])
    scale([0.6, 1, 1])
      linear_extrude(0.5)
        text("HS-P", font="Liberation Sans", valign="center");
	
	difference() {
		// Case exterior
		translate([-wall_t - allow_h, 0, 0]) hull() {
			offset = wall_t - corner_r + prong_c;
			
			// Left main
			translate([0, -offset, 0])
				exterior_perimeter(board_l + wall_t + allow_h - board_c);
			
			// Right main
			translate([0, board_w + offset, 0])
				exterior_perimeter(board_l + wall_t + allow_h - board_c);
			
			// Left chamfer
			translate([0, board_c - offset, 0])
				exterior_perimeter(board_l + wall_t + allow_h);
			
			// Right chamfer
			translate([0, board_w - board_c + offset, 0])
				exterior_perimeter(board_l + wall_t + allow_h);
		}
		
		// Space to cut out for board
		union() {
			// PCB and component space
			hull() {
				translate([-allow_h, -allow_h/2, 0])
					cube([
						board_l - board_c + allow_h,
						board_w + allow_h,
						board_t + part_h]);
				
			  translate([-allow_h, board_c - allow_h/2, 0])
					cube([
						board_l + allow_h,
						board_w - board_c*2 + allow_h,
						board_t + part_h]);
			}
			
			// Endcap prong cutout
			translate([0, -(prong_w - board_e), board_t + E])
				cube([
					prong_l + 1,
					board_w + 2*(prong_w - board_e),
					part_h]);
			
			// Cutout below PCB for better sliding
			/*translate([-allow_h, board_c, -0.25])
				cube([
					board_l + allow_h,
					board_w - board_c*2 + allow_h,
					0.25]);*/

			// USB connector
			
      translate([board_l - 10, (board_w - usb_w)/2, board_t + 1.8 - usb_h/2])
        cube([20, usb_w, usb_h]);
      
      /*translate([board_l - 10, 0, board_t + usb_h/2])
				hull() {
					translate([0, board_w/2 - (usb_w/2 - usb_h/2), 0])
						rotate(90, [0, 1, 0])
							cylinder(d=usb_h + usb_a, h=20, $fn=45);
					
					translate([0, board_w/2 + (usb_w/2 - usb_h/2), 0])
						rotate(90, [0, 1, 0])
							cylinder(d=usb_h + usb_a, h=20, $fn=45);
				}*/
			
			// Debug connector
			dbg_cutout();
      
      if (enable_led_cutout) {
        // LED cutout
        translate([led_x - led_s/2, led_y - led_s/2, board_t - E])
          cube([led_s, led_s, 50]);
        
        // Extra LED cutout to ensure bridgeability
        translate([led_x - led_s/2, -prong_c, board_t - E])
          cube([led_s, board_w + prong_c*2, part_h + wall_t/2]);
      }
		}
	}
}

// Debug connector cutout
module dbg_cutout() {
	translate([dbg_x - (dbg_l/2), dbg_y - (dbg_w/2), board_t + dbg_h + E])
		cube([dbg_l, dbg_w, 20]);
}

// Volume that defines part of solid_case to cut off for endcap
module endcap_cut() {
	translate([dbg_x + (dbg_l/2) - L - E, -L/2, board_t])
		cube([L, L, L]);
}

module endcap() {
	// Cut off part of solid case for endcap
	intersection() {
		solid_case();
		translate([-0.2, 0, 0]) endcap_cut();
	}
		
	// Locking prongs	
	difference() {
		union() {
			translate([-wall_t - E, board_e - prong_w, board_t])
				cube([prong_l + wall_t, prong_w, part_h + prong_adjust]);
			
			translate([-wall_t - E, board_w - board_e, board_t])
				cube([prong_l + wall_t, prong_w, part_h + prong_adjust]);
		}
		
		dbg_cutout();
	}
  
  // End reinforcement
  translate([-(wall_t + allow_h), -(wall_t + prong_c), board_t + 1.6])
    cube([dbg_x - (dbg_l/2) + wall_t + allow_h, case_w, part_h - 1.6 + E]);
}

module case() {
	// Remove endcap from solid case
	difference() {
		solid_case();
		endcap_cut();
	}
}

module view_assembled() {
	case();
	translate([0, 0, 0.2]) endcap();
}

module view_print() {
	translate([0, 0, wall_t]) {
		case();
		
		translate([0, -(case_w + 2), -(board_t + wall_t)])
			endcap();
	}
}

module view_cross_section(h) {
	difference() {
		case();
		translate([-L/2, -L/2, h]) cube([L, L, L]);
	}
}

view_print();
* view_assembled();
* view_cross_section(5);

echo(total_case_width=case_w);