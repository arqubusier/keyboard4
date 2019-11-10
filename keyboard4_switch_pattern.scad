include <../switcholder/cherrymx.scad>


module column_rep(n,radius,radius_offset,angle) {
    translate([0,0,radius])
        for (row = [0:n-1] ) {
                rotate(row*angle-(n-1.5)/2*angle+radius_offset, [1,0,0])
                    translate([0, 0, -radius])
                        children();
        }
}

module column(n,radius,radius_offset,angle) {
    difference() {
        hull()
            column_rep(n,radius,radius_offset,angle)
                        switch_pos();
        hull()
            translate([0,0,height])
                    column_rep(n,radius-height,radius_offset,angle)
                        switch_pos();
        column_rep(n,radius-height,radius_offset,angle)
            switch_neg(2);
    }
}


column_radii = 72;

// Common
common_offset = [0,0,34];
common_rotate_y = 20;

// Main part
column_radius = 72;

module matrix_rep(row_numbers, radius, offs, columnHull) {
        n_columns=5;
        column_y_offsets = [0,4,9,4,-9];
        column_z_offsets = [0,0,-4,0,7];
        column_angle = 17;
        column_radii_offset = [2,0,0,0,0];
        column_x_sep = 0;


    translate(common_offset) {
        rotate(common_rotate_y, [0,1,0]) {
            for (col_i = [0:n_columns-1]) {
                if (columnHull) {
                    hull() {
                    translate(offs)
                        translate([col_i*(column_x_sep + switch_side_outer),
                            column_y_offsets[col_i], column_z_offsets[col_i]])
                                    column_rep(row_numbers[col_i],radius,column_radii_offset[col_i],
                                            column_angle)
                                        children();
                    }
                } else {
                    translate(offs)
                        translate([col_i*(column_x_sep + switch_side_outer),
                            column_y_offsets[col_i], column_z_offsets[col_i]])
                                    column_rep(row_numbers[col_i],radius,column_radii_offset[col_i],
                                            column_angle)
                                        children();
                }
            }
        }
    }
}

corners = [ [-10,-58], [-40,0], [-10,60], [76,60], [76,-53], [10,-53] ] ;

        //translate([0,0,height/2+5.5])
        //    rotate(90, [1,0,0])
        //        import("../DSA_Keycap_Set_8mm/files/DSA_1u.stl");


module thumb_row_rep(out_angle, flatness_angle, in_offs, up_offs, forward_offs, n) {
    for (i = [0:n-1]) {
        translate([in_offs, 0.5*switch_side_outer + forward_offs, up_offs])
            rotate(-flatness_angle+10, v=[0,1,0])
                rotate(out_angle, v=[1,0,0])
                        translate([i*switch_side_outer, 0, 0])
                            children();
    }
}


module thumb_cluster_rep(in_offs) {
    // Thumb cluster

    thumb_radius1 = 0;
    thumb_z_angle1 = 0;
    thumb_radius2 = 0;
    thumb_height_diff = 10;
    thumb_radius3 = 0;
    thumb_z_angle2 = 0;
    thumb_z_angle3 = 0;
    thumb_flattness_angle = 95;
    thumb_x_angle = 0;
    thumb_out_angle = 22;
    translate(common_offset) {
        rotate(common_rotate_y, [0,1,0]) {
            translate([-2 -0.5*switch_side_outer, -23, -3 -1.5*switch_side_outer - 0.5*height]){
                rotate(-13, v=[1,0,0]) {
                    thumb_row_rep( thumb_out_angle + 12, thumb_flattness_angle,
                                    in_offs-thumb_height_diff, 2, 0.5*switch_side_outer, 2)
                                    children();
                    thumb_row_rep( thumb_out_angle, thumb_flattness_angle,
                                    in_offs, 0, -0.5*switch_side_outer, 2)
                                    children();
                    thumb_row_rep( thumb_out_angle - 12, thumb_flattness_angle,
                                    in_offs+thumb_height_diff, 0, -1.5*switch_side_outer, 2)
                                    children();
                        }
                }
        }
    }
}

/*
thumb_cluster_rep(0)
    switch_pos();
    */
/*
difference() {
    //outer
    hull() {
        hull()
            thumb_cluster_rep(0)
                switch_pos();

        linear_extrude(2)
            offset(r=1.5)
            polygon(corners);
    }

    //inner
    hull() {
        thumb_cluster_rep(-height)
            switch_neg(1);

        linear_extrude(2)
            offset(r=-1.5)
            polygon(corners);
    }


    for (i=[0:1])
        hull()
            thumb_cluster_rep(i*height)
                switch_pos();
}
*/

/*
difference() {
    hull()
        thumb_cluster_rep(0)
            switch_pos();
    thumb_cluster_rep(0)
        switch_neg(3);
    #hull()
        thumb_cluster_rep(height)
            switch_pos();
}
*/

/*
row_numbers = [4,5,5,5,5];
difference(){
    union() {
        difference() {
            //outer
            hull(){
                matrix_rep(row_numbers, column_radius, [0,0,0],false)
                    switch_pos();

                linear_extrude(2)
                    offset(r=1.5)
                    polygon(corners);
            }

            //inner
            hull(){
                row_numbers = [4,5,5,5,5];
                matrix_rep(row_numbers, column_radius, [0,0,0],false)
                    switch_neg(1);

                linear_extrude(2)
                    offset(r=-1.5)
                    polygon(corners);
            }


        }

        difference() {
            hull()
                matrix_rep(row_numbers, column_radius, [0,0,0],true)
                    switch_pos();
            matrix_rep(row_numbers, column_radius - height, [0,0,0],false)
                switch_neg(10);
        }
    }

    for (i = [1:1]) {
        row_numbers_minus = [5,7,7,7,6];
        #matrix_rep(row_numbers_minus, column_radius - i*height, [0,0,i*height],true)
            switch_pos();
    }

}
*/
