$fn=50;

// size of the coverglass
coverslip_dims_x = 24;
coverslip_dims_y = 24;
coverslip_dims_z = 0.17; // glass thickness


coverslip_inner_brim_width = 2.5; //2.5; // support space beneath coverslip edges
coverslip_outer_brim_width = 2.5; //2.5; // support space beyond coverslip

// dimensions of the base 'slide' -- to fit into a standard holder
base_width = 75; // standard microscope slide = 75
base_depth = 25; // standard microscope slide = 25
base_thickness = 1.5;

// outer well properties - well within which the coverglass sits
base_well_thickness = 2.0;
base_well_height = 5;

// insert and main sample buffer well
insert_well_height = 10;
insert_gap_with_base = 0.5;    // gap between any side of the lid and the outer well on the slide part

num_insert_wells = 4;
insert_well_thickness = 2.0;

// plug-lid
plug_lid_gap_with_insert = 0.5;       // space between the plug wall and the well wall.
plug_gap_from_sample = 3; // space between bottom of the plug and the **bottom** of the coverslip

// gasket properties
gasket_width = 0.7; // width of the gasket channels or gasket ridges. This should be set to a multiple of your nozzle width!
gasket_depth = 0.8;   // positive value = depth of channel cut into insert base, to hold a fitted gasket.
                    //                  Set this to less than the actual thickness of your gasket 
                    //                  to allow some gasket to protrude.
                    // negative value = depth of a ridge protruding from insert base, e.g. to press
                    //                  into a flat gasket sheet.
                    // value of zero =  No ridges or channels flat insert base

// magnetic wings
magnet_thickness = 2.2;
magnet_radius = 5;

show_coverslip = false; // adds a coverslip to the model -- set to false before you print!

// set these to true/false to show/hide the components, e.g. those you wish to print
show_main_chamber = true;
show_insert_chamber = true;
show_plug_lid = true;
show_gasket_mould = true;

show_cross_section_a = false; // adds a box to show a cross section through the long side of the base
show_cross_section_b = false; // adds a box to show a cross section through the short side of the base
show_cross_section_c = false; // adds a box to show a cross section through the gasket mould
cross_section_height_tweak = 1.00; // adjust this to change the gap between the assembled components -- helps for display!

// calculated dims etc -- no need to edit anything here!

//centering
centre_x = base_width / 2;
centre_y = base_depth / 2;

// coverslip viewing hole
coverslip_hole_x = coverslip_dims_x - 2*coverslip_inner_brim_width;
coverslip_hole_y = coverslip_dims_y - 2*coverslip_inner_brim_width;

// base well dims
well_width_x = coverslip_dims_x + 2*coverslip_outer_brim_width + 2*base_well_thickness;
well_width_y = coverslip_dims_y + 2*coverslip_outer_brim_width + 2*base_well_thickness;
well_hole_x = coverslip_dims_x + 2*coverslip_outer_brim_width;
well_hole_y = coverslip_dims_y + 2*coverslip_outer_brim_width;

// insert main-well dims
lid_width_x = well_width_x - 2*base_well_thickness - insert_gap_with_base;
lid_width_y = well_width_y - 2*base_well_thickness - insert_gap_with_base;

lid_hole_x = coverslip_hole_x; //lid_width_x - 2*lid_thickness;
lid_hole_y = coverslip_hole_y; //lid_width_y - 2*lid_thickness;

lid_thickness_x = (lid_width_x - lid_hole_x)/2;
lid_thickness_y = (lid_width_y - lid_hole_y)/2;

wing_width_y = 3*magnet_radius;
wing_width_x = well_width_x + wing_width_y + wing_width_y;

insert_gasket_bounding_box_x = coverslip_hole_x + 2*gasket_width + (coverslip_inner_brim_width - gasket_width);
insert_gasket_bounding_box_y = coverslip_hole_y + 2*gasket_width + (coverslip_inner_brim_width - gasket_width);

//    insert_gasket_bounding_box_x = coverslip_hole_x + 2*gasket_width + (insert_well_thickness - gasket_width);
//    insert_gasket_bounding_box_y = coverslip_hole_y + 2*gasket_width + (insert_well_thickness - gasket_width);

