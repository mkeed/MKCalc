pub const EquationExample = struct {
    eq: []const u8,
    result: []const u8,
    docs: []const u8,
};

pub const Equations = [_]EquationExample{
    .{
        .eq = "1 + 1",
        .result = "2",
        .docs = "simple equation",
    },
    .{
        .eq = "floor(1.5)",
        .result = "1",
        .docs = "function calls",
    },
    .{
        .eq = "max([1, 2, 3, 4])",
        .result = "4",
        .docs = "arrays",
    },
    .{
        .eq = "floor([1.5,3.14,10.1])",
        .result = "[1,3,10]",
        .docs = "functions can operate or arrays as well",
    },
};
