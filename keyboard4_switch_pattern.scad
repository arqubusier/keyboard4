include <../switcholder/cherrymx.scad>


/******************************************************************************

		screw inset holder

/*****************************************************************************/
inset_height = 5.10+0.5;
inset_height_outer = 5.10+1.5;
inset_diameter = 5.35;
inset_diameter_outer = inset_diameter+2;


module screw_inset() {
	difference () {
		screw_inset_pos();
		screw_inset_neg();
	}
}

module screw_inset_pos() {
	cylinder(d=inset_diameter_outer, inset_height_outer);
}

module screw_inset_neg() {
	cylinder(d=inset_diameter, inset_height);
	cylinder(d=inset_diameter-1, inset_height_outer);
}

/******************************************************************************

		Common

/*****************************************************************************/

$fn=20;

// Common
common_offset = [0,0,34];
common_rotate_y = 20;

main_max_x = 73;

bottom_height = 2;
corner_radius = inset_diameter_outer/2;
corner_radius_inner = 0;

function split_side_point(side, split_factor) =
	let(delta = side[1] - side[0])
		side[0] + delta * split_factor;

/******************************************************************************

		Main Columns

/*****************************************************************************/

module column_rep(n,radius,angle_offset,angle) {
    translate([0,0,radius])
        for (row = [0:n-1] ) {
                rotate(row*angle-(n-1.5)/2*angle+angle_offset, [1,0,0])
                    translate([0, 0, -radius])
                        children();
        }
}

module column(n,radius,angle_offset,angle) {
    difference() {
        hull()
            column_rep(n,radius,angle_offset,angle)
                        switch_pos();
        hull()
            translate([0,0,height])
                    column_rep(n,radius-height,angle_offset,angle)
                        switch_pos();
        column_rep(n,radius-height,angle_offset,angle)
            switch_neg(2);
    }
}


column_radii = 72;

// Main part
column_radius = 72;

module matrix_rep(row_numbers, radius, offs, columnHull) {
        n_columns=5;
        column_y_offsets = [0,4,9,4,-9];
        column_z_offsets = [0,0,-4,0,7];
        column_angle = 17;
        column_angle_offset = [2,0,0,0,column_angle/2];
        column_x_sep = 0;


    translate(common_offset) {
        rotate(common_rotate_y, [0,1,0]) {
            for (col_i = [0:n_columns-1]) {
                if (columnHull) {
                    hull() {
                    translate(offs)
                        translate([col_i*(column_x_sep + switch_side_outer),
                            column_y_offsets[col_i], column_z_offsets[col_i]])
                                    column_rep(row_numbers[col_i],radius,column_angle_offset[col_i],
                                            column_angle)
                                        children();
                    }
                } else {
                    translate(offs)
                        translate([col_i*(column_x_sep + switch_side_outer),
                            column_y_offsets[col_i], column_z_offsets[col_i]])
                                    column_rep(row_numbers[col_i],radius,column_angle_offset[col_i],
                                            column_angle)
                                        children();
                }
            }
        }
    }
}


        //translate([0,0,height/2+5.5])
        //    rotate(90, [1,0,0])
        //        import("../DSA_Keycap_Set_8mm/files/DSA_1u.stl");

/******************************************************************************

		Thumb Columns

/*****************************************************************************/

module thumb_row_rep(out_angle, flatness_angle, in_offs, up_offs, forward_offs, n) {
    for (i = [0:n-1]) {
        translate([0, 0.5*switch_side_outer + forward_offs, up_offs])
            rotate(-flatness_angle+10, v=[0,1,0])
                rotate(out_angle, v=[1,0,0])
                        translate([i*switch_side_outer, 0, -in_offs])
                            children();
    }
}