// This module splits up the observation chamber into smaller wells
module lid_wells() {//(num_wells=4,x_bounds=30, y_bounds=30, z_bounds=10,well_gap=3.5,gasket_width=2, outside_penetration) {
    
    num_wells_x = floor(pow(num_insert_wells,0.5));
    num_wells_y = ceil(num_insert_wells / num_wells_x);
    
    // size of each well
    size_well_x = (lid_hole_x - ((num_wells_x-1)*insert_well_thickness))/num_wells_x;
    size_well_y = (lid_hole_y - ((num_wells_y-1)*insert_well_thickness))/num_wells_y;

    echo(str("well size: ",size_well_x," mm by ", size_well_y, " mm"));
    echo(str("well gap: ",insert_well_thickness, " mm"));    
    
    well_vol = size_well_x * size_well_y * insert_well_height;
    echo(str("well area: ", (size_well_x * size_well_y)/100," cm2"));
    echo(str("max. volume (without lid): ",well_vol," ul per well"));
    
    if (num_insert_wells > 1) {
    
    union() {
        for (ix = [1:num_wells_x]) {
            for (iy = [1:num_wells_y]) {
                    sub_well_offset_x = (ix-1)*(size_well_x + insert_well_thickness);
                    sub_well_offset_y = (iy-1)*(size_well_y + insert_well_thickness);
                
                    translate([sub_well_offset_x, sub_well_offset_y, -2*insert_well_height])
                    cube([size_well_x, size_well_y, 3* insert_well_height]);
                }
            }
    }
    } else {
        translate([0, 0, -2*insert_well_height]) cube([lid_hole_x, lid_hole_y, 3*insert_well_height]);
    }
}




// This module generates a gasket grid
module inner_gasket (gasket_width=gasket_width) {

        union() {
           
           // outer gasket
           difference() {
                  cube([insert_gasket_bounding_box_x, insert_gasket_bounding_box_y, 2*abs(gasket_depth)]);
                    translate([gasket_width, gasket_width, -abs(gasket_depth)]) {
                        cube([insert_gasket_bounding_box_x - 2*gasket_width,
                               insert_gasket_bounding_box_y - 2*gasket_width,
                               4*abs(gasket_depth)]);
                    }
                }
        
            //inner gaskets        
            if (num_insert_wells > 1) {
                
                num_wells_x = floor(pow(num_insert_wells,0.5));
                num_wells_y = ceil(num_insert_wells / num_wells_x);
                
                // gasket strips along x
                inital_offset = gasket_width + 0.5*(coverslip_inner_brim_width - gasket_width);
                
                per_x_offset = ((lid_hole_x - ((num_wells_x-1)*insert_well_thickness))/num_wells_x) + 0.5*(insert_well_thickness - gasket_width);
                per_y_offset = ((lid_hole_y - ((num_wells_y-1)*insert_well_thickness))/num_wells_y) + 0.5*(insert_well_thickness - gasket_width);
                
                for (gx = [1:num_wells_x - 1]) {
                    translate([inital_offset + (gx * per_x_offset) +  (gx-1)*(insert_well_thickness - 0.5*(insert_well_thickness - gasket_width)), 0, 0])
                        cube([gasket_width, insert_gasket_bounding_box_y, 2*abs(gasket_depth)]);
                    }
                // gasket strips along y
                for (gy = [1:num_wells_y - 1]) {
                    translate([ 0, inital_offset + (gy * per_y_offset) +  (gy-1)*(insert_well_thickness - 0.5*(insert_well_thickness - gasket_width)), 0])
                        cube([insert_gasket_bounding_box_x, gasket_width, 2*abs(gasket_depth)]);
                }
            }
        }
    }




// This module generates a snug-fitting lid with plugs to reduce the buffer volume and limit oxygen ingress
module lid_plugs(vent_tube=true,fitting_gap=plug_lid_gap_with_insert) { //(num_wells=4,x_bounds=30, y_bounds=30, z_bounds=10,well_gap=3.5,gasket_width=2, gasket_depth=1) {
    
    num_wells_x = floor(pow(num_insert_wells,0.5));
    num_wells_y = ceil(num_insert_wells / num_wells_x);
      
