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
        root: void,
    };
    pub const Node = struct {
        nodeType: NodeType,
        subNodes: std.ArrayList(Node),
        pub fn deinit(self: Node) void {
            for (self.subNodes.items) |sub| {
                sub.deinit();
            }
            self.subNodes.deinit();
        }
    };
    root: Node,
    alloc: std.mem.Allocator,
    pub fn init(alloc: std.mem.Allocator) AST {
        return .{
            .root = .{
                .nodeType = .root,
                .subNodes = std.ArrayList(*Node).init(alloc),
            },
            .alloc = alloc,
        };
    }
    pub fn deinit(self: AST) void {
        self.root.deinit();
    }
};

fn constant(val: i64) AST.Node {
    return .{
        .nodeType = .{ .constant = val },
        .subNodes = &.{},
    };
}

pub fn astGen(tokens: []const tokenize.Token, alloc: std.mem.Allocator) !AST {
    var ast = AST.init(alloc);
    for (tokens) |t| {
        std.log.info("token:{}", .{t});
    }

    return ast;
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