module thumb_cluster_rep(in_offs) {
    // Thumb cluster
    up_offs = 0.2;
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
            translate([-2 -0.5*switch_side_outer, -23, up_offs-1.5*switch_side_outer - 0.5*height]){
                rotate(-13, v=[1,0,0]) {
                    thumb_row_rep( thumb_out_angle + 12, thumb_flattness_angle,
                                    in_offs-thumb_height_diff, 2, 1*switch_side_outer, 2)
                                    children();
                    thumb_row_rep( thumb_out_angle, thumb_flattness_angle,
                                    in_offs, 0, -0.5*switch_side_outer, 2)
                                    children();
                    thumb_row_rep( thumb_out_angle - 12, thumb_flattness_angle,
                                    in_offs+thumb_height_diff, 0, 3 + -2*switch_side_outer, 2)
                                    children();
                        }
                }
        }
    }
}

module bottom_plate(height, points, r) {
	translate([0,0,height/2])
        linear_extrude(height, center=true)
            offset(r)
            polygon(points);
}

/******************************************************************************

		Thumb Region

/*****************************************************************************/

thumb_side0 = [[-8,-58], [-37,08]];

thumb_corners = [ thumb_side0[0],  thumb_side0[1], [-10,25],
			[main_max_x,40], [main_max_x,0], [25,-45] ] ;

module thumb_outer () {
    //outer body
    hull() {
	thumb_cluster_rep(0)
		switch_pos();
	bottom_plate(inset_height_outer, thumb_corners, corner_radius);
    }
}

module thumb_inner () {
    #hull() {
        #thumb_cluster_rep(height)
            switch_neg(1);
        bottom_plate(inset_height_outer, thumb_corners, corner_radius_inner);
    }
}

module thumb_keys () {
	// Connected Switch holes with excess above
	difference() {
	    hull()
		thumb_cluster_rep(0)
		    switch_pos();
	    thumb_cluster_rep(0)
		switch_neg(3);
	}
}

module thumb_keys_excess() {
    // Trim excess above switch holes
    for (i=[1:3])
	thumb_cluster_rep(-i*height)
	    switch_pos();
    thumb_cluster_rep(0)
        switch_neg(3);
}


/******************************************************************************

		Main Region

/*****************************************************************************/

main_side0 = [[main_max_x, 60], [main_max_x,-45]];
main_corners = [ [-5,-40], [-10,35], [0,60], main_side0[0], main_side0[1] , [20,-45] ] ;
row_numbers = [4,5,5,5,4];

module main_outer() {
    //outer body
    hull(){
	matrix_rep(row_numbers, column_radius, [0,0,0],false)
	    switch_pos();

        bottom_plate(inset_height_outer, main_corners, corner_radius);
    }
}

module main_inner() {
    //inner body
    hull(){
	matrix_rep(row_numbers, column_radius, [0,0,0],false)
	    switch_neg(1);

	bottom_plate(inset_height_outer, main_corners, corner_radius_inner);
    }
}

module main_keys() {
    // Connected Switch holes with excess above
    difference() {
        hull()
    	matrix_rep(row_numbers, column_radius, [0,0,0],true)
    	    switch_pos();
        matrix_rep(row_numbers, column_radius - height, [0,0,0],false)
    	switch_neg(10);
    }

}

module main_switch_clearance() {
    switch_depth = 8;
    matrix_rep(row_numbers, column_radius, [0,0,0],false)
        translate([0,0,height/2 - switch_depth/2])
            cube([10,10,switch_depth],center=true);
}

module main_keys_excess() {
    row_numbers_minus = row_numbers + [2,2,2,2,2];
    // Trim excess above switch holes
    for (i = [1:1]) {
        matrix_rep(row_numbers_minus, column_radius - i*height, [0,0,i*height],true)
            switch_pos();
    }

}


/******************************************************************************

		Screws

/*****************************************************************************/

main_side_split_p0 = split_side_point(main_side0, 0.5);
plate0_screws = [thumb_corners[2], thumb_side0[1], main_side_split_p0,
			main_corners[3], main_corners[2]]; 

main_side_split_p1 = split_side_point(main_side0, 0.83);
thumb_side_split_p1 = split_side_point(thumb_side0, 0.35); 
plate1_screws = [thumb_side0[0], main_side_split_p1, thumb_side_split_p1, main_corners[4],
		thumb_corners[5]]; 

