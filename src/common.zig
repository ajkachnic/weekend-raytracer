pub const c = @cImport({
    @cDefine("STB_IMAGE_IMPLEMENTATION", {});
    @cDefine("STB_IMAGE_WRITE_IMPLEMENTATION", {});
    @cInclude("stb_image.h");
    @cInclude("stb_image_write.h");
});

pub const Image = @import("./image.zig").Image;

const vec3 = @import("./vec3.zig");
usingnamespace vec3;
// pub const Vec3 = vec3.Vec3;
// pub const Color = vec3.Color;
// pub const Point3 = vec3.Point3;
// pub const Vector3 = vec3.Vector3;

pub const color = @import("./color.zig");
usingnamespace color;

const ray = @import("./ray.zig");
usingnamespace ray;
