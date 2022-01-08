const std = @import("std");
const common = @import("./common.zig");
const c = common.c;

pub const Image = struct {
    const AllocationType = enum {
        stb_allocated,
        self_allocated,
        no_allocation,
    };

    width: u32,
    height: u32,
    channels: u32,
    size: u32,
    data: ?[]u8,
    allocation: AllocationType,

    allocator: std.mem.Allocator = null,

    pub fn load(allocator: std.mem.Allocator, filename: [*c]const u8) ?Image {
        var width: c_int = 0;
        var height: c_int = 0;
        var channels: c_int = 0;

        if (c.stbi_load(filename, &width, &height, &channels, 0)) |data| {
            return Image{
                .width = @intCast(u32, width),
                .height = @intCast(u32, height),
                .channels = @intCast(u32, channels),
                .size = @intCast(u32, width * height * channels),
                .data = std.mem.span(data),
                .allocation = .stb_allocated,
                .allocator = allocator,
            };
        }

        return null;
    }

    pub fn create(
        allocator: std.mem.Allocator,
        width: u32,
        height: u32,
        channels: u32,
    ) !Image {
        const size = width * height * channels;
        const data = try allocator.alloc(u8, size);

        return Image{
            .width = width,
            .height = height,
            .channels = channels,
            .size = size,
            .data = data,
            .allocation = .self_allocated,
            .allocator = allocator,
        };
    }

    pub fn save(self: *Image, filename: [*c]const u8) !void {
        const fname = std.mem.span(filename);
        const ext = std.fs.path.extension(fname);

        const cdata = try std.cstr.addNullByte(self.allocator, self.data.?);
        defer self.allocator.free(cdata);

        if (std.mem.endsWith(u8, ext, ".jpg") or std.mem.endsWith(u8, ext, ".jpeg") or std.mem.endsWith(u8, ext, ".JPG") or std.mem.endsWith(u8, ext, ".JPEG")) {
            _ = c.stbi_write_jpg(
                filename,
                @intCast(i32, self.width),
                @intCast(i32, self.height),
                @intCast(i32, self.channels),
                cdata.ptr,
                100,
            );
        }
        // else if (std.mem.endsWith(u8, ext, ".png") or std.mem.endsWith(u8, ext, ".png")) {
        //     _ = c.stbi_write_png(
        //         filename,
        //         @intCast(i32, self.width),
        //         @intCast(i32, self.height),
        //         @intCast(i32, self.channels),
        //         cdata.ptr,
        //         @intCast(i32, self.width * self.channels),
        //     );
        // }
    }

    pub fn deinit(self: *Image) void {
        if (self.allocation != .no_allocation and self.data != null) {
            if (self.allocation == .stb_allocated) {
                c.stbi_image_free(self.data);
            } else {
                self.allocator.free(self.data);
            }
        }
    }
};
