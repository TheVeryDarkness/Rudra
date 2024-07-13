# Copied and modified from the rust official image
# https://github.com/rust-lang/docker-rust/blob/bbc7feb12033da3909dced4e88ddbb6964fbc328/1.50.0/buster/Dockerfile
FROM buildpack-deps:bookworm

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=nightly-2023-11-23

# ENV RUSTFLAGS="-L ${RUSTUP_HOME}/toolchains/${RUST_VERSION}-aarch64-unknown-linux-gnu/lib" \
#     LD_LIBRARY_PATH="${RUSTUP_HOME}/toolchains/${RUST_VERSION}-aarch64-unknown-linux-gnu/lib"

# Thanks to https://mirrors.tuna.tsinghua.edu.cn/help/rustup/
# for bash
RUN echo 'export RUSTUP_UPDATE_ROOT=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup' >> ~/.bash_profile && \
    echo 'export RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup' >> ~/.bash_profile
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain $RUST_VERSION

# Install Rust
RUN set -eux; \
    rustup default $RUST_VERSION; \
    rustup component add rustc-dev; \
    rustup --version; \
    cargo --version; \
    rustc --version;

COPY ./docker/sources.list /etc/apt/sources.list

# Install sccache
RUN set -eux; \
    apt-get update;

COPY ./docker/config /root/config
RUN cat /root/config >> $CARGO_HOME/config && rm /root/config

# Install Rudra
COPY rust-toolchain.toml /tmp/rust-toolchain.toml
COPY crawl /tmp/crawl
RUN set -eux; \
    cargo install --path /tmp/crawl --bin rudra-runner --bin unsafe-counter; \
    rm -rf /tmp/rust-toolchain.toml /tmp/crawl;

RUN apt-get install -y cmake clang

RUN rustup component add llvm-tools

COPY . /usr/local/rudra/
RUN set -eux; \
    cd /usr/local/rudra/; \
    cargo build --release --all-targets; \
    ./install-release.sh;
    # ./install-release.sh;
