using System;
using System.Diagnostics;

namespace blake3;

using static blake3.blake3;

static
{
	[Test]
	static void hash()
	{
		blake3_hasher hasher = ?;
		blake3_hasher_init(&hasher);

		// Read input bytes from stdin.
		String input = "this is a string to hash";

		blake3_hasher_update(&hasher, input.CStr(), (.)input.Length);

		// Finalize the hash. BLAKE3_OUT_LEN is the default output length, 32 bytes.
		uint8[BLAKE3_OUT_LEN] output = .();
		blake3_hasher_finalize(&hasher, &output, BLAKE3_OUT_LEN);

		String hex = scope .();

		// Print the hash as hexadecimal.
		for (let i < BLAKE3_OUT_LEN)
		{
			hex.AppendF("{0:X}", output[i]);
		}

		Test.Assert(hex == "EE5A1A957DCFD563CC9384B33DC39A58A5C21F0E3FF33FE10F3D4AB1C472C11");

		Debug.WriteLine($"hashed {hex}");
	}
}