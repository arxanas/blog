---
layout: post
title: 'Incrementally porting a small Python project to Rust'
permalink: port-python-to-rust/
tags:
  - python
  - rust
  - software-engineering
---

I've been working on [git-branchless](https://github.com/arxanas/git-branchless), a Git workflow similar to the Mercurial "stacked-diff" workflows used at Google and Facebook. I originally wrote it in Python, but later ported it to Rust. This post details various aspects of the porting process.

* toc
{:toc}

## Introduction

### Motivation

Initially, I prototyped a working version of git-branchless using Python. The `git-branchless` executable can be invoked in one of two ways:

1. **Explicitly by a user's command**. For example, `git-branchless smartlog`. This is typically aliased to `git sl`.
2. **By a [Git "hook"](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)**. This is an event that triggers when specific actions occur in the repository. For example, when a user makes a commit, it triggers the `post-commit` hook, which then tells `git-branchless` to register the commit in its internal database.

However, some Git operations can result in many Git hook invocations, and therefore Python invocations. For example, a rebase of a stack of several commits will trigger several `post-commit` hooks in sequence. The Python interpreter takes tens or hundreds of milliseconds to start up, which degrades performance in the situation where we invoke it many times serially.

I considered adding some kind of long-running background daemon to the Python codebase, but I hate the amount of additional complexity and edge-cases associated with such an approach. Instead, I decided to rewrite the project in Rust to address the startup time issue.

### Why Rust?

These were the requirements for my choice of language:

* Fast startup time.
* Bindings to [SQLite](https://www.sqlite.org/index.html), [`libgit2`](https://libgit2.org/) (or equivalent), and to some kind of [TUI](https://en.wikipedia.org/wiki/Text-based_user_interface) library.
* Python interop, to support an incremental porting approach.

There are a lot of languages which may meet these constraints. I chose Rust because I had some prior experience with it, and I liked the ML-style type system. The Python codebase was already statically-checked with Mypy and written in an ML style, so it was largely a line-by-line port.

Realistically, Go would have been equally good, if not better, for this domain. I chose Rust anyways because I prefer it as a language.

### Previous Rust experience

I used OCaml professionally for four years. Rust is descended from OCaml, so it's quite similar. During that time, my team was rewriting various components from OCaml into Rust for performance reasons. I personally wrote one of the  smaller modules, which was called from OCaml.

Since we were a team working on a programming language, we also happened to have had read a couple of papers on linear types, so the underlying theory guiding the borrow checker was familiar to me.

Essentially, I had as much Rust experience as one can have without actually having written any large amount of code in it. Overall, the language did not surprise me very much. A couple of points that did surprise me:

* I already knew about the `Deref` trait, which allows references to be automatically dereferenced (in the style of a [smart pointer](https://en.wikipedia.org/wiki/Smart_pointer)), but didn't know about the `Borrow` trait, which allows values to be borrowed as a different type. The exact relationship between `String` and `str` wasn't clear to me until observing this.
* The `'static` lifetime includes not only statically-allocated data, but also any owned data. Since the data is owned, the user of that data can ensure that it lives for any length of time. Once I realized this, the lifetime annotations on closures made a lot more sense.

### Why incremental?

By *incremental*, I mean that I ported the project one module at a time, rather than all at once. This is accomplished by calling between Rust and Python as appropriate at runtime.

The amount of code in the project was still small enough that I could conceivably rewrite it all at once, but I figured it would take a long time to iron out all the bugs if I did it that way. I wanted the end result to be stable once I finished, rather than having to deal with occasional bugs after the initial porting process, so I preferred to do an incremental approach and port the project one module at a time.

## Porting

For git-branchless, [version 0.1.0](https://github.com/arxanas/git-branchless/releases/tag/v0.1.0) is the last Python-only version, and [version 0.2.0](https://github.com/arxanas/git-branchless/releases/tag/v0.2.0) is the first Rust-only version. There were 65 commits in between these versions. You can browse the commits in between to see the progress over time.

### Strategy

I used the [PyO3](https://github.com/PyO3/pyo3) library for Rust to handle the Python-Rust interop. See [this commit](https://github.com/arxanas/git-branchless/commit/3020395c96f519c2a70da521d4d20f591582d628) for the initial setup.

PyO3 supports calling Rust from Python and vice-versa:

* Call Rust from Python: a step is added to `setup.py` which compiles the Rust modules into modules available to Python.
* Call Python from Rust: a specific version of the Python interpreter is linked into the Rust executable, which can be used to execute Python code.

I ported all the lowest-level modules individually and worked my way up the dependency hierarchy until I arrived at the main function.

Since git-branchless is implemented as a short-lived script, there weren't any significant lifetime-related difficulties in the Rust version. The problematic situations were when the Python and Rust code both need to keep a reference to a shared resource, like a database connection. I worked around these resource issues by copying the resources on the Rust side (e.g. opening a new database connection to the same database), and then I undid those workarounds once the Python code was gone.

### IDE ergonomics

If you're using VS Code, do not use the [official Rust extension (`rust-lang.rust`)](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust), and instead use the [Rust Analyzer plugin (`matklad.rust-analyzer`)](https://marketplace.visualstudio.com/items?itemName=matklad.rust-analyzer). The former is unreliable and doesn't offer many features, but the latter is reliable and has a lot of nice features.

The IDE experience is refreshingly good compared to VS Code's Python offerings.  Some feature highlights (see [the manual](https://rust-analyzer.github.io/manual.html) for a full list):

* Autocomplete works reliably, including for symbols not imported into the current scope. In those cases, selecting the autocomplete item also adds a `use` statement in the appropriate scope.
* Useful refactorings are suggested routinely. See [the manual](https://rust-analyzer.github.io/manual.html#assists-code-actions) for a full list.
  * The most common ones I use are "add borrow"/"remove borrow" as appropriate, and "import this missing symbol". They're very convenient!
  * You can rename symbols, even across multiple modules. If you move or rename a module, it also automatically refactors the module name.
  * As someone who has spent time implementing refactorings for a language server, I can say that the plugin authors put care into the selection and functionality/reliability of the available refactorings.
* Inline type annotations are shown.
  * This is really useful for longer `.iter()` method chains to see the inferred types for lambda parameters and results.
  * It's not always obvious when values are borrowed or dereferenced, particularly for a beginner. For example, it's not necessarily obvious when the fields of a struct are borrowed in a `match` statement. Even if you know the types involved, seeing the borrows is still useful.
  * It's also just generally nice to look at a `let foo = bar();` binding and see what the type of `foo` is.
* It can format your documents using `rustfmt` on save. If you're not using an automatic formatter, then you're doing yourself a disservice.

### Build ergonomics

The Rust incremental build times weren't particularly fast, particularly when using macros from dependencies, as they cannot be compiled ahead of time. Nonetheless, the incremental build time was generally much less than the time it took to run the entire test suite. It was only a problem when selecting only a few tests to run.

On the other hand, the compiler diagnostics, static typing, and IDE support are good enough to write significant amounts of code before having to run a build at all. The typechecker was generally faster than Mypy for Python.

### Testing ergonomics

Rust lets you write unit tests inside the same module as the unit itself, which is particularly convenient when the unit is small enough that you don't want to expose it to callers. Of course, you can write inline tests in Python too --- this is more of an improvement versus other static languages like C++ and Java.

The dynamic nature of Python makes testing easier in general. For example, it's oftentimes useful to mock out a dependency in a test without having to declare an interface for a dependency and inject it. In similar cases in Rust, I created a `testing` sub-module of the modules in question, which exposed the internals of the module to make them more testable.

The default test runner for Rust leaves a lot to be desired compared to [Pytest](https://docs.pytest.org/en/6.2.x/). It's difficult to ascertain how many tests ran and how many passed, especially when you've attempted to filter out some of the tests. The test runner API is [available under a nightly flag](https://github.com/rust-lang/rust/issues/49359), so hopefully we will see some better test runners become available soon.

### Interop ergonomics

The ergonomics of the PyO3 library for Python/Rust interop are great. Interop is *safe* and *composable*.

*Safety*: I had no instances of segfaults due to interop. (My only segfault was a stack overflow in Rust-only code, unrelated to interop.) Type mismatches are surfaced as helpful `TypeError` exceptions in Python. This was a lot better than the OCaml interop I had to do, where not enough type information is carried at runtime to dynamically check type conversions at the interop boundaries.

PyO3 also uses Rust's ownership system to ensure that you have a handle to Python's [Global Interpreter Lock (GIL)](https://en.wikipedia.org/wiki/Global_interpreter_lock) before doing Python operations. Even if you don't have concurrency in your project, it ensures you have a handle to a correctly-initialized Python runtime before attempting to do Python operations.

*Composability*: PyO3 makes strong use of Rust's trait system and coherence rules. If the type system knows how to convert a given set of base types, then it's easy to teach it how to build an aggregate type consisting of those base types.  This allows for lightweight implicit type conversions between Python types and Rust types, without it being overly difficult to figure out how a type is converted.

These conversions are all *fallible* as well, so you can fail a type conversion when appropriate, which lets you keep boilerplate error-checking out of the calling code.

After having dealt with OCaml's overly-powerful module system, I can say that I prefer [typeclasses](https://en.wikipedia.org/wiki/Type_class) (Rust traits) for nearly all day-to-day programming. (The typeclass vs module preference is one reason people prefer Haskell over OCaml or vice-versa.)

#### PyO3's hello world

To start, let's take a look at this complete example:

```rust
use pyo3::prelude::*;

fn main() -> PyResult<()> {
    Python::with_gil(|py| {
        let os = py.import("os")?;
        let username: String = os
            .call1("getenv", ("USER",))?
            .extract()?;
        println!("Hello, {}", username);
        Ok(())
    })
}
```

To summarize:

1. You create an instance of a `Python` object using `Python::with_gil` or similar.
2. You can then access modules, etc., by calling a method like `py.import`. Error-checking is handled with the `?` operator. It will fail e.g. if the module could not be found.
3. To call a method with arguments, use the `call1` method with a tuple of arguments. The tuple has to contain values of types which implement the `IntoPy` trait, which is already implemented for Rust built-in types. (The `call` method works for calls with both positional and keyword arguments; the `call0` method works for simple calls without any arguments.) The result is checked with `?`. It will fail e.g. if the method threw an exception.
4. To convert the result into a Rust type, call `.extract()` on it. The result is checked with `?`. It will fail e.g. if the Python type could not be converted into the desired Rust type at runtime. In this case, the desired result type is indicated with the `: String` type annotation on the `let`-binding.

It would be difficult to make this simpler and still be statically-checked!

#### Real example

Consider this example of the Python wrapper for the `make_graph` function.

```rust
#[pyfunction]
fn py_make_graph(
    py: Python,
    repo: PyObject,
    merge_base_db: &PyMergeBaseDb,
    event_replayer: &PyEventReplayer,
    head_oid: Option<PyOidStr>,
    main_branch_oid: PyOid,
    branch_oids: HashSet<PyOidStr>,
    hide_commits: bool,
) -> PyResult<PyCommitGraph> {
    let py_repo = &repo;
    let PyRepo(repo) = repo.extract(py)?;
    let PyMergeBaseDb { merge_base_db } = merge_base_db;
    let PyEventReplayer { event_replayer } = event_replayer;
    let head_oid = HeadOid(head_oid.map(|PyOidStr(oid)| oid));
    let PyOid(main_branch_oid) = main_branch_oid;
    let main_branch_oid = MainBranchOid(main_branch_oid);
    let branch_oids = BranchOids(branch_oids.into_iter().map(|PyOidStr(oid)| oid).collect());
    let graph = make_graph(
        &repo,
        &merge_base_db,
        &event_replayer,
        &head_oid,
        &main_branch_oid,
        &branch_oids,
        hide_commits,
    );
    let graph = map_err_to_py_err(graph, "Could not make graph")?;
    let graph: PyResult<HashMap<PyOidStr, PyNode>> = graph
        .into_iter()
        .map(|(oid, node)| {
            let py_node = node_to_py_node(py, &py_repo, &node)?;
            Ok((PyOidStr(oid), py_node))
        })
        .collect();
    let graph = graph?;
    Ok(graph)
}
```

Going over it:

1. The function is annotated with the `#[pyfunction]` macro. This means that any parameters are automatically converted from `PyObject`s into the listed types at runtime. It also inserts the `py: Python` argument, if your function needs it. The corresponding Python function is registered to be available in a module accessible to Python, not shown here.
2. Most argument types are complex types like `PyMergeBaseDb` (which wraps the Rust type `MergeBaseDb`) or composite types like `HashSet<PyOidStr>`.
  * You can actually annotate regular Rust types to make them convertible into Python types. I chose to create separate types like `PyMergeBaseDb` so that it would be easier to delete them later, without separating out the Python-specific functionality from the Rust functionality.
  * The type `PyOidStr` is a wrapper type which converts from a Python `str` into a Rust `git2::Oid`. We can't use a `String` here, because then PyO3 would convert the Python `str` into a Rust `String`, which is not what we want. So we use a wrapper type to define a non-default type conversion behavior.
3. The `repo` argument is left as a `PyObject`, rather than a `PyRepo` object, because I call Python methods on it later. I get a `git2::Repository` object corresponding to it in the body of the function with the `.extract` function.
4. I explicitly unpack each wrapped argument in the body of the function. This isn't strictly necessary, and you can just use e.g. `repo.0` if you like, which would make the function body significantly shorter. I did this as a stylistic matter to ensure exhaustiveness-checking.
5. The Rust `make_graph` function is called with Rust types, and it returns a Rust type.
6. The result of `make_graph` is checked with `map_err_to_py_err`. I'm pretty sure this is unnecessary, and it could have been handled by `?`, but I wasn't familiar enough when I was writing this code.
7. We convert the result back into a Python type with `into_iter().map().collect()`, and then check the result with `?`.

I could have made this example even shorter by using more wrapper types (for `head_oid`, `main_branch_oid`, and `branch_oids`) and by not creating intermediate variables.

### Bugs encountered

I kept track of a selection of bugs encountered while porting from Python to Rust. Nearly all of them were caught by the regular integration tests. The hardest-to-detect ones involved specification mistranslations, such as changing the meaning of domain entities or setting a configuration flag to the wrong default.

One example of a changed domain entity is that the Python `git2` library only allows the construction of valid object IDs (OIDs), while the Rust `git2` library allows the construction of arbitrary OIDs. This means that invalid OID errors are detected at different times. I could have wrapped the Rust OID type in a wrapper type which forces me to verify that it exists, but I didn't bother, and instead relied on tests to expose bugs.

These are my raw notes. They do not accurately capture the frequency of each kind of issue.

* Returned OID instead of string from method (immediately caught by tests).
* `struct` properties not visible from Python (added `#[pyo3(get)]`).
* No `==` method for `dataclass` replacements. Worked around by some minor
  rewrites.
* Legitimate regression where we didn't treat the `0` commit hash as a
  non-existent old/new ref (partly due to `git2::Oid` not verifying that the
  OID exists).
* Forgot to implement some methods (immediately revealed by tests).
* Panic due to conversion of -1 to `usize` with `try_into().unwrap()`; fixed by
delaying conversion until bounds check.
* Legitimate regression: old version of code names were misleading, and I
simplified the ported version into an incorrect version (should have checked
the status of an event at a time in the past, but instead checked the current
status). Detected by tests.
* Double bug: name mixup for two string fields in Rust; and off-by-one error
  when translating reverse iteration in Python to Rust.
* `TypeError: argument 'main_branch_oid': 'Oid' object cannot be converted to 'PyString'` (immediately caught by tests). Legitimate type mismatch
  between Python and Rust type signatures.
* TypeError: accidentally wrote list of bytes to TextIO instead of str.
* Defaulted a configuration setting to `false` instead of `true`, causing
  test failures.
* Several bugs which reproduced only in CI builds, but not on my local machine. Generally, they were due to passing the wrong environment variables around, which caused them to load the wrong dynamically-linked Rust modules (`LD_LIBRARY_PATH`) or invoke the wrong version of Git (`PATH`).

I filed three issues against Rust libraries that I used:

* `rustfmt`: [https://github.com/rust-lang/rustfmt/issues/4624](https://github.com/rust-lang/rustfmt/issues/4624)
* `cursive`: [https://github.com/gyscos/cursive/issues/563](https://github.com/gyscos/cursive/issues/563)
* `pyo3`: [https://github.com/PyO3/pyo3/issues/1490](https://github.com/PyO3/pyo3/issues/1490)

## Results

### Porting time

I was generally able to port a given module and its tests in one or two days. However, I worked on this over a long period of time as it's not part of my day job, so it took a a few months to finish the port (from December 18, 2020 to March 15, 2021).

The Python code was already written in an ML style, with use of algebraic data types and very limited metaprogramming. If you can statically check your code with Mypy, then it will probably be relatively easy to port it to Rust. But if it uses dynamic runtime features, you should expect it to be more difficult.

### Lines of code

I used [`cloc`](https://github.com/AlDanial/cloc) to perform line counts.

| Language | Type              | Files  | Blank | Comment | Code |
|:---------|:------------------|:-------|:------|:--------|:-----|
| Python   | Source code       | 16     | 614   | 849     | 2481 |
| Python   | Test code         | 14     | 295   | 535     | 1308 |
| Python   | Total             | 30     | 909   | 1384    | 3789 |
| Rust     | Source code       | 18     | 531   | 835     | 4186 |
| Rust     | Source noise      | 18     |       |         | 644  |
| Rust     | Test code         | 9      | 217   | 11      | 1642 |
| Rust     | Test noise        | 9      |       |         | 277  |
| Rust     | Total             | 27     | 748   | 846     | 5828 |
| Rust     | Total minus noise | 27     | 748   | 846     | 4907 |

The Rust version has significantly more lines of code. A portion of that can be attributed to "line noise" (lines which only consist of whitespace and closing delimiters). I calculated the amount of line noise with this command:

```
find <dir> -name '*.rs' -exec egrep '^[ });,]+$' {} \; | wc -l
```

The rest is probably due to more verbose idioms, such as the following:

* Chained iterator functions rather than list comprehensions.
* Can't use `let seq = if cond { vec.iter() } else  { vec.iter().rev() }`; you have to use a helper function or write the code twice.
  * Ideally, you would be able to write something like `let seq: impl Iterator<Item = Foo> = { ... };`, although this probably has significant compiler difficulties.
* Generators are not yet supported in stable Rust, so I had to rewrite one case of a breadth-first search to use callbacks instead.

Despite this, I feel that Rust is nearly as expressive as Python, particularly compared to a language like C++.

### Time comparison

It's hard to compare the speedup between Python and Rust, as I didn't have any end-to-end benchmarks set up.

I took the following measurements for running the test suites serially. Unfortunately, it's not very meaningful, because the majority of the time is spent shelling out to Git to set up the test repository.

* Python: ~50 seconds.
* Rust: ~20 seconds.

The specific case of Git hooks taking too long to run was considerably improved. I initiated a rebase of a stack of 20 commits with the Python and Rust versions. The Python version got through only a couple of commits in 10 seconds or so before I cancelled it, whereas the Rust version finished rebasing all the commits in a few seconds. So the particular use-case I was optimizing for was greatly improved.

## Conclusions

In summary:

* The static typing and IDE support is better for Rust compared to Python.
* The build and testing workflow is worse for Rust compared to Python.
* The performance is greatly improved for Rust compared to Python, but I didn't measure it in a quantitative way.
* Incremental porting with PyO3 was quite reasonable for this small project.
  * It would presumably be more difficult with a larger project which has more nuanced runtime resource management.
  * For "hub-and-spoke" projects, which don't have deep dependency trees, an incremental approach is likely tractable.
