include <Chamfers-for-OpenSCAD/Chamfer.scad>;

$fn = 100;

THE_BLESSED_NUMBER = 0.402;
function bless(x) = floor(x / THE_BLESSED_NUMBER) * THE_BLESSED_NUMBER;

gate_d = 35 - 2;
t = 3;

leg_w = 3;
leg_l = 3;
leg_h = 6;

tolerance = 0.5;

for(pos = [[35, 30, 0], [-25, -30, 0]]) {
    translate(pos)
    gate_clamp(
        d = gate_d,
        t = t,
        h = leg_w,
        pin_l = leg_h,
        pin_w = leg_l,
        cut_angle = 100
    );
}

stand(
    support_h = 30,
    support_w = leg_w,
    support_l = leg_l,
    support_well=leg_h,

    clamp_r = gate_d / 2 + t,

    arm_l = 100,

    t = bless(2)
);

module stand() {
    stiffener_h = 2.5;
    stiffener_w = bless(1);

    arm_w = support_w + t * 4;

    center_r = arm_w / 2.2;
    support_r = max(support_l, support_w) + t + tolerance;

    difference() {
        union() {
            for(a = [0, 90]) {
                rotate([0, 0, a])
                translate([-arm_l / 2, -arm_w / 2, 0])
                arm(
                    l = arm_l,
                    w = arm_w,
                    h = t,
                    stiffener_w = stiffener_w,
                    stiffener_h = stiffener_h
                );
            }

            cylinder(h=stiffener_h + t, r=center_r);

            support_full_l = support_l + t * 2;
            support_full_w = support_w + t * 2;

            for(x = [arm_l / 2, -arm_l / 2]) {
                translate([x, 0, 0]) {
                    difference() {
                        cylinder(h=support_h, r=min(support_full_l, support_full_w) / 2);

                        translate([-(support_l + tolerance) / 2, 0, clamp_r + support_h - t])
                        rotate([0, 90, 0])
                            cylinder(h=support_l + tolerance, r=clamp_r);
                    }
                }
            }
        }

        translate([0, 0, -1])
            cylinder(h=stiffener_h + t + 2, r=center_r - stiffener_w);

        for(x = [arm_l / 2 - support_l / 2, -arm_l / 2 - support_l / 2]) {
            translate([x, -support_w / 2, support_h - support_well - t - tolerance]) {
                cube(size=[support_l, support_w, support_well + t + tolerance]);
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

    translate([ -w / 2, (w - stiffener_w) / 2, h])
        chamferCube(l + w, stiffener_w, stiffener_h, w / 2, [0, 0, 0, 0], [0, 1, 1, 0], [0, 0, 0, 0]);
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
