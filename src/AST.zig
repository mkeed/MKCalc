const std = @import("std");
const tokenize = @import("Tokenize.zig");
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
    tokens: []const tokenize.Token,
};

fn astGen(tokens: []tokenize.Token) AST {
    _ = tokens;
    return .{};
}

const TestCase = struct {
    tokens: []const tokenize.Token,
};
