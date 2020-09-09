# Crux

Crux is a static analyzer to detect common undefined behaviors in Rust programs.

## Configurations

### Common

- CRUX_LOG
  - Adjust logging level. Use `.env` file at your discretion.
  - Example: `CRUX_LOG=info,crux::analyze::call_graph=error,tokei::language::language_type=error`

### Crux

- CRUX_REPORT
  - Report file location. If set, Crux analysis result will be serialized and
    saved to that file. Otherwise, the result will be printed to stderr.

### Crux-Runner

- CRUX_SCRATCH_DIR
  - Directory to store crawled crates (default: ../crux_scratch)
- CRUX_REPORT_DIR
  - Directory to store reports (default: ../crux_report)

## Development Setup

You need nightly Rust for Crux and custom Miri for PoC testing.

```
# Toolchain setup
rustup install nightly-2020-08-26
rustup component add rustc-dev
rustup component add miri

# Environment variable setup, put these in your `.bashrc`
export CRUX_RUST_CHANNEL=nightly-2020-08-26
export CRUX_PATH="<your project path>"
export RUSTFLAGS="-L $HOME/.rustup/toolchains/${CRUX_RUST_CHANNEL}-x86_64-unknown-linux-gnu/lib"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$HOME/.rustup/toolchains/${CRUX_RUST_CHANNEL}-x86_64-unknown-linux-gnu/lib:${CRUX_PATH}/target/release/deps:${CRUX_PATH}/target/debug/deps"

# Test your installation
cargo run -- --crate-type lib samples/trivial_escape.rs
```

Don't forget to add `.env` file for your local development.

## Code Formatting

1. Follow whatever `rustfmt` does
2. Group `use` statements in order of `std` - `rustc` internals - 3rd party - local order

## Setup rust-analyzer

Run:
```
cd ..
git clone https://github.com/rust-lang/rust.git rust-nightly-2020-08-26
cd rust-nightly-08-26
git checkout bf4342114
```

Add to workspace setting:
```
"rust-analyzer.cargo.features": [
    "rust-analyzer"
]
```

## Install Crux to Cargo

```
# this executes: cargo install --debug --path ./ --force --locked
./install-debug

crux ./test.rs  # for single file testing (you need to set library include path, or use `cargo run` instead)
cargo crux  # for crate compilation
cargo crux-update  # wrapper for ./install-debug
```

## Baseline Algorithm

```
Input: P
output: UAF

cg = CallGraph(P)
pta = PTA(p, cg)
path = collectHeapOpDFPath(P)
foreach P in Path
    UAF(p, pta)
```

- [ ] build call graph -> start from the root node
- [ ] flow-insensitive points-to analysis
- [ ] build data-flow graph
  - [ ] detect alloc / load / store / dealloc
  - just analyze the same function multiple times
- [ ] see if use of a pointer overlaps with a dropped pointer
