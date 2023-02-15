const std = @import("std");
const tokenize = @import("Tokenize.zig");

const Generator = struct {
    idx: usize = 0,
    pub fn peek(self: *Generator) [2]u8 {
        var buffer = [2]u8{
            'A' + @truncate(u8, self.idx / 26 % 26),
            'A' + @truncate(u8, self.idx % 26),
        };
        return buffer;
    }
    pub fn next(self: *Generator) [2]u8 {
        defer self.idx += 1;
        return self.peek();
    }
};

pub const AST = struct {
    pub const Operator = enum {
        Add,
        Subtract,
        pub fn toString(self: Operator) []const u8 {
            return switch (self) {
                .Add => "Add",
                .Subtract => "Subtract",
            };
        }
    };
    pub const NodeType = union(enum) {
        operator: Operator,
        constant: i64,
        root: void,
    };
    pub const Node = struct {
        nodeType: NodeType,
        subNodes: std.ArrayList(*Node),
        alloc: std.mem.Allocator,
        pub fn init(alloc: std.mem.Allocator, nt: NodeType) Node {
            return .{
                .nodeType = nt,
                .subNodes = std.ArrayList(*Node).init(alloc),
                .alloc = alloc,
            };
        }
        pub fn deinit(self: Node) void {
            for (self.subNodes.items) |sub| {
                sub.deinit();
                self.alloc.destroy(sub);
            }
            self.subNodes.deinit();
        }
        pub fn addSubNode(self: *Node, new: Node) !void {
            var newNode = try self.alloc.create(Node);
            errdefer self.alloc.destroy(newNode);
            newNode.* = new;
            try self.subNodes.append(newNode);
        }
        pub fn format(
            value: Node,
            _: []const u8,
            _: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            switch (value.nodeType) {
                .operator => |o| try std.fmt.format(writer, "Operator_{s}", .{o.toString()}),
                .constant => |val| try std.fmt.format(writer, "value:{}", .{val}),
                .root => try std.fmt.format(writer, "root", .{}),
            }
        }
        pub const GenerateDOTError = error{
            writeError,
        };
        pub fn generateDOT(self: Node, writer: anytype, gen: *Generator) GenerateDOTError!void {
            var curName = gen.next();
            std.fmt.format(writer, "{s} [label=\"{s}\"];\n", .{
                curName,
                self,
            }) catch return GenerateDOTError.writeError;
            for (self.subNodes.items) |sub| {
                std.fmt.format(writer, "{s} -> {s};\n", .{ curName, gen.peek() }) catch return GenerateDOTError.writeError;
                try sub.generateDOT(writer, gen);
            }
        }
    };
    root: Node,
    alloc: std.mem.Allocator,
    pub fn init(alloc: std.mem.Allocator) AST {
        return .{
            .root = Node.init(alloc, .root),
            .alloc = alloc,
        };
    }
    pub fn deinit(self: AST) void {
        self.root.deinit();
    }
    pub fn generateDOT(self: AST, writer: anytype) !void {
        var gen = Generator{};
        try std.fmt.format(writer, "digraph AST {{\n", .{});
        try self.root.generateDOT(writer, &gen);
        try std.fmt.format(writer, "}}\n", .{});
    }
};

fn constant(val: i64, alloc: std.mem.Allocator) AST.Node {
    return AST.Node.init(alloc, .{ .constant = val });
}

const CurState = enum {
    Init,
};

pub fn astGen(tokens: []const tokenize.Token, alloc: std.mem.Allocator) !AST {
    var ast = AST.init(alloc);
    for (tokens) |t| {
        std.log.info("token:{}", .{t});
    }
    var astTokens = std.ArrayList(ASTInfo).init(alloc);
    defer astTokens.deinit();

    var curState = CurState.init;

    ast.root.nodeType = .{ .operator = .Add };
    try ast.root.addSubNode(constant(10, alloc));
    try ast.root.addSubNode(constant(11, alloc));
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
