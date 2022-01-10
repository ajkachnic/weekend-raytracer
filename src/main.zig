const std = @import("std");
const common = @import("./common.zig");

const Camera = common.Camera;
const Color = common.Color;
const Hittable = common.Hittable;
const HittableList = common.HittableList;
const Image = common.Image;
const Material = common.Material;
const Ray = common.Ray;
const Point3 = common.Point3;
const Sphere = common.Sphere;
const Vec3 = common.Vec3;

const randomFloat = common.randomFloat;

// materials
const Dielectric = common.Dieletric;
const Metal = common.Metal;
const Lambertian = common.Lambertian;

fn rayColor(r: Ray, world: *Hittable, depth: u32) Color {
    var rec = common.HitRecord{};

    // If we've exceeded the ray bounce limit, no more light is gathered.
    if (depth <= 0)
        return Color.init(0, 0, 0);

    if (world.hit(r, 0.001, std.math.inf_f64, &rec)) {
        var scattered: Ray = undefined;
        var attenuation: Color = undefined;

        if (rec.mat_ptr.scatter(r, &rec, &attenuation, &scattered)) {
            return Vec3.mul(attenuation, rayColor(scattered, world, depth - 1));
        }
        return Color.init(0, 0, 0);
    }

    const unitDirection = r.dir.unitVector();
    const t = 0.5 * (unitDirection.y + 1.0);

    // (1.0 - t) * Color.init(1.0, 1.0, 1.0) + t * Color.init(0.5, 0.7, 1.0)
    return Color.init(1.0, 1.0, 1.0).mul(1.0 - t)
        .add(Color.init(0.5, 0.7, 1.0).mul(t));
}

fn randomScene(allocator: std.mem.Allocator) !HittableList {
    var world = HittableList.init(allocator);

    var groundMaterial = Lambertian.init(Color.init(0.8, 0.8, 0.0));
    var ground = Sphere.init(Point3.init(0, -1000, -1), 1000, &groundMaterial.interface);
    try world.append(&ground.interface);

    var a: isize = -11;
    while (a < 11) : (a += 1) {
        var b: isize = -11;
        while (b < 11) : (b += 1) {
            const center = Point3.init(
                @intToFloat(f64, a) + 0.9 * randomFloat(f64),
                0.2,
                @intToFloat(f64, b) + 0.9 * randomFloat(f64),
            );

            if (center.sub(Point3.init(4, 0.2, 0)).length() > 0.9) {
                const _r = common.rnd.random().float(f64);
                const MatType = enum { Diffuse, Metal, Glass };
                var choose_mat: MatType = if (_r < 0.8)
                    MatType.Diffuse
                else if (_r < 0.95)
                    MatType.Metal
                else
                    MatType.Glass;

                switch (choose_mat) {
                    .Diffuse => {
                        var material = try allocator.create(Lambertian);
                        const albedo = Color.random().mul(Color.random());
                        material.* = Lambertian.init(albedo);

                        var sphere = try allocator.create(Sphere);
                        sphere.* = Sphere.init(center, 0.2, &material.interface);

                        try world.append(&sphere.interface);
                    },
                    .Metal => {
                        var material = try allocator.create(Metal);
                        const albedo = Color.random().mul(Color.random());
                        const fuzz = randomFloat(f64) / 2;
                        material.* = Metal.init(albedo, fuzz);

                        var sphere = try allocator.create(Sphere);
                        sphere.* = Sphere.init(center, 0.2, &material.interface);

                        try world.append(&sphere.interface);
                    },
                    .Glass => {
                        var material = try allocator.create(Dielectric);
                        material.* = Dielectric.init(1.5);

                        var sphere = try allocator.create(Sphere);
                        sphere.* = Sphere.init(center, 0.2, &material.interface);

                        try world.append(&sphere.interface);
                    },
                }
            }
        }
    }

    return world;
}

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    // image
    const aspectRatio = 16.0 / 9.0;
    const imageWidth = 1920;
    const imageHeight = @floatToInt(comptime_int, @intToFloat(f64, imageWidth) / aspectRatio);
    const samplesPerPixel = 100; // 100
    const maxDepth = 50; // 50

    std.log.debug("image width: {d}, image height: {d}\n", .{ imageWidth, imageHeight });

    // world
    var world = try randomScene(arena.allocator());
    defer world.deinit();

    // camera
    const lookfrom = Point3.init(13, 2, 3);
    const lookat = Point3.init(0, 0, 0);
    const vup = Vec3.init(0, 1, 0);
    const distToFocus = 10.0;
    const aperture = 0.1;

    var cam = Camera.init(
        lookfrom,
        lookat,
        vup,
        20.0,
        aspectRatio,
        aperture,
        distToFocus,
    );

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
                const u = (@intToFloat(f64, i) + randomFloat(f64)) / @intToFloat(f64, imageWidth - 1);
                const v = (@intToFloat(f64, j) + randomFloat(f64)) / @intToFloat(f64, imageHeight - 1);
                var r = cam.getRay(u, v);
                pixelColor = Color.add(pixelColor, rayColor(r, &world.interface, maxDepth));
            }

            common.writeColor(data[k..], pixelColor, samplesPerPixel);
        }
    }

    try image.save("image.jpg");
}
