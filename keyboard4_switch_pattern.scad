include <../switcholder/cherrymx.scad>


module column(n) {
    for (row = [0:n-1] ) {
        translate([0, row*switch_side_outer, 0])
            switch();
    }
}

n_columns=5;
row_numbers = [3,4,4,4,3];
column_y_offsets = [0,+6 -switch_side_outer,-switch_side_outer + 11,-switch_side_outer + 6,-2];
column_z_offsets = [0,0,-4,0,7];
column_x_sep = 0;

for (col_i = [0:n_columns-1]) {
    translate([col_i*(column_x_sep + switch_side_outer),
                column_y_offsets[col_i],
                column_z_offsets[col_i]])
        column(row_numbers[col_i]);
}

//thumb_radius1 = 86;
thumb_radius1 = 0;
//thumb_z_angle1 = 14;
thumb_z_angle1 = 0;
//thumb_radius2 = 65;
thumb_radius2 = 0;
thumb_height_diff = 10;
//thumb_radius3 = 65;
thumb_radius3 = 0;
//thumb_z_angle2 = 19.2;
thumb_z_angle2 = 0;
//thumb_z_angle3 = 19.3;
thumb_z_angle3 = 0;
thumb_flattness_angle = 75;
thumb_x_angle = 0;
thumb_out_angle = 20;

module thumb_row(angle, radius, n) {
    for (i = [0:n-1]) {
        rotate(i*-angle, v=[0, 1, 0])
            translate([i*switch_side_outer, i*-1 + radius, 0])
                    switch();
    }
}


translate([-0.5*switch_side_outer, -1, -5 -1.5*switch_side_outer - 0.5*height]){
        rotate(-13, v=[1,0,0]) {
            //translate([+height/2 -1.5*switch_side_outer, 2 -switch_side_outer, 0]) {
                #rotate(0, v=[0,0,1])
                    translate([-thumb_height_diff, 0.5*switch_side_outer, -0])
                        rotate(-thumb_flattness_angle, v=[0,1,0])
                            rotate(thumb_out_angle, v=[1,0,0])
                                thumb_row(0, 0, 2);
                rotate(0, v=[0,0,1])
                    translate([0,-0.5*switch_side_outer,0])
                        rotate(-thumb_flattness_angle, v=[0,1,0])
                            rotate(thumb_out_angle, v=[1,0,0])
                                thumb_row(0, 0, 2);
                rotate(0, v=[0,0,1])
                    translate([+thumb_height_diff, -1.5*switch_side_outer, 0])
                        rotate(-thumb_flattness_angle, v=[0,1,0])
                            rotate(thumb_out_angle, v=[1,0,0])
                                    thumb_row(0, 0, 2);
            //}
        }
}
