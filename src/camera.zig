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

    u: Vec3,
    v: Vec3,
    w: Vec3,
    lens_radius: f64,

    pub fn init(
        lookfrom: Point3,
        lookat: Point3,
        vup: Vec3,
        vfov: f64,
        aspect_ratio: f64,
        aperture: f64,
        focus_dist: f64,
    ) Camera {
        const theta = common.degreesToRadians(vfov);
        const h = std.math.tan(theta / 2);
        const viewportHeight = 2.0 * h;
        const viewportWidth = aspect_ratio * viewportHeight;

        const w = Vec3.sub(lookfrom, lookat).unitVector();
        const u = Vec3.cross(vup, w).unitVector();
        const v = Vec3.cross(w, u);

        const origin = lookfrom;
        const horizontal = u.mul(viewportWidth * focus_dist);
        const vertical = v.mul(viewportHeight * focus_dist);
        // origin - horizontal/2 - vertical/2 - w * focus_dist
        const lowerLeftCorner = origin
            .sub(horizontal.div(2.0))
            .sub(vertical.div(2.0))
            .sub(w.mul(focus_dist));

        const lensRadius = aperture / 2;

        return .{
            .origin = origin,
            .horizontal = horizontal,
            .vertical = vertical,
            .lower_left_corner = lowerLeftCorner,
            .w = w,
            .u = u,
            .v = v,
            .lens_radius = lensRadius,
        };
    }

    pub fn getRay(self: Camera, s: f64, t: f64) Ray {
        const rd = Vec3.randomInUnitDisk().mul(self.lens_radius);
        const offset = Vec3.add(self.u.mul(rd.x), self.v.mul(rd.y));

        return Ray.init(
            self.origin.add(offset),
            self.lower_left_corner
                .add(self.horizontal.mul(s))
                .add(self.vertical.mul(t))
                .sub(self.origin)
                .sub(offset),
        );
    }
};
