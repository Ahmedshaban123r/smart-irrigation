// ============================================================
// AI-Based Smart Precision Irrigation System
// 1-Axis Linear Redesign — Full Assembly Visualization
// CIE-349/408 Embedded Systems — Spring 2026
// ============================================================
// Units: millimeters
// Open in OpenSCAD → Press F5 (Preview) or F6 (Render)
// Use the parameter panel (Window > Customizer) to toggle zones
// ============================================================

/* [Display Controls] */
show_frame       = true;   // Zone B: 2020 extrusions + rod
show_control_box = true;   // Zone A: electronics enclosure
show_carriage    = true;   // Zone C: moving platform
show_motor       = true;   // NEMA17 + pulley
show_idler       = true;   // Idler pulley assembly
show_belt        = true;   // GT2 belt path
show_pump        = true;   // Submersible pump + tube
show_plants      = true;   // Plant pots on ground
show_pi          = true;   // Raspberry Pi 4
show_camera      = true;   // Pi Camera v2 on carriage
show_limit_sw    = true;   // Homing limit switch
show_brackets    = true;   // Drive-end + idler-end brackets
show_rod_holders = true;   // Smooth rod end holders
show_labels      = false;  // Text labels (slow render)

/* [Carriage Position] */
// Plant index 0-4 or manual step position
carriage_plant_index = 2;  // [0:4]

/* [System Parameters] */
num_plants       = 5;
plant_spacing    = 80;     // mm between plants
first_plant_off  = 50;     // mm from home to first plant
rail_length      = 500;    // mm (2020 extrusion length)
rail_spacing     = 60;     // mm center-to-center
rod_diameter     = 8;      // mm smooth rod
frame_height     = 250;    // mm above ground (leg height)

// ============================================================
// DERIVED PARAMETERS
// ============================================================
carriage_x = first_plant_off + carriage_plant_index * plant_spacing;
belt_y_offset = rail_spacing / 2;
rod_y = 0; // centered between rails

// ============================================================
// COLOR PALETTE
// ============================================================
col_aluminum  = [0.75, 0.75, 0.78, 1.0];
col_black     = [0.15, 0.15, 0.15, 1.0];
col_pla_gray  = [0.55, 0.55, 0.50, 1.0];
col_pla_blue  = [0.30, 0.50, 0.75, 1.0];
col_green_pcb = [0.10, 0.45, 0.15, 1.0];
col_red       = [0.85, 0.20, 0.15, 1.0];
col_orange    = [0.90, 0.55, 0.10, 1.0];
col_belt      = [0.20, 0.20, 0.22, 1.0];
col_steel     = [0.60, 0.60, 0.62, 1.0];
col_copper    = [0.72, 0.45, 0.20, 1.0];
col_tube      = [0.70, 0.85, 0.90, 0.5];
col_soil      = [0.40, 0.28, 0.15, 1.0];
col_plant     = [0.20, 0.60, 0.15, 1.0];
col_pot       = [0.65, 0.35, 0.15, 1.0];
col_camera    = [0.25, 0.25, 0.28, 1.0];
col_pi        = [0.10, 0.50, 0.15, 1.0];
col_yellow    = [0.95, 0.85, 0.20, 1.0];
col_white     = [0.92, 0.92, 0.90, 1.0];

// ============================================================
// PRIMITIVE MODULES
// ============================================================

// 2020 V-Slot Aluminum Extrusion (simplified cross-section)
module extrusion_2020(length) {
    color(col_aluminum)
    difference() {
        cube([20, 20, length], center=false);
        // V-slot grooves (simplified)
        for (side = [0:3]) {
            rotate([0, 0, side * 90])
            translate([10, -0.5, -1])
            rotate([0, 0, 0])
            translate([-3, 0, 0])
            cube([6, 4, length + 2]);
        }
        // Center bore
        translate([10, 10, -1])
        cylinder(d=4.2, h=length+2, $fn=20);
    }
}

// Simplified 2020 extrusion (faster render)
module extrusion_2020_simple(length) {
    color(col_aluminum)
    translate([0, 0, 0])
    cube([20, 20, length]);
}

