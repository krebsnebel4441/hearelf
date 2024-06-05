use elf;
use encoding::hex;
use fmt;
use fs;
use getopt;
use io;
use os;

export fn main() void = {
	const cmd = getopt::parse(os::args,
		"hearelf",
		('H', "display header"),
		"file",
	);
	defer getopt::finish(&cmd);

	let head = false;
	for (let opt .. cmd.opts) {
		switch (opt.0) {
		case 'H' =>
			head = true;
		case => abort();
		};
	};

	for (let arg .. cmd.args) {
		const file = match (os::open(arg)) {
		case let err: fs::error =>
			fmt::fatalf("error opening {} caused by {}", arg, fs::strerror(err));
		case let file: io::file =>
			yield file;
		};
		const file = io::drain(file)!;
		defer free(file);

		const header = match (elf::readheader(file)) {
		case elf::headererr =>
			fmt::fatal("header invalid");
		case let head: elf::header =>
			yield head;
		};

		fmt::printf("File {}\n", arg)!;

		if (head) {
			displayheader(header);
		};
	};
};

fn displayheader(header: elf::header) void = {
	let strings = elf::strfields(header);
	fmt::println("ELF Header:")!;
	fmt::printf("   Class:\t\t\t{}\n", strings.0)!;
	fmt::printf("   Data:\t\t\t{}\n", strings.1)!;
	fmt::printf("   Version:\t\t\t{}\n", header.ident[6])!;
	fmt::printf("   OS/ABI:\t\t\t{}\n", header.ident[7])!;
	fmt::printf("   Type:\t\t\t{}\n", strings.2)!;
	fmt::printf("   Maschine:\t\t\t{}\n", header.machine)!;
	fmt::printf("   Version:\t\t\t{}\n", "0x1")!;
	fmt::printf("   Entry point:\t\t\t{:x}\n", header.entry)!;
	fmt::printf("   Program headers:\t\t{:x}\n", header.phoff)!;
	fmt::printf("   Section headers:\t\t{:x}\n", header.shoff)!;
	fmt::printf("   Flags:\t\t\t{:x}\n", header.flags)!;
	fmt::printf("   Headersize:\t\t\t{} (bytes)\n", header.hsize)!;
	fmt::printf("   Program header size:\t\t{} (bytes)\n", header.phentsize)!;
	fmt::printf("   Program header count:\t{}\n", header.phnum)!;
	fmt::printf("   Section header size:\t\t{} (bytes)\n", header.shentsize)!;
	fmt::printf("   Section header count:\t{}\n", header.shnum)!;
	fmt::printf("   String table index:\t\t{}\n", header.shstrndx)!;
};
