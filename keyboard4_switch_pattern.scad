include <../switcholder/cherrymx.scad>

/******************************************************************************

        Parameters

/*****************************************************************************/
main_max_x = 79;
main_max_y = 52;

thumb_back_middle_p = [45,-49];
thumb_middle0_out_p = [-17,-26];
thumb_middle1_out_p = [-9,-27];
thumb_middle2_out_p = [-1,-43];
thumb_middle3_out_p = [+6,-46];
thumb_front_out_p = [-27,-12.5];
thumb_back_out_p = [11,-65];
thumb_front_middle_p = [-10,5];
thumb_front_in_p = [73,-35];
thumb_middle_in_p = [73,10];
thumb_back_in_p0 = [73,40];
thumb_back_in_p1 = [73,10];

/******************************************************************************

        Util

/*****************************************************************************/
function get(data, key) = data[search([key], data)[0]][1];

/******************************************************************************

		screw inset holder

/*****************************************************************************/
inset_height = 5.10+0.5;
inset_height_outer = 5.10+1.5;
inset_diameter = 5.5;
inset_diameter_outer = inset_diameter+2.5;


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
	cylinder(d1=inset_diameter+1, d2=inset_diameter, 1);
}

/******************************************************************************

		Common

/*****************************************************************************/

$fn=20;

// Common
common_offset = [0,0,34];
common_rotate_y = 20;


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

module matrix_rep(row_numbers, radius, offs, columnHull, switch_side) {
        n_columns=5;
        column_y_offsets = [0,4,9,4,-9];
        column_z_offsets = [0,0,-4,0,7];
        column_angle = 18;
        column_angle_offset = [2,0,0,0,0];
        column_x_sep = 0;


