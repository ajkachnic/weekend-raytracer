const std = @import("std");
const common = @import("./common.zig");

const Vec3 = common.Vec3;
const Point3 = common.Point3;

pub const Ray = struct {
    orig: Point3 = .{ .x = 0, .y = 0, .z = 0 },
    dir: Vec3 = .{ .x = 0, .y = 0, .z = 0 },

    pub fn init(origin: Point3, direction: Vec3) Ray {
        return .{ .orig = origin, .dir = direction };
    }

    pub fn empty() Ray {
        return .{};
    }

    pub fn at(self: Ray, t: f64) Point3 {
        return self.orig.add(self.dir.mul(t));
    }
};
