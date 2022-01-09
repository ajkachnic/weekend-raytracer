const std = @import("std");
const common = @import("./common.zig");

const clamp = std.math.clamp;
const Image = common.Image;

pub fn writeColor(out: []u8, color: common.Vec3, samples_per_pixel: u32) void {
    // std.debug.assert(color.x <= 1.0);
    // std.debug.assert(color.y <= 1.0);
    // std.debug.assert(color.z <= 1.0);

    const scale = 1.0 / @intToFloat(f64, samples_per_pixel);

    const r = color.x * scale;
    const g = color.y * scale;
    const b = color.z * scale;

    const ir = @floatToInt(u8, 256 * clamp(r, 0.0, 0.999));
    const ig = @floatToInt(u8, 256 * clamp(g, 0.0, 0.999));
    const ib = @floatToInt(u8, 256 * clamp(b, 0.0, 0.999));

    out[0] = ir;
    out[1] = ig;
    out[2] = ib;
}
