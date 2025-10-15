# linux-musl-rust

Build cross-compiled multi-platform statically-linked linux-musl Rust application images natively. Slow and unreliable architecture emulation (QEMU, Rosetta, etc.) is avoided.

Available target platforms:

* `linux/amd64`
* `linux/arm64`

Available build-host platforms:

* `linux/amd64`
* `linux/arm64`

## Use

The multi-platform `bitshock/linux-musl-rust` docker image is published on [Bitshock](https://hub.docker.com/u/bitshock) Docker hub.

```shell
docker pull bitshock/linux-musl-rust
```

The version tags are mapped to Rust versions.

### Example

```dockerfile
# Use BUILDPLATFORM to build with native architecture
ARG BUILDPLATFORM

FROM --platform=$BUILDPLATFORM bitshock/linux-musl-rust:1.90.0 AS builder

ARG TARGETPLATFORM

# Use TARGETPLATFORM to set --target for Rust build
RUN case ${TARGETPLATFORM} in \
         "linux/amd64") echo "RUST_TARGET=x86_64-unknown-linux-musl" > ./build.env ;; \
         "linux/arm64") echo "RUST_TARGET=aarch64-unknown-linux-musl" > ./build.env ;; \
         *) echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1 ;; \
    esac

# Build and copy application to predictable location
# Use --config to source included linux-musl Rust setup
RUN . ./build.env && \
    cargo build --release \
    --config /opt/rust/linux-musl-rust.toml \
    --target ${RUST_TARGET} && \
    cp ./target/${RUST_TARGET}/release/my_app /my_app


# Final image has scratch base
# Application is statically linked, no OS needed
FROM scratch AS final

COPY --from=builder /my_app /usr/local/sbin/my_app

ENV RUST_LOG=info

ENTRYPOINT ["/usr/local/sbin/my_app"]
```

Build your multi-platform application image:

```shell
docker buildx build --platform linux/amd64,linux/arm64 -t my_app:latest --load .
```

## Build

To build the `linux-musl-rust` image:

```shell
docker buildx build --platform linux/amd64,linux/arm64 -t linux-musl-rust:latest --load .
```