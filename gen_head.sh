#!/bin/bash
# cbindgen --config cbindgen.toml --crate driver-e1000/src/linux/binding_helper/Cargo.toml --output driver-e1000/src/linux/e1000.h
cbindgen --config cbindgen.toml  --output driver-e1000/src/linux/e1000.h driver-e1000/src/platform_linux.rs 