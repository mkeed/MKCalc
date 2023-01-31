const std = @import("std");
const Result = usize;
pub fn execute(equation: []const u8) !Result {
    //
    _ = equation;
    return 1;
}

const MatchCase = union(enum) {
    pub const Range = struct {
        start: u8,
        end: u8,
    };
    range: Range,
    list: []const u8,
    pub fn match(self: MatchCase, val: u8) bool {
        switch (self) {
            .range => |r| {
                return (val >= r.start and val <= r.end);
            },
            .list => |l| {
                for (l) |v| {
                    if (v == val) return true;
                }
                return false;
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
};

const TokenInfo = struct {
    begin: []const MatchCase,
    internal: []const MatchCase,
    tokenType: TokenType,
};

const tokenInfos = [_]TokenInfo{
    .{
        .begin = &.{range('0', '9')},
        .internal = &.{range('0', '9')},
        .tokenType = .Number,
    },
    .{
        .begin = &.{.{ .list = "+-/*" }},
        .internal = &.{},
        .tokenType = .Operator,
    },
    .{
        .begin = &.{ range('a', 'z'), range('A', 'Z') },
        .internal = &.{
            range('a', 'z'),
            range('A', 'Z'),
            .{ .list = "_" },
        },
        .tokenType = .Identifier,
    },
};

fn tokenize(equation: []const u8, alloc: std.mem.allocator) ![]Token {
    var count: usize = 0;
    while (count < equation.len) : (count += 1) {
        for (tokenInfos) |ti| {}
    }
}

const TestCase = struct {
    equation: []const u8,
    result: []const u8,
};
fn tc(equation: []const u8, result: []const u8) TestCase {
    return .{ .equation = equation, .result = result };
}
const tests = [_]TestCase{
    tc("1 + 1", "2"),
    tc("2 / 2 + 1", "2"),
    tc("2 + 1 / 2", "2"),
};

pub fn c_code(writer: anytype) !void {
    try std.fmt.format(writer,
        \\#include <stdio.h>
        \\int main(int argc,char **argv)
        \\{{
        \\
    , .{});
    for (tests) |t| {
        try std.fmt.format(writer,
            \\    printf("%d\n",({s}));
            \\
        , .{t.equation});
    }
    try std.fmt.format(writer, "}}\n", .{});
}
