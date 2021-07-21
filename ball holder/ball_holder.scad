$fn=100;

outer_dim = 30;
inner_dim = 20;
holder_height = 10;
b1 = (outer_dim - inner_dim)/2;
theta = atan2(holder_height, b1);
c_height = tan(theta) * outer_dim/2;

//import("text.stl");

difference() {
    cylinder(c_height, d1=outer_dim, d2=0);
    
    rotate([180, 0, 0])
    translate([0, 0, -holder_height])
    cylinder((inner_dim/2)*tan(theta), d1 = inner_dim, d2=0);
    
    translate([-outer_dim/2, -outer_dim/2, holder_height-0.1])
    cube([outer_dim, outer_dim, 100]);
}