const std = @import("std");
const common = @import("./common.zig");

const Camera = common.Camera;
const Color = common.Color;
const Hittable = common.Hittable;
const HittableList = common.HittableList;
const Image = common.Image;
const Ray = common.Ray;
const Point3 = common.Point3;
const Sphere = common.Sphere;
const Vec3 = common.Vec3;

fn rayColor(r: Ray, world: *Hittable) Color {
    var rec = common.HitRecord{};
    if (world.hit(r, 0, std.math.inf_f64, &rec)) {
        return Vec3.mul(Color.init(1, 1, 1).add(rec.normal), 0.5);
    }

    const unitDirection = r.dir.unitVector();
    const t = 0.5 * (unitDirection.y + 1.0);

    // (1.0 - t) * Color.init(1.0, 1.0, 1.0) + t * Color.init(0.5, 0.7, 1.0)
    return Color.init(1.0, 1.0, 1.0).mul(1.0 - t)
        .add(Color.init(0.5, 0.7, 1.0).mul(t));
}

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    // image
    const aspectRatio = 16.0 / 9.0;
    const imageWidth = 800;
    const imageHeight = @floatToInt(comptime_int, @intToFloat(f64, imageWidth) / aspectRatio);
    const samplesPerPixel = 100;

    std.log.debug("image width: {d}, image height: {d}\n", .{ imageWidth, imageHeight });

    var world = HittableList.init(allocator);
    defer world.deinit();

    var sphere_a = Sphere.init(Point3.init(0, 0, -1), 0.5);
    var sphere_b = Sphere.init(Point3.init(0, -100.5, -1), 100);

    try world.append(&sphere_a.interface);
    try world.append(&sphere_b.interface);

    // camera
    var cam = Camera.init();

    // render
    var image = try Image.create(allocator, imageWidth, imageHeight, 3);
    defer image.deinit();
    const data = image.data.?;

    var k: usize = 0;
    var j: isize = imageHeight - 1;
    while (j >= 0) : (j -= 1) {
        var i: usize = 0;
        while (i < imageWidth) : ({
            i += 1;
            k += image.channels;
        }) {
            var pixelColor = Color.init(0, 0, 0);
            var s: usize = 0;
            while (s < samplesPerPixel) : (s += 1) {
                const u = (@intToFloat(f64, i) + common.randomFloat(f64)) / @intToFloat(f64, imageWidth - 1);
                const v = (@intToFloat(f64, j) + common.randomFloat(f64)) / @intToFloat(f64, imageHeight - 1);
                var r = cam.getRay(u, v);
                pixelColor = Color.add(pixelColor, rayColor(r, &world.interface));
            }

            common.writeColor(data[k..], pixelColor, samplesPerPixel);
        }
    }

    try image.save("image.jpg");
}
