// ============================================================
// PART 2 — Idler-End Bracket
// AI-Based Smart Precision Irrigation System (1-Axis)
// ============================================================
// Dimensions: 70 x 70 x 15 mm
// Material: PLA+, 0.20mm layer, 30% infill, 3 perimeters
// Print time: ~2.5 hours
// Print orientation: Flat on back face
// ============================================================

/* [Bracket Parameters] */
bracket_w = 70;
bracket_d = 70;
bracket_h = 15;

/* [Idler Pulley] */
idler_shaft_dia   = 5.2;   // 5mm shaft + 0.2mm clearance
idler_center_x    = 35;
idler_center_y    = 35;
tension_slot_len  = 10;    // Slot travel for belt tension adjustment
tension_bolt_dia  = 5.2;   // M5 tension lock bolt

/* [Smooth Rod] */
rod_bore_dia      = 7.85;  // Press-fit for 8mm rod
rod_center_x      = 35;
rod_center_y      = 60;
rod_slit_width    = 1.0;
pinch_bolt_dia    = 3.2;

/* [Extrusion Mounting] */
ext_bolt_dia      = 5.2;
ext_cbore_dia     = 8.5;
ext_cbore_depth   = 3.5;
ext_hole_x        = [8, 62];
ext_hole_y        = [10, 50];

/* [Belt Path] */
belt_slot_w       = 8;
belt_slot_h       = 10;

$fn = 40;

module idler_end_bracket() {
    difference() {
        // Main body
        cube([bracket_w, bracket_d, bracket_h]);

        // === IDLER SHAFT HOLE + TENSION SLOT ===
        // The slot runs along X-axis to allow pulling idler outward
        translate([idler_center_x, idler_center_y, -1])
        hull() {
            cylinder(d=idler_shaft_dia, h=bracket_h + 2);
            translate([tension_slot_len, 0, 0])
            cylinder(d=idler_shaft_dia, h=bracket_h + 2);
        }

        // Tension lock bolt slot (parallel, offset from shaft)
        translate([idler_center_x, idler_center_y + 12, -1])
        hull() {
            cylinder(d=tension_bolt_dia, h=bracket_h + 2);
            translate([tension_slot_len, 0, 0])
            cylinder(d=tension_bolt_dia, h=bracket_h + 2);
        }

        // === SMOOTH ROD BORE ===
        translate([rod_center_x, rod_center_y, -1])
        cylinder(d=rod_bore_dia, h=bracket_h + 2);

        // === ROD CLAMPING SLIT ===
        translate([rod_center_x - rod_slit_width/2, rod_center_y, -1])
        cube([rod_slit_width, bracket_d - rod_center_y + 1, bracket_h + 2]);

        // === ROD PINCH BOLT ===
        translate([rod_center_x - 15, rod_center_y + 5, bracket_h / 2])
        rotate([0, 90, 0])
        cylinder(d=pinch_bolt_dia, h=30);

        // === EXTRUSION MOUNT HOLES ===
        for (ex = ext_hole_x, ey = ext_hole_y) {
            translate([ex, ey, -1])
            cylinder(d=ext_bolt_dia, h=bracket_h + 2);
            translate([ex, ey, -1])
            cylinder(d=ext_cbore_dia, h=ext_cbore_depth + 1);
        }

        // === BELT PATH CLEARANCE ===
        translate([idler_center_x - belt_slot_w/2, -1, bracket_h/2 - belt_slot_h/2])
        cube([belt_slot_w + tension_slot_len, idler_center_y - 10, belt_slot_h]);

        translate([idler_center_x - belt_slot_w/2, idler_center_y + 10, bracket_h/2 - belt_slot_h/2])
        cube([belt_slot_w + tension_slot_len, bracket_d - idler_center_y - 5, belt_slot_h]);

        // === CORNER RADII (stress relief) ===
        // Fillets at internal corners where slot meets body
        // (simplified as chamfers for printability)
    }
}

// Render
idler_end_bracket();

// === PRINT NOTES ===
// Orientation: Back face on print bed
// Supports: None needed
// The tension slot must be oriented in XY plane for accuracy
// Test-fit with idler pulley before full assembly
// If slot is too tight, sand with 120-grit or ream with 5mm drill