    plug_extra = abs(min(0,gasket_depth)); // declarative languages are super annoying.
    
    plug_lid_thickness = 3;
    plug_height = insert_well_height + base_thickness + plug_lid_thickness - plug_gap_from_sample + plug_extra;
    
    sub_well_x = (lid_hole_x - (num_wells_x-1)*insert_well_thickness)/num_wells_x - fitting_gap;
    sub_well_y = (lid_hole_y - (num_wells_y-1)*insert_well_thickness)/num_wells_y - fitting_gap;

    well_vol = floor((sub_well_x * sub_well_y * fitting_gap) + 3.141*plug_height);
    echo(str("max. volume (with lid): ",well_vol," ul per well"));
    


    
    if (num_insert_wells > 1) {
    
        difference() {
            union() {
                
                // 'top' of the lid
                translate([-2.5,-2.5,0]) cube([lid_hole_x+5, lid_hole_y+5, plug_lid_thickness]);
                
                // plugs for each well
                for (px = [1:num_wells_x]) {
                    for (py = [1:num_wells_y]) {
                            sub_well_offset_x = (px-1)*(sub_well_x + insert_well_thickness + fitting_gap) + 0.5*fitting_gap;
                            sub_well_offset_y = (py-1)*(sub_well_y + insert_well_thickness + fitting_gap) + 0.5*fitting_gap;
                        
                            translate([sub_well_offset_x, sub_well_offset_y, 0])
                            cube([sub_well_x, sub_well_y, plug_height]);
                        }
                    }
            }
            
            // remove buffer escape tube
            if (vent_tube) {
                for (cx = [1:num_wells_x]) {
                for (cy = [1:num_wells_y]) {
                        sub_well_offset_x = (cx-1)*(sub_well_x + insert_well_thickness + fitting_gap) + 0.5*fitting_gap + 0.5*sub_well_x;
                        sub_well_offset_y = (cy-1)*(sub_well_y + insert_well_thickness + fitting_gap) + 0.5*fitting_gap + 0.5*sub_well_y;
                    
                        translate([sub_well_offset_x, sub_well_offset_y, -2])
                         cylinder(h=plug_height+4, r1=1,r2=1);
                    }
                }
            }
            
//            // cut corner for orientation
//            translate([-5, lid_hole_y-3 ,-5]) rotate(45) cube(10,10,10);
        }
    } else {
        difference() {
            cube([lid_hole_x, lid_hole_y, plug_height]);
            translate([0.5*lid_hole_x, 0.5*lid_hole_y, -2])
                cylinder(h=plug_height+4, r1=1,r2=1);
        }
    }
}


