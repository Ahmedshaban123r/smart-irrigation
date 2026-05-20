// ============================================================
// PART 3 — Carriage Plate
// AI-Based Smart Precision Irrigation System (1-Axis)
// ============================================================
// Dimensions: 80 x 60 x 12 mm (base plate)
// Material: PLA+, 0.20mm layer, 50% infill, 4 perimeters
// Print time: ~2 hours
// Print orientation: Bearing-cavity side DOWN (flat on bed)
// CRITICAL: Highest infill part — dynamic loads from belt motion
// ============================================================

/* [Plate Parameters] */
plate_w       = 80;    // Along travel direction
plate_d       = 60;    // Perpendicular to travel
plate_h       = 12;    // Thickness

/* [LM8UU Bearing Cavities] */
bearing_od    = 14.85; // 15mm nominal - 0.15mm for press-fit
bearing_len   = 24;    // LM8UU length
bearing_sep   = 48;    // Center-to-center separation
bearing_y     = 30;    // Y center (centered in plate)
bearing_x1    = 16;    // First bearing X center
bearing_x2    = 64;    // Second bearing X center

/* [Belt Anchor Slots] */
belt_slot_w   = 2.5;   // GT2 belt is 6mm wide, slot for clamping
belt_slot_l   = 8;     // Slot length
belt_slot_h   = 8;     // Slot depth from top
clamp_hole_dia = 3.2;  // M3 clearance for clamp bolts
clamp_hole_sep = 14;   // Spacing between clamp bolt holes

/* [Pi Camera v2 Mount] */
cam_hole_dia  = 2.2;   // M2 clearance
cam_pattern_x = 21;    // Camera PCB hole spacing X
cam_pattern_y = 12.5;  // Camera PCB hole spacing Y
cam_base_x    = 52;    // Camera mount origin X
cam_base_y    = 20;    // Camera mount origin Y
cam_angle     = 30;    // Downward angle (degrees)
cam_wedge_w   = 30;    // Wedge width
cam_wedge_d   = 22;    // Wedge depth
cam_wedge_h   = 12;    // Wedge max height
cam_standoff_h = 5;    // Standoff height above wedge

/* [Water Nozzle] */
nozzle_bore   = 8.2;   // 8mm barbed fitting + 0.2mm clearance
nozzle_x      = 20;    // Nozzle X position
nozzle_y      = 30;    // Nozzle Y position (centered)

/* [Cable Tie Points] */
tie_slot_w    = 3.5;   // Width for standard cable tie
tie_slot_h    = 2;     // Thickness slot

$fn = 40;

