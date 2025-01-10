const std = @import("std");
const ParticleSystem = @import("particleSystem.zig");

const debug = std.debug.print;
const stdout_file = std.io.getStdOut().writer();
var bw = std.io.bufferedWriter(stdout_file);
const stdout = bw.writer();

const H = 50;
const W = 50;

pub fn main() !void {
    const rng = std.rand.DefaultPrng(42);
    const ps = ParticleSystem.ParticleSystem.init(rng);


    //var renderer = Renderer.init();

}