// NEMA17 Stepper Motor (42x42x40mm)
module nema17() {
    // Body
    color(col_black)
    difference() {
        translate([-21, -21, 0])
        cube([42, 42, 40]);
        // Corner chamfers
        for (cx = [-21, 21], cy = [-21, 21])
            translate([cx, cy, -1])
            rotate([0, 0, 45])
            cube([8, 8, 42], center=true);
    }
    // Front face plate
    color(col_steel)
    translate([0, 0, 40])
    cylinder(d=38.1, h=2, $fn=40);
    // Collar boss
    color(col_steel)
    translate([0, 0, 42])
    cylinder(d=22, h=2, $fn=30);
    // Shaft (5mm diameter, extends 24mm)
    color(col_steel)
    translate([0, 0, 42])
    cylinder(d=5, h=24, $fn=20);
    // Mounting holes (visual indicators)
    color(col_black)
    for (mx = [-15.5, 15.5], my = [-15.5, 15.5])
        translate([mx, my, 40])
        cylinder(d=3, h=3, $fn=12);
}

// GT2 20-tooth Pulley
module gt2_pulley() {
    color(col_aluminum) {
        // Toothed section
        cylinder(d=12.22, h=7, $fn=30);
        // Top flange
        translate([0, 0, 7])
        cylinder(d=16, h=1, $fn=30);
        // Bottom flange
        translate([0, 0, -1])
        cylinder(d=16, h=1, $fn=30);
    }
}

// GT2 Idler Pulley (toothless)
module gt2_idler() {
    color(col_aluminum) {
        difference() {
            union() {
                cylinder(d=12, h=7, $fn=30);
                translate([0, 0, 7])
                cylinder(d=16, h=1, $fn=30);
                translate([0, 0, -1])
                cylinder(d=16, h=1, $fn=30);
            }
            translate([0, 0, -2])
            cylinder(d=5, h=12, $fn=20);
        }
    }
}

// Smooth Rod
module smooth_rod(length, dia=8) {
    color(col_steel)
    rotate([0, 0, 0])
    cylinder(d=dia, h=length, $fn=30);
}

// LM8UU Linear Bearing
module lm8uu() {
    color(col_steel)
    difference() {
        cylinder(d=15, h=24, $fn=30);
        translate([0, 0, -1])
        cylinder(d=8.1, h=26, $fn=30);
    }
}

// Limit Switch (micro, SPDT lever type)
module limit_switch() {
    // Body
    color(col_black)
    cube([12.8, 5.8, 6.5]);
    // Lever arm
    color(col_steel)
    translate([12.8, 2.9, 5.5])
    rotate([0, 0, 0]) {
        cube([14, 0.5, 1]);
        // Roller
        translate([14, 0, 0.5])
        rotate([90, 0, 0])
        cylinder(d=3, h=0.5, center=true, $fn=16);
    }
    // Pins
    color(col_copper)
    for (px = [2, 6.4, 10.8])
        translate([px, 2.9, -3])
        cylinder(d=0.8, h=3, $fn=8);
}

// Pi Camera v2 Module
module pi_camera_v2() {
    // PCB
    color(col_green_pcb)
    cube([25, 24, 1]);
    // Sensor module
    color(col_black)
    translate([4, 5, 1])
    cube([8, 8, 3]);
    // Lens
    color(col_camera)
    translate([8, 9, 4])
    cylinder(d=6, h=2, $fn=20);
    // FFC connector
    color(col_white)
    translate([3, 20, -1])
    cube([19, 3, 1]);
}

// Raspberry Pi 4 (simplified)
module raspberry_pi_4() {
    // PCB
    color(col_pi)
    difference() {
        cube([85, 56, 1.6]);
        // Mounting holes (58x49mm pattern)
        for (hx = [3.5, 61.5], hy = [3.5, 52.5])
            translate([hx, hy, -1])
            cylinder(d=2.7, h=4, $fn=12);
    }
    // USB-C power
    color(col_steel)
    translate([7, -2, 1.6])
    cube([9, 4, 3.5]);
    // Micro HDMI x2
    color(col_steel)
    translate([22, -2, 1.6])
    cube([7, 4, 3]);
    translate([35, -2, 1.6])
    cube([7, 4, 3]);
    // USB-A x2 (stacked)
    color(col_steel)
    translate([69, -2, 1.6])
    cube([14, 18, 16]);
    // Ethernet
    color(col_steel)
    translate([69, 22, 1.6])
    cube([16, 16, 14]);
    // GPIO header
    color(col_black)
    translate([6, 29, 1.6])
    cube([51, 5, 8.5]);
    // CSI camera connector
    color(col_white)
    translate([38, 10, 1.6])
    cube([22, 3, 5]);
    // SoC heatspreader
    color(col_steel)
    translate([25, 22, 1.6])
    cube([14, 14, 2.5]);
}

