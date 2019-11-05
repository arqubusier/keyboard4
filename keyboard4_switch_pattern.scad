include <../switcholder/cherrymx.scad>


module column(n,radius,angle) {
    translate([0,0,radius])
        for (row = [0:n-1] ) {
            rotate(row*angle-(n-1)/2*angle, [1,0,0])
                translate([0, 0, -radius])
                    switch();
        }
}


module thumb_row(angle, radius, n) {
    for (i = [0:n-1]) {
        rotate(i*-angle, v=[0, 1, 0])
            translate([i*switch_side_outer, 0 + radius, 0])
                    switch();
    }
}

// Main part
n_columns=5;
row_numbers = [3,4,4,4,3];
//column_y_offsets = [0,+6 -switch_side_outer,-switch_side_outer + 11,-switch_side_outer + 6,-2];
column_y_offsets = [switch_side_outer/2,4,9,4,switch_side_outer/2-8];
column_z_offsets = [0,0,-4,0,7];
column_radii = 72;
column_angle = 17;
column_x_sep = 0;

// Thumb cluster

thumb_radius1 = 0;
thumb_z_angle1 = 0;
thumb_radius2 = 0;
thumb_height_diff = 10;
thumb_radius3 = 0;
thumb_z_angle2 = 0;
thumb_z_angle3 = 0;
thumb_flattness_angle = 75;
thumb_x_angle = 0;
thumb_out_angle = 22;

//column(3,column_radii,column_angle);

rotate(20, [0,1,0]) {
for (col_i = [0:n_columns-1]) {
    translate([col_i*(column_x_sep + switch_side_outer),
                column_y_offsets[col_i],
                column_z_offsets[col_i]])
        column(row_numbers[col_i],column_radii,column_angle);
}

//translate([0,0,height/2+5.5])
//    rotate(90, [1,0,0])
//        import("../DSA_Keycap_Set_8mm/files/DSA_1u.stl");

translate([-2 -0.5*switch_side_outer, -10, -3 -1.5*switch_side_outer - 0.5*height]){
        rotate(-13, v=[1,0,0]) {
                    translate([-thumb_height_diff, 0.5*switch_side_outer, 2])
                        rotate(-thumb_flattness_angle, v=[0,1,0])
                            rotate(thumb_out_angle+12, v=[1,0,0])
                                thumb_row(0, 0, 2);
                    translate([0,-0.5*switch_side_outer,0])
                        rotate(-thumb_flattness_angle, v=[0,1,0])
                            rotate(thumb_out_angle, v=[1,0,0])
                                thumb_row(0, 0, 2);
                    translate([+thumb_height_diff, -1.5*switch_side_outer, 0])
                        rotate(-thumb_flattness_angle, v=[0,1,0])
                            rotate(thumb_out_angle-12, v=[1,0,0])
                                    thumb_row(0, 0, 2);
        }
}
}
