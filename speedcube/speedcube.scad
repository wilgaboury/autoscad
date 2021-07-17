// Global Constants
$fn=25;

side_len = 57;
tolerance = 0.1;
layer_outer_radius = 25;
layer_width = 3;
center_ring_diam = 32;

// Helper Contants
center = [side_len / 2, side_len / 2, side_len / 2];

// Helper Functions
// None here yet

// Helper Modules
module layer_hollow_sphere(layer) {
    difference() {
        translate(center)
        sphere(r = layer_outer_radius - (layer - 1) * layer_width - tolerance/2);
        translate(center)
        sphere(r = layer_outer_radius - layer * layer_width + tolerance/2);
    }
}
module oval(w,h, height, center = false) {
    scale([1, h/w, 1]) 
    cylinder(h=height, r=w, center=center);
}
module oval_cone(w,h, height, center = false) {
    scale([1, h/w, 1]) 
    cylinder(h=height, r1=w, r2=0, center=center);
}
module rotate_about_pt(rot, pt) {
    translate(pt)
        rotate(rot)
            translate(-pt)
                children();   
}


core_diameter = side_len/3 - tolerance;
core_width = 8;
hole_diam = 2.5;
module Core() {
    translate(center) {
        difference() {
            union() {
                cylinder(core_diameter, d=core_width, center=true);
                rotate([0, 90, 0])
                cylinder(core_diameter, d=core_width, center=true);
                rotate([90, 0, 0])
                cylinder(core_diameter, d=core_width, center=true);
            }
            union() {
                cylinder(core_diameter+1, d=hole_diam, center=true);
                rotate([0, 90, 0])
                cylinder(core_diameter+1, d=hole_diam, center=true);
                rotate([90, 0, 0])
                cylinder(core_diameter+1, d=hole_diam, center=true);
            }
        }
    }
}

module CenterPiece() {
    screw_shaft_diam = 4;
    screw_spring_diam = 6;
    screw_spring_len = 6;
    screw_head_diam = 8;
    screw_head_len = 4;
    
    difference() {
        union() {
            intersection() {
                layer_hollow_sphere(1);
                translate([side_len/2, side_len/2, 0])
                cylinder(side_len/2, d1=center_ring_diam, d2=0);
            }
            difference() {
                translate([side_len/2, side_len/2, 0])
                cylinder(side_len/2, d = side_len/3 - tolerance/2);
                
                translate(center)
                sphere(layer_outer_radius - tolerance/2);
            }
            translate([side_len/2, side_len/2, 0])
            cylinder(side_len/3-tolerance/2, d = 8);
        }
        
        translate([side_len/2, side_len/2, -1])
        union() {
            cylinder(screw_head_len+1, d=screw_head_diam);
            cylinder(screw_spring_len+1, d=screw_spring_diam);
            cylinder(side_len+1, d=screw_shaft_diam);
        }
    }
}

module EdgePiece() {
    module L1WeirdOval() {
        square_cross_axis_len = sqrt(2*side_len^2);
        oval_x = center_ring_diam/2; // TODO: this is not correct
        oval_y = sqrt(2*((side_len-center_ring_diam)/2)^2)/2;
        yz_move_len = oval_y;
        yz_move_part = sqrt(yz_move_len^2/2);
        oval_len = square_cross_axis_len/2 - yz_move_len;
        
        translate([side_len/2, yz_move_part, yz_move_part])
        rotate([-45, 0, 0])
        oval_cone(oval_x, oval_y-tolerance, oval_len-tolerance);
    }
    
    module OuterCube(inner_tol) {
        difference() {
            translate([side_len/3+tolerance, 0, 0])
            cube([side_len/3-tolerance, side_len/3-tolerance/2, side_len/3-tolerance/2]);
            
            translate(center)
            sphere(layer_outer_radius+inner_tol);
        }
    }
    
    module InnerOval() {
        oval_x = 4;
        oval_y = 8;
        
        translate([side_len/2, 0, 0])
        rotate([-45, 0, 0])
        oval(oval_x, oval_y, side_len/2);
    }
    
    union() {
        intersection() {
            L1WeirdOval();
            layer_hollow_sphere(1);
        }
        
        intersection() {
            L1WeirdOval();
            OuterCube(-tolerance/2);
        }
        
        OuterCube(tolerance/2);
        
        intersection() {
            InnerOval();
            layer_hollow_sphere(2);
        }
        
        difference() {
            intersection() {
                L1WeirdOval();
                InnerOval();
            }
            
            translate(center)
            sphere(layer_outer_radius-layer_width-tolerance/2);
        }
    }
}



module CornerPiece() {
    union() {
        difference() {
            cube([side_len/3-tolerance/2,side_len/3-tolerance/2,side_len/3-tolerance/2]);
            
            translate(center)
            sphere(layer_outer_radius+tolerance/2);
        }
        
        difference() {
            translate([side_len/4, side_len/4, side_len/4])
            rotate([-atan(sqrt(2)), 0, -45])
            cylinder(side_len/2, d=4);
            
            translate(center)
            sphere(layer_outer_radius-layer_width*2+tolerance/2);
        }
        
        difference() {
            layer_hollow_sphere(2);
            
            translate([side_len/2-core_width/2-tolerance, 0, 0])
            cube(side_len);
            
            translate([0, side_len/2-core_width/2-tolerance, 0])
            cube(side_len);
            
            translate([0, 0, side_len/2-core_width/2-tolerance])
            cube(side_len);
        }
        
    }
}


Core();
CenterPiece();
EdgePiece();
CornerPiece();