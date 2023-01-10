---
layout: post
title: OCaml file extensions
permalink: ocaml-file-extensions/
tags:
  - ocaml
---

* toc
{:toc}

OCaml has a similar compilation model to C or C++. (Indeed, the OCaml compiler
will let you link the two together.) However, it's complicated by the fact that
it can target both bytecode and native code. As a result, there are a lot of
possible file extensions, and it's not obvious what they mean.

There are a lot of pages on the internet that specify *some* of the extensions
that I've encountered in practice, but no single page documents all of them.
I'm documenting here what I've found about each of them.

**Update 2022-03-18**: The online book *Real World OCaml* now has [a summary of file extensions][rwo-file-extensions].

  [rwo-file-extensions]: https://dev.realworldocaml.org/compiler-backend.html#scrollNav-4

## Bytecode vs native

OCaml can be compiled to bytecode or native code. See [Real World OCaml, Chapter
23][rwo-bytecode-native-code] for more detail.

  [rwo-bytecode-native-code]: https://dev.realworldocaml.org/compiler-backend.html

Bytecode:

* Portable, as long as the runtime exists on the target system.
* Probably faster to compile.
* Slower to execute.
* Can be used in conjunction with `ocamldebug` (e.g. to support time-traveling
  debugging).

Native code:

* Non-portable.
* Probably slower to compile.
* Faster to execute.
* Can't be used with `ocamldebug`.
  * Note that a traditional debugger like `gdb` will still work.
  * You can choose to compile OCaml to native code with debugging symbols using
    the [`-g` flag to `ocamlopt`][ocamlopt]. This is required to preserve stack
    traces.

  [ocamlopt]: https://caml.inria.fr/pub/docs/manual-ocaml/native.html

## File extensions

Source files:

* `.ml`: Implementation file.
* `.mli`: Interface file.

Compiled module interface:

* `.cmi` (both bytecode and native).
* This appears to be used to describe the signature of a module, but not contain
  its implementation. The analog in C or C++ might be a precompiled header.

Compiled module object code:

* Bytecode: `.cmo`
* Native: `.cmx`
* Analogous to `.o` files in C or C++.

Compiled module archive:

* Bytecode: `.cma`
* Native: `.cmxa`
* Analogous to `.a` files in C or C++.

Dynamically-linkable library:

* Native: `.cmxs`.
* No obvious counterpart for bytecode.
* Can be used with the [`Dynlink` library][dynlink].
* Analogous to `.so` or `.dll` files in C or C++.

  [dynlink]: https://caml.inria.fr/pub/docs/manual-ocaml/libdynlink.html

Documentation file:

* Documentation for source file: `.cmt`.
* Documentation for interface file: `.cmti`.
* These extensions seem to be specific to tooling, and are not used to generate
  code.
* It's unclear which tools make use of these. My guesses:
  * Yes: `odoc`, `codoc`.
  * No: `ocamldoc`.

{% include end_matter.md %}
