// ============================================================
// PART 5 — Control Box (Base + Lid)
// AI-Based Smart Precision Irrigation System (1-Axis)
// ============================================================
// External: 200 x 150 x 80 mm
// Wall: 3mm, Material: PLA+, 0.20mm layer, 25% infill, 3 perimeters
// Print time: ~8 hours (base ~5h, lid ~3h)
// Print: Base open-face UP, Lid flat face DOWN
// ============================================================

/* [Box Dimensions] */
box_w    = 200;      // X (front-to-back)
box_d    = 150;      // Y (side-to-side)
box_h    = 80;       // Z total height
wall     = 3;        // Wall thickness
lid_h    = 15;       // Lid portion height (splits from box_h)

/* [LCD 1602 Window] */
lcd_w    = 71;       // Display visible area width
lcd_h    = 24;       // Display visible area height
lcd_off_top = 8;     // Offset from top of front face
lcd_mount_w = 80;    // PCB width (for screw tabs)
lcd_mount_h = 36;    // PCB height
lcd_screw   = 2.8;   // M2.5 self-tap holes

/* [Keypad 4x4 Window] */
kp_w     = 69;
kp_h     = 77;
kp_gap   = 5;        // Gap between LCD and keypad

/* [LED Holes] */
led_dia  = 5.1;      // 5mm LED + clearance
led_num  = 3;
led_spacing = 15;

/* [Cable Glands (PG7)] */
gland_dia = 12.5;    // PG7 hole diameter
gland_num = 4;
gland_spacing = 30;

/* [Ventilation] */
vent_slots    = 8;
vent_w        = 3;    // Slot width
vent_h        = 35;   // Slot height
vent_spacing  = 12;

/* [Internal Mounting] */
standoff_h   = 5;     // PCB standoff height
standoff_dia = 6;     // Standoff outer diameter
standoff_hole = 2.8;  // M2.5 self-tap

/* [Lid Fastening] */
lid_screw_dia = 3.2;  // M3 clearance
lid_boss_dia  = 8;    // Boss around screw hole
insert_dia    = 4.2;  // M3 brass heat-set insert

/* [Gasket Groove] */
gasket_w     = 1.5;
gasket_d     = 1.0;

$fn = 30;

// ============================================================
// BASE (bottom portion, contains all electronics)
// ============================================================
module control_box_base() {
    base_h = box_h - lid_h;

    difference() {
        union() {
            // Outer shell
            cube([box_w, box_d, base_h]);

            // Lid screw bosses (4 corners, extending up)
            for (bx = [wall + lid_boss_dia/2, box_w - wall - lid_boss_dia/2],
                 by = [wall + lid_boss_dia/2, box_d - wall - lid_boss_dia/2])
                translate([bx, by, 0])
                cylinder(d=lid_boss_dia, h=base_h);
        }

        // Hollow interior
        translate([wall, wall, wall])
        cube([box_w - 2*wall, box_d - 2*wall, base_h + 1]);

        // === FRONT FACE CUTOUTS (X = 0 face) ===

        // LCD window
        lcd_y = (box_d - lcd_w) / 2;
        lcd_z = base_h - lcd_off_top - lcd_h;
        translate([-1, lcd_y, lcd_z])
        cube([wall + 2, lcd_w, lcd_h]);

        // LCD mounting screw holes (4 corners of PCB)
        lcd_mount_y = (box_d - lcd_mount_w) / 2;
        lcd_mount_z = base_h - lcd_off_top - lcd_mount_h + 3;
        for (sy = [lcd_mount_y + 3, lcd_mount_y + lcd_mount_w - 3],
             sz = [lcd_mount_z + 3, lcd_mount_z + lcd_mount_h - 3])
            translate([-1, sy, sz])
            rotate([0, 90, 0])
            cylinder(d=lcd_screw, h=wall + 5);

        // Keypad window
        kp_y = (box_d - kp_w) / 2;
        kp_z = lcd_z - kp_gap - kp_h;
        translate([-1, kp_y, kp_z])
        cube([wall + 2, kp_w, kp_h]);

        // LED holes (above LCD)
        led_base_y = box_d/2 - (led_num - 1) * led_spacing / 2;
        for (li = [0 : led_num - 1])
            translate([-1, led_base_y + li * led_spacing, base_h - 4])
            rotate([0, 90, 0])
            cylinder(d=led_dia, h=wall + 2);

        // === REAR FACE CUTOUTS (X = box_w face) ===

        // Cable glands (PG7)
        gland_base_y = box_d/2 - (gland_num - 1) * gland_spacing / 2;
        for (gi = [0 : gland_num - 1])
            translate([box_w - wall - 1, gland_base_y + gi * gland_spacing, base_h / 2])
            rotate([0, 90, 0])
            cylinder(d=gland_dia, h=wall + 2);

        // === SIDE VENTILATION SLOTS (Y = 0 face) ===
        vent_start_x = (box_w - (vent_slots - 1) * vent_spacing) / 2;
        for (vi = [0 : vent_slots - 1])
            translate([vent_start_x + vi * vent_spacing - vent_w/2, -1, (base_h - vent_h) / 2])
            cube([vent_w, wall + 2, vent_h]);

        // Same on opposite side (Y = box_d)
        for (vi = [0 : vent_slots - 1])
            translate([vent_start_x + vi * vent_spacing - vent_w/2, box_d - wall - 1, (base_h - vent_h) / 2])
            cube([vent_w, wall + 2, vent_h]);

        // === LID SCREW HOLES (M3 heat-set inserts) ===
        for (bx = [wall + lid_boss_dia/2, box_w - wall - lid_boss_dia/2],
             by = [wall + lid_boss_dia/2, box_d - wall - lid_boss_dia/2])
            translate([bx, by, base_h - 12])
            cylinder(d=insert_dia, h=13);

        // === GASKET GROOVE (top rim) ===
        translate([wall + 2, wall + 2, base_h - gasket_d])
        difference() {
            cube([box_w - 2*wall - 4, box_d - 2*wall - 4, gasket_d + 1]);
            translate([gasket_w, gasket_w, -1])
            cube([box_w - 2*wall - 4 - 2*gasket_w, box_d - 2*wall - 4 - 2*gasket_w, gasket_d + 3]);
        }
    }

