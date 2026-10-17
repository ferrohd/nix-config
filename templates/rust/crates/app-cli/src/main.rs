//! A command line interface.
//!
//! The only crate producing a binary, so the one dist ships and the one release-plz marks as a
//! draft release for dist to upload into. Renaming it means moving `tag-namespace` in
//! dist-workspace.toml and `[[package]]` in release-plz.toml with it.

fn main() {
    println!("2 + 2 = {}", app::add(2, 2));
}
