const std = @import("std");
const Result = usize;
const tokenize = @import("Tokenize.zig");
const AST = @import("AST.zig");

pub fn execute(equation: []const u8, alloc: std.mem.Allocator) !Result {
    //
    var tokens = try tokenize.tokenize(equation, alloc);
    defer tokens.deinit();

    var ast = try AST.astGen(tokens.items, alloc);
    defer ast.deinit();
    return 1;
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
