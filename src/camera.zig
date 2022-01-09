const std = @import("std");
const common = @import("./common.zig");

const Ray = common.Ray;
const Point3 = common.Point3;
const Vec3 = common.Vec3;

pub const Camera = struct {
    origin: Point3,
    lower_left_corner: Point3,
    horizontal: Vec3,
    vertical: Vec3,

    pub fn init(
        lookfrom: Point3,
        lookat: Point3,
        vup: Vec3,
        vfov: f64,
        aspect_ratio: f64,
    ) Camera {
        const theta = common.degreesToRadians(vfov);
        const h = std.math.tan(theta / 2);
        const viewportHeight = 2.0 * h;
        const viewportWidth = aspect_ratio * viewportHeight;

        const w = Vec3.sub(lookfrom, lookat).unitVector();
        const u = Vec3.cross(vup, w).unitVector();
        const v = Vec3.cross(w, u);
        std.log.debug("w: {}", .{w});
        std.log.debug("u: {}", .{u});
        std.log.debug("v: {}", .{v});

        const origin = lookfrom;
        const horizontal = Vec3.mul(u, viewportWidth);
        const vertical = Vec3.mul(v, viewportHeight);
        // origin - horizontal/2 - vertical/2 - w
        const lowerLeftCorner = origin
            .sub(horizontal.div(2.0))
            .sub(vertical.div(2.0))
            .sub(w);

        const self = .{
            .origin = origin,
            .horizontal = horizontal,
            .vertical = vertical,
            .lower_left_corner = lowerLeftCorner,
        };
        std.log.debug("self: {}", .{self});
        return self;
    }

    pub fn getRay(self: Camera, s: f64, t: f64) Ray {
        return Ray.init(
            self.origin,
            self.lower_left_corner
                .add(self.horizontal.mul(s))
                .add(self.vertical.mul(t))
                .sub(self.origin),
        );
    }
};
