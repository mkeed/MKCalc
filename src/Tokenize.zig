const std = @import("std");

const MatchCase = union(enum) {
    pub const Range = struct {
        start: u8,
        end: u8,
    };
    range: Range,
    list: []const []const u8,

    pub fn match(self: MatchCase, val: []const u8) ?usize {
        switch (self) {
            .range => |r| {
                return if (val[0] >= r.start and val[0] <= r.end) 1 else null;
            },
            .list => |l| {
                for (l) |v| {
                    const subval = if (val.len > v.len) val[0..v.len] else val;
                    if (std.mem.eql(u8, v, subval)) return v.len;
                }
                return null;
            },
        }
    }
};

fn range(start: u8, end: u8) MatchCase {
    return MatchCase{ .range = .{ .start = start, .end = end } };
}

const TokenType = enum {
    Number,
    Operator,
    Identifier,
    Units,
};

const ParseFuncError = error{
    InvalidParse,
};

const ParseFunc = *const fn (data: []const u8) ParseFuncError!Token;

const TokenInfo = struct {
    begin: []const MatchCase,
    internal: []const MatchCase,
    tokenType: ?TokenType,
    parse: ?ParseFunc,
    pub fn match(self: TokenInfo, text: []const u8) ?usize {
        var anyMatch = false;
        for (self.begin) |b| {
            if (b.match(text[0..])) |len| {
                anyMatch = true;
                var count: usize = len;
                while (count < text.len) : (count += 1) {
                    var internalMatch = false;
                    for (self.internal) |i| {
                        if (i.match(text[count..]) != null) internalMatch = true;
                    }
                    if (internalMatch == false) return count;
                }
            }
        }
        if (anyMatch == false) return null;
        return text.len;
    }
};

fn parseInt(data: []const u8) ParseFuncError!Token {
    const val = std.fmt.parseInt(i64, data, 0) catch {
        return ParseFuncError.InvalidParse;
    };
    return .{ .Number = val };
}

fn parseIdentifier(data: []const u8) ParseFuncError!Token {
    return .{
        .Identifier = data,
    };
}
fn unitsParse(data: []const u8) ParseFuncError!Token {
    return .{
        .Units = data[1..],
    };
}
const tokenInfos = [_]TokenInfo{
    .{
        .begin = &.{.{ .list = &.{"0x"} }},
        .internal = &.{ range('0', '9'), range('a', 'f'), range('A', 'F') },
        .tokenType = .Number,
        .parse = parseInt,
    },
    .{
        .begin = &.{.{ .list = &.{"0b"} }},
        .internal = &.{range('0', '1')},
        .tokenType = .Number,
        .parse = parseInt,
    },
    .{
        .begin = &.{range('0', '9')},
        .internal = &.{range('0', '9')},
        .tokenType = .Number,
        .parse = parseInt,
    },
    Operator.info,
    .{
        .begin = &.{ range('a', 'z'), range('A', 'Z') },
        .internal = &.{
            range('a', 'z'),
            range('A', 'Z'),
            .{ .list = &.{"_"} },
        },
        .tokenType = .Identifier,
        .parse = parseIdentifier,
    },
    .{
        .begin = &.{.{ .list = &.{"#"} }},
        .internal = &.{
            range('a', 'z'),
            range('A', 'Z'),
            .{ .list = &.{"_"} },
        },
        .tokenType = .Units,
        .parse = unitsParse,
    },
    .{
        .begin = &.{.{ .list = &.{ " ", "\t", "\n" } }},
        .internal = &.{.{ .list = &.{ " ", "\t", "\n" } }},
        .tokenType = null,
        .parse = null,
    },
};

