// ============================================================
// PART 6 — Smooth Rod End Holders (print 2x)
// AI-Based Smart Precision Irrigation System (1-Axis)
// ============================================================
// Dimensions: 25 x 25 x 18 mm each
// Material: PLA+, 0.20mm layer, 60% infill, 3 perimeters
// Print time: ~40 min (both)
// Print orientation: Flat face (extrusion contact) DOWN
// ============================================================

/* [Holder Parameters] */
holder_w    = 25;     // X width
holder_d    = 25;     // Y depth
holder_h    = 18;     // Z height

/* [Rod Bore] */
rod_dia     = 8.0;    // Nominal rod diameter (no interference here — clamped)
rod_z       = 10;     // Rod center height from base
slit_width  = 1.2;    // Clamping slit (slightly wider than bracket for adjustment)

/* [Pinch Bolt] */
pinch_dia   = 3.2;    // M3 clearance
pinch_nut_w = 5.6;    // M3 nut trap width (across flats)
pinch_nut_h = 2.5;    // M3 nut trap depth

/* [Extrusion Mount] */
ext_bolt_dia = 5.2;   // M5 clearance
ext_nut_w    = 8.1;   // M5 T-nut width
ext_nut_h    = 3.5;   // T-nut recess depth

/* [V-Groove Registration] */
// V-groove on bottom face seats into 2020 V-slot for self-alignment
vgroove_depth = 2;
vgroove_angle = 90;    // V-slot angle

$fn = 30;

module rod_end_holder() {
    difference() {
        union() {
            // Main body
            cube([holder_w, holder_d, holder_h]);

            // Reinforcement ears around rod (higher clamping area)
            translate([holder_w/2, holder_d/2, 0])
            cylinder(d=rod_dia + 8, h=holder_h);
        }

        // Trim to rectangular envelope
        // Left
        translate([-20, -1, -1])
        cube([20, holder_d + 2, holder_h + 2]);
        // Right
        translate([holder_w, -1, -1])
        cube([20, holder_d + 2, holder_h + 2]);
        // Front
        translate([-1, -20, -1])
        cube([holder_w + 2, 20, holder_h + 2]);
        // Back
        translate([-1, holder_d, -1])
        cube([holder_w + 2, 20, holder_h + 2]);

        // === ROD BORE (through-hole) ===
        translate([-1, holder_d/2, rod_z])
        rotate([0, 90, 0])
        cylinder(d=rod_dia, h=holder_w + 2);

        // === CLAMPING SLIT (vertical, from rod to top) ===
        translate([(holder_w - slit_width)/2, -1, rod_z])
        cube([slit_width, holder_d + 2, holder_h - rod_z + 1]);

        // === PINCH BOLT (horizontal M3, perpendicular to slit) ===
        // Bolt passes through one ear, across slit, threads into other ear
        translate([holder_w/2, -1, rod_z + rod_dia/2 + 3])
        rotate([-90, 0, 0])
        cylinder(d=pinch_dia, h=holder_d + 2);

        // Nut trap on one side
        translate([holder_w/2, holder_d - 3, rod_z + rod_dia/2 + 3])
        rotate([-90, 30, 0])
        cylinder(d=pinch_nut_w / cos(30), h=pinch_nut_h, $fn=6);

        // Bolt head clearance on other side
        translate([holder_w/2, -1, rod_z + rod_dia/2 + 3])
        rotate([-90, 0, 0])
        cylinder(d=6.5, h=4);

        // === EXTRUSION MOUNT BOLT (M5, vertical) ===
        translate([holder_w/2, holder_d/2, -1])
        cylinder(d=ext_bolt_dia, h=holder_h + 2);

        // T-nut recess on bottom
        translate([holder_w/2, holder_d/2, -1])
        cube([ext_nut_w, ext_nut_w, ext_nut_h + 1], center=true);

        // === V-GROOVE (bottom face, for 2020 V-slot alignment) ===
        translate([holder_w/2, -1, 0])
        rotate([-90, 45, 0])
        cylinder(d=vgroove_depth * 2 * sqrt(2), h=holder_d + 2, $fn=4);
    }
}

// === PRINT LAYOUT: 2 holders side by side ===
rod_end_holder();
translate([holder_w + 10, 0, 0])
rod_end_holder();

// === PRINT NOTES ===
// Orientation: V-groove face (bottom/extrusion side) on bed
//   - Rod bore in XY plane for best circularity
//   - Clamping slit prints cleanly (vertical)
//   - Nut trap prints as overhang — use 0.16mm for bridge layer
//
// Post-processing:
//   - Clear the clamping slit with a razor blade
//   - Verify 8mm rod slides in with mild friction
//   - Tighten pinch bolt until rod is locked (don't over-torque)
//   - The V-groove should seat into the 2020 V-slot
//     preventing rotation — verify before bolting down
//
// Assembly order:
//   1. Slide rod through both holders
//   2. Seat V-groove into 2020 extrusion slot
//   3. Insert M5 bolt through holder into T-nut
//   4. Tighten M5, then tighten M3 pinch bolts
