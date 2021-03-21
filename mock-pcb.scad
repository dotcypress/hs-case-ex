$fn = 90;

E = 0.001;

// Reference board (remove * to show, n.b. it's a bit slow)
*color("green")
  translate([0, 0, 0])
    scale([25.4, 25.4, 25.4])
      import("hs-probe-pcb.stl");

cube([40, 14, 1.6]);


translate([33.2, 7, 3.35]) hull() for(i = [
  [-1, -1],
  [+1, -1],
  [-1, +1],
  [+1, +1],
]) {
  translate([0, i[0] * 3.4, i[1] * 0.5])
    rotate(90, [0, 1, 0])
      cylinder(r=1, h=7.7);
}

#translate([33.2, 2.6, 1.6 - E]) cube([6.8, 8.8, 2]);

translate([13.5, 2, 1.6 - E]) cube([10, 10, 0.8]);

difference() {
  translate([1.7, 1.1, 1.6 - E]) cube([5.2, 8.8, 6.2]);

  translate([2.5, 0, 4]) cube([3.5, 20, 6.2]);
}