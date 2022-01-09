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

    pub fn init() Camera {
        const aspectRatio = 16.0 / 9.0;
        const viewportHeight = 2.0;
        const viewportWidth = aspectRatio * viewportHeight;
        const focalLength = 1.0;

        const origin = common.Point3.init(0.0, 0.0, 0.0);
        const horizontal = Vec3.init(viewportWidth, 0.0, 0.0);
        const vertical = Vec3.init(0.0, viewportHeight, 0.0);
        // origin - horizontal/2 - vertical/2 - Vec3.init(0, 0, focalLength)
        const lowerLeftCorner = origin
            .sub(horizontal.div(2.0))
            .sub(vertical.div(2.0))
            .sub(Vec3.init(0, 0, focalLength));

        return .{
            .origin = origin,
            .horizontal = horizontal,
            .vertical = vertical,
            .lower_left_corner = lowerLeftCorner,
        };
    }

    pub fn getRay(self: Camera, u: f64, v: f64) Ray {
        return Ray.init(
            self.origin,
            self.lower_left_corner
                .add(self.horizontal.mul(u))
                .add(self.vertical.mul(v))
                .sub(self.origin),
        );
    }
};
