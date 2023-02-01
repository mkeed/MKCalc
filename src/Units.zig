const std = @import("std");

const Unit = struct {
    time: i8 = 0,
    length: i8 = 0,
    mass: i8 = 0,
    current: i8 = 0,
    temperature: i8 = 0,
    amount: i8 = 0,
    luminous: i8 = 0,
    pub fn multiply(self: Unit, other: Unit) Unit {
        return .{
            .time = self.time + other.time,
            .length = self.length + other.length,
            .mass = self.mass + other.mass,
            .current = self.current + other.current,
            .temperature = self.temperature + other.temperature,
            .amount = self.amount + other.amount,
            .luminous = self.luminous + other.luminous,
        };
    }
    pub fn divide(self: Unit, other: Unit) Unit {
        return .{
            .time = self.time - other.time,
            .length = self.length - other.length,
            .mass = self.mass - other.mass,
            .current = self.current - other.current,
            .temperature = self.temperature - other.temperature,
            .amount = self.amount - other.amount,
            .luminous = self.luminous - other.luminous,
        };
    }

    pub fn equal(self: Unit, other: Unit) bool {
        return self.time == other.time and
            self.length == other.length and
            self.mass == other.mass and
            self.current == other.current and
            self.temperature == other.temperature and
            self.amount == other.amount and
            self.luminous == other.luminous;
    }
};

const Second = Unit{ .time = 1 };
const Hertz = Unit{ .time = -1 };
const Metre = Unit{ .length = 1 };
const SqMetre = Unit{ .length = 2 };
const CubicMetre = Unit{ .length = 3 };
const KiloGram = Unit{ .mass = 1 };
const Ampere = Unit{ .current = 1 };
const Kelvin = Unit{ .temperature = 1 };
const Mole = Unit{ .amount = 1 };
const Candela = Unit{ .luminous = 1 };

const Newton = Unit{ .time = -2, .length = 1, .mass = 1 };
const Pascal = Unit{ .time = -2, .length = -1, .mass = 1 };
const Joule = Unit{ .time = -2, .length = 2, .mass = 1 };
const Watt = Unit{ .time = -3, .length = 2, .mass = 1 };
const Coulomb = Unit{ .time = 1, .current = 1 };

test {
    try std.testing.expect(Pascal.equal(Newton.divide(SqMetre)));
}
