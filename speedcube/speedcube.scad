// Global Constants
$fn=50;

small_number=0.000;

side_len = 56;
tolerance = 0.25;
layer_outer_radius=23;
layer_width = 3;
center_ring_diam = 29.2;

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


core_diameter = side_len/3;
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
screw_head_diam = 8;
screw_head_len = 4;
screw_spring_diam = 5.5;
screw_spring_len = 4;
screw_shaft_diam = 3.5;
shaft_len = side_len/3 - 1.5;
shaft_diam = 10;

cap_height = 2;
cap_lip_height = 2.5;
cap_lip_diam = 15;
cap_lip_width = 1;
cap_lip_tol = 0;
cap_top_tol = 0.5;
cap_cutout_width = 5;
cap_cutout_height = 1;
cap_cutout_depth = 1.5;

module CenterCap() {
    translate([side_len/2, side_len/2, 0])
    
    union() {
        difference() {
            cylinder(cap_height, d=side_len/3-tolerance);
            
            translate([-cap_cutout_width/2, side_len/6-cap_cutout_depth, cap_height-cap_cutout_height])
            cube([cap_cutout_width, side_len, cap_cutout_height+1]);
        }
        
        difference() {
            cylinder(cap_height+cap_lip_height-cap_lip_width/2, d=cap_lip_diam);
            cylinder(cap_height+cap_lip_height+1, d=cap_lip_diam-cap_lip_width*2);
        }
        
        translate([0,0,cap_height+cap_lip_height-cap_lip_width/2])
        rotate_extrude(convexity=10)
        translate([cap_lip_diam/2-cap_lip_width/2, 0, 0])
        circle(cap_lip_width/2);
        
    }
}

module CenterPiece() {
    difference() {
        union() {
            intersection() {
                layer_hollow_sphere(1);
                translate([side_len/2, side_len/2, 0])
                cylinder(side_len/2, d1=center_ring_diam, d2=0);
            }
            difference() {
                translate([side_len/2, side_len/2, 0])
                cylinder(side_len/2, d =side_len/3-tolerance);
                
                translate(center)
                sphere(layer_outer_radius - tolerance/2);
            }
            translate([side_len/2, side_len/2, 0])
            cylinder(shaft_len, d=shaft_diam);
        }
        
        //Make hole through center
        translate([side_len/2, side_len/2, cap_height-1])
        union() {
            cylinder(screw_head_len+1, d=screw_head_diam);
            cylinder(screw_head_len+screw_spring_len+1, d=screw_spring_diam);
            cylinder(side_len+1, d=screw_shaft_diam);
        }
                
        // Chamfer the top edge
        difference() {
            translate([0, 0, shaft_len+tolerance-shaft_diam/4])
            cube(side_len);
            
            translate([side_len/2, side_len/2, shaft_len+tolerance/2-shaft_diam/4])
            cylinder(shaft_diam/4, d1=shaft_diam+tolerance, d2=shaft_diam*3/4);
        }
        
        // make room for the cap
        translate([side_len/2, side_len/2, -1])
        cylinder(cap_height+1, d=side_len/3);
        
        translate([side_len/2, side_len/2, 0])
        difference() {
            cylinder(cap_height+cap_lip_height+cap_top_tol+cap_lip_tol, d=cap_lip_diam+cap_lip_tol*2);
            cylinder(side_len, d=screw_head_diam+2);
        }
    } 
}

edge_curve_height=3.5;

module EdgePiece() {
    module L1WeirdOval() {
        square_cross_axis_len = sqrt(2*side_len^2);
        oval_x = center_ring_diam*0.53; // TODO: this is not correct
        oval_y = sqrt(2*((side_len-center_ring_diam)/2)^2)/2;
        yz_move_len = oval_y;
        yz_move_part = sqrt(yz_move_len^2/2);
        oval_len = square_cross_axis_len/2 - yz_move_len;
        
        translate([side_len/2, yz_move_part, yz_move_part])
        rotate([-45, 0, 0])
        oval_cone(oval_x, oval_y-tolerance, oval_len-tolerance*2.5);
    }
    
    module OuterCube(inner_tol) {
        difference() {
            translate([side_len/3+tolerance/2, 0, 0])
            cube([side_len/3-tolerance, side_len/3-tolerance/2, side_len/3-tolerance/2]);
            
            translate(center)
            sphere(layer_outer_radius+inner_tol);
        }
    }
    
    module InnerOval() {
        oval_x = shaft_diam/2;
        oval_y = 12;
        
        translate([side_len/2, 0, 0])
        rotate([-45, 0, 0])
        oval(oval_x, oval_y, side_len/2);
    }
    
    module RoundCutawayPart() {
        translate([side_len/2,-1,side_len/3-tolerance/2-edge_curve_height])
        difference() {
            translate([-side_len/2,0,0])
            cube(side_len);
            
            rotate([-90,0,0])
            oval(side_len/6-tolerance/2+small_number, edge_curve_height+small_number, side_len);
        }
    }
    
    module RoundCutaway() {
        difference() {
            union() {
                children();
            }
            
            RoundCutawayPart();
            
            mirror([0,-1,1])
            RoundCutawayPart();
        }
    }
    
    union() {
        intersection() {
            L1WeirdOval();
            layer_hollow_sphere(1);
        }
        
        RoundCutaway() {
            OuterCube(tolerance/2);
            
            intersection() {
                L1WeirdOval();
                OuterCube(-tolerance/2);
            }
        }
        
