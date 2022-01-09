const std = @import("std");
const common = @import("./common.zig");

pub const Vec3 = Vector3(f64);

pub const Color = Vec3;
pub const Point3 = Vec3;

pub fn Vector3(comptime T: type) type {
    return struct {
        const Self = @This();

        x: T,
        y: T,
        z: T,

        pub fn init(x: T, y: T, z: T) Self {
            return .{ .x = x, .y = y, .z = z };
        }

        pub inline fn random() Self {
            const gen = common.rnd.random().float;
            return Self.init(gen(T), gen(T), gen(T));
        }

        pub inline fn randomRange(min: T, max: T) Self {
            // TODO: refactor to support ints
            const gen = common.rnd.random().float;
            return Self.init(
                (gen(T) * max) + min,
                (gen(T) * max) + min,
                (gen(T) * max) + min,
            );
        }

        pub fn randomInUnitSphere() Self {
            while (true) {
                const p = Self.random();
                if (p.lengthSquared() >= 1) continue;
                return p;
            }
        }

        pub fn randomUnitVector() Self {
            return unitVector(randomInUnitSphere());
        }

        pub fn randomInHemisphere(normal: Self) Self {
            const inUnitSphere = randomInUnitSphere();
            if (dot(inUnitSphere, normal) > 0.0) {
                return inUnitSphere;
            } else {
                return inUnitSphere.neg();
            }
        }

        pub fn empty() Self {
            return .{ .x = 0, .y = 0, .z = 0 };
        }

        pub fn add(a: Self, b: anytype) Self {
            const t_info = @typeInfo(T);
            const b_info = @typeInfo(@TypeOf(b));

            if (@TypeOf(b) == Self) {
                return .{
                    .x = a.x + b.x,
                    .y = a.y + b.y,
                    .z = a.z + b.z,
                };
            } else if (t_info == .Float and (b_info == .Float or b_info == .ComptimeFloat)) {
                return .{
                    .x = a.x + @floatCast(T, b),
                    .y = a.y + @floatCast(T, b),
                    .z = a.z + @floatCast(T, b),
                };
            } else if (t_info == .Int and (b_info == .Int or b_info == .ComptimeInt)) {
                return .{
                    .x = a.x + @intCast(T, b),
                    .y = a.y + @intCast(T, b),
                    .z = a.z + @intCast(T, b),
                };
            } else {
                @compileLog(t_info, b_info);
                @compileError("invalid argument type for b: " ++ @typeName(@TypeOf(b)));
            }
        }

        pub fn sub(a: Self, b: anytype) Self {
            const t_info = @typeInfo(T);
            const b_info = @typeInfo(@TypeOf(b));

            if (@TypeOf(b) == Self) {
                return .{
                    .x = a.x - b.x,
                    .y = a.y - b.y,
                    .z = a.z - b.z,
                };
            } else if (t_info == .Float and (b_info == .Float or b_info == .ComptimeFloat)) {
                return .{
                    .x = a.x - @floatCast(T, b),
                    .y = a.y - @floatCast(T, b),
                    .z = a.z - @floatCast(T, b),
                };
            } else if (t_info == .Int and (b_info == .Int or b_info == .ComptimeInt)) {
                return .{
                    .x = a.x - @intCast(T, b),
                    .y = a.y - @intCast(T, b),
                    .z = a.z - @intCast(T, b),
                };
            } else {
                @compileLog(t_info, b_info);
                @compileError("invalid argument type for b: " ++ @typeName(@TypeOf(b)));
            }
        }

        pub fn mul(a: Self, b: anytype) Self {
            const t_info = @typeInfo(T);
            const b_info = @typeInfo(@TypeOf(b));

            if (@TypeOf(b) == Self) {
                return .{
                    .x = a.x * b.x,
                    .y = a.y * b.y,
                    .z = a.z * b.z,
                };
            } else if (t_info == .Float and (b_info == .Float or b_info == .ComptimeFloat)) {
                return .{
                    .x = a.x * @floatCast(T, b),
                    .y = a.y * @floatCast(T, b),
                    .z = a.z * @floatCast(T, b),
                };
            } else if (t_info == .Int and (b_info == .Int or b_info == .ComptimeInt)) {
                return .{
                    .x = a.x * @intCast(T, b),
                    .y = a.y * @intCast(T, b),
                    .z = a.z * @intCast(T, b),
                };
            } else {
                @compileLog(t_info, b_info);
                @compileError("invalid argument type for b: " ++ @typeName(@TypeOf(b)));
            }
        }

        pub fn div(a: Self, b: anytype) Self {
            const t_info = @typeInfo(T);
            const b_info = @typeInfo(@TypeOf(b));

            if (@TypeOf(b) == Self) {
                return .{
                    .x = a.x / b.x,
                    .y = a.y / b.y,
                    .z = a.z / b.z,
                };
            } else if (t_info == .Float and (b_info == .Float or b_info == .ComptimeFloat)) {
                return .{
                    .x = a.x / @floatCast(T, b),
                    .y = a.y / @floatCast(T, b),
                    .z = a.z / @floatCast(T, b),
                };
            } else if (t_info == .Int and (b_info == .Int or b_info == .ComptimeInt)) {
                return .{
                    .x = a.x / @intCast(T, b),
                    .y = a.y / @intCast(T, b),
                    .z = a.z / @intCast(T, b),
                };
            } else {
                @compileLog(t_info, b_info);
                @compileError("invalid argument type for b: " ++ @typeName(@TypeOf(b)));
            }
        }

        pub fn dot(a: Self, b: Self) T {
            return a.x * b.x + a.y * b.y + a.z * b.z;
        }

        pub fn cross(a: Self, b: Self) Self {
            return .{
                .x = a.y * b.z - a.z * b.y,
                .y = a.z * b.x - a.x * b.z,
                .z = a.x * b.y - a.y * b.x,
            };
        }

        pub fn neg(a: Self) Self {
            return .{
                .x = -a.x,
                .y = -a.y,
                .z = -a.z,
            };
        }

        pub fn unitVector(self: Self) Self {
            return self.div(self.length());
        }

        pub fn length(self: Self) T {
            return std.math.sqrt(self.lengthSquared());
        }

        pub fn lengthSquared(self: Self) T {
            return self.x * self.x + self.y * self.y + self.z * self.z;
        }
    };
}
