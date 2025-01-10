const std = @import("std");
const Particle = @import("particle.zig");
const stdout_file = std.io.getStdOut().writer();
var bw = std.io.bufferedWriter(stdout_file);
const stdout = bw.writer();

pub const ParticleSystem = struct {
    rng: std.rand.DefaultPrng,
    height: usize,
    width: usize,
    particles: []Particle.Particle,

    pub fn init(rng: std.rand.DefaultPrng, h: usize, w: usize) ParticleSystem {
        return ParticleSystem{ .rng = rng, .height = h, .width = w, .particles = [h * w]Particle.Particle };
    }

    fn flatten_indices(self: ParticleSystem, row: usize, col: usize) usize {
        return row * self.width + col;
    }

    pub fn setup(self: *ParticleSystem) void {
        for (0..self.height) |i| {
            for (0..self.width) |j| {
                const index = self.flatten_indices(i, j);
                var particle = self.particles[index];
                particle.calculate(self.rng);
            }
        }
    }
};
