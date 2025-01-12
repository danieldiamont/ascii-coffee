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
    rng: std.Random,
    fixed: bool,

    pub fn init(row: usize, col: usize, seed: usize, fixed: bool) Particle {
        const _row: f64 = @floatFromInt(row);
        const _col: f64 = @floatFromInt(col);

        var rand = std.rand.DefaultPrng.init(seed);
        const rng = rand.random();

        return Particle{ .row = _row, .col = _col, .drow = 0, .dcol = 0, .rowInit = _row, .colInit = _col, .value = 0, .rng = rng, .fixed = fixed, .ch = ' ' };
    }

    pub fn render(self: *Particle) u8 {
        if (self.fixed == false) {
            self.ch = map(self.value);
        }
        return self.ch;
    }

    pub fn update(self: *Particle) void {
        if (self.fixed == false) {
            //self.updatePosition();

            if (self.row == particleSystem.LAST_DRAWABLE_ROW) {
                const f = self.rng.floatNorm(f64);
                self.value = f;
            }
        } else {}
    }

    pub fn unfix(self: *Particle) void {
        self.fixed = false;
    }

    pub fn forceCharacter(self: *Particle, ch: u8) void {
        self.ch = ch;
    }

    pub fn map(f: f64) u8 {
        if (f < -3) {
            return ' ';
        } else if (f >= -3 and f < -2) {
            return '{';
        } else if (f >= -2 and f < -1) {
            return '{';
        } else if (f >= -1 and f < 1) {
            return '.';
        } else if (f >= 1 and f < 2) {
            return '}';
        } else {
            return ' ';
        }
    }

    fn updatePosition(self: *Particle) void {
        self.row = self.row + self.drow;
        self.col = self.col + self.dcol;

        if (self.row < 0 or self.row > particleSystem.LAST_DRAWABLE_ROW) {
            self.row = self.rowInit;
        }
        if (self.col < particleSystem.FIRST_DRAWABLE_COL or self.col > particleSystem.LAST_DRAWABLE_COL) {
            self.col = self.colInit;
        }
    }

    pub fn getRow(self: Particle) usize {
        return @intFromFloat(self.row);
    }

    pub fn getCol(self: Particle) usize {
        return @intFromFloat(self.col);
    }
};