// LCD 1602 Module
module lcd_1602() {
    // PCB
    color(col_green_pcb)
    cube([80, 36, 1.6]);
    // Display area
    color(col_pla_blue)
    translate([4.5, 6, 1.6])
    cube([71, 24, 3]);
}

// 4x4 Matrix Keypad
module keypad_4x4() {
    color(col_white)
    cube([69, 77, 1]);
    // Keys
    color(col_pla_gray)
    for (kx = [0:3], ky = [0:3])
        translate([8 + kx*15, 6 + ky*17, 1])
        cube([10, 10, 1.5]);
}

// Control Box (200x150x80mm)
module control_box() {
    wall = 3;
    // Base
    color(col_pla_gray)
    difference() {
        cube([200, 150, 80]);
        translate([wall, wall, wall])
        cube([200-2*wall, 150-2*wall, 80]);
        // LCD window (front face)
        translate([-1, (150-71)/2, 80-10-24])
        cube([wall+2, 71, 24]);
        // Keypad window
        translate([-1, (150-69)/2, 80-10-24-5-77])
        cube([wall+2, 69, 77]);
        // LED holes x3
        for (li = [0:2])
            translate([-1, 45 + li*20, 80-6])
            rotate([0, 90, 0])
            cylinder(d=5.1, h=wall+2, $fn=16);
        // Rear cable glands x4
        for (gi = [0:3])
            translate([200-wall-1, 20 + gi*35, 40])
            rotate([0, 90, 0])
            cylinder(d=12.5, h=wall+2, $fn=20);
        // Ventilation slots (side)
        for (vi = [0:7])
            translate([40 + vi*15, -1, 30])
            cube([3, wall+2, 40]);
    }
    // Internal components (simplified)
    // Breadboard
    color(col_white)
    translate([10, 20, 3])
    cube([165, 55, 10]);
    // PIC16F877A on breadboard
    color(col_black)
    translate([60, 30, 13])
    cube([52, 14, 4]);
    // A4988 driver
    color(col_red)
    translate([130, 35, 13])
    cube([20, 15, 12]);
    // ESP8266 NodeMCU
    color(col_green_pcb)
    translate([170, 80, 3])
    cube([25, 55, 8]);
    // Relay module
    color(col_pla_blue)
    translate([10, 90, 3])
    cube([45, 35, 18]);
    // LM7805 regulators
    color(col_black)
    for (ri = [0:1])
        translate([80 + ri*25, 100, 3])
        cube([10, 15, 20]);
    // LCD (mounted in front panel window)
    translate([0, (150-80)/2, 80-10-36])
    lcd_1602();
}

// Water Pump (submersible, simplified)
module water_pump() {
    color(col_black) {
        cube([30, 25, 30]);
        // Outlet nozzle
        translate([15, 12.5, 30])
        cylinder(d=7.5, h=10, $fn=16);
    }
}

// Plant Pot with soil and plant
module plant_pot() {
    // Terracotta pot (tapered)
    color(col_pot)
    difference() {
        cylinder(d1=60, d2=75, h=65, $fn=30);
        translate([0, 0, 3])
        cylinder(d1=54, d2=69, h=65, $fn=30);
    }
    // Soil
    color(col_soil)
    translate([0, 0, 55])
    cylinder(d1=66, d2=68, h=5, $fn=30);
    // Plant (simple stylized)
    color(col_plant) {
        // Stem
        translate([0, 0, 60])
        cylinder(d=4, h=40, $fn=12);
        // Leaves
        for (la = [0, 90, 180, 270]) {
            rotate([0, 0, la])
            translate([0, 0, 75])
            rotate([30, 0, 0])
            scale([1, 0.4, 1])
            sphere(d=25, $fn=16);
        }
        // Top cluster
        translate([0, 0, 90])
        sphere(d=20, $fn=16);
    }
}

// Silicone Tube (along path)
module silicone_tube(path_points, od=10, id=8) {
    color(col_tube)
    for (i = [0 : len(path_points)-2]) {
        hull() {
            translate(path_points[i])
            sphere(d=od, $fn=12);
            translate(path_points[i+1])
            sphere(d=od, $fn=12);
        }
    }
}

