# Force platform to amd64 for GitHub Actions compatibility
FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install essential build tools, static analysis, and ARM GCC toolchain
RUN apt-get update && apt-get install -y \
    build-essential \
    make \
    cmake \
    wget \
    tar \
    bzip2 \
    cppcheck \
    git \
    gcc-arm-none-eabi \
    libnewlib-arm-none-eabi \
    && rm -rf /var/lib/apt/lists/*

# Add non-root user matching the video setup
RUN useradd -m ubuntu
USER ubuntu
WORKDIR /home/ubuntu