//! A library.
//!
//! The crate-level doc is not decoration: `missing_docs = "deny"` means the crate does not
//! compile without it, and the same goes for every public item.

// `just doc` and docs.rs both set `--cfg docsrs`, so `#[cfg(docsrs)]` behaves the same in both.
// Not `#![cfg_attr(docsrs, feature(doc_auto_cfg))]` — that was removed in 1.92 and folded into
// `doc_cfg`, and was nightly-only anyway, so on stable it is a hard error.

/// Adds two numbers.
///
/// The doctest is why `just test` runs `cargo test --doc` separately: nextest does not run
/// doctests at all.
///
/// ```
/// assert_eq!(app::add(2, 2), 4);
/// ```
#[must_use]
pub const fn add(left: u64, right: u64) -> u64 {
    left + right
}

#[cfg(test)]
mod tests {
    use super::add;

    #[test]
    fn adds() {
        assert_eq!(add(2, 2), 4);
    }
}
