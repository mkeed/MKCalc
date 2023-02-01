const std = @import("std");
const Result = usize;
pub fn execute(equation: []const u8, alloc: std.mem.Allocator) !Result {
    //
    var tokens = try tokenize(equation, alloc);
    defer tokens.deinit();
    for (tokens.items) |t| {
        std.log.info("match:[{s}] token:{}", .{ t.data, t.tokenType });
    }
    return 1;
}

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
};

const TokenInfo = struct {
    begin: []const MatchCase,
    internal: []const MatchCase,
    tokenType: TokenType,
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

const tokenInfos = [_]TokenInfo{
    .{
        .begin = &.{.{ .list = &.{"0x"} }},
        .internal = &.{ range('0', '9'), range('a', 'f'), range('A', 'F') },
        .tokenType = .Number,
    },
    .{
        .begin = &.{.{ .list = &.{"0b"} }},
        .internal = &.{range('0', '1')},
        .tokenType = .Number,
    },
    .{
        .begin = &.{range('0', '9')},
        .internal = &.{range('0', '9')},
        .tokenType = .Number,
    },
    .{
        .begin = &.{.{ .list = &.{ "+", "-", "/", "*", "(", ")", ",", "=" } }},
        .internal = &.{},
        .tokenType = .Operator,
    },
    .{
        .begin = &.{ range('a', 'z'), range('A', 'Z') },
        .internal = &.{
            range('a', 'z'),
            range('A', 'Z'),
            .{ .list = &.{"_"} },
        },
        .tokenType = .Identifier,
    },
};

pub const Token = struct {
    data: []const u8,
    tokenType: TokenType,
};

fn tokenize(equation: []const u8, alloc: std.mem.Allocator) !std.ArrayList(Token) {
    std.log.info("tokenize", .{});
    var count: usize = 0;
    var tokens = std.ArrayList(Token).init(alloc);
    errdefer tokens.deinit();
    outer: while (count < equation.len) : (count += 1) {
        for (tokenInfos) |ti| {
            if (ti.match(equation[count..])) |m| {
                try tokens.append(.{
                    .data = equation[count .. count + m],
                    .tokenType = ti.tokenType,
                });
                count += (m - 1);
                continue :outer;
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

pub const AST = struct {
    pub const Operator = enum {
        Add,
        Subtract,
    };
    pub const NodeType = union(enum) {
        operator: Operator,
    };
    pub const Node = struct {
        nodeType: NodeType,
        subNodes: []const Node,
    };
};

const ASTTest = struct {
    tokens: []const Token,
};

fn astGen(tokens: []Token) AST {
    _ = tokens;
    return .{};
}
