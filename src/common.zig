const std = @import("std");
pub const c = @cImport({
    @cDefine("STB_IMAGE_IMPLEMENTATION", {});
    @cDefine("STB_IMAGE_WRITE_IMPLEMENTATION", {});
    @cInclude("stb_image.h");
    @cInclude("stb_image_write.h");
});

const camera = @import("./camera.zig");
const color = @import("./color.zig");
const hittable = @import("./hittable.zig");
const material = @import("./material.zig");
const ray = @import("./ray.zig");
const sphere = @import("./sphere.zig");
const vec3 = @import("./vec3.zig");

usingnamespace camera;
usingnamespace color;
usingnamespace hittable;
usingnamespace material;
usingnamespace sphere;
usingnamespace ray;
usingnamespace vec3;

pub const Image = @import("./image.zig").Image;
const RndGen = std.rand.DefaultPrng;

pub var rnd = RndGen.init(0);

pub const randomFloat = rnd.random().float;

pub inline fn degreesToRadians(degrees: f64) f64 {
    return degrees * std.math.pi / 180.0;
}
