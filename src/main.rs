use clap::Parser;

#[derive(Parser, Debug)]
#[command(author, version)] // read from cargo.toml
#[command(about)] // would read from cargo.toml, but long_about isn't.
#[command(long_about)]
#[command(verbatim_doc_comment)]
/// A file renamer.
///
/// Renames files/folders under ROOT matching PATT to REPL.
/// Capture clauses in PATT are available in REPL.
/// Files cannot be moved by this tool, ony their names changed.
struct CliArgs {
    /// Do the rename or just print what would be renamed to what.
    #[arg(short='n', long="dry-run")]
    dry_run: bool,

    /// The root path to use.
    ///
    /// Should be shell-expanded, but isn't..
    /// Note: ~/ and ~<name> do not get expanded.
    #[arg(verbatim_doc_comment)]
    root: std::path::PathBuf,

    /// Regex of the pattern to find..
    ///
    /// Use ( ) to capture content to use when replacing..
    #[arg(verbatim_doc_comment)]
    patt: String,

    /// Replacement regex..
    ///
    /// Use $<n> to use captured string <n> in patt..
    #[arg(verbatim_doc_comment)]
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
    let opts = CliArgs::parse();
    //eprintln!("{:#?}",opts);
    rename(&opts.root, &opts.patt, &opts.repl, opts.dry_run);
}
