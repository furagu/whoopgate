$fn = 100;

main(
    balloon_diameter = 40,
    thickness        = 3,
    length           = 100,
    holder_length    = 5,
    clamp_length     = 5,
    clamp_height     = 8,
    clamp_gap        = 0.5,
    clamp_extra_cut  = 3
);

module main() {
    cube(size=[length, balloon_diameter / 2, thickness]);

    holder_positions = [
        [0, 0],
        [length - holder_length, 0]
    ];

    for(pos = holder_positions) {
        translate(pos)
            balloon_holder(
                l         = holder_length,
                r         = balloon_diameter / 2,
                cut_angle = 100,
                thickness = thickness
            );
    }

    translate([(length - clamp_length) / 2, 0, balloon_diameter / 2 - clamp_height / 2 + thickness])
        clamp(
            l         = clamp_length,
            w         = balloon_diameter,
            h         = clamp_height,
            gap       = clamp_gap,
            extra_cut = clamp_extra_cut
        );

    translate([(length - clamp_length) / 2, 0, 0])
        cube(size=[clamp_length, balloon_diameter / 2, balloon_diameter / 2 + thickness - clamp_height / 2 + 0.1], center=false);
}

module clamp() {
    difference() {
        cube(size=[l, w, h]);

        translate([-1, w / 2 - extra_cut, (h - gap) / 2])
        cube(size=[l + 2, w / 2 + extra_cut, gap]);

        mouth_side = sqrt(h * h / 2);

        translate([l / 2, w, h / 2])
        rotate([45, 0, 0])
            cube(size=[l + 2, mouth_side, mouth_side], center=true);
    }
}


module balloon_holder() {
    holder_side = (r + thickness) * 2;
    outer_r = r + thickness;

    translate([l / 2, outer_r, outer_r])
    rotate([90, 0, 90])
    union() {
        difference() {
            union() {
                cylinder(h=l, r=outer_r, center=true);

                translate([-outer_r / 2, -outer_r / 2])
                    cube(size=[outer_r, outer_r, l], center=true);
            }

            cylinder(h=l + 2, r=r, center=true);

            difference() {
                h = l + 2;
                r = outer_r + 1;

                cylinder(h=h, r=r, center=true);

                rotate([0, 0, cut_angle / 2])
                translate([-r, 0, -h / 2 - 1])
                    cube([r * 2, r, h + 2]);

                rotate([0, 0, -cut_angle / 2])
                translate([-r, -r, -h / 2 - 1])
                    cube([r * 2, r, h + 2]);
            }
        }

        lip_r = thickness / 2;
        lip_x = (r + thickness / 2) * cos(cut_angle / 2);
        lip_y = (r + thickness / 2) * sin(cut_angle / 2);

        lip_positions = [
            [lip_x, +lip_y],
            [lip_x, -lip_y],
        ];

        for(pos = lip_positions) {
            translate(pos)
                cylinder(r=lip_r, h=l, center=true);
        }
    }
}
