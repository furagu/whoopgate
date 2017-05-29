include <Chamfers-for-OpenSCAD/Chamfer.scad>;

$fn = 100;

THE_BLESSED_NUMBER = 0.402;
function bless(x) = floor(x / THE_BLESSED_NUMBER) * THE_BLESSED_NUMBER;

gate_d = 35 - 3;
t = 3;

leg_l = 2.5;
leg_w = 4;
leg_h = 6;

tolerance = 0.25;

for(pos = [[30, 50, 0], [30, 10, 0]]) {
    translate(pos)
    clamp(
        d = gate_d,
        t = t,
        h = leg_l,
        pin_l = leg_h,
        pin_w = leg_w,
        cut_angle = 90
    );
}

// intersection() {
//     translate([53, 0, 0])
//     cube([200, 200, 8], true);

    rotate([0, 0, 90])
    stand(
        support_h = 30,
        leg_w = leg_w,
        leg_l = leg_l,
        leg_h = leg_h,

        t = t,

        base_l = 60,
        base_w = 50,
        base_h = 1,
        arm_w = 6,

        stiffener_h = 2.5,
        stiffener_w = bless(1),
        stiffener_r = 0.5
    );
// }

module stand() {
    base(
        l = base_l,
        w = base_w,
        h = base_h,

        arm_w = arm_w,

        stiffener_w = stiffener_w,
        stiffener_h = stiffener_h,
        stiffener_r = stiffener_r
    );

    for(xa = [[arm_w / 2, 0], [base_l - arm_w / 2, 180]]) {
        translate([xa[0], base_w / 2, 0]) {
        rotate([0, 0, xa[1]])
            difference() {
                support(
                    h = support_h,

                    arm_w = arm_w,
                    arm_l = base_l / 4,
                    arm_h = base_h,

                    stiffener_w = stiffener_w,

                    leg_l = leg_l,
                    leg_w = leg_w,
                    leg_h = leg_h,

                    clamp_h = t
                );

                for(y = [arm_w, -base_w - arm_w]) {
                    translate([-arm_w, y, 0])
                        cube(size=[arm_w * 2, base_w, base_h + stiffener_h]);
                }
            }
        }
    }
}

module base() {
    arm_r = arm_w / 2;

    linear_extrude(h)
    difference() {
        translate([arm_r, arm_r])
        offset(r=arm_r)
            square([l - arm_r * 2, w - arm_r * 2]);

        translate([arm_w, arm_w])
            square([l - arm_w * 2, w - arm_w * 2]);
    }

    translate([0, (w - arm_w) / 2, 0])
        cube(size=[l, arm_w, h]);

    translate([arm_w / 2, (w - stiffener_w) / 2, h])
        cube(size=[l - arm_w, stiffener_w, stiffener_h]);

    translate([arm_w / 2 - stiffener_w / 2, arm_w / 2 - stiffener_w / 2, h])
    linear_extrude(stiffener_h)
    translate([stiffener_w + stiffener_r, stiffener_w + stiffener_r])
        difference(){
            offset(r=stiffener_r + stiffener_w)
                square([l - arm_w - stiffener_r * 2 - stiffener_w, w - arm_w - stiffener_r * 2 - stiffener_w]);

            offset(r=stiffener_r)
                square([l - arm_w - stiffener_r * 2 - stiffener_w, w - arm_w - stiffener_r * 2 - stiffener_w]);
        }
}

module support() {
    stiffener_l = arm_l - arm_w / 2;
    stiffener_h = h * 0.5;
    a = atan(stiffener_h / stiffener_l);

    for(r = [0, 90, 270]) {
        rotate([0, 0, r])
        translate([0, -stiffener_w / 2, arm_h])
            difference() {
                cube([stiffener_l, stiffener_w, stiffener_h]);

                translate([0, -1, stiffener_h])
                rotate([0, a, 0])
                    cube(size=[stiffener_l * 2, stiffener_w + 2, stiffener_l * 2]);
            }
    }

    tower_l = leg_l + tolerance + THE_BLESSED_NUMBER * 4;
    tower_w = leg_w + tolerance + THE_BLESSED_NUMBER * 4;

    cut_l = leg_l + tolerance;
    cut_w = leg_w + tolerance;
    cut_h = leg_h + tolerance;

    difference() {
        translate([-tower_l / 2, - tower_w / 2, 0])
            cube([tower_l, tower_w, h]);

        translate([-cut_l / 2, -tower_w / 2 - 1, h - clamp_h])
            cube(size=[cut_l, tower_w + 2, clamp_h + 1]);

        translate([-cut_l / 2, -cut_w / 2, h - cut_h - clamp_h])
            cube(size=[cut_l, cut_w, cut_h + clamp_h + 1]);
    }

}

module clamp() {
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
