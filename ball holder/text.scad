$fn=50;

outer_dim = 30;
inner_dim = 20;
holder_height = 10;
b1 = (outer_dim - inner_dim)/2;
theta = atan2(holder_height, b1);

radius = 13;
height = 5;
slices = 50;

txt = "Supreme Ball!";
text_depth = 0.4;

circumference = 2 * 3.14159 * radius;
slice_width = circumference / slices;

module circular_text () {
   
    union () {
   
        for (i = [0:1:slices]) {
           
            rotate ([-90+theta,0,i*(360/slices)]) translate ([0,-radius,0]) intersection () {
               
                translate ([-slice_width/2 - (i*slice_width) ,0 ,-3]) rotate ([90,0,0])
                                
                linear_extrude(text_depth, center = true, convexity = 10)                
                text(txt, size=height);
               
                cube ([slice_width+0.1, text_depth+0.1, height*2], true);
            }
        }
    }
}

circular_text();