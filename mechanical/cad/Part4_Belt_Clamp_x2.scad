// ============================================================
// PART 4 — Belt Clamp Plates (print 2x)
// AI-Based Smart Precision Irrigation System (1-Axis)
// ============================================================
// Dimensions: 20 x 12 x 4 mm each
// Material: PLA+, 0.16mm layer, 100% infill, 3 perimeters
// Print time: ~20 min (both)
// Print orientation: Tooth side UP
// CRITICAL: 100% infill — these clamp the belt under full tension
// ============================================================

/* [Clamp Parameters] */
clamp_w     = 20;     // Width (along belt direction)
clamp_d     = 12;     // Depth
clamp_h     = 4;      // Base thickness

/* [GT2 Tooth Profile] */
tooth_pitch = 2.0;    // GT2 standard pitch
tooth_depth = 0.75;   // Tooth engagement depth
tooth_width = 1.0;    // Tooth land width
num_teeth   = 9;      // Number of teeth across clamp width

/* [Bolt Holes] */
bolt_dia    = 3.2;    // M3 clearance
bolt_sep    = 14;     // Matches carriage clamp boss spacing

$fn = 30;

module belt_clamp() {
    difference() {
        union() {
            // Base plate
            cube([clamp_w, clamp_d, clamp_h]);

            // GT2 tooth profile (top surface)
            for (i = [0 : num_teeth - 1]) {
                translate([clamp_w/2 - (num_teeth * tooth_pitch)/2 + i * tooth_pitch + (tooth_pitch - tooth_width)/2, 0, clamp_h])
                cube([tooth_width, clamp_d, tooth_depth]);
            }
        }

        // === M3 BOLT HOLES ===
        translate([clamp_w/2 - bolt_sep/2 + 3, clamp_d/2, -1])
        cylinder(d=bolt_dia, h=clamp_h + tooth_depth + 2);

        translate([clamp_w/2 + bolt_sep/2 - 3, clamp_d/2, -1])
        cylinder(d=bolt_dia, h=clamp_h + tooth_depth + 2);

        // === ALIGNMENT GROOVE (helps locate belt) ===
        // Shallow channel on bottom face to center belt
        translate([(clamp_w - 7)/2, -0.1, -0.1])
        cube([7, clamp_d + 0.2, 0.5]);
    }
}

// === PRINT LAYOUT: 2 clamps side by side ===
belt_clamp();
translate([clamp_w + 5, 0, 0])
belt_clamp();

// === PRINT NOTES ===
// Print TOOTH SIDE UP at 0.16mm layer height
// 100% infill is mandatory — these are structural
// The teeth must mesh with GT2 belt tooth side
// After printing, verify teeth mesh with a belt scrap
// If teeth don't grip: increase tooth_depth to 0.85mm
//
// Assembly: Belt routes through carriage slot, tooth side
// faces clamp teeth, M3 bolts sandwich belt between
// carriage plate and clamp plate. Torque to 0.3 Nm.
