using System;
using System.Interop;

namespace blake3;

public static class blake3
{
	typealias uint8_t = uint8;
	typealias uint16_t = uint16;
	typealias uint32_t = uint32;
	typealias uint64_t = uint64;
	typealias size_t = c_size;
	typealias char = c_char;

	public const c_char* BLAKE3_VERSION_STRING = "1.8.1";
	public const c_int BLAKE3_KEY_LEN = 32;
	public const c_int BLAKE3_OUT_LEN = 32;
	public const c_int BLAKE3_BLOCK_LEN = 64;
	public const c_int BLAKE3_CHUNK_LEN = 1024;
	public const c_int BLAKE3_MAX_DEPTH = 54;

	// This struct is a private implementation detail. It has to be here because
	// it's part of blake3_hasher below.
	[CRepr]
	public struct blake3_chunk_state
	{
		public uint32_t[8] cv;
		public uint64_t chunk_counter;
		public uint8_t[BLAKE3_BLOCK_LEN] buf;
		public uint8_t buf_len;
		public uint8_t blocks_compressed;
		public uint8_t flags;
	}

	[CRepr]
	public struct blake3_hasher
	{
		public uint32_t[8] key;
		public blake3_chunk_state chunk;
		public uint8_t cv_stack_len;
		// The stack size is MAX_DEPTH + 1 because we do lazy merging. For example,
		// with 7 chunks, we have 3 entries in the stack. Adding an 8th chunk
		// requires a 4th entry, rather than merging everything down to 1, because we
		// don't know whether more input is coming. This is different from how the
		// reference implementation does things.
		public uint8_t[(BLAKE3_MAX_DEPTH + 1) * BLAKE3_OUT_LEN] cv_stack;
	}

	[CLink] public static extern char* blake3_version(void);
	[CLink] public static extern void blake3_hasher_init(blake3_hasher* self);
	[CLink] public static extern void blake3_hasher_init_keyed(blake3_hasher* self, uint8_t[BLAKE3_KEY_LEN] key);
	[CLink] public static extern void blake3_hasher_init_derive_key(blake3_hasher* self, char* context);
	[CLink] public static extern void blake3_hasher_init_derive_key_raw(blake3_hasher* self, void* context, size_t context_len);
	[CLink] public static extern void blake3_hasher_update(blake3_hasher* self, void* input, size_t input_len);
#if BLAKE3_USE_TBB
	[CLink] public static extern void blake3_hasher_update_tbb(blake3_hasher* self, void *input, size_t input_len);
#endif
	[CLink] public static extern void blake3_hasher_finalize(blake3_hasher* self, uint8_t* output, size_t out_len);
	[CLink] public static extern void blake3_hasher_finalize_seek(blake3_hasher* self, uint64_t seek, uint8_t* output, size_t out_len);
	[CLink] public static extern void blake3_hasher_reset(blake3_hasher* self);
}