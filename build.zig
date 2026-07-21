const std = @import("std");
const zbh = @import("zbh");

pub fn build(b: *std.Build) !void {
    const upstream = b.dependency("upstream", .{});
    const target = b.option([]const u8, "target", "");

    _ = try zbh.lib(b, .{
        .name = "assetsys",
        .target = target,
        .macros = &.{
            .{ "BLAKE3_USE_NEON", "0" },
            .{ "BLAKE3_NO_SSE2", "" },
            .{ "BLAKE3_NO_SSE41", "" },
            .{ "BLAKE3_NO_AVX2", "" },
            .{ "BLAKE3_NO_AVX512", "" },
        },
        .includes = &.{
            upstream.path(""),
        },
        .files = .{
            .root = upstream.path("c"),
            .files = &.{
                "blake3.c",
                "blake3_dispatch.c",
                "blake3_portable.c",
            },
        },
    });
}