    // === INTERNAL STANDOFFS (for breadboard/PCB) ===
    // 4 standoffs for main breadboard
    color([0.5, 0.5, 0.45])
    for (sx = [15, 175], sy = [25, 70])
        translate([sx, sy, wall])
        difference() {
            cylinder(d=standoff_dia, h=standoff_h);
            translate([0, 0, -1])
            cylinder(d=standoff_hole, h=standoff_h + 2);
        }

    // 2 standoffs for ESP8266 NodeMCU (right wall)
    color([0.5, 0.5, 0.45])
    for (sy = [85, 130])
        translate([box_w - wall - 15, sy, wall])
        difference() {
            cylinder(d=standoff_dia, h=standoff_h);
            translate([0, 0, -1])
            cylinder(d=standoff_hole, h=standoff_h + 2);
        }

    // 2 standoffs for relay module (rear left)
    color([0.5, 0.5, 0.45])
    for (sx = [15, 50])
        translate([sx, box_d - 40, wall])
        difference() {
            cylinder(d=standoff_dia, h=standoff_h);
            translate([0, 0, -1])
            cylinder(d=standoff_hole, h=standoff_h + 2);
        }
}

// ============================================================
// LID (top portion)
// ============================================================
module control_box_lid() {
    difference() {
        union() {
            // Lid body
            cube([box_w, box_d, lid_h]);

            // Inner lip (seats into base opening)
            translate([wall + 0.3, wall + 0.3, -3])
            cube([box_w - 2*wall - 0.6, box_d - 2*wall - 0.6, 3]);
        }

        // Hollow (thin shell)
        translate([wall, wall, -1])
        cube([box_w - 2*wall, box_d - 2*wall, lid_h - wall + 1]);

        // Screw holes (M3 clearance, countersunk)
        for (bx = [wall + lid_boss_dia/2, box_w - wall - lid_boss_dia/2],
             by = [wall + lid_boss_dia/2, box_d - wall - lid_boss_dia/2]) {
            translate([bx, by, -5])
            cylinder(d=lid_screw_dia, h=lid_h + 10);
            // Countersink
            translate([bx, by, lid_h - wall - 1.5])
            cylinder(d1=lid_screw_dia, d2=7, h=3);
        }

        // Label engraving (top surface)
        translate([box_w/2, box_d/2, lid_h - 0.5])
        linear_extrude(0.6)
        text("CIE-349/408", size=8, halign="center", valign="center");

        translate([box_w/2, box_d/2 - 12, lid_h - 0.5])
        linear_extrude(0.6)
        text("Smart Irrigation", size=6, halign="center", valign="center");
    }
}

// ============================================================
// RENDER — choose what to display
// ============================================================

/* [Display] */
show_base = true;
show_lid  = true;
exploded  = true;   // Separate lid from base

if (show_base)
    control_box_base();

if (show_lid)
    translate([0, 0, exploded ? box_h + 20 : box_h - lid_h])
    control_box_lid();

// === PRINT NOTES ===
// BASE: Print open-face UP (bottom of box on bed)
//   - No supports needed
//   - Cable gland holes and vent slots are horizontal = clean
//   - Gasket groove prints cleanly at top layer
//
// LID: Print FLAT (outer face DOWN on bed)
//   - Inner lip prints upward
//   - Text engraving on top face
//   - No supports needed
//
// Post-processing:
//   - Install M3 brass heat-set inserts in base corner bosses
//     (use soldering iron at 220°C, press straight in)
//   - Test-fit LCD and keypad before final assembly
//   - Apply silicone gasket cord (1.5mm diameter) in groove
//   - Route cables through PG7 glands with strain relief
