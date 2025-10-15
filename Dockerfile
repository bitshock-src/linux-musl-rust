ARG TARGETARCH

FROM bitshock/x86_64-linux-musl-ubuntu-24.04:2.0.0 AS x86_64-musl

FROM bitshock/aarch64-linux-musl-ubuntu-24.04:2.0.0 AS aarch64-musl

FROM ubuntu:24.04  AS base

RUN apt update && apt upgrade -y && apt install -y \
    build-essential \
    clang \
    cmake \
    curl \
    git \
    libclang-dev \
    protobuf-compiler

FROM base AS base_amd64

RUN apt install -y \
    g++-aarch64-linux-gnu \
    gcc-aarch64-linux-gnu \
    libc6-dev-arm64-cross \
    libstdc++-12-dev-arm64-cross

FROM base AS base_arm64

RUN apt install -y \
    g++-x86-64-linux-gnu \
    gcc-x86-64-linux-gnu \
    libc6-dev-amd64-cross \
    libstdc++-12-dev-amd64-cross


FROM base_${TARGETARCH} AS final

ARG RUST=1.90.0

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain ${RUST} -y

ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup target add x86_64-unknown-linux-musl && \
    rustup target add aarch64-unknown-linux-musl

COPY --from=aarch64-musl /musl /opt/aarch64-linux-musl
COPY --from=x86_64-musl /musl /opt/x86_64-linux-musl

COPY linux-musl-rust.toml /opt/rust/linux-musl-rust.toml

ENV PATH="/opt/aarch64-linux-musl/bin:/opt/x86_64-linux-musl/bin:${PATH}"
