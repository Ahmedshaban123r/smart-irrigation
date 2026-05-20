// ============================================================
// PART 1 — Drive-End Bracket
// AI-Based Smart Precision Irrigation System (1-Axis)
// ============================================================
// Dimensions: 80 x 70 x 20 mm
// Material: PLA+, 0.20mm layer, 40% infill, 4 perimeters
// Print time: ~3.5 hours
// Print orientation: Flat on back face (NEMA17 face UP)
// ============================================================

/* [Bracket Parameters] */
bracket_w = 80;       // X width
bracket_d = 70;       // Y depth
bracket_h = 20;       // Z thickness

/* [NEMA17 Parameters] */
nema_hole_spacing = 31;    // Bolt circle (center-to-center)
nema_center_bore  = 23;    // Motor collar clearance
nema_screw_dia    = 3.2;   // M3 clearance (0.2mm over)
nema_center_x     = 40;    // Motor center X
nema_center_y     = 35;    // Motor center Y

/* [Smooth Rod] */
rod_bore_dia      = 7.85;  // 8mm rod, 0.15mm interference for press-fit
rod_center_x      = 40;
rod_center_y      = 60;
rod_slit_width    = 1.0;   // Clamping slit
pinch_bolt_dia    = 3.2;   // M3 pinch bolt

/* [Extrusion Mounting] */
ext_bolt_dia      = 5.2;   // M5 clearance
ext_cbore_dia     = 8.5;   // M5 counterbore
ext_cbore_depth   = 4;     // Counterbore depth
ext_hole_x        = [8, 72]; // Bolt X positions
ext_hole_y        = [10, 50]; // Bolt Y positions

/* [Limit Switch Tab] */
sw_tab_w          = 15;
sw_tab_d          = 18;
sw_tab_h          = 20;
sw_hole_dia       = 2.2;   // M2 clearance
sw_hole_spacing   = 9.5;   // Standard micro switch

/* [Belt Path] */
belt_slot_w       = 8;
belt_slot_h       = 10;

$fn = 40;

module drive_end_bracket() {
    difference() {
        union() {
            // Main bracket body
            cube([bracket_w, bracket_d, bracket_h]);

            // Limit switch mounting tab (extends from side)
            translate([bracket_w - 5, (bracket_d - sw_tab_d) / 2 - 10, 0])
            cube([sw_tab_w + 5, sw_tab_d, sw_tab_h]);
        }

        // === NEMA17 CENTER BORE ===
        translate([nema_center_x, nema_center_y, -1])
        cylinder(d=nema_center_bore, h=bracket_h + 2);

        // === NEMA17 MOUNTING HOLES (31mm bolt circle) ===
        for (dx = [-1, 1], dy = [-1, 1]) {
            translate([
                nema_center_x + dx * nema_hole_spacing / 2,
                nema_center_y + dy * nema_hole_spacing / 2,
                -1
            ])
            cylinder(d=nema_screw_dia, h=bracket_h + 2);

            // Counterbore on bottom for bolt heads
            translate([
                nema_center_x + dx * nema_hole_spacing / 2,
                nema_center_y + dy * nema_hole_spacing / 2,
                -1
            ])
            cylinder(d=6.5, h=ext_cbore_depth + 1);
        }

        // === SMOOTH ROD BORE (press-fit) ===
        translate([rod_center_x, rod_center_y, -1])
        cylinder(d=rod_bore_dia, h=bracket_h + 2);

        // === ROD CLAMPING SLIT ===
        translate([rod_center_x - rod_slit_width/2, rod_center_y, -1])
        cube([rod_slit_width, bracket_d - rod_center_y + 1, bracket_h + 2]);

        // === ROD PINCH BOLT (M3, horizontal) ===
        translate([rod_center_x - 15, rod_center_y + 5, bracket_h / 2])
        rotate([0, 90, 0])
        cylinder(d=pinch_bolt_dia, h=30);

        // === EXTRUSION MOUNT HOLES (M5 counterbored) ===
        for (ex = ext_hole_x, ey = ext_hole_y) {
            // Through hole
            translate([ex, ey, -1])
            cylinder(d=ext_bolt_dia, h=bracket_h + 2);
            // Counterbore (bottom side)
            translate([ex, ey, -1])
            cylinder(d=ext_cbore_dia, h=ext_cbore_depth + 1);
        }

        // === BELT PATH CLEARANCE SLOTS ===
        // Slot for belt to pass from motor pulley to carriage
        translate([nema_center_x - belt_slot_w/2, -1, bracket_h / 2 - belt_slot_h / 2])
        cube([belt_slot_w, nema_center_y - nema_center_bore/2, belt_slot_h]);

        translate([nema_center_x - belt_slot_w/2, nema_center_y + nema_center_bore/2, bracket_h / 2 - belt_slot_h / 2])
        cube([belt_slot_w, bracket_d - nema_center_y, belt_slot_h]);

        // === LIMIT SWITCH HOLES (M2) ===
        sw_base_x = bracket_w + sw_tab_w / 2;
        sw_base_y = (bracket_d - sw_tab_d) / 2 - 10;
        translate([sw_base_x, sw_base_y + sw_tab_d/2 - sw_hole_spacing/2, -1])
        cylinder(d=sw_hole_dia, h=sw_tab_h + 2);
        translate([sw_base_x, sw_base_y + sw_tab_d/2 + sw_hole_spacing/2, -1])
        cylinder(d=sw_hole_dia, h=sw_tab_h + 2);

        // === WEIGHT REDUCTION POCKET (underside) ===
        translate([20, 15, -1])
        hull() {
            cylinder(d=8, h=6);
            translate([40, 0, 0]) cylinder(d=8, h=6);
            translate([40, 15, 0]) cylinder(d=8, h=6);
            translate([0, 15, 0]) cylinder(d=8, h=6);
        }
    }
}

// Render
drive_end_bracket();

// === PRINT NOTES ===
// Orientation: Print with NEMA17 face pointing UP (back face on bed)
// Layer lines perpendicular to motor pulling force
// Supports: None needed
// First layer: 0.25mm for adhesion
// Brim: 5mm recommended for flat adhesion
