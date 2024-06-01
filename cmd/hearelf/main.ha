use encoding::hex;
use fmt;
use fs;
use io;
use os;

export fn main() void = {
	if (len(os::args) == 1) {
		fmt::fatal("no argments given");
	};
	const file = match (os::open(os::args[1])) {
	case let err: fs::error =>
		fmt::fatalf("error {} opening file {}\n", fs::strerror(err), os::args[1]);
	case let file: io::file =>
		yield file;
	};
	defer io::close(file)!;

	const file = io::drain(file)!;
	defer free(file);

	hex::dump(os::stdout, file)!;
	fmt::printf("elf file contains {} bytes\n", len(file))!;
};