// Drive-End Bracket (3D printed, PLA+)
module drive_end_bracket() {
    color(col_pla_gray)
    difference() {
        cube([80, 70, 20]);

        // NEMA17 center bore (23mm)
        translate([40, 35, -1])
        cylinder(d=23, h=22, $fn=30);

        // NEMA17 mounting holes (31mm bolt circle, M3.2 clearance)
        for (mx = [-15.5, 15.5], my = [-15.5, 15.5])
            translate([40+mx, 35+my, -1])
            cylinder(d=3.2, h=22, $fn=16);

        // Smooth rod bore (7.85mm for press-fit)
        translate([40, 60, -1])
        cylinder(d=7.85, h=22, $fn=24);

        // Rod clamping slit
        translate([39.5, 60, -1])
        cube([1, 12, 22]);

        // Rod pinch bolt (M3)
        translate([30, 66, 10])
        rotate([0, 90, 0])
        cylinder(d=3.2, h=25, $fn=12);

        // Extrusion mount slots (M5)
        for (ey = [10, 50]) {
            translate([8, ey, -1])
            cylinder(d=5.2, h=22, $fn=16);
            translate([72, ey, -1])
            cylinder(d=5.2, h=22, $fn=16);
        }
    }
    // Limit switch mounting tab
    color(col_pla_gray)
    translate([70, 25, 0]) {
        difference() {
            cube([10, 15, 20]);
            // M2 holes for limit switch
            translate([5, 4, -1])
            cylinder(d=2.2, h=22, $fn=12);
            translate([5, 11, -1])
            cylinder(d=2.2, h=22, $fn=12);
        }
    }
}

// Idler-End Bracket
module idler_end_bracket() {
    color(col_pla_gray)
    difference() {
        cube([70, 70, 15]);

        // Idler shaft hole with tension slot (5mm hole, 10mm slot)
        translate([35, 35, -1])
        cylinder(d=5, h=17, $fn=20);
        // Tension adjustment slot
        translate([35, 30, -1])
        hull() {
            cylinder(d=5, h=17, $fn=20);
            translate([10, 0, 0])
            cylinder(d=5, h=17, $fn=20);
        }

        // Smooth rod bore
        translate([35, 60, -1])
        cylinder(d=7.85, h=17, $fn=24);

        // Rod clamping slit
        translate([34.5, 60, -1])
        cube([1, 12, 17]);

        // Extrusion mount slots
        for (ey = [10, 50]) {
            translate([8, ey, -1])
            cylinder(d=5.2, h=17, $fn=16);
            translate([62, ey, -1])
            cylinder(d=5.2, h=17, $fn=16);
        }
    }
}

// Carriage Plate (80x60x12mm)
module carriage_plate() {
    color(col_pla_blue)
    difference() {
        cube([80, 60, 12]);

        // LM8UU bearing cavities (2x, press-fit 14.85mm)
        translate([16, 30, -1])
        cylinder(d=14.85, h=14, $fn=30);
        translate([64, 30, -1])
        cylinder(d=14.85, h=14, $fn=30);

        // Belt anchor slots (2x)
        translate([30, -1, 4])
        cube([2.5, 10, 8]);
        translate([47.5, -1, 4])
        cube([2.5, 10, 8]);
        translate([30, 52, 4])
        cube([2.5, 10, 8]);
        translate([47.5, 52, 4])
        cube([2.5, 10, 8]);

        // Camera mount holes (M2, 21x12.5mm pattern)
        for (cx = [0, 21], cy = [0, 12.5])
            translate([55+cx, 20+cy, -1])
            cylinder(d=2.2, h=14, $fn=12);

        // Nozzle bore (8mm, vertical)
        translate([20, 30, -1])
        cylinder(d=8, h=14, $fn=20);
    }

    // Camera wedge (30 degree angled surface)
    color(col_pla_blue)
    translate([50, 15, 12])
    rotate([0, 0, 0])
    difference() {
        hull() {
            cube([30, 30, 1]);
            translate([0, 0, 0])
            rotate([-30, 0, 0])
            translate([0, 0, 10])
            cube([30, 30, 1]);
        }
        // Trim excess
        translate([-1, -20, -15])
        cube([32, 20, 30]);
    }
}

// Belt Clamp Plate
module belt_clamp() {
    color(col_pla_gray)
    difference() {
        cube([20, 10, 4]);
        // M3 holes
        translate([5, 5, -1])
        cylinder(d=3.2, h=6, $fn=12);
        translate([15, 5, -1])
        cylinder(d=3.2, h=6, $fn=12);
    }
    // GT2 teeth (simplified)
    color(col_pla_gray)
    for (ti = [0:8])
        translate([1 + ti*2, 0, 4])
        cube([1, 10, 0.75]);
}

// Smooth Rod End Holder
module rod_end_holder() {
    color(col_pla_gray)
    difference() {
        cube([25, 20, 15]);
        // Rod bore (8mm)
        translate([-1, 10, 7.5])
        rotate([0, 90, 0])
        cylinder(d=8, h=27, $fn=24);
        // Clamping slit
        translate([-1, 9.5, 7.5])
        cube([27, 1, 8]);
        // Pinch bolt (M3)
        translate([12.5, -1, 11])
        rotate([-90, 0, 0])
        cylinder(d=3.2, h=22, $fn=12);
        // Extrusion mount (M5)
        translate([12.5, 10, -1])
        cylinder(d=5.2, h=17, $fn=16);
    }
}

// LED indicator
module led_5mm(col) {
    color(col) {
        cylinder(d=5, h=8, $fn=16);
        translate([0, 0, 8])
        sphere(d=5, $fn=16);
    }
}

// ============================================================
// MAIN ASSEMBLY
// ============================================================
module assembly() {

    // ----------------------------------------------------------
    // ZONE B: LINEAR RAIL FRAME (origin at drive-end, ground-level)
    // Frame is elevated on legs
    // ----------------------------------------------------------
    if (show_frame) {
        // Left extrusion rail (along X-axis)
        translate([0, -rail_spacing/2 - 10, frame_height])
        rotate([0, 90, 0])
        rotate([0, 0, 90])
        extrusion_2020_simple(rail_length);

        // Right extrusion rail
        translate([0, rail_spacing/2 - 10, frame_height])
        rotate([0, 90, 0])
        rotate([0, 0, 90])
        extrusion_2020_simple(rail_length);

        // Smooth rod (centered between rails)
        translate([0, 0, frame_height + 10])
        rotate([0, 90, 0])
        rotate([0, 0, 0])
        smooth_rod(rail_length);

        // Support legs (4x, simplified as cylinders)
        color(col_aluminum)
        for (lx = [20, rail_length-20], ly = [-rail_spacing/2, rail_spacing/2])
            translate([lx, ly, 0])
            cylinder(d=20, h=frame_height, $fn=20);
    }

    // ----------------------------------------------------------
    // BRACKETS
    // ----------------------------------------------------------
    if (show_brackets) {
        // Drive-end bracket (at X=0)
        translate([-5, -35, frame_height - 5])
        drive_end_bracket();

        // Idler-end bracket (at X=rail_length)
        translate([rail_length - 65, -35, frame_height - 2])
        idler_end_bracket();
    }

    if (show_rod_holders) {
        // Rod end holders
        translate([15, -10, frame_height + 3])
        rod_end_holder();
        translate([rail_length - 40, -10, frame_height + 3])
        rod_end_holder();
    }

    // ----------------------------------------------------------
    // MOTOR + PULLEY (Drive End)
    // ----------------------------------------------------------
    if (show_motor) {
        translate([35, 0, frame_height - 30])
        rotate([0, 0, 0])
        nema17();

        // GT2 pulley on motor shaft
        translate([35, 0, frame_height + 14])
        gt2_pulley();
    }

    // ----------------------------------------------------------
    // IDLER PULLEY
    // ----------------------------------------------------------
    if (show_idler) {
        translate([rail_length - 35, 0, frame_height + 14])
        gt2_idler();
    }

    // ----------------------------------------------------------
    // LIMIT SWITCH
    // ----------------------------------------------------------
    if (show_limit_sw) {
        translate([5, 15, frame_height + 15])
        limit_switch();
    }

    // ----------------------------------------------------------
    // GT2 BELT PATH
    // ----------------------------------------------------------
    if (show_belt) {
        color(col_belt) {
            // Upper belt run
            translate([35, -0.5, frame_height + 17.5])
            cube([rail_length - 70, 1, 1.5]);
            // Lower belt run
            translate([35, -0.5, frame_height + 12])
            cube([rail_length - 70, 1, 1.5]);
        }
    }