    translate(common_offset + [0,0,-7]) {
        rotate(common_rotate_y, [0,1,0]) {
            for (col_i = [0:n_columns-1]) {
                if (columnHull) {
                    hull() {
                        translate([col_i*(column_x_sep + switch_side),
                            column_y_offsets[col_i], column_z_offsets[col_i]])
                                    column_rep(row_numbers[col_i],radius,column_angle_offset[col_i],
                                            column_angle)
                    translate(offs)
                                        children();
                    }
                } else {
                        translate([col_i*(column_x_sep + switch_side),
                            column_y_offsets[col_i], column_z_offsets[col_i]])
                                    column_rep(row_numbers[col_i],radius,column_angle_offset[col_i],
                                            column_angle)
                    translate(offs)
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

module thumb_row_rep(out_angle, flatness_angle, in_offs, up_offs, forward_offs, n) {
    for (i = [0:n-1]) {
        translate([0, 0.5*switch_side_outer + forward_offs, up_offs])
            rotate(-flatness_angle+10, v=[0,1,0])
                rotate(out_angle, v=[1,0,0])
                        translate([i*switch_side_outer, 0, -in_offs])
                            children();
    }
}



module thumb_pos() {
    translate(common_offset)
        rotate(common_rotate_y, [0,1,0])
            translate([+12.5 -0.5*switch_side_outer, -39, .8-1.5*switch_side_outer - 0.5*height])
                rotate(-13, v=[1,0,0])
                    children();
}

module thumb_front_row(in_offs) {
    thumb_pos()
        thumb_row_rep( thumb_out_angle + 12, thumb_flattness_angle,
                        -0.1+in_offs-1.75*thumb_height_diff, 2, .85*switch_side_outer, 2)
                        children();
}
module thumb_middle_row(in_offs) {
    thumb_pos()
        thumb_row_rep( thumb_out_angle, thumb_flattness_angle,
                        in_offs, 5, -0.5*switch_side_outer, 2)
                        children();
}
module thumb_back_row(in_offs) {
    thumb_pos()
        thumb_row_rep( thumb_out_angle - 10, thumb_flattness_angle,
                        in_offs+thumb_height_diff+3, 7.5, -10.5 -1*switch_side_outer, 2)
                        children();
}

module thumb_cluster_rep(in_offs, pairwise_hull) {
    if (pairwise_hull) {
        hull() {
            thumb_front_row(in_offs) children();
            thumb_middle_row(in_offs) children();
        }
        hull() {
            thumb_middle_row(in_offs) children();
            thumb_back_row(in_offs) children();
        }
    } else {
        thumb_front_row(in_offs) children();
        thumb_middle_row(in_offs) children();
        thumb_back_row(in_offs) children();
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

thumb_corners = [ thumb_back_in_p1,  thumb_front_middle_p, thumb_front_out_p,
                    thumb_middle0_out_p, thumb_middle1_out_p,
                    thumb_back_out_p, thumb_back_middle_p, thumb_front_in_p];

module thumb_body (_corner_radius) {
    //outer body
    hull() {
        thumb_front_row(0)
            children();
        bottom_plate(inset_height_outer,
             [
            thumb_middle_in_p,
            thumb_back_in_p0,
            thumb_front_middle_p,
            thumb_front_out_p,
            thumb_middle0_out_p,
              ]
            , _corner_radius);
    }
    hull() {
        thumb_middle_row(0)
            children();
        bottom_plate(inset_height_outer, 
             [
            thumb_back_in_p1,
            thumb_front_in_p,
            thumb_middle1_out_p,
            thumb_middle2_out_p,
              ],
            _corner_radius);
    }
    hull() {
        thumb_back_row(0)
            children();
        bottom_plate(inset_height_outer,
             [
            thumb_front_in_p,
            thumb_back_in_p0,
            thumb_back_middle_p,
            thumb_back_out_p,
            thumb_middle3_out_p,
              ],
        _corner_radius);
    }
}

module thumb_keys () {
    thumb_front_row(0)
        switch();
    thumb_middle_row(0)
        switch();
    thumb_back_row(0)
        switch();
}
/*
module thumb_keys () {
	// Connected Switch holes with excess above
	difference() {
		thumb_cluster_rep(0,true)
		    switch_pos();
	    thumb_cluster_rep(0,false)
            switch_neg(3);
	}
}
*/

module thumb_keys_hole() {
    // Trim excess above switch holes
    for (i=[1:1])
		thumb_cluster_rep(-i*height,true)
		    switch_pos();
}
module thumb_keys_excess() {
    // Trim excess above switch holes
    for (i=[1:4])
	thumb_cluster_rep(-i*height,false)
	    switch_pos();
    thumb_cluster_rep(0,false)
        switch_neg(4);
}


/******************************************************************************

		Main Region

/*****************************************************************************/

main_switch_side = switch_side_outer + 0.3;
main_side0 = [[main_max_x, main_max_y], [main_max_x,-45]];
main_corners = [ [0,-15], [0,05], [-3,main_max_y], main_side0[0], main_side0[1] , [20,-45] ] ;
row_numbers = [3,4,4,4,4];
matrix_offs = [0,0,2];

module main_outer() {
    //outer body
    hull(){
	matrix_rep(row_numbers, column_radius, matrix_offs, false, main_switch_side)
	    switch_pos(main_switch_side);
        bottom_plate(inset_height_outer, main_corners, corner_radius);
    }
}

module main_inner() {
    //inner body
    hull(){
	matrix_rep(row_numbers, column_radius, matrix_offs,false, main_switch_side)
	    switch_neg(1);

	bottom_plate(inset_height_outer, main_corners, corner_radius_inner);
    }
}

module main_keys() {
    // Connected Switch holes with excess above
    difference() {
        hull()
    	matrix_rep(row_numbers, column_radius, matrix_offs,true, main_switch_side)
    	    switch_pos(main_switch_side);
        matrix_rep(row_numbers, column_radius - height, matrix_offs,false, main_switch_side)
            switch_neg(10);
    }

}

module main_switch_clearance() {
    switch_depth = 8;
    matrix_rep(row_numbers, column_radius, matrix_offs,false, main_switch_side)
        translate([0,0,height/2 - switch_depth/2])
            cube([10,9,switch_depth],center=true);
}

module main_keys_excess() {
    row_numbers_minus = row_numbers + [2,2,2,2,2];
    // Trim excess above switch holes
    for (i = [1:1]) {
        matrix_rep(row_numbers_minus, column_radius - i*height, matrix_offs + [0,0,i*height],true, main_switch_side)
            switch_pos(main_switch_side);
    }

}


/******************************************************************************

		Screws

/*****************************************************************************/

main_side_split_p0 = split_side_point(main_side0, 0.57);
plate0_screws = [thumb_front_out_p, thumb_front_middle_p, main_side_split_p0,
			main_corners[3], main_corners[2]]; 

main_side_split_p1 = split_side_point(main_side0, 0.81);
plate1_screws = [thumb_back_middle_p, main_side_split_p1, thumb_middle1_out_p, main_corners[4]]; 

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
plate_offs_y=-9;

screw_diameter = 3;
screw_head_diameter = 5.45 + 1;
module screw_hole() {
	cylinder(d2=screw_diameter, d1=screw_head_diameter, h=bottom_height);
}

module plate1() {
	hand_rest_length = 95;
	hand_rest_height = 22;
	hand_rest_p0 = main_corners[4] - [-30,hand_rest_length];
	hand_rest_p1 = main_corners[5] - [-15,hand_rest_length];
	hand_rest_middle0 = main_corners[4] + [20,-30];
	hand_rest_middle1 = main_corners[5] + [30,-30];
	hand_rest_corners = [thumb_back_out_p, main_corners[5], main_corners[4],
				, hand_rest_middle0, hand_rest_p0, hand_rest_p1];

	difference() {
        union() {
            bottom_plate(bottom_height, hand_rest_corners, corner_radius);
            full_plate();
        }
        translate([0, plate_offs_y,0])
            rotate(plate_chamfer_angle-180, [1, 0, 0])
                translate([-bigvalue/2,  -bigvalue/2, 0])
                    cube([bigvalue, bigvalue, bigvalue]);
		for (p = plate1_screws) {
			translate(p)
				screw_hole();
		}
	}

	bottom_plate(hand_rest_height,
			[hand_rest_middle0, hand_rest_middle1, hand_rest_p1, hand_rest_p0],
			corner_radius);
}

module plate0() {
    translate([0,0,bottom_height]){
        usb_holder(usb_bmini_data);
        usb_holder(usb_a_data);
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
        for (p = usb_screws_pos(usb_bmini_data)){
            translate(p)
                cylinder(d=screw_head_diameter,h=bottom_height);
        }
        for (p = usb_screws_pos(usb_a_data)){
            translate(p)
                cylinder(d=screw_head_diameter,h=bottom_height);
        }
        translate([3,0,bottom_height-0.5])
            controller_clearance();
	}
}


/******************************************************************************

		connector holders

/*****************************************************************************/


module connector_holder (data) {
    difference() {
        cube([get(data,"holder_width"),
              get(data,"holder_depth"),
              get(data,"holder_height")]);
        translate([get(data,"holder_width")/2-get(data,"width_connections")/2,0,0])
            cube([get(data,"width_connections"),
                  get(data,"depth_connections"),
                  get(data,"holder_height")]);
    }
    translate([get(data,"holder_width")/2-get(data,"connector_width")/2,
                get(data,"holder_depth"), 0]) 
        cube([get(data,"connector_width"), corner_radius - usb_holder_inset(data),
              get(data,"holder_height") + get(data,"pcb_height")]);
}

usb_a_data = [
    ["connector_height", 7.6],
    ["connector_width", 13.6],
    ["holder_width", 26],
    ["holder_depth", 20.16],
    ["holder_height", 2],
    ["holder_side_offset", 33],
    ["hole_side_offset", 1.1],
    ["hole_front_offset", 0.8],
    ["hole_radius", 1.75],
    ["depth_connections", 15],
    ["width_connections", 17],
    ["connector_overhang", 2.7],
    ["pcb_height", 1.7],
];

usb_bmicro_data = [
    ["holder_height", 2],
    ["depth_connections", 4],
    ["width_connections", 14],
    ["connector_overhang", 1.3],
    ["pcb_height", 1.7],
    ["connector_height", 3.0],
    ["connector_width", 8.0],
    ["holder_width", 21],
    ["holder_depth", 11.4],
    ["holder_side_offset", 35],
    ["hole_side_offset", 1.1],
    ["hole_front_offset", 0.9],
    ["hole_radius", 1.75],
];

usb_bmini_data = [
    ["holder_height", 2],
    ["depth_connections", 4],
    ["width_connections", 14],
    ["connector_overhang", 1.3],
    ["pcb_height", 1.7],
    ["connector_height", 4.1],
    ["connector_width", 7.7],
    ["holder_depth", 19.2],
    ["holder_width", 26],
    ["holder_side_offset", 5],
    ["hole_side_offset", 1.1],
    ["hole_front_offset", 0.7],
    ["hole_radius", 1.75],
];

function usb_holder_inset(data) = corner_radius - get(data,"connector_overhang") - 1.0;

function usb_holder_offset(data) = main_corners[3] +
                [-get(data, "holder_side_offset")-get(data, "holder_width"),
                usb_holder_inset(data) -get(data, "holder_depth"), 0];
function usb_screws_pos(data) = [
                usb_holder_offset(data) +
                    [get(data, "hole_radius") + get(data, "hole_side_offset"),
                     get(data, "holder_depth")
                        - get(data, "hole_radius")
                        - get(data, "hole_front_offset"), 0],
                usb_holder_offset(data) +
                   [get(data,"holder_width") -
                       (get(data,"hole_radius") + get(data,"hole_side_offset")),
                       get(data, "holder_depth")
                           - get(data, "hole_radius")
                           - get(data, "hole_front_offset"), 0]];
module usb_holder_screws(data) {
    for (p = usb_screws_pos(data)){
        translate(p)
            screw_hole();
    }
}
module usb_holder(data) {
    difference() {
        translate(usb_holder_offset(data))
            connector_holder(data);
        usb_holder_screws(data);
    }
}

module usb_hole(data) {
    tolerance0 = 0.4;
    tolerance1 = 1.5;
    translate(usb_holder_offset(data)) {
        translate([get(data,"holder_width")/2 - (get(data,"connector_width") + tolerance0)/2,
                    get(data,"holder_depth")-usb_holder_inset(data)+0,0])
            cube([get(data,"connector_width") + tolerance0, 10,
                    get(data,"holder_height")+get(data,"connector_height")+get(data,"pcb_height")]);
        translate([0,0,0])
            cube([get(data,"holder_width")+tolerance0,
                    get(data,"holder_depth")+tolerance1,
                    get(data,"holder_height")]);
    }

    tolerance2 = 0.3;
    m3_nut_max_w = 6.3;
    m3_nut_h = 2.4;

    for (p = usb_screws_pos(data)) {
        translate(p)
            cylinder(d=m3_nut_max_w+tolerance2,
                     h=get(data,"holder_height") + m3_nut_h + tolerance2);
    }
}

/******************************************************************************

		Misc

/*****************************************************************************/
module controller_clearance() {
    controller_width=20;
    controller_length=40;
    controller_height=15;
    translate(main_corners[2]+[-1,-controller_length-corner_radius-4])
        cube([controller_width,controller_length,controller_height]);
}

/******************************************************************************

		full model

/*****************************************************************************/


difference() {
    union() {
        difference() {
            union() {
                #main_outer();
                thumb_body(corner_radius)
                    switch_pos();
            }
            main_inner();
            thumb_body(0)
                switch_neg(1);
        }
        main_keys();
        thumb_keys();
        insets_pos();
    }
    matrix_rep(row_numbers, column_radius - height, matrix_offs,false, main_switch_side)
        switch_neg(1);

    thumb_keys_excess();
    main_keys_excess();
    main_switch_clearance();
    insets_neg();
    usb_hole(usb_a_data);
    usb_hole(usb_bmini_data);
    usb_holder_screws(usb_a_data);
    usb_holder_screws(usb_bmini_data);
    controller_clearance();
}

translate([0,0,-bottom_height]) {
    !plate0();
	plate1();
*screw_hole();

*thumb_front_row(0)
*    switch();
*thumb_middle_row(0)
*    switch();
*thumb_back_row(0)
*    switch();
*
*matrix_rep(row_numbers, column_radius, matrix_offs,false, main_switch_side)
*    	    switch(main_switch_side);
}
