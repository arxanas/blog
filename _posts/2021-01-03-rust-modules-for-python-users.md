---
layout: post
title: 'The Rust module system for Python users'
permalink: rust-modules-for-python-users/
tags:
  - python
  - rust
  - software-engineering
---

Every time I go back to Rust, I have to figure out how the module system works again. Here are some of my notes comparing it to Python's module system.

These notes are for Rust 2018.

* toc
{:toc}

### Crates

A **crate** is a build target in Rust. A crate can either be a library or a binary. It can be built with `cargo build`.

In Python, libraries are called "packages". Binaries are an entirely heterogenous concept, typically installed by configuring [entry points](https://packaging.python.org/specifications/entry-points/). Such a binary doesn't even need to be Python code (for example, it can be a shell script instead).

### Packages

A **package** in Rust consists of up to one library crate and any number of binary crates. (It's required that there be at least one library or binary crate.)

In Python, a single "distribution package" (i.e. one that you can `pip install`) can contain multiple "import packages" (i.e. one that you can `import`), while Rust allows at most one import package per distribution package.

### File layout

#### Crate roots

Python places `__init__.py` at the root of a package to indicate that it's importable as a package. Similarly, Rust conventionally puts `lib.rs` at the root of a crate as the library **crate root**. (Unlike Python, the name can be re-configured, but `lib.rs` is the default.)

In Python, `__main__.py` corresponds to the main entry point for the module when run with `python -m`. Rust conventionally puts `main.rs` as a binary crate root. (This can also be renamed, which is probably desirable if you have more than one binary.)

#### Module lookups

In Python, all modules are available by importing them via their filesystem path name. For example, `import foo.bar` first looks for a `foo/` directory on the `PYTHONPATH`. Then it looks for a `bar/` package or a `bar.py` module underneath the `foo/` directory.

In Rust, modules also correspond to their paths on the filesystem (by default; [you can use the `path` attribute](https://doc.rust-lang.org/reference/items/modules.html#the-path-attribute) to change this behavior). However, they are not immediately `use`-able just because the corresponding file is present! They must be declared with a `mod foo;` declaration in the crate root file (e.g. `lib.rs`).

#### Nested modules

In Python, a nested module `foo.bar` is implemented either by `foo/bar.py` or `foo/bar/__init__.py`. You can't use both. If you want to have sub-modules of `foo.bar`, you'll place additional modules or packages under `foo/bar/`.

A statement like `from foo.bar import qux` could either be importing a symbol declared in `foo/bar/__init__.py` or the module `foo/bar/qux.py`. Some developers choose to explicitly re-export the public interface of `bar` in `__init__.py` for clarity, and prefix sub-modules with underscores (e.g. `_qux.py` instead of `qux.py`).

In Rust, you use `foo/bar.rs` to declare members of the namespace `foo::bar`. If you also want to have sub-namespaces of bar (e.g. `foo::bar::qux`), then you additionally create the `bar/` directory alongside `bar.rs`. To access a sub-namespace `qux` inside `bar.rs`, the line `mod qux;` must be added to `bar.rs`. (This is similar to how we have to add `mod foo;` at the top-level `lib.rs`.)

To re-export the namespace and make it available to all users outside of `bar`, it should be changed to `pub mod qux;`.

The main take-away is that Rust requires the explicit re-exporting of nested modules using `mod` at each step of the hierarchy, while Python does not.
