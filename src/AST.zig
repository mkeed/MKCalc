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
};

fn constant(val: i64) AST.Node {
    return .{
        .nodeType = .{ .constant = val },
        .subNodes = &.{},
    };
}

fn astGen(tokens: []tokenize.Token) AST {
    _ = tokens;
    return .{};
}

const TestCase = struct {
    tokens: []const tokenize.Token,
    ast: AST,
};

test {
    const tc = [_]TestCase{
        .{
            .tokens = &.{
                .{
                    .tokens = &.{
                        .{ .number = 10 },
                        .{ .operator = .Add },
                        .{ .number = 1 },
                    },
                },
            },
            .ast = .{
                .root = .{
                    .nodeType = .{ .operator = .Add },
                    .subNodes = &.{ constant(10), constant(1) },
                },
            },
        },
    };
    _ = tc;
}
