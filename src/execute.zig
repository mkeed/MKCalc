const std = @import("std");
const Result = usize;
pub fn execute(equation: []const u8, alloc: std.mem.Allocator) !Result {
    //
    var tokens = try tokenize(equation, alloc);
    defer tokens.deinit();
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
    pub fn match(self: TokenInfo, text: []const u8) ?usize {
        var anyMatch = false;
        for (self.begin) |b| {
            if (b.match(text[0])) {
                anyMatch = true;
                var count: usize = 1;
                while (count < text.len) : (count += 1) {
                    var internalMatch = false;
                    for (self.internal) |i| {
                        if (i.match(text[count])) internalMatch = true;
                    }
                    if (internalMatch == false) return count;
                }
            }
        }
        if (anyMatch == false) return null;
        return text.len;
    }
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

pub const Token = struct {
    start: usize,
    end: usize,
    tokenType: TokenType,
};

fn tokenize(equation: []const u8, alloc: std.mem.Allocator) !std.ArrayList(Token) {
    var count: usize = 0;
    var tokens = std.ArrayList(Token).init(alloc);
    errdefer tokens.deinit();
    while (count < equation.len) : (count += 1) {
        for (tokenInfos) |ti| {
            if (ti.match(equation[count..])) |m| {
                std.log.info("match:[{s}] token:{}", .{ equation[count..][0..m], ti.tokenType });
                count += (m - 1);
            }
        }
    }
    return tokens;
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
