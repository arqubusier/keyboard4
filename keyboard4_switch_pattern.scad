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
column_z_offsets = [0,0,-3,0,5];
column_x_sep = 0;

for (col_i = [0:n_columns-1]) {
    translate([col_i*(column_x_sep + switch_side_outer),
                column_y_offsets[col_i],
                column_z_offsets[col_i]])
        column(row_numbers[col_i]);
}

thumb_radius1 = 86;
thumb_z_angle1 = 14;
thumb_radius2 = 65;
thumb_z_offset2 = 5;
thumb_z_angle2 = 19.2;
thumb_y_angle = 0;
thumb_x_angle = 0;

module thumb_row(angle, radius, n) {
    for (i = [0:n-1]) {
        rotate(i*angle, v=[0, 0, 1])
            translate([0, radius, 0])
                    switch();
    }
}

rotate(-thumb_y_angle, v=[0,1,0])
rotate(thumb_x_angle, v=[1,0,0])
    translate([-0, -1*switch_side_outer -0 -thumb_radius1, 0*switch_side_outer + 1 ]) {
	    thumb_row(thumb_z_angle1, thumb_radius1, 4);
	    translate([0, 0, -thumb_z_offset2])
		rotate(2, v=[0,0,1])
		    thumb_row(thumb_z_angle2, thumb_radius2, 3);
    }
