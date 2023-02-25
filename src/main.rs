use structopt::StructOpt;

#[derive(StructOpt, Debug)]
#[structopt(name = "rsrename", about = "rsrename.")]
struct Opt {
    // A flag, true if used in the command line. Note doc comment will
    // be used for the help message of the flag. The name of the
    // argument will be, by default, based on the name of the field.

    // The number of occurrences of the `v/verbose` flag
    //// Verbose mode (-v, -vv, -vvv, etc.)
    // #[structopt(short, long, parse(from_occurrences))]
    // verbose: u8,

    // do the rename or just print what would be done..
    #[structopt(short="-n", long="--dry-run")]
    dry_run: bool,

    /// the root path to use
    /// should be shell-expanded.
    root: std::path::PathBuf,

    /// regex of the pattern from find
    patt: String,

    // replacement regex
    repl: String
}

use walkdir;
use regex;


fn rename(root: &std::path::Path, regx: &String, repl: &String, dry_run: bool) {
    let re = regex::Regex::new(regx).unwrap();
    let walker = walkdir::WalkDir::new(root);
    for entry in walker.into_iter() {
        let entry = entry.unwrap();
        let orig = entry.path();
        let newn = re.replace(orig.file_name().unwrap().to_str().unwrap(), repl);
        let dest = orig.with_file_name(newn.as_ref());
        if dest != orig {
            if dry_run {
                eprintln!("{} {} -> {}", "would rename", orig.to_str().unwrap(), dest.to_str().unwrap());
            } else {
                eprintln!("{} {} -> {}", "renamed", orig.to_str().unwrap(), dest.to_str().unwrap());
                std::fs::rename(orig, dest).unwrap();
            }
        }
    }
}

fn main() {
    let opts = Opt::from_args();

    rename(&opts.root, &opts.patt, &opts.repl, opts.dry_run);
}
