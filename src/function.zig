pub const FunctionImpl = *const fn ([]const Value) Value;
pub const Function = struct {
    name: []const u8,
    funcImpl: FunctionImpl,
};
