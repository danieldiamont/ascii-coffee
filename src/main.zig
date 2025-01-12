const std = @import("std");
const output = @import("output.zig");
const particleSystem = @import("particleSystem.zig");

fn parseAscii(path: []const u8, buf: []u8) !void {
    _ = try std.fs.cwd().readFile(path, buf);
}

pub fn main() !void {

    // initially clear screen and reset cursor position
    try output.stdout.print("\x1b[2J", .{});
    try output.stdout.print("\x1b[H", .{});
    try output.flush();

    // account for newlines
    var buffer: [particleSystem.ROWS * particleSystem.COLS + particleSystem.ROWS]u8 = undefined;
    try parseAscii("cup.txt", &buffer);

    var ps = particleSystem.ParticleSystem.init(42);

    ps.withAsciiSeed(&buffer);

    while (true) {
        ps.updateAll();
        try ps.renderAll();
        std.time.sleep(1_000_000_000);
    }
}
