FROM node:13.11.0-alpine3.11

# install stuff to run rust (copied from official rust image)
RUN apk add --no-cache \
        ca-certificates \
        gcc \
        bash

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.42.0

RUN set -eux; \
    url="https://static.rust-lang.org/rustup/archive/1.21.1/x86_64-unknown-linux-musl/rustup-init"; \
    wget "$url"; \
    echo "0c86d467982bdf5c4b8d844bf8c3f7fc602cc4ac30b29262b8941d6d8b363d7e *rustup-init" | sha256sum -c -; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version;

# copy code & scripts
COPY js /js
COPY rust /rust
#COPY js/am-i-alive.js /js/am-i-alive.js
COPY run.sh /run.sh

# prepare javascript code
WORKDIR /js
RUN npm i

# build rust code & clean up
WORKDIR /rust
RUN cargo build --release \
    && chmod +x target/release/rstream-in \
    && mv target/release/rstream-in /rust/ \
    && cargo clean \
    && rm -rf /usr/local/rustup /usr/local/cargo

WORKDIR /

CMD /run.sh