pub const Operator = enum {
    Add,
    Subtract,
    Divide,
    Multiply,
    OpenFunction,
    CloseFunction,
    OpenArray,
    CloseArray,
    Seperator,
    Equal,
    const info = TokenInfo{
        .begin = &.{.{ .list = &.{ "+", "-", "/", "*", "(", ")", ",", "=", "[", "]" } }},
        .internal = &.{},
        .tokenType = .Operator,
        .parse = &operatorParse,
    };
    fn operatorParse(data: []const u8) ParseFuncError!Token {
        return .{ .Operator = switch (data[0]) {
            '+' => .Add,
            '-' => .Subtract,
            '/' => .Divide,
            '*' => .Multiply,
            '(' => .OpenFunction,
            ')' => .CloseFunction,
            ',' => .Seperator,
            '=' => .Equal,
            '[' => .OpenArray,
            ']' => .CloseArray,
            else => {
                return ParseFuncError.InvalidParse;
            },
        } };
    }
};

pub const Token = union(TokenType) {
    Operator: Operator,
    Number: i64,
    Identifier: []const u8,
    Units: []const u8,
    pub fn compare(self: Token, other: Token) bool {
        switch (self) {
            .Operator => |val| {
                const oval = switch (other) {
                    .Operator => |otherval| otherval,
                    else => return false,
                };
                return oval == val;
            },
            .Number => |val| {
                const oval = switch (other) {
                    .Number => |otherval| otherval,
                    else => return false,
                };
                return oval == val;
            },
            .Identifier => |val| {
                const oval = switch (other) {
                    .Identifier => |otherval| otherval,
                    else => return false,
                };
                return std.mem.eql(u8, oval, val);
            },
            .Units => |val| {
                const oval = switch (other) {
                    .Units => |otherval| otherval,
                    else => return false,
                };
                return std.mem.eql(u8, oval, val);
            },
        }
    }
    pub fn format(value: Token, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        switch (value) {
            .Operator => |op| {
                try std.fmt.format(writer, "Operator => [{}]", .{op});
            },
            .Number => |num| {
                try std.fmt.format(writer, "Number => [{}]", .{num});
            },
            .Identifier => |id| {
                try std.fmt.format(writer, "identifier => [{s}]", .{id});
            },
            .Units => |id| {
                try std.fmt.format(writer, "unit => [{s}]", .{id});
            },
        }
    }
};

pub fn tokenize(equation: []const u8, alloc: std.mem.Allocator) !std.ArrayList(Token) {
    std.log.info("tokenize", .{});
    var count: usize = 0;
    var tokens = std.ArrayList(Token).init(alloc);
    errdefer tokens.deinit();
    outer: while (count < equation.len) : (count += 1) {
        for (tokenInfos) |ti| {
            if (ti.match(equation[count..])) |m| {
                if (ti.parse) |parse| {
                    const t = try parse(equation[count .. count + m]);
                    try tokens.append(t);
                }
                count += (m - 1);
                continue :outer;
            }
        }
        return error.InvalidToken;
    }
    return tokens;
}

const TokenTest = struct {
    equation: []const u8,
    tokens: []const Token,
};

test {
    const testCases = [_]TokenTest{
        .{
            .equation = "10 + 1",
            .tokens = &.{ .{ .Number = 10 }, .{ .Operator = .Add }, .{ .Number = 1 } },
        },
        .{
            .equation = "10+1/2-2#kg",
            .tokens = &.{
                .{ .Number = 10 },
                .{ .Operator = .Add },
                .{ .Number = 1 },
                .{ .Operator = .Divide },
                .{ .Number = 2 },
                .{ .Operator = .Subtract },
                .{ .Number = 2 },
                .{ .Units = "kg" },
            },
        },
    };

    const alloc = std.testing.allocator;
    for (testCases) |tc| {
        var tokens = try tokenize(tc.equation, alloc);
        defer tokens.deinit();
        for (tokens.items) |t, idx| {
            try std.testing.expect(t.compare(tc.tokens[idx]));
        }
    }
}

const ParsedToken = struct {};

const ParseInfo = struct {
    list: []const TokenType,
};

const parseInfo = [_]ParseInfo{
    .{
        .list = &.{ .Number, .Units },
    },
};
