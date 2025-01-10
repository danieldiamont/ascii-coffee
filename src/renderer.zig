const std = @import("std");
const stdout_file = std.io.getStdOut().writer();
var bw = std.io.bufferedWriter(stdout_file);
const stdout = bw.writer();

const H = 30;
const W = 100;

const MTP = "\x1b[H\x1b[2J";

const Renderer = struct {
    buffer: [H][W]u8,

    pub fn init() Renderer {
        return Renderer{ .buffer = undefined };
    }

    pub fn render(self: *Renderer) !void {
        try stdout.print("{s}", .{MTP});
        for (0..H) |i| {
            for (0..W) |j| {
                try stdout.print("{c}", .{self.buffer[i][j]});
            }
            try stdout.print("\n", .{});
        }
        try bw.flush();
    }

    pub fn initialize_buffer(self: *Renderer, c: u8) void {
        for (0..H) |i| {
            for (0..W) |j| {
                self.buffer[i][j] = c;
            }
        }
    }

    pub fn update_buffer(self: *Renderer, buf: *[H][W]u8) void {
        for (0..H) |i| {
            for (0..W) |j| {
                self.buffer[i][j] = buf.*[i][j];
            }
        }
    }
};
