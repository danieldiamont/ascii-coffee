const std = @import("std");
const output = @import("output.zig");
const particleSystem = @import("particleSystem.zig");

pub const Particle = struct {
    row: f64,
    col: f64,
    drow: f64,
    dcol: f64,
    rowInit: f64,
    colInit: f64,
    value: f64,
    ch: u8,
    rand: std.rand.DefaultPrng,
    fixed: bool,

    pub fn init(
        row: usize,
        col: usize,
        drow: f64,
        dcol: f64,
        seed: usize,
    ) Particle {
        const _row: f64 = @floatFromInt(row);
        const _col: f64 = @floatFromInt(col);

        return Particle{
            .row = _row,
            .col = _col,
            .drow = drow,
            .dcol = dcol,
            .rowInit = _row,
            .colInit = _col,
            .value = 0,
            .rand = std.rand.DefaultPrng.init(seed),
            .fixed = true,
            .ch = ' ',
        };
    }

    pub fn render(self: *Particle) u8 {
        if (self.fixed == false) {
            self.ch = map(self.value);
        }
        return self.ch;
    }

    pub fn update(self: *Particle) void {
        const rng = self.rand.random();
        if (self.fixed == false) {
            const f = rng.floatNorm(f64);
            self.value = f;
            //std.log.debug("self.value {d}", .{self.value});
        }
        self.updatePosition();
    }

    pub fn unfix(self: *Particle) void {
        self.fixed = false;
    }

    pub fn forceCharacter(self: *Particle, ch: u8) void {
        self.ch = ch;
    }

    pub fn map(f: f64) u8 {
        if (f < -2) {
            return '{';
        } else if (f >= -2 and f < -1) {
            return '.';
        } else if (f >= -1 and f < 1) {
            return ' ';
        } else if (f >= 1 and f < 2) {
            return '.';
        } else {
            return '}';
        }
    }

    fn updatePosition(self: *Particle) void {
        if (self.fixed) {
            return;
        }

        self.row = self.row + self.drow;
        self.col = self.col + self.dcol;
    }

    pub fn getRow(self: Particle) usize {
        return @intFromFloat(self.row);
    }

    pub fn getCol(self: Particle) usize {
        return @intFromFloat(self.col);
    }
};
