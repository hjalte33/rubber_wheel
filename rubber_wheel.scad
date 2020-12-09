
/* [Wheel size] */
// Thickness of you center piece material. The wheel will be double the thickness
thickness = 10;

// Radius of the center pieces
radius = 65;

// Thickness of the outer rubber
rubber_thickness = 2;

/* [Mount size] */
// Number of holes round the center
mount_ring_n_holes = 6;

// Radius for the ring of holes
mount_ring_radius = 23.85;

// Hole diameter for the ring
mount_hole_dia = 5;

// Hole diameter for the center hole
mount_center_hole_dia = 6;

// Depth of cut for the keyed center
key_depth = 0.6;

/* [Part selector] */
render_2D = 0;//[1:true, 0:false]

// Render rubber ring
select_rubber = 1;//[1:true, 0:false]

// Render top center piece
select_center_top = 0;//[1:true, 0:false]

// Render bottom center piece
select_center_bottom = 1;//[1:true, 0:false]

/* [Quality] */
$fa = 1;
$fs = 0.5;

if (render_2D){
    projection(cut = false){
        if(select_center_top) mounting_holes()wheel_center("top");
        if(select_center_bottom) mounting_holes() wheel_center("bottom");
        if(select_rubber) color("grey") rubber();
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
    difference(){
        union(){
            render(convexity = 10)for(i=[0:n-1]){
                rotate([0,0,360/n*i])translate([radius+rubber_thickness,0,0])
                    translate([-bar_x,-bar_y/2,0])
                        render(convexity = 4)shape();
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
        render()offset(fudge)difference(){
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
