const std = @import("std");
pub const debug = std.debug.print;
pub const stdout_file = std.io.getStdOut().writer();
pub var bw = std.io.bufferedWriter(stdout_file);
pub const stdout = bw.writer();

pub fn flush() !void {
    try bw.flush();
}