module insets_pos() {
	for (p = concat(plate0_screws,plate1_screws)) {
		translate(p)
			screw_inset_pos();
	}
}

module insets_neg() {
	for (p = concat(plate0_screws,plate1_screws)) {
		translate(p)
			screw_inset_neg();
	}
}

/******************************************************************************

		Bottom Plates

/*****************************************************************************/
module full_plate() {
	bottom_plate(bottom_height, thumb_corners, corner_radius);
	bottom_plate(bottom_height, main_corners, corner_radius);
}
bigvalue=200;
plate_chamfer_angle=45;
plate_offs_y=-20;

screw_diameter = 3;
screw_head_diameter = 5.45;
module screw_hole() {
	cylinder(d2=screw_diameter, d1=screw_head_diameter, h=bottom_height);
}

module plate1() {
	hand_rest_length = 95;
	hand_rest_height = 30;
	hand_rest_p0 = main_corners[4] - [-30,hand_rest_length];
	hand_rest_p1 = main_corners[5] - [0,hand_rest_length];
	hand_rest_corners = [thumb_side0[0], main_corners[5], main_corners[4],
				, hand_rest_p0, hand_rest_p1];
	bottom_plate(bottom_height, hand_rest_corners, corner_radius);
	difference() {
		full_plate();
			translate([0, plate_offs_y,0])
				rotate(plate_chamfer_angle-180, [1, 0, 0])
					translate([-bigvalue/2,  -bigvalue/2, 0])
						cube([bigvalue, bigvalue, bigvalue]);
		for (p = plate1_screws) {
			translate(p)
				screw_hole();
		}
	}

	hand_rest_middle0 = split_side_point([hand_rest_p0, main_corners[4]], 0.7);
	hand_rest_middle1 = split_side_point([hand_rest_p1, main_corners[5]], 0.7);
	bottom_plate(hand_rest_height,
			[hand_rest_middle0, hand_rest_middle1+[25,0], hand_rest_p1+[15,0], hand_rest_p0],
			corner_radius);
}

module plate0() {
    translate([0,0,bottom_height]){
        holder_usb_bmini();
        holder_usb_bmicro();
    }
	difference() {
		full_plate();
			translate([0, plate_offs_y,0])
				rotate(plate_chamfer_angle, [1, 0, 0])
					translate([-bigvalue/2, -bigvalue/2, 0])
						cube([bigvalue, bigvalue, bigvalue]);
		for (p = plate0_screws) {
			translate(p)
				screw_hole();
		}
        for (p = usb_bmini_screws){
            translate(p)
                cylinder(d=screw_head_diameter,h=bottom_height);
        }
        for (p = usb_bmicro_screws){
            translate(p)
                cylinder(d=screw_head_diameter,h=bottom_height);
        }
	}
}


/******************************************************************************

		connector holders

/*****************************************************************************/


module connector_holder (width, depth, height, width_connections, depth_connections,
			 connector_overhang, pcb_height, connector_width) {
    difference() {
        cube([width, depth, height]);
        translate([width/2-width_connections/2,0,0])
            cube([width_connections, depth_connections, height]);
    }
    translate([width/2 - connector_width/2, depth, 0]) 
        cube([connector_width, connector_overhang, height+pcb_height]);
}

pcb_height = 1.7;
connector_holder_height = 2;
usb_bmini_connector_height = 4.1;
usb_bmini_connector_width = 7.7;
usb_bmini_holder_depth = 19.2;
usb_bmini_holder_width = 26;
usb_bmini_holder_side_offset = 35;
usb_bmini_hole_side_offset = 1.1;
usb_bmini_hole_front_offset = 0.7;
usb_bmini_hole_radius = 1.75;
connector_holder_inset = corner_radius - 2.5;

usb_bmini_offset = main_corners[3] +
                [-usb_bmini_holder_side_offset-usb_bmini_holder_width,
                connector_holder_inset -usb_bmini_holder_depth, 0];
