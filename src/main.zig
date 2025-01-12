const std = @import("std");
const output = @import("output.zig");
const particleSystem = @import("particleSystem.zig");

fn parseAscii(path: []const u8, buf: []u8) !void {
    _ = try std.fs.cwd().readFile(path, buf);
}

var caught_signal: bool = false;

fn handleSig(sig: c_int) callconv(.C) void {
    std.log.debug("Caught signal {d}", .{sig});
    caught_signal = true;
}

pub fn main() !void {

    // initially clear screen and reset cursor position
    try output.stdout.print("\x1b[2J", .{});
    try output.stdout.print("\x1b[H", .{});
    try output.flush();

    // account for newlines
    var buffer: [particleSystem.ROWS * particleSystem.COLS + particleSystem.ROWS]u8 = undefined;
    try parseAscii("cup.txt", &buffer);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer {
        std.log.debug("Cleaning up arena...\n", .{});
        arena.deinit();
    }

    const action = std.os.linux.Sigaction{
        .handler = .{ .handler = handleSig },
        .mask = std.os.linux.empty_sigset,
        .flags = 0,
    };
    _ = std.os.linux.sigaction(std.os.linux.SIG.INT, &action, null);

    const allocator = arena.allocator();

    var ps = particleSystem.ParticleSystem.init(42, -0.25, allocator);
    try ps.withAsciiSeed(&buffer);

    while (!caught_signal) {
        try ps.updateAll();
        try ps.renderAll();
        std.time.sleep(100_000_000);
    }
}
