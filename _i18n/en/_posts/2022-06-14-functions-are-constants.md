---
layout: post
title: "Functions are constants too"
permalink: functions-are-constants/
tags:
  - programming-languages
  - software-engineering
---

{% include toc.md %}

Once in a while, I get feedback on a code review remarking that I ought to extract a certain string literal into a constant. For example, that this:

```rust
fn get_foo() -> {
    std::env::var("FOO").unwrap()
}
```

Should become this:

```rust
const FOO_KEY: &str = "FOO";

fn get_foo() -> {
    std::env::var(FOO_KEY).unwrap()
}
```

This *increases* the scope of the relevant constant. Now you have to check to see if that constant is used anywhere else, without improving legibility otherwise. So I'm oftentimes opposed to this kind of change.

(That being said, I'm not opposed to writing a helpful constant name which is still restricted in scope to the function body.)

Functions are constant values too! It's perfectly acceptable to leave implementation details, *including magic values*, inside a function definition (assuming that they're not used anywhere else).

Or alternatively --- constants are essentially zero-ary functions. This is more obvious in e.g. an ML-style language where function and constant bindings follow the same syntactic pattern:

```ocaml
let foo = 3      (* constant binding *)
let bar baz = 4  (* function which takes one argument *)
```

{% include end_matter.md %}