usb_bmini_screws =   
                [usb_bmini_offset +
                    [usb_bmini_hole_radius+usb_bmini_hole_side_offset,
                    usb_bmini_holder_depth - usb_bmini_hole_radius - usb_bmini_hole_front_offset, 0],
                 usb_bmini_offset +
                    [usb_bmini_holder_width - (usb_bmini_hole_radius+usb_bmini_hole_side_offset),
                    usb_bmini_holder_depth - usb_bmini_hole_radius - usb_bmini_hole_front_offset, 0]];

module holder_usb_bmini() {
    difference() {
        translate(usb_bmini_offset)
            connector_holder(usb_bmini_holder_width, usb_bmini_holder_depth,
                connector_holder_height, 13, 5, 1.0,
                pcb_height, usb_bmini_connector_width);
        for (p = usb_bmini_screws){
            translate(p)
                screw_hole();
        }
    }
}

usb_bmicro_connector_height = 3.0;
usb_bmicro_connector_width = 8.0;
usb_bmicro_holder_width = 21;
usb_bmicro_holder_depth = 11.4;
usb_bmicro_holder_side_offset = 10;
usb_bmicro_hole_side_offset = 1.1;
usb_bmicro_hole_front_offset = 0.9;
usb_bmicro_hole_radius = 1.75;

usb_bmicro_offset = main_corners[3] +
                [-usb_bmicro_holder_side_offset-usb_bmicro_holder_width,
                connector_holder_inset-usb_bmicro_holder_depth, 0];
usb_bmicro_screws = [usb_bmicro_offset +
                        [usb_bmicro_hole_radius+usb_bmicro_hole_side_offset,
                        usb_bmicro_holder_depth - usb_bmicro_hole_radius - usb_bmicro_hole_front_offset,0],
                    usb_bmicro_offset +
                        [usb_bmicro_holder_width - (usb_bmicro_hole_radius+usb_bmicro_hole_side_offset),
                        usb_bmicro_holder_depth - usb_bmicro_hole_radius - usb_bmicro_hole_front_offset,0]];

module holder_usb_bmicro() {
    difference() {
        translate(usb_bmicro_offset)
            connector_holder(usb_bmicro_holder_width, usb_bmicro_holder_depth, connector_holder_height,
                        13, 4, 1.0,
                        pcb_height, usb_bmicro_connector_width);
        for (p = usb_bmicro_screws){
            translate(p)
                screw_hole();
        }
    }
}


module usb_bmini_hole() {
    translate(main_corners[3] + [ - usb_bmini_holder_side_offset, connector_holder_inset,0]) {
        translate([-usb_bmini_holder_width/2 - usb_bmini_connector_width/2,-5])
            cube([usb_bmini_connector_width, 10,
            connector_holder_height+usb_bmini_connector_height+pcb_height]);
        translate([-usb_bmini_holder_width,-usb_bmini_holder_depth,0])
            cube([usb_bmini_holder_width, usb_bmini_holder_depth, connector_holder_height]);
    }
}

module usb_bmicro_hole() {
    translate(main_corners[3] + [ - usb_bmicro_holder_side_offset, connector_holder_inset,0]) {
        translate([-usb_bmicro_holder_width/2 - usb_bmicro_connector_width/2,-5])
            cube([usb_bmicro_connector_width, 10,
            connector_holder_height+usb_bmicro_connector_height+pcb_height]);
        translate([-usb_bmicro_holder_width,-usb_bmicro_holder_depth,0])
            cube([usb_bmicro_holder_width, usb_bmicro_holder_depth, connector_holder_height]);
    }
}
/******************************************************************************

		full model

/*****************************************************************************/


difference() {
    union() {
        difference() {
            union() {
                main_outer();
                thumb_outer();
            }
            main_inner();
            thumb_inner();
        }
        main_keys();
        thumb_keys();
        insets_pos();
    }
    thumb_keys_excess();
    main_keys_excess();
    main_switch_clearance();
    insets_neg();
    usb_bmicro_hole();
    usb_bmini_hole();
}

translate([0,0,-bottom_height]) {
	*plate0();
	*plate1();
}

