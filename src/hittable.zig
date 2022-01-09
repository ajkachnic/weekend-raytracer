const std = @import("std");
const common = @import("./common.zig");

const Ray = common.Ray;
const Point3 = common.Point3;
const Vec3 = common.Vec3;

pub const HitRecord = struct {
    p: Point3 = .{ .x = 0, .y = 0, .z = 0 },
    normal: Vec3 = .{ .x = 0, .y = 0, .z = 0 },
    t: f64 = 0.0,
    front_face: bool = true,

    pub inline fn init(p: Point3, normal: Vec3, t: f64, front_face: bool) HitRecord {
        return .{
            .p = p,
            .normal = normal,
            .t = t,
            .front_face = front_face,
        };
    }

    pub inline fn setFaceNormal(self: *HitRecord, r: Ray, outward_normal: Vec3) void {
        self.front_face = Vec3.dot(r.dir, outward_normal) < 0;
        self.normal = if (self.front_face) outward_normal else outward_normal.neg();
    }
};

/// Hacky interface for any object/quandry that can be hit by a ray
pub const Hittable = struct {
    hitFn: fn (self: *const Hittable, r: Ray, t_min: f64, t_max: f64, rec: *HitRecord) bool,

    // Wrap the hit function call
    pub fn hit(self: *const Hittable, r: Ray, t_min: f64, t_max: f64, rec: *HitRecord) bool {
        return self.hitFn(self, r, t_min, t_max, rec);
    }
};

pub const HittableList = struct {
    interface: Hittable,
    objects: std.ArrayList(*Hittable),

    pub fn myHit(iface: *const Hittable, r: Ray, t_min: f64, t_max: f64, rec: *HitRecord) bool {
        const self = @fieldParentPtr(HittableList, "interface", iface);
        var temp_rec = HitRecord{};
        var hit_anything = false;
        var closest_so_far = t_max;

        for (self.objects.items) |object| {
            if (object.*.hit(r, t_min, closest_so_far, &temp_rec)) {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec.* = temp_rec;
            }
        }

        return hit_anything;
    }

    pub fn init(allocator: std.mem.Allocator) HittableList {
        return .{
            .objects = std.ArrayList(*Hittable).init(allocator),
            .interface = Hittable{ .hitFn = myHit },
        };
    }

    pub fn deinit(self: *HittableList) void {
        self.objects.deinit();
    }

    pub fn append(self: *HittableList, object: *Hittable) !void {
        try self.objects.append(object);
    }
};
