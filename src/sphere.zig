const std = @import("std");
const common = @import("./common.zig");

const Hittable = common.Hittable;
const HitRecord = common.HitRecord;
const Ray = common.Ray;
const Point3 = common.Point3;
const Vec3 = common.Vec3;

pub const Sphere = struct {
    center: Point3,
    radius: f64,
    interface: Hittable,

    pub fn init(cen: Point3, r: f64) Sphere {
        return .{
            .center = cen,
            .radius = r,
            .interface = Hittable{ .hitFn = hit },
        };
    }

    pub fn hit(iface: *const Hittable, r: Ray, t_min: f64, t_max: f64, rec: *HitRecord) bool {
        const self = @fieldParentPtr(Sphere, "interface", iface);

        const oc = Vec3.sub(r.orig, self.center);
        const a = r.dir.lengthSquared();
        const half_b = Vec3.dot(oc, r.dir);
        const c = oc.lengthSquared() - (self.radius * self.radius);

        const discriminant = half_b * half_b - a * c;
        if (discriminant < 0) return false;
        const sqrtd = std.math.sqrt(discriminant);

        // Find the nearest root that lies in the acceptable range.
        var root = (-half_b - sqrtd) / a;
        if (root < t_min or root >= t_max) {
            root = (-half_b + sqrtd) / a;
            if (root < t_min or root >= t_max) return false;
        }

        rec.*.t = root;
        rec.*.p = r.at(rec.t);

        const outwardNormal = Vec3.sub(rec.p, self.center).div(self.radius);
        rec.setFaceNormal(r, outwardNormal);

        return true;
    }
};