        difference() {
            intersection() {
                InnerOval();
                layer_hollow_sphere(2);
            }
                        
            sub_oval_len = 15;
            
            difference() {
                translate([0, side_len/2-sub_oval_len/2-shaft_diam/2-tolerance, 0])
                cube([side_len, side_len, side_len/4]);
                
                translate([side_len/2, side_len/2-sub_oval_len/2-shaft_diam/2-tolerance, 0])
                oval(shaft_diam/2, sub_oval_len/2, side_len);
            }
            
            difference() {
                translate([0, 0, side_len/2-sub_oval_len/2-shaft_diam/2-tolerance])
                cube([side_len, side_len/4, side_len]);
                
                translate([side_len/2, 0, side_len/2-sub_oval_len/2-shaft_diam/2-tolerance])
                rotate([-90, 0, 0])
                oval(shaft_diam/2, sub_oval_len/2, side_len);
            }
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

outer_sphere_radius = sqrt((side_len/2)^2+2*(side_len/6+tolerance/2)^2);

module CornerPiece() {
    stem_width = 5.6;
    
    union() {
        difference() {
            cube([side_len/3-tolerance/2,side_len/3-tolerance/2,side_len/3-tolerance/2]);
            
            translate(center)
            sphere(layer_outer_radius+tolerance/2);
            
            translate(center)
sphere(outer_sphere_radius);
        }
        
        difference() {
            translate([side_len/6, side_len/6, side_len/6])
            rotate([-atan(sqrt(2)), 0, -45])
            cylinder(side_len/2, d=stem_width);
            
            translate(center)
            sphere(layer_outer_radius-layer_width*2+tolerance/2);
        }
        
        intersection() {
            difference() {
                layer_hollow_sphere(2);
                
                translate([side_len/2-shaft_diam/2-tolerance, 0, 0])
                cube(side_len);
                
                translate([0, side_len/2-shaft_diam/2-tolerance, 0])
                cube(side_len);
                
                translate([0, 0, side_len/2-shaft_diam/2-tolerance])
                cube(side_len);
            }
                
            radius = 30;

            translate([side_len/2-tolerance-shaft_diam/2-radius,0,0+small_number])
            rotate([-45,0,0])
            cylinder(side_len, r=radius);
            
            translate([0,0,side_len/2-tolerance-shaft_diam/2-radius+small_number])
            rotate([-90,0,-45])
            cylinder(side_len, r=radius);
            
            translate([0,side_len/2-tolerance-shaft_diam/2-radius+small_number,0])
            rotate([0,45,0])
            cylinder(side_len, r=radius);
        }
        
        // Center pointing cone thing
        difference() {
            c=cos(90-atan(sqrt(2)))*sqrt(((side_len/3-tolerance/2)^2)/2);
            rotate([-atan(sqrt(2)), 0, -45])
            translate([0,0,c])
            cylinder((sqrt(3)*(side_len/3-tolerance/2))-c, r1=sqrt(2*((side_len/3-tolerance/2)^2))*(sqrt(3)/3), r2=0);
            
            difference() {
                cube(side_len, center=true);
                cube(side_len);
            }
            
            translate(center)
            sphere(layer_outer_radius+tolerance/2);
        }
        
    }
}

module FullCube() {
    
    union() {
        CenterPiece();
        CenterCap();
        
        CornerPiece();
        rotate_about_pt([0,0,90], center)
        CornerPiece();
        rotate_about_pt([0,0,180], center)
        CornerPiece();
        rotate_about_pt([0,0,-90], center)
        CornerPiece();
        EdgePiece();
        rotate_about_pt([0,0,90], center)
        EdgePiece();
        rotate_about_pt([0,0,180], center)
        EdgePiece();
        rotate_about_pt([0,0,-90], center)
        EdgePiece();
    }
    
    translate([0,0,30])
    union() {
        Core();
    
        rotate_about_pt([90,0,0], center) {
            CenterPiece();
            CenterCap();
        }
        rotate_about_pt([-90,0,0], center) {
            CenterPiece();
            CenterCap();
        }
        rotate_about_pt([0,90,0], center) {
            CenterPiece();
            CenterCap();
        }
        rotate_about_pt([0,-90,0], center) {
            CenterPiece();
            CenterCap();
        }
        
        rotate_about_pt([0,90,0], center)
        EdgePiece();
        rotate_about_pt([0,90,90], center)
        EdgePiece();
        rotate_about_pt([0,90,180], center)
        EdgePiece();
        rotate_about_pt([0,90,-90], center)
        EdgePiece();
    }
    
    translate([0,0,60])
    rotate_about_pt([0,0,40], center)
    union() {
        rotate_about_pt([180,0,0],center) {
            CenterPiece();
            
            translate([0,0,-20])
            CenterCap();
        }
        
        rotate_about_pt([-90,0,0], center)
        EdgePiece();
        rotate_about_pt([-90,0,90], center)
        EdgePiece();
        rotate_about_pt([-90,0,180], center)
        EdgePiece();
        rotate_about_pt([-90,0,-90], center)
        EdgePiece();
        
        rotate_about_pt([-90,0,0], center)
        CornerPiece();
        rotate_about_pt([-90,0,90], center)
        CornerPiece();
        rotate_about_pt([-90,0,180], center)
        CornerPiece();
        rotate_about_pt([-90,0,-90], center)
        CornerPiece();
    }
}

module SomeCube() {
    Core();

    CenterPiece();

    translate([0,0,-10])
    CenterCap();

    EdgePiece();

    rotate_about_pt([0, 0, 90], center)
    EdgePiece();

//    rotate_about_pt([45, 0, 0], center)
    CornerPiece();

    rotate_about_pt([0,0,90], center)
    CornerPiece();
}

//FullCube();
SomeCube();

//CornerPiece();