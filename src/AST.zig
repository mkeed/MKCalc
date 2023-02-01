const std = @import("std");
const tokenize = @import("Tokenize.zig");
pub const AST = struct {
    pub const Operator = enum {
        Add,
        Subtract,
    };
    pub const NodeType = union(enum) {
        operator: Operator,
        constant: i64,
    };
    pub const Node = struct {
        nodeType: NodeType,
        subNodes: []const Node,
    };
    root: Node,
};

fn constant(val: i64) AST.Node {
    return .{
        .nodeType = .{ .constant = val },
        .subNodes = &.{},
    };
}

fn astGen(tokens: []const tokenize.Token, alloc: std.mem.Allocator) AST {
    return .{
        .root = constant(10),
    };
}

const TestCase = struct {
    tokens: []const tokenize.Token,
    ast: AST,
};

test {
    const tc = [_]TestCase{
        .{
            .tokens = &.{
                .{ .number = 10 },
                .{ .operator = .Add },
                .{ .number = 1 },
            },
            .ast = .{
                .root = .{
                    .nodeType = .{ .operator = .Add },
                    .subNodes = &.{ constant(10), constant(1) },
                },
            },
        },
    };
    const alloc = std.testing.allocator;
    for (tc) |t| {
        _ = astGen(t.tokens, alloc);
    }
}
