const std = @import("std");
const common = @import("./common.zig");

const Color = common.Color;
const HitRecord = common.HitRecord;
const Point3 = common.Point3;
const Ray = common.Ray;
const Vec3 = common.Vec3;

pub const Material = struct {
    // pub const Lambertian = Lambertian;
    // pub const Metal = Metal;

    // can call directly: iface.scatterFn(iface)
    scatterFn: fn (*Material, r_in: Ray, rec: *HitRecord, color: *Color, scattered: *Ray) bool,

    // allows calling: iface.scatter()
    pub fn scatter(iface: *Material, r_in: Ray, rec: *HitRecord, color: *Color, scattered: *Ray) bool {
        return iface.scatterFn(iface, r_in, rec, color, scattered);
    }
};

pub const Lambertian = struct {
    albedo: Color = .{ .x = 0, .y = 0, .z = 0 },
    interface: Material,

    pub fn init(albedo: Color) Lambertian {
        return .{
            .albedo = albedo,
            .interface = Material{ .scatterFn = scatter },
        };
    }

    pub fn scatter(
        iface: *Material,
        _: Ray,
        rec: *HitRecord,
        attenuation: *Color,
        scattered: *Ray,
    ) bool {
        const self = @fieldParentPtr(Lambertian, "interface", iface);

        var scatter_direction = Vec3.add(rec.normal, Vec3.randomUnitVector());
        // Catch degenerate scatter direction
        if (scatter_direction.nearZero())
            scatter_direction = rec.normal;

        scattered.* = Ray.init(rec.p, scatter_direction);
        attenuation.* = self.albedo;

        return true;
    }
};

pub const Metal = struct {
    albedo: Color = .{ .x = 0, .y = 0, .z = 0 },
    fuzz: f64,
    interface: Material,

    pub fn init(albedo: Color, fuzz: f64) Metal {
        return .{
            .albedo = albedo,
            .fuzz = if (fuzz < 1) fuzz else 1,
            .interface = Material{ .scatterFn = scatter },
        };
    }

    pub fn scatter(
        iface: *Material,
        r_in: Ray,
        rec: *HitRecord,
        attenuation: *Color,
        scattered: *Ray,
    ) bool {
        const self = @fieldParentPtr(Metal, "interface", iface);

        const reflected = Vec3.reflect(Vec3.unitVector(r_in.dir), rec.normal);
        scattered.* = Ray.init(
            rec.p,
            Vec3.add(reflected, Vec3.randomInUnitSphere().mul(self.fuzz)),
        );
        attenuation.* = self.albedo;

        return (Vec3.dot(scattered.dir, rec.normal) > 0);
    }
};

pub const Dieletric = struct {
    ir: f64 = 0,
    interface: Material,

    pub fn init(ir: f64) Dieletric {
        return .{
            .ir = ir,
            .interface = Material{ .scatterFn = scatter },
        };
    }

    pub fn scatter(
        iface: *Material,
        r_in: Ray,
        rec: *HitRecord,
        attenuation: *Color,
        scattered: *Ray,
    ) bool {
        const self = @fieldParentPtr(Dieletric, "interface", iface);

        attenuation.* = Color.init(1.0, 1.0, 1.0);
        const refraction_ratio = if (rec.front_face) (1.0 / self.ir) else self.ir;

        const unit_direction = Vec3.unitVector(r_in.dir);
        const cos_theta = std.math.min(Vec3.dot(unit_direction.neg(), rec.normal), 1.0);
        const sin_theta = std.math.sqrt(1.0 - cos_theta * cos_theta);

        const cannot_refract = refraction_ratio * sin_theta > 1.0;
        var direction = if (cannot_refract or reflectance(cos_theta, refraction_ratio) > common.randomFloat(f64))
            Vec3.reflect(unit_direction, rec.normal)
        else
            Vec3.refract(unit_direction, rec.normal, refraction_ratio);

        scattered.* = Ray.init(rec.p, direction);

        return true;
    }

    fn reflectance(cosine: f64, ref_idx: f64) f64 {
        // Use Schlick's approximation for reflectance.
        var r0 = (1 - ref_idx) / (1 + ref_idx);
        r0 = r0 * r0;
        return r0 + (1 - r0) * std.math.pow(f64, (1 - cosine), 5);
    }
};