// cross section differencer
difference() {
union() {





// -----------------------------------------------------------------------
// the main chamber
// -----------------------------------------------------------------------
if (show_main_chamber) {

    color([0.95,0.35,0.75])
    difference() {
        union() {
            
            // the slide base
            cube([base_width,base_depth,base_thickness]);
            hull() {
                cube([(base_width - wing_width_x)/2,base_depth,base_thickness]);
                translate([0,0.5*(base_depth-wing_width_y),insert_well_height - base_well_height - 0.5]) cube([(base_width - wing_width_x)/2,wing_width_y,1]);
            }
            
            translate([base_width - (base_width - wing_width_x)/2,0,0]) hull() {
                cube([(base_width - wing_width_x)/2,base_depth,base_thickness]);
                translate([0,0.5*(base_depth-wing_width_y),insert_well_height - base_well_height - 0.5]) cube([(base_width - wing_width_x)/2,wing_width_y,1]);
            }
            
            // the outer well
            translate([centre_x - 0.5*well_width_x , centre_y - 0.5*well_width_y, 0])
                cube([well_width_x, well_width_y, base_well_height+base_thickness]);
                
            
            // magnetic wings
            translate([centre_x-wing_width_y-0.5*well_width_x,centre_y-(0.5*wing_width_y),0])
                difference() {
                    
                    hull() {
                        translate([0,-0.5*(lid_width_y-wing_width_y),0]) cube([wing_width_x,lid_width_y, 1]);
                        translate([0,0,insert_well_height - base_well_height - 0.5]) cube([wing_width_x,wing_width_y, 1 + abs(min(0,gasket_depth))]);
                    }
                    
                    //cube([wing_width_x,wing_width_y,base_well_height+base_thickness]);
                    
                    
                    translate([wing_width_x-0.5*wing_width_y,
                               0.5*wing_width_y, 
                               base_well_height + base_thickness - magnet_thickness])
                        cylinder(h=magnet_thickness+0.5, r1=magnet_radius, r2=magnet_radius);
                    translate([0.5*wing_width_y,0.5*wing_width_y,base_well_height+base_thickness - magnet_thickness])
                        cylinder(h=magnet_thickness+0.5, r1=magnet_radius, r2=magnet_radius);
                }
     
        }
        
        // main well hole
        translate([centre_x - 0.5*well_width_x + base_well_thickness, centre_y - 0.5*well_width_y + base_well_thickness, 0.5*base_thickness]) 
            cube([well_hole_x,well_hole_y,2*base_well_height]);
        
        // coverslip shallow hole
        translate([centre_x - 0.5*coverslip_dims_x-0.5, centre_y - 0.5*coverslip_dims_x-0.5, (0.5*base_thickness)- 2*coverslip_dims_z])
             union() {
                translate([0,0,0]) cube([coverslip_dims_x+1,coverslip_dims_y+1,5*coverslip_dims_z]); // the dent for the slip
                translate([0,coverslip_dims_y-0.5,-0.1])
                   hull() {
                        cylinder(h=1,r1=1,r2=1);
                        translate([1,1,0]) cylinder(h=1,r1=1,r2=1);
                       translate([-1,0,0]) cube([2,2,1]);
                    }
            }

        // coverslip viewing hole
        translate([centre_x - 0.5*coverslip_hole_x, centre_y - 0.5*coverslip_hole_y, -base_thickness])
            cube([coverslip_hole_x,coverslip_hole_y,3*base_thickness]);
            
    //    // well hole bevel
    //      // color([0.75,0.25,0.75, 0.500])
    //       translate([0,0,(0.5*base_thickness)- coverslip_dims_z-0.5]) hull() {
    //        translate([centre_x - 0.5*coverslip_hole_x, centre_y - 0.5*coverslip_hole_y, 0])
    //           cube([coverslip_hole_x,coverslip_hole_y,0.5]);
    //       translate([centre_x - 0.55*coverslip_hole_x, centre_y - 0.55*coverslip_hole_y, -1])
    //           cube([1.1*coverslip_hole_x,1.1*coverslip_hole_y,0.5]);
    //    }

    }
}



// -----------------------------------------------------------------------
// a fake coverslip
// -----------------------------------------------------------------------
if (show_coverslip) {
     translate([centre_x - 0.5*coverslip_dims_x, centre_y - 0.5*coverslip_dims_x, (0.5*base_thickness)- coverslip_dims_z]) 
        color([0.75,0.75,0.75, 0.5])
        cube([coverslip_dims_x,coverslip_dims_y,coverslip_dims_z]);
}





// -----------------------------------------------------------------------
// the insert
// -----------------------------------------------------------------------

if (show_insert_chamber) {
    //// remove commenting here to show the insert assembled with the base
//        translate([centre_x*2,0, insert_well_height + base_thickness + coverslip_dims_z + cross_section_height_tweak - min(0,gasket_depth)])
//        rotate([0,180,0])

    // commenting next line when showing the insert assembled with the base
    translate([0,1.5*coverslip_dims_y,0])

   // color([0.95,0.75,0.25,1.0])
    difference() {
        
        union() { // combines a box for the buffer/sample + magnet wings + (optional) raised ridges
            
            
            // insert outer box
            translate([centre_x - 0.5*lid_width_x , centre_y - 0.5*lid_width_y, 0])
                cube([lid_width_x, lid_width_y, insert_well_height + base_thickness]);
        
            
            // magnetic wings
            translate([centre_x-wing_width_y-0.5*well_width_x, centre_y-(0.5*wing_width_y), 0])
                difference() {
                    hull() {
                        translate([0,-0.5*(lid_width_y-wing_width_y),0]) cube([wing_width_x,lid_width_y, 1]);
                        translate([0,0,insert_well_height - base_well_height -0.5]) cube([wing_width_x,wing_width_y, 1 + abs(min(0,gasket_depth))]);
                    }
                    translate([wing_width_x-0.5*wing_width_y,
                               0.5*wing_width_y,
                               //insert_well_height - base_well_height - 0.5*(gasket_depth) - magnet_thickness
                               insert_well_height - base_well_height - magnet_thickness + 1 + abs(min(0,gasket_depth))])
                        cylinder(h=magnet_thickness+0.5, r1=magnet_radius, r2=magnet_radius);
                    translate([0.5*wing_width_y,
                               0.5*wing_width_y,
                               insert_well_height - base_well_height - magnet_thickness + 1 + abs(min(0,gasket_depth))])
                        cylinder(h=magnet_thickness+0.5, r1=magnet_radius, r2=magnet_radius);
                }
                
            // gasket ridges
            if (gasket_depth < 0) {
                offset_extra = 2*abs(min(0,gasket_depth)); // declarative languages are super annoying.
                z_offset = (insert_well_height + base_thickness) - gasket_depth - offset_extra;
                translate([centre_x - 0.5*(lid_hole_x + coverslip_inner_brim_width + gasket_width),
                           centre_y - 0.5*(lid_hole_y + coverslip_inner_brim_width + gasket_width),
                           z_offset]) 
                  inner_gasket();
            }      
        }
        
        // from the main shape subtract the wells and (optional) gasket channels
        
        // lid well cutout
        translate([centre_x - (0.5*lid_hole_x), // - 0.5*abs(gasket_width) - 0.5*insert_well_thickness, // - 0.5*lid_thickness_x - 0.5*abs(gasket_width), 
                   centre_y - (0.5*lid_hole_x), // - 0.5*lid_thickness_y - 0.5*abs(gasket_width), 
                   insert_well_height - gasket_depth  + 0.5*base_thickness + 0.5])
            lid_wells(); //(num_insert_wells,lid_hole_x, lid_hole_y, insert_well_height + 0.5*base_thickness + 0.5,insert_well_thickness,gasket_width,lid_thickness_x);
        
        // gasket channel
        if (gasket_depth >= 0) {
            
            offset_extra = 2*abs(min(0,gasket_depth)); // declarative languages are super annoying.
            z_offset = (insert_well_height + base_thickness) - gasket_depth - offset_extra;
            translate([centre_x - 0.5*(lid_hole_x + coverslip_inner_brim_width + gasket_width),
                       centre_y - 0.5*(lid_hole_y + coverslip_inner_brim_width + gasket_width),
                       z_offset])
                  inner_gasket();
              }
              
    //    }

    }
}

// -----------------------------------------------------------------------
// plugs - reduces exposure of sample buffer to atmosphere
// -----------------------------------------------------------------------
if (show_plug_lid) {
    //// remove commenting here to show the insert assembled with the base
//    translate([centre_x*2,0, insert_well_height + 3* base_thickness +coverslip_dims_z + 1.2*cross_section_height_tweak - min(0,gasket_depth)])
//    rotate([0,180,0])

    // commenting next line when showing the insert assembled with the base
    translate([-coverslip_dims_x,3*coverslip_dims_y,0])

    color([0.15,0.85,0.75])
        // lid plugs
        translate([(centre_x - 0.5*lid_width_x) + lid_thickness_x,
                   (centre_y - 0.5*lid_width_y) + lid_thickness_y,
                    0])
            lid_plugs(); //(num_insert_wells,lid_hole_x, lid_hole_y, insert_well_height + 0.5*base_thickness + 0.5,insert_well_thickness,gasket_width,lid_thickness_x);    
}

// -----------------------------------------------------------------------
// Casting tray - make your own gaskets here in PDMS or 3% agarose!
// -----------------------------------------------------------------------


//close of cross section
}
if (show_cross_section_a) translate([-5,-37.5,-5]) color([1,0,0]) cube([100,50,50]); // cross section block
if (show_cross_section_b) translate([-5,-5,-5]) color([1,0,0]) cube([0.5*base_width,50,50]); // cross section block
}
//close of cross section


