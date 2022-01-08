const std = @import("std");
const common = @import("./common.zig");

const Color = common.Color;
const Image = common.Image;
const Ray = common.Ray;
const Point3 = common.Point3;
const Vec3 = common.Vec3;

fn hitSphere(center: Point3, radius: f64, r: Ray) f64 {
    const oc = r.orig.sub(center);

    const a = r.dir.lengthSquared();
    const half_b = Vec3.dot(oc, r.dir);
    const c = oc.lengthSquared() - (radius * radius);

    // // quadratic formula motherfuckers!
    const discriminant = half_b * half_b - a * c;

    if (discriminant < 0) {
        return -1.0;
    } else {
        return (-half_b - std.math.sqrt(discriminant)) / a;
    }
}

fn rayColor(r: Ray) Color {
    var t = hitSphere(Point3.init(0, 0, -1), 0.5, r);
    if (t > 0.0) {
        const n = Vec3.unitVector(Vec3.sub(r.at(t), Vec3.init(0, 0, -1)));
        return Vec3.mul(Color.init(n.x + 1, n.y + 1, n.z + 1), 0.5);
    }
    const unitDirection = r.dir.unitVector();
    t = 0.5 * (unitDirection.y + 1.0);

    // (1.0 - t) * Color.init(1.0, 1.0, 1.0) + t * Color.init(0.5, 0.7, 1.0)
    return Color.init(1.0, 1.0, 1.0).mul(1.0 - t)
        .add(Color.init(0.5, 0.7, 1.0).mul(t));
}

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    // image
    const aspectRatio = 16.0 / 9.0;
    const imageWidth = 800;
    const imageHeight = @floatToInt(comptime_int, @intToFloat(f64, imageWidth) / aspectRatio);
    std.debug.print("image width: {d}, image height: {d}", .{ imageWidth, imageHeight });

    // camera
    const viewportHeight = 2.0;
    const viewportWidth = aspectRatio * viewportHeight;
    const focalLength = 1.0;

    const origin = common.Point3.init(0.0, 0.0, 0.0);
    const horizontal = Vec3.init(viewportWidth, 0.0, 0.0);
    const vertical = Vec3.init(0.0, viewportHeight, 0.0);
    // origin - horizontal/2 - vertical/2 - Vec3.init(0, 0, focalLength);
    const lowerLeftCorner = origin
        .sub(horizontal.div(2.0))
        .sub(vertical.div(2.0))
        .sub(Vec3.init(0, 0, focalLength));

    // render

    var image = try Image.create(allocator, imageWidth, imageHeight, 3);
    const data = image.data.?;

    var k: usize = 0;
    var j: isize = imageHeight - 1;
    while (j >= 0) : (j -= 1) {
        var i: usize = 0;
        while (i < imageWidth) : ({
            i += 1;
            k += image.channels;
        }) {
            const u = @intToFloat(f64, i) / @intToFloat(f64, imageWidth - 1);
            const v = @intToFloat(f64, j) / @intToFloat(f64, imageHeight - 1);

            // lowerLeftCorner + u * horizontal + v * vertical - origin
            const r = Ray.init(origin, lowerLeftCorner
                .add(horizontal.mul(u))
                .add(vertical.mul(v))
                .sub(origin));

            const pixelColor = rayColor(r);
            common.color.writeColor(data[k..], pixelColor);
            // const r = @intToFloat(f64, i) / @intToFloat(f64, imageWidth - 1);
            // const g = @intToFloat(f64, j) / @intToFloat(f64, imageHeight - 1);
            // const b = 0.5;

            // const color = Vec3.init(r, g, b);
        }
    }

    try image.save("image.jpg");
}
