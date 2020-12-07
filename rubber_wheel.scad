
thickness = 10;
radius = 70;
rubber_thickness = 2;
r_mount=23.85;
mount_hole_dia = 5;
mount_center_hole_dia = 6;
key_depth = 0.6;

_2d = false;

$fa = 1;
$fs = 0.5;

if (_2d){
    projection(cut = false){
        wheel_center("top");
        translate([0,2*radius+1,0])wheel_center("bottom");
    }
}
else{
    rubber();
    translate([0,2*radius*2+20,-thickness])wheel_center("top");
    translate([0,2*radius+10,0])wheel_center("bottom");
}


module rubber(){
    bar_x = 0.8;
    bar_y = 2;
    n = radius;

    difference(){
        cylinder(r=radius+rubber_thickness,h=2*thickness);
        translate([0,0,-thickness])scale([1,1,2])wheel_center();

        translate([0,0,thickness])
            rotate_extrude(convexity = 10, $fn = 100)
            polygon(points=[[0,radius],[0,-radius],[radius,0]]);
    }

    module shape(){
        length = 2*thickness;
        // all the wedge shaked pices
        translate([0,thickness/2,thickness])rotate([90,0,0]){
            rotate([45,0,0])translate([0,-bar_y/2,-bar_y/2])cube([bar_x*2,bar_y,length]);
            rotate([-45,0,0])translate([0,-bar_y/2,-bar_y/2])cube([bar_x*2,bar_y,length]);
        }    
    }

    render()difference(){
        union(){
            for(i=[0:n-1]){
                rotate([0,0,360/n*i])translate([radius+rubber_thickness,0,0])
                    translate([-bar_x,-bar_y/2,0])
                        shape();
            }
        }
        translate([0,0,-thickness])cylinder(r=radius*2, h=thickness);
        translate([0,0,2*thickness])cylinder(r=radius*2, h=thickness);
    
    }
}

module wheel_center(select = "all"){
    difference(){        
        union(){
            if(select != "top") linear_extrude(thickness)gear(r=radius, r2=4, fudge=4);
            if(select != "bottom") translate([0,0,thickness-0.001])rotate([0,0,45])linear_extrude(thickness)gear(r=radius, r2=4, fudge=4);
        }
        for(i=[0:5]){
            rotate([0,0,360/6*i])translate([r_mount,0,-1])cylinder(d=mount_hole_dia, h=100);
        }
        cylinder(d=mount_center_hole_dia, h=100);
    }
    // key
    if(select != "top")   translate([mount_center_hole_dia/2-key_depth,-10,0])cube([10,20,thickness]);
    if(select != "bottom")translate([mount_center_hole_dia/2-key_depth,-10,thickness])cube([10,20,thickness]);
}

module gear (r, r2, n, fudge=2){
    // knob

    _r = r-fudge;
    _r2 = r2+fudge/2;
    _n = n == undef ? round((2*PI*_r)/(2*r2)) : n ; 
    echo(_n);

    difference(){
        offset(fudge)
            difference(){
                circle(_r);
                for (i=[0:_n]){
                    rotate([0,0,i*360/_n]) translate([r,0]) circle(_r2);
                }
            }
    }
    
}