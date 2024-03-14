#!/bin/sh -e
rustup install nightly-2023-11-23
rustup default nightly-2023-11-23
rustup component add rustc-dev
rustup component add miri
