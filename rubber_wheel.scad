
thickness = 10;
radius = 65;
rubber_thickness = 2;

mount_ring_n_holes = 6;
mount_ring_radius = 23.85;
mount_hole_dia = 5;
mount_center_hole_dia = 6;
key_depth = 0.6;

2d = false;
select_rubber = true;
select_center_top = true;
select_center_bottom = true;

$fa = 1;
$fs = 0.5;

if (2d){
    projection(cut = false){
        assert(!select_center_bottom || !select_center_top, "Both top and bottom selected at the same time, they are now on top of each other. Please select only one at a time");
        if(select_center_top) mounting_holes()wheel_center("top");
        if(select_center_bottom) mounting_holes() wheel_center("bottom");
    }
}
else{
    if(select_rubber) color("grey") rubber();
    if(select_center_top)    color("#A06535") mounting_holes()wheel_center("top");
    if(select_center_bottom) color("#A06535") mounting_holes()wheel_center("bottom");
}

///////////////////////////////////////////////////////////////////////////////

module rubber(){
    bar_x = 0.8;
    bar_y = 2;
    n = radius;

    // create a ring by subtracting the wheel center from a cylinder
    difference(){
        cylinder(r=radius+rubber_thickness,h=2*thickness);
        translate([0,0,-thickness])scale([1,1,2])wheel_center();

        // subtract a huge cone to make a 45 degree edge to ease the 3d printing by removing overhangs.
        translate([0,0,thickness])
            rotate_extrude(convexity = 10, $fn = 100)
            polygon(points=[[0,radius],[0,-radius],[radius,0]]);
    }

    // design a shape to paste round the outside. This is the V shape like tractor wheel pattern.
    module shape(){
        length = 2*thickness;
        // all the wedge shaked pices
        translate([0,thickness/2,thickness])rotate([90,0,0]){
            rotate([45,0,0])translate([0,-bar_y/2,-bar_y/2])cube([bar_x*2,bar_y,length]);
            rotate([-45,0,0])translate([0,-bar_y/2,-bar_y/2])cube([bar_x*2,bar_y,length]);
        }    
    }

    // Render the desired outisde traction pattern 
    render(convexity = 10)difference(){
        union(){
            for(i=[0:n-1]){
                rotate([0,0,360/n*i])translate([radius+rubber_thickness,0,0])
                    translate([-bar_x,-bar_y/2,0])
                        shape();
            }
        }
        // trim off everything of the shape that goes outside the wheels outer perimiter. 
        translate([0,0,-thickness])cylinder(r=radius*2, h=thickness);
        translate([0,0,2*thickness])cylinder(r=radius*2, h=thickness);
    
    }
}

module wheel_center(select = "all"){
    
    fudge = 4;
    bumpsRadius = 4;
    $_r = radius - fudge;
    $_r2 = bumpsRadius + fudge/2;
    $_n = round((2*PI*$_r)/(2*bumpsRadius)) ; 
   

    gearOffset = 360/$_n/2;

    module gear (){
        offset(fudge)difference(){
            circle($_r);
            for (i=[0:$_n]){
                rotate([0,0,i*360/$_n]) translate([radius,0]) circle($_r2);
            }
        }
    }

    // put the two gears together 
    if(select != "top")    
        linear_extrude(thickness)gear();
    if(select != "bottom") 
        translate([0,0,thickness-0.001])rotate([0,0,gearOffset])linear_extrude(thickness)gear();

}

module mounting_holes(){
    difference(){
        children();
        // outer ring of holes 
        for(i=[0:mount_ring_n_holes-1]){
            rotate([0,0,360/6*i])translate([mount_ring_radius , 0,-1])cylinder(d=mount_hole_dia, h=100);
        }
        // center hole
        difference(){
            cylinder(d=mount_center_hole_dia, h=100);
            translate([mount_center_hole_dia/2-key_depth,-10,-1])cube([10,20,2*thickness+2]);
        }
    }
}     
