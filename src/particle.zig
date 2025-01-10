const std = @import("std");
const stdout_file = std.io.getStdOut().writer();
var bw = std.io.bufferedWriter(stdout_file);
const stdout = bw.writer();

pub const Particle = struct {
    x: usize,
    y: usize,
    d: f64,
    value: u8,

    pub fn render(self: Particle) void {
        stdout.print("\x1b[{d};{d}H", .{ self.x, self.y }); // move cursor
        stdout.print("{d}", .{self.value});
    }

    pub fn calculate(self: *Particle, rng: std.rand.DefaultPrng) void {
        self.value = rng.random();
    }
};
