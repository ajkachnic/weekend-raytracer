const std = @import("std");
const common = @import("./common.zig");

const Image = common.Image;

pub fn writeColor(out: []u8, color: common.Vec3) void {
    const ir = @floatToInt(u8, 255.999 * color.x);
    const ig = @floatToInt(u8, 255.999 * color.y);
    const ib = @floatToInt(u8, 255.999 * color.z);

    out[0] = ir;
    out[1] = ig;
    out[2] = ib;
}
