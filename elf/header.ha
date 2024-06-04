use endian;

// Describes the content of an elf header
// Can be used for 32 and 64 bit as the data for 32 bits also fits into the data
// for 64.
export type header = struct {
	ident: [16]u8,
	etype: u16,
	machine: u16,
	version: u32,
	entry: u64,
	phoff: u64,
	shoff: u64,
	flags: u32,
	hsize: u16,
	phentsize: u16,
	phnum: u16,
	shentsize: u16,
	shnum: u16,
	shstrndx: u16,
};

// An error in reading the header
export type headererr = !void;

// Takes a slice containing at least the header of an elf file and reads the header information out
// of it. The data is either returned in the [[elfheader]] struct or an headererr is returned.
export fn readheader(file: []u8) (header | headererr) = {
	if (len(file) < 52
		|| file[0] != 0x7f
		|| file[1] != 'E'
		|| file[2] != 'L'
		|| file[3] != 'F'
		|| file[4] == 0
		|| file[5] == 0) {
		return headererr;
	};

	let conv: *endian::endian = endian::host;
	if (file[5] == 1) {
		conv = &endian::little;
	} else {
		conv = &endian::big;
	};

	let header = header{...};
	header.ident[0..16] = file[0..16];
	header.etype = conv.getu16(file[16..18]);
	header.machine = conv.getu16(file[18..20]);
	header.version = conv.getu32(file[20..24]);
	let index = 0z;
	if (file[4] == 1) {
		header.entry = conv.getu32(file[24..28]);
		header.phoff = conv.getu32(file[28..32]);
		header.shoff = conv.getu32(file[32..36]);
		index = 36;
	} else {
		header.entry = conv.getu64(file[24..32]);
		header.phoff = conv.getu64(file[32..40]);
		header.shoff = conv.getu64(file[40..48]);
		index = 48;
	};
	header.flags = conv.getu32(file[index..index+4]);
	header.hsize = conv.getu16(file[index+4..index+6]);
	header.phentsize = conv.getu16(file[index+6..index+8]);
	header.phnum = conv.getu16(file[index+8..index+10]);
	header.shentsize = conv.getu16(file[index+10..index+12]);
	header.shnum = conv.getu16(file[index+12..index+14]);
	header.shstrndx = conv.getu16(file[index+14..index+16]);
	return header;
};