module carriage_plate() {
    difference() {
        union() {
            // === BASE PLATE ===
            cube([plate_w, plate_d, plate_h]);

            // === CAMERA WEDGE (30° angled surface) ===
            translate([cam_base_x, cam_base_y, plate_h]) {
                // Wedge body with 30-degree slope
                hull() {
                    cube([cam_wedge_w, cam_wedge_d, 0.5]);
                    translate([0, cam_wedge_d * sin(cam_angle) * 0.3, cam_wedge_h * 0.7])
                    cube([cam_wedge_w, cam_wedge_d * 0.6, 0.5]);
                }
            }

            // === CAMERA STANDOFFS (4x M2 pillars on wedge) ===
            translate([cam_base_x, cam_base_y, plate_h])
            for (cx = [3, 3 + cam_pattern_x], cy = [3, 3 + cam_pattern_y]) {
                translate([cx, cy, 0])
                cylinder(d=5, h=cam_standoff_h);
            }

            // === NOZZLE REINFORCEMENT RING ===
            translate([nozzle_x, nozzle_y, 0])
            cylinder(d=nozzle_bore + 5, h=plate_h);

            // === BELT CLAMP BOSSES (raised pads for bolt grip) ===
            // Front side (Y=0)
            for (bx = [plate_w/2 - clamp_hole_sep/2, plate_w/2 + clamp_hole_sep/2])
                translate([bx, 3, plate_h])
                cylinder(d=7, h=2);
            // Back side (Y=plate_d)
            for (bx = [plate_w/2 - clamp_hole_sep/2, plate_w/2 + clamp_hole_sep/2])
                translate([bx, plate_d - 3, plate_h])
                cylinder(d=7, h=2);
        }

        // === LM8UU BEARING CAVITIES ===
        // Bearing 1
        translate([bearing_x1, bearing_y, plate_h/2])
        rotate([0, 0, 0])
        cylinder(d=bearing_od, h=bearing_len, center=true);

        // Bearing 2
        translate([bearing_x2, bearing_y, plate_h/2])
        cylinder(d=bearing_od, h=bearing_len, center=true);

        // Rod clearance through full plate (8mm rod passes through bearings)
        translate([bearing_x1, bearing_y, -1])
        cylinder(d=8.5, h=plate_h + 2);
        translate([bearing_x2, bearing_y, -1])
        cylinder(d=8.5, h=plate_h + 2);

        // === BELT ANCHOR SLOTS (both sides) ===
        // Front pair
        translate([plate_w/2 - belt_slot_w/2 - 5, -0.1, plate_h - belt_slot_h])
        cube([belt_slot_w, 8, belt_slot_h + 1]);
        translate([plate_w/2 + belt_slot_w/2 + 3, -0.1, plate_h - belt_slot_h])
        cube([belt_slot_w, 8, belt_slot_h + 1]);

        // Back pair
        translate([plate_w/2 - belt_slot_w/2 - 5, plate_d - 8, plate_h - belt_slot_h])
        cube([belt_slot_w, 8.1, belt_slot_h + 1]);
        translate([plate_w/2 + belt_slot_w/2 + 3, plate_d - 8, plate_h - belt_slot_h])
        cube([belt_slot_w, 8.1, belt_slot_h + 1]);

        // === BELT CLAMP BOLT HOLES (M3 through bosses) ===
        for (bx = [plate_w/2 - clamp_hole_sep/2, plate_w/2 + clamp_hole_sep/2]) {
            // Front
            translate([bx, 3, -1])
            cylinder(d=clamp_hole_dia, h=plate_h + 5);
            // Back
            translate([bx, plate_d - 3, -1])
            cylinder(d=clamp_hole_dia, h=plate_h + 5);
        }

        // === NOZZLE BORE (vertical, through full plate) ===
        translate([nozzle_x, nozzle_y, -1])
        cylinder(d=nozzle_bore, h=plate_h + 2);

        // === CAMERA MOUNT HOLES (M2 through standoffs) ===
        translate([cam_base_x, cam_base_y, -1])
        for (cx = [3, 3 + cam_pattern_x], cy = [3, 3 + cam_pattern_y])
            translate([cx, cy, 0])
            cylinder(d=cam_hole_dia, h=plate_h + cam_standoff_h + 5);

        // === CABLE TIE SLOTS (2x for tube and ribbon cable) ===
        // Slot 1: near nozzle for silicone tube
        translate([nozzle_x + 8, nozzle_y - tie_slot_w/2, -1])
        cube([tie_slot_h, tie_slot_w, plate_h + 2]);

        // Slot 2: near camera for CSI ribbon
        translate([cam_base_x - 5, cam_base_y + cam_pattern_y/2 - tie_slot_w/2, -1])
        cube([tie_slot_h, tie_slot_w, plate_h + 2]);

        // === WEIGHT REDUCTION (bottom pocket) ===
        translate([30, 12, -1])
        hull() {
            cylinder(d=6, h=4);
            translate([15, 0, 0]) cylinder(d=6, h=4);
            translate([15, 20, 0]) cylinder(d=6, h=4);
            translate([0, 20, 0]) cylinder(d=6, h=4);
        }
    }
}

// Render
carriage_plate();

// === PRINT NOTES ===
// CRITICAL ORIENTATION: Print bearing-cavity side DOWN on bed
//   - Best dimensional accuracy on bearing bores (XY plane)
//   - Camera wedge builds upward (no supports needed for 30°)
//   - Nozzle bore is vertical = perfect circularity
//
// Post-processing:
//   - Test-fit LM8UU bearings immediately after printing
//   - If too tight: use 15mm reamer or fine sandpaper
//   - If too loose: wrap bearing in thin Kapton tape
//   - Verify 8mm rod slides freely through both bearings
//
// Total carriage mass budget: <80g
//   Plate: ~35g | Camera: ~3g | Nozzle fitting: ~5g
//   Clamps: ~4g | Bearings: ~20g each = ~40g
//   WARNING: Bearings alone are ~40g, leaving 40g for everything else