difference() {
if (show_gasket_mould) {
    
    tray_thickness = 3;
                
    // base of the casting tray - gasket will slightly overhang the coverslip outer edges
    cast_tray_x = lid_width_x - coverslip_outer_brim_width;
    cast_tray_y = lid_width_y - coverslip_outer_brim_width;
    
    gap_above_cslip = insert_well_height;
    
    wall_height = tray_thickness + abs(gasket_depth);
    
    rotate([180,0,0]) { translate([1.5*coverslip_dims_x,-5*coverslip_dims_y,-2*wall_height - tray_thickness]) {
            

                
            difference() {
                
                     // outer mould
                     translate([-9,-9,1]) difference() {
                        cube([cast_tray_x+18, cast_tray_y+18, 2*wall_height + tray_thickness - 1]);
                     }
                     
                union() {
                    // base of the tray
                    cube([cast_tray_x, cast_tray_y, tray_thickness]);
                    
                    if (gasket_depth < 0) {
                    // gasket ridges
                        translate([0.5*(cast_tray_x - insert_gasket_bounding_box_x),
                                   0.5*(cast_tray_y - insert_gasket_bounding_box_y),
                                   tray_thickness - abs(gasket_depth)]) 
                            inner_gasket(gasket_width=1.1*gasket_width);
                    }
                    

                    
                    // sample wells
                    difference() {
                         translate([0.5*(cast_tray_x - lid_hole_x),
                                    0.5*(cast_tray_y - lid_hole_y),
                                    0])        
                            lid_plugs(vent_tube=false,fitting_gap=0);
                        
                            // delete top of well plugs
                           translate([0,0,tray_thickness + abs(gasket_depth)]) cube([lid_hole_x+10, lid_hole_y+10, insert_well_height + base_thickness]);
                     }
                     
                     // inner wall
                    translate([-2.5,-2.5,0]) difference() {
                       cube([cast_tray_x+5, cast_tray_y+5, wall_height]);
                       translate([2.5,2.5,-0.5*wall_height]) cube([cast_tray_x, cast_tray_y, 2*wall_height]);    
                     }
                     
                      // outer wall
                     translate([-4.5,-4.5,0]) difference() {
                        cube([cast_tray_x+9, cast_tray_y+9, 2*wall_height]);
                        translate([2,2,-0.5*wall_height]) cube([cast_tray_x+5, cast_tray_y+5, 4*wall_height]);
                        //overflow tube
                        translate([0.5*(cast_tray_x+9),-2,wall_height+1]) cube([10,5,5]); //scale([1,1,0.3]) rotate([90,0,0]) cylinder(3,3,5);
                     }
                     

                }
                if (gasket_depth > 0) {
                // gasket ridges
               translate([0.5*(cast_tray_x - insert_gasket_bounding_box_x),
                           0.5*(cast_tray_y - insert_gasket_bounding_box_y),
                           tray_thickness - abs(gasket_depth)]) 
                    inner_gasket(gasket_width=0.8*gasket_width);
                }
        }
    }
}
}
// if (show_cross_section_a) translate([-5,-38,-5]) color([0,0,1]) cube([100,50,50]); // cross section block
if (show_cross_section_c) translate([coverslip_dims_x,1.5*coverslip_dims_y,-5]) color([1,0,0]) cube([base_width,50,50]); // cross section block

}


// some useful information will be displayed in the console window

echo(str("Coverslip viewport = ", coverslip_hole_x, " by ", coverslip_hole_y,  " mm")) ;

outer_well_volume = (well_hole_x * well_hole_y * base_well_height)/pow(10,3);
echo(str("Outer well size = ", well_hole_x, " mm by ", well_hole_y, " mm by ", base_well_height, " mm (",outer_well_volume," ml total)")) ;

lid_volume = (lid_hole_x * lid_hole_y * insert_well_height)/pow(10,3);
echo(str("Inner well size = ", lid_hole_x, " mm by ", lid_hole_y,  " mm by ", insert_well_height ,"mm (",lid_volume," ml total)")) ;