FROM ubuntu:22.04

ARG rust_version
ARG bindgen_version

RUN echo rust: $rust_version bindgen: $bindgen_version

#定义时区参数
ENV TZ=Asia/Shanghai
#设置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo '$TZ' > /etc/timezone

# 将源列表中的 http://.*ubuntu.com 替换为 http://repo.huaweicloud.com
RUN sed -i 's@http://.*ubuntu.com@http://repo.huaweicloud.com@g' /etc/apt/sources.list

RUN apt-get clean
RUN apt-get -y update --fix-missing

RUN apt-get install -y git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc flex clang bison lld libclang-dev curl gdb  libelf-dev  binutils
RUN apt-get install -y llvm

ENV RUSTUP_DIST_SERVER "https://rsproxy.cn"
ENV RUSTUP_UPDATE_ROOT "https://rsproxy.cn/rustup"

RUN curl --proto '=https' --tlsv1.2 -sSf https://rsproxy.cn/rustup-init.sh | bash -s -- -y --default-toolchain ${rust_version}

ENV PATH="/root/.cargo/bin:${PATH}"

RUN tee ~/.cargo/config <<EOF
[source.crates-io]
replace-with = 'rsproxy'
[source.rsproxy]
registry = "https://rsproxy.cn/crates.io-index"
[source.rsproxy-sparse]
registry = "sparse+https://rsproxy.cn/index/"
[registries.rsproxy]
index = "https://rsproxy.cn/crates.io-index"
[net]
git-fetch-with-cli = true
EOF

RUN rustup component add rustfmt
RUN rustup component add clippy
RUN rustup component add rust-src


RUN cargo install --locked --version ${bindgen_version} bindgen

RUN apt-get install -y qemu-system

RUN  mkdir /workspace

WORKDIR /workspace
CMD [ "/bin/bash" ]