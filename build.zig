const std = @import("std");

const optimize_matrix: []const std.builtin.OptimizeMode = &.{
    .Debug,
    .ReleaseSmall,
};

const targets_matrix: []const std.Target.Query = &.{
    .{ .cpu_arch = .x86_64, .os_tag = .windows, .abi = .msvc },
    .{ .cpu_arch = .aarch64, .os_tag = .windows, .abi = .gnu },

    .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .musl },
    .{ .cpu_arch = .aarch64, .os_tag = .linux, .abi = .gnu },

    .{ .cpu_arch = .x86_64, .os_tag = .macos },
    .{ .cpu_arch = .aarch64, .os_tag = .macos },
};

const upstream_name = "upstream";

const lib_name = "blake3";

const lib_name_debug = "blake3_d";

const sources = &.{
    "c/blake3.c",
    "c/blake3_dispatch.c",
    "c/blake3_portable.c",
};

pub fn build(b: *std.Build) !void {
    const target: []const u8 = b.option([]const u8, "target", "specify target triple") orelse "";

    const upstream = b.dependency(upstream_name, .{});

    for (optimize_matrix) |o| {
        for (targets_matrix) |t| {
            const triple = t.zigTriple(b.allocator) catch "";

            const mod = b.createModule(.{
                .target = b.resolveTargetQuery(t),
                .optimize = o,
                .sanitize_c = .off,
                .stack_check = false,
                .stack_protector = false,
                .single_threaded = true,
            });

            mod.linkSystemLibrary("c", .{});

            mod.addIncludePath(upstream.path(""));

            mod.addCSourceFiles(.{ .root = upstream.path(""), .files = sources });

            mod.addCMacro("BLAKE3_USE_NEON", "0");
            mod.addCMacro("BLAKE3_NO_SSE2", "");
            mod.addCMacro("BLAKE3_NO_SSE41", "");
            mod.addCMacro("BLAKE3_NO_AVX2", "");
            mod.addCMacro("BLAKE3_NO_AVX512", "");

            const lib = b.addLibrary(.{
                .name = if (o == .Debug) lib_name_debug else lib_name,
                .linkage = .static,
                .root_module = mod,
            });

            const target_output = b.addInstallArtifact(lib, .{
                .dest_dir = .{
                    .override = .{
                        .custom = triple,
                    },
                },
            });

            if (std.mem.eql(u8, target, "") or std.mem.eql(u8, target, triple)) {
                b.getInstallStep().dependOn(&target_output.step);
            }
        }
    }
}
