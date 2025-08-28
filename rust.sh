package: rust
version: "1.84"
system_requirement_missing: |
  Please install the Rust toolchain on your system:
    * On RHEL-compatible systems: rust-toolset
    * On Ubuntu-compatible systems: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
system_requirement: ".*"
system_requirement_check: |
  type rustc && type cargo
---
