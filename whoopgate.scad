include <Chamfers-for-OpenSCAD/Chamfer.scad>;

$fn = 100;

THE_BLESSED_NUMBER = 0.402;
function bless(x) = floor(x / THE_BLESSED_NUMBER) * THE_BLESSED_NUMBER;

gate_d = 35 - 3;
t = 3;

leg_l = 2;
leg_w = 4;
leg_h = 6;

tolerance = 0.25;

for(pos = [[90, 30, 0], [90, -30, 0]]) {
    translate(pos)
    gate_clamp(
        d = gate_d,
        t = t,
        h = leg_l,
        pin_l = leg_h,
        pin_w = leg_w,
        cut_angle = 90
    );
}

// intersection() {
    // translate([53, 0, 0])
    // cube([200, 200, 8], true);

    stand(
        support_h = 40,
        leg_w = leg_w,
        leg_l = leg_l,
        support_well=leg_h + tolerance * 2,

        clamp_r = gate_d / 2 + t,

        arm_l = 100,

        t = t,
        h = 1
    );
// }

module stand() {
    stiffener_h = 2.5;
    stiffener_w = bless(1);

    arm_w = leg_w + t * 2;

    center_r = arm_w / 4;

    support_l = leg_l + tolerance + THE_BLESSED_NUMBER * 4;
    support_w = leg_w + tolerance + THE_BLESSED_NUMBER * 4;

    cut_l = leg_l + tolerance;
    cut_w = leg_w + tolerance;

    difference() {
        union() {
            for(a = [0, 90]) {
                rotate([0, 0, a])
                translate([-arm_l / 2, -arm_w / 2, 0])
                arm(
                    l = arm_l,
                    w = arm_w,
                    h = h,
                    stiffener_w = stiffener_w,
                    stiffener_h = stiffener_h
                );
            }

            translate([0, 0, h])
                cylinder(h=stiffener_h, r=center_r);

            for(x = [arm_l / 2, -arm_l / 2]) {
                translate([x, 0, 0]) {
                    difference() {
                        translate([-support_l / 2, - support_w / 2, 0])
                            cube([support_l, support_w, support_h]);

                        translate([-cut_l / 2, 0, clamp_r + support_h - t])
                        rotate([0, 90, 0])
                            cylinder(h=cut_l, r=clamp_r);

                    }
                }
            }
        }


        for(x = [arm_l / 2 - cut_l / 2, -arm_l / 2 - cut_l / 2]) {
            translate([x, -cut_w / 2, support_h - support_well - t - tolerance]) {
                cube(size=[cut_l, cut_w, support_well + t + tolerance + 1]);
            }
        }
    }
}

module arm() {
    middle_w = w * 0.6;

    translate([0, (w - middle_w) / 2, 0])
        cube(size=[l, middle_w, h]);

    for(x = [0, l]) {
        translate([x, w / 2, 0])
            cylinder(r=w / 2, h=h);
    }

    translate([ 0, (w - stiffener_w) / 2, h])
        chamferCube(l, stiffener_w, stiffener_h, 1, [0, 0, 0, 0], [0, 1, 1, 0], [0, 0, 0, 0]);
}


module gate_clamp() {
    inner_r = d / 2;
    outer_r = inner_r + t;

    difference() {
        cylinder(h=h, r=outer_r);

        translate([0, 0, -1])
        cylinder(h=h + 2, r=inner_r);

        translate([0, 0, -1])
        difference() {
            r = outer_r + 1;

            cylinder(h=h + 2, r=r);

            rotate([0, 0, cut_angle / 2])
            translate([-r, 0, 0])
                cube([r * 2, r, h + 2]);

            rotate([0, 0, -cut_angle / 2])
            translate([-r, -r, 0])
                cube([r * 2, r, h + 2]);
        }
    }

    lip_r = t / 2;
    lip_x = (inner_r + t / 2) * cos(cut_angle / 2);
    lip_y = (inner_r + t / 2) * sin(cut_angle / 2);

    lip_positions = [
        [lip_x, +lip_y],
        [lip_x, -lip_y],
    ];

    for(pos = lip_positions) {
        translate(pos)
            cylinder(r=lip_r, h=h);
    }

    translate([-inner_r - pin_l - t, -pin_w / 2, 0])
        chamferCube(pin_l + t, pin_w, h, min(t, h) / 3, [0, 0, 0, 0], [1, 1, 0, 0], [1, 0, 0, 1]);
}
