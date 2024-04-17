let
  javascript = {
    path = ./javascript;
    description = "Javascript / Typescript dev environment";
  };

  python = {
    path = ./python;
    description = "Python dev environment";
  };

  rust = {
    path = ./rust;
    description = "Rust dev environment";
  };

  rust-stable = {
    path = ./rust-stable;
    description = "Rust (latest stable from fenix) dev environment";
  };
  rust-toolchain = {
    inherit welcomeText;
    path = ./rust-toolchain;
    description = "Rust dev environment, but from toolchain.toml";
  };
  empty = {
    inherit welcomeText;
    path = ./empty;
    description = "Default empty dev environment";
  };

in
{
  inherit
    javascript
    python
    rust
    rust-stable
    rust-toolchain
    empty
    ;
  js = javascript;
  ts = javascript;
  py = python;
  rs = rust;
  rs-stable = rust-stable;
}