    // ----------------------------------------------------------
    // ZONE C: MOVING CARRIAGE
    // ----------------------------------------------------------
    if (show_carriage) {
        translate([carriage_x - 40, -30, frame_height + 2]) {
            carriage_plate();

            // LM8UU bearings inside carriage
            translate([16, 30, 0])
            lm8uu();
            translate([64, 30, 0])
            lm8uu();

            // Belt clamps
            translate([28, -2, 4])
            belt_clamp();
            translate([28, 52, 4])
            belt_clamp();
        }

        // Water nozzle (below carriage)
        color(col_steel)
        translate([carriage_x - 20, 0, frame_height - 15])
        cylinder(d=8, h=17, $fn=16);

        // Pi Camera on carriage (30° angle)
        if (show_camera) {
            translate([carriage_x + 15, -5, frame_height + 16])
            rotate([-30, 0, 0])
            pi_camera_v2();
        }
    }

    // ----------------------------------------------------------
    // ZONE A: CONTROL BOX (beside frame on ground)
    // ----------------------------------------------------------
    if (show_control_box) {
        translate([-230, -75, 0])
        control_box();

        // LEDs above control box
        translate([-230, -30, 80]) {
            translate([3, 0, 0]) led_5mm([0, 0.8, 0, 1]);  // Green
            translate([3, 20, 0]) led_5mm([1, 0.8, 0, 1]);  // Amber
            translate([3, 40, 0]) led_5mm([0.9, 0.1, 0, 1]);// Red
        }
    }

    // ----------------------------------------------------------
    // RASPBERRY PI 4 (mounted near control box)
    // ----------------------------------------------------------
    if (show_pi) {
        translate([-130, -28, 5])
        raspberry_pi_4();
    }

    // ----------------------------------------------------------
    // WATER PUMP + TUBING
    // ----------------------------------------------------------
    if (show_pump) {
        // Pump next to control box
        translate([-180, 50, 0])
        water_pump();

        // Simplified tube path: pump -> along frame -> to carriage
        tube_path = [
            [-180, 50, 35],      // Pump outlet
            [-180, 50, frame_height + 25],  // Up
            [0, 0, frame_height + 25],      // To frame start
            [carriage_x - 20, 0, frame_height + 25], // Along frame
            [carriage_x - 20, 0, frame_height]  // Down to nozzle
        ];
        silicone_tube(tube_path);
    }

    // ----------------------------------------------------------
    // PLANT ROW (on ground, below frame)
    // ----------------------------------------------------------
    if (show_plants) {
        for (pi = [0 : num_plants - 1]) {
            px = first_plant_off + pi * plant_spacing;
            translate([px, 0, 0])
            plant_pot();
        }
    }

    // ----------------------------------------------------------
    // TEXT LABELS (optional — slow to render)
    // ----------------------------------------------------------
    if (show_labels) {
        color(col_black) {
            // Zone labels
            translate([-200, -100, 100])
            rotate([90, 0, 0])
            linear_extrude(1)
            text("ZONE A: Control Box", size=8, halign="center");

            translate([rail_length/2, -80, frame_height + 40])
            rotate([90, 0, 0])
            linear_extrude(1)
            text("ZONE B: Linear Rail Frame", size=8, halign="center");

            translate([carriage_x, -70, frame_height + 30])
            rotate([90, 0, 0])
            linear_extrude(1)
            text("ZONE C: Carriage", size=6, halign="center");

            // Plant indices
            for (pi = [0 : num_plants - 1]) {
                px = first_plant_off + pi * plant_spacing;
                translate([px, 55, 0])
                rotate([90, 0, 0])
                linear_extrude(1)
                text(str("Plant[", pi, "]"), size=6, halign="center");
            }
        }
    }
}

// ============================================================
// RENDER
// ============================================================
assembly();

// ============================================================
// DIMENSIONAL REFERENCE (commented for documentation)
// ============================================================
// Frame:         2x 500mm 2020 extrusion, 60mm spacing
// Smooth Rod:    8mm x 500mm hardened steel
// Carriage:      80x60x12mm, PLA+, 50% infill
// Motor:         NEMA17 42x42x40mm, 1.8°/step
// Pulley:        GT2 20T, 5mm bore, 40mm pitch circ.
// Belt:          GT2 6mm, ~1100mm loop length
// Resolution:    40/3200 = 0.0125 mm/microstep (1/16)
// Travel:        ~450mm usable
// Plant spacing: 80mm (configurable)
// Carriage mass: <80g target
// Control Box:   200x150x80mm, PLA+, 25% infill
// Camera angle:  30° downward from horizontal
// Tube:          8mm ID silicone, ~700mm length
