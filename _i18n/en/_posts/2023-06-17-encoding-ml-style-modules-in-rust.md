---
layout: post
title: Encoding ML-style modules in Rust
permalink: encoding-ml-style-modules-in-rust/
translations:
  pl: "/pl/kodowanie-w-rust-modułów-w-stylu-ml/"
tags:
  - programming-languages
  - rust
lobsters: https://lobste.rs/s/hcwjcs/encoding_ml_style_modules_rust
---

<div class="publication-notes">
  <table>
    <tr>
      <td>Intended audience</td>
      <td><ul>
        <li>OCaml/SML programmers learning Rust.</li>
        <li>New-wave functional programmers who haven’t used older languages like OCaml or Haskell, but who might be interested in a certain abstraction technique.</li>
        <ul><li>
        Note that “ML-style module” refers to <a href="https://en.wikipedia.org/wiki/ML_(programming_language)">the ML family of programming languages</a>, not <a href="https://en.wikipedia.org/wiki/Machine_learning">machine learning</a>.
        </li></ul>
      </ul>
      </td>
    </tr>
    <tr>
      <td>Origin</td>
      <td><ul>
        <li>OCaml and Rust experience.</li>
        <li>Type theory experience.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Mood</td>
      <td>Helpful.</td>
    </tr>
  </table>
</div>

{% include toc.md %}

## Problem statement

Problem: you want to take an existing type satisfying some trait and augment it with new functionality — including new internal state.

If you _didn’t_ want to add any internal state, there are many solutions:



* You could use [default implementations for trait methods](https://doc.rust-lang.org/book/ch10-02-traits.html#default-implementations).
* You could use [extension traits](https://rust-lang.github.io/rfcs/0445-extension-trait-conventions.html).
* You could use [`impl dyn`](https://radicle.community/t/rust-s-impl-dyn-trait-syntax/102) (<span class="note-inline"><span class="note-tag note-info">technical note:</span> uses dynamic dispatch at runtime</span>).
* You could use free (global) functions which are generic and accept any type implementing the trait.

One example of this problem would be implementing a caching layer _once_ that could then be applied to _any_ implementation of some `Backend` trait.

ML-style modules are a natural fit for this kind of problem. They’re more capable than traditional “modules”, as considered in mainstream programming languages. Both ML-style and traditional of modules support:



* Separating code into logical namespaces.
* Defining interfaces.
* Abstracting data types and hiding implementation details.

But ML-style modules can be parametrized on _types_ (similar to templates or generics in mainstream languages) or even _other modules_ (discussed in this article).

Although Rust descends from OCaml, it doesn’t inherit an ML-style module system. Instead, Rust’s trait system resembles [Haskell’s typeclasses](https://en.wikipedia.org/wiki/Type_class). However, with some additional features (associated types), we can simulate ML-style modules in Rust.

{% noteblock note-info %}
<span class="note-tag note-info">Pedagogically:</span> The canonical example for ML-style modules over typeclasses is perhaps creating a new kind of tree-set which accepts different orderings, ratther than being restricted to a single ordering per type. I think that example is rather boring to consider because it doesn't solve Real Engineering Problems, and because the typeclass solution — creating a wrapper type with the new ordering — is roughly the same amount of work for the programmer.
{% endnoteblock %}

## Caching a function

Suppose we have an expensive computation we want to cache (perhaps it queries a database or does lots of CPU-bound work). For the sake of example, we’ll use a function that calculates the length of a string:

```rust
fn str_len(s: &str) -> usize {
    println!("Called expensive function str_len");
    s.len()
}
```


### Caching an individual function

How do we write a function that acts like `str_len`, but caches the results such that we never compute the same key-value pair twice? One way is to generate a wrapper function with a mutable internal cache and calls the underlying `str_len` function when the value isn’t in the cache:

```rust
// Declare that we return an `FnMut` rather than an `Fn`
// because the returned closure may modify mutable state
// (and thus isn't safe to call in parallel -- not relevant
// in this example).
fn make_cached_str_len() -> impl (FnMut(&str) -> usize) {
    let mut cache = HashMap::new();
    // Use the `move` keyword to move the mutable `cache`
    // into the returned closure object. Unlike a variable defined
    // in the closure body itself, this cache will be shared across
    // *all* invocations of the new function.
    move |s: &str| -> usize {
        // For simplicity, we clone the `&str` as the cache key
        // rather than worry about the lifetime annotations here.
        // If we didn't do this, it's possible that our internal `cache`
        // would hold a reference to a `str` even after that `str` was freed.
        let key: String = s.to_owned();
        // Look up the entry in our cache,
        // or create a new one if none exists.
        let result: usize = *cache.entry(key).or_insert_with_key(|key| str_len(key));
        result
    }
}

fn main() {
    let mut cached_str_len = make_cached_str_len();
    let key = "foo";

    // Prints:
    // Called expensive function str_len
    // Cached str len 1/2: 3
    println!("Cached str len 1/2: {}", cached_str_len(key));

    // Cached str len 2/2: 3
    println!("Cached str len 2/2: {}", cached_str_len(key));
}
```

Of course, it’s also possible to create a `struct` which holds the internal `cache`, and to simply demand that the caller invoke the wrapped function via a `.call` method.

{% noteblock note-info %}
<span class="note-tag note-info">Technical note:</span> Rust does not currently support overloading the function call operator.
{% endnoteblock %}

### Caching functions generically

Now to abstract this by one level: what if we want to write a generic caching function that can cache the results of _any_ function, not just `str_len` specifically?

{% noteblock note-info %}
<span class="note-tag note-info">Technical note:</span> To simplify the situation, we’ll restrict ourselves to caching the results of only functions which accept exactly one parameter, as [Rust currently does not support variadic generics](https://github.com/rust-lang/rfcs/issues/376).
{% endnoteblock %}

We can accomplish this with a generic function:

```rust
// Create a function which is generic over the key and value types,
// and accepts a "base" function which takes a key and returns a value.
//
// In order to store the key in the cache, we had to add the additional
// bounds `Eq + Hash` to `K`. To simplify the lifetimes, we added
// the lifetime bound `'static` to `K` and the bound `Clone` to `V`
// (and cloned the value before returning it).
fn cache_f<K: Eq + Hash + 'static, V: Clone>(f: impl Fn(&K) -> V) -> impl (FnMut(K) -> V) {
    let mut cache = HashMap::new();
    move |key: K| -> V {
        let result: &V = cache.entry(key).or_insert_with_key(|key| f(key));
        result.clone()
    }
}
```


Then we adjust the parameter we pass slightly for the types to work in this example:

```rust
fn main() {
    // To make some types work, add an additional `&`
    // to the parameter type.
    let mut cached_str_len = cache_f(|s: &&str| str_len(s));
    let key = "foo";

    // Prints:
    // Called expensive function str_len
    // Cached str len 1/2: 3
    println!("Cached str len 1/2: {}", cached_str_len(key));

    // Cached str len 2/2: 3
    println!("Cached str len 2/2: {}", cached_str_len(key));
}
```

### Treating the function as a value

Of course, since we went to all the trouble of making this cache, we probably want to pass it around and use it. Ideally, we would be able to write it like this:


```rust
// `impl T` does not compile (yet).
type CachedF<K: Eq + Hash + 'static, V: Clone> = impl FnMut(K) -> V;
type CachedStrLenF = CachedF<&'static str, usize>;

fn accepts_cached_str_len(cached_str_len: CachedStrLenF) {
    let key = "foo";
    println!("Cached str len 1/2: {}", cached_str_len(key));
    println!("Cached str len 2/2: {}", cached_str_len(key));
}

fn main() {
    let mut cached_str_len = cache_f(|s: &&str| str_len(s));
    accepts_cached_str_len(cached_str_len);
}
```

But it unfortunately produces this error:

```
error[E0658]: `impl Trait` in type aliases is unstable
  --> src/bin/main3-pass-function.rs:24:50
   |
24 | type CachedF<K: Eq + Hash + 'static, V: Clone> = impl FnMut(K) -> V;
   |                                                  ^^^^^^^^^^^^^^^^^^
   |
   = note: see issue #63063 <https://github.com/rust-lang/rust/issues/63063> for more information

error: non-defining opaque type use in defining scope
  --> src/bin/main3-pass-function.rs:35:5
   |
35 |     accepts_cached_str_len(cached_str_len);
   |     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   |
note: used non-generic type `&'static str` for generic parameter
  --> src/bin/main3-pass-function.rs:24:14
   |
24 | type CachedF<K: Eq + Hash + 'static, V: Clone> = impl FnMut(K) -> V;
   |              ^
```

We can’t use `impl Fn` in a type alias, so we have to actually write it out:

```rust
fn accepts_cached_str_len(mut cached_str_len: impl FnMut(&'static str) -> usize) {
    let key = "foo";
    println!("Cached str len 1/2: {}", cached_str_len(key));
    println!("Cached str len 2/2: {}", cached_str_len(key));
}

fn main() {
    let cached_str_len = cache_f(|s: &&str| str_len(s));
    accepts_cached_str_len(cached_str_len);
}
```

That is, _every use of our function type has to also include the generic type parameters._ This “infectious” behavior quickly becomes unwieldy in practice for programs of even moderate size.


## Encoding modules


### Modules in OCaml

ML-style modules can “hide” the generic types in a way that generic functions alone can’t accomplish (<span class="note-inline"><span class="note-tag note-info">technical note:</span> using a form of [existential types](https://en.wikipedia.org/wiki/Type_system#Existential_types)</span>). To express a similar example using ML-style modules, you can skim over — and probably not understand — the following OCaml code:

```ocaml
module type Backend = sig
    type t
    type key
    type value
    val compute : t -> key -> value
end

module StrLenBackend = struct
    type t = unit
    type key = string
    type value = int
  let make () = ()
    let compute () key =
    Printf.printf "Computing length of string %s\n" key;
    String.length key
end

module CachedBackend(B: Backend) : sig
    type t
    type key = B.key
    type value = B.value
  val make : B.t -> t
    val compute_cached : t -> key -> value
end = struct
  type key = B.key
  type value = B.value
    type t = {
        backend: B.t;
        cache: (key, value) Hashtbl.t;
    }
  let make backend = {
    backend;
    cache = Hashtbl.create 0;
  }
    let compute_cached t key = match Hashtbl.find_opt t.cache key with
    | Some value -> value
    | None ->
      let value = B.compute t.backend key in
      let () = Hashtbl.add t.cache key value in
      value
end
```

The point is ultimately that you can write a function like `accepts_cached_str_len` using a non-generic type like `CachedStrLenBackend.t`:

```ocaml
let accepts_cached_str_len (cached_str_len : CachedStrLenBackend.t) =
  let key = "foo" in
  Printf.printf "Cached len 1/2: %d\n" (CachedStrLenBackend.compute_cached cached_str_len key);
  Printf.printf "Cached len 2/2: %d\n" (CachedStrLenBackend.compute_cached cached_str_len key);
  ()
  
let () =
    let backend = StrLenBackend.make () in
  let cached_str_len: CachedStrLenBackend.t = CachedStrLenBackend.make backend in
  accepts_cached_str_len cached_str_len;
 ()
```

### Associated types

To accomplish something similar to ML-style modules, we can use [Rust’s associated types](https://doc.rust-lang.org/rust-by-example/generics/assoc_items/types.html). The first thing we’ll do is convert our function types into traits (<span class="note-inline"><span class="note-tag note-info">technical note:</span> ultimately, a form of [defunctionalization](https://en.wikipedia.org/wiki/Defunctionalization)</span>).

```rust
trait Backend {
    // We declare "associated types" for this trait. For any type 
    // which implements `Backend`, it must declare corresponding `Key`
    // and `Value` types, and include an implementation of `compute`
    // adhering to those types.
    type Key;
    type Value;
    fn compute(&self, key: &Self::Key) -> Self::Value;
}
```

And now we’ll create our `str_len` function as a new type and an implementation of the `Backend` trait:


```rust
// This type doesn't need state, but you could imagine
// embedding e.g. a database connection in this struct.
//
// Normally, types without any data aren't very useful, but
// this is one of the key ideas of the "encoding of ML-style
// modules". Instead of state (or in addition to state), the
// type instead has associated types and functions,
// declared below.
//
// This type corresponds to the "closed-over" variables
// of a closure object.
struct StrLenBackend;

impl Backend for StrLenBackend {
    type Key = &'static str;
    type Value = usize;
    fn compute(&self, key: &Self::Key) -> Self::Value {
        println!("Computing length of key {key:?}");
        key.len()
    }
}
```

Now, how do we define a generic version of a “cached” backend which works for _any_ kind of `Backend`? A simple generic function like `compute_cached<B: Backend>` doesn’t work, since we want it to store state. Instead, we declare _another_ type which is parametrized on a `Backend` type:

```rust
struct CachedBackend<B: Backend> {
    backend: B,
    cache: HashMap<B::Key, B::Value>,
}

impl<B: Backend> CachedBackend<B>
where
    // We require that the wrapped backend adheres to these bounds
    // in order to call any of the functions in this `impl`
    // (including `new`, which is how you would get a new value
    // of this type).
    //
    // Previously, we had to add the appropriate bounds to 
    // each generic type in each place that it appeared.
    // Using a `trait`, we can instead declare the bounds
    // just once on the `impl`.
    B::Key: Eq + Hash,
{
    fn new(backend: B) -> Self {
        Self {
            backend,
            cache: Default::default(),
        }
    }

    fn compute_cached(&mut self, key: B::Key) -> &B::Value {
        self.cache
            .entry(key)
            .or_insert_with_key(|key| self.backend.compute(key.clone()))
    }
}
```

Then we construct values of the types and pass them around. Unlike before, we can even create a type alias for the cached function type — without having to re-specify generic type parameters everywhere.


```rust
type CachedStrLenBackend = CachedBackend<StrLenBackend>;

fn accepts_cached_str_len(mut cached_str_len: CachedStrLenBackend) {
    let key = "foo";

    // Prints:
    // Computing length of key "foo"
    // Cached len 1/2: 3
    println!("Cached len 1/2: {}", cached_str_len.compute_cached(key));

    // Cached len 2/2: 3
    println!("Cached len 2/2: {}", cached_str_len.compute_cached(key));
}

fn main() {
    let backend = StrLenBackend;
    let cached_str_len = CachedBackend::new(backend);
    accepts_cached_str_len(cached_str_len);
}
```


### Parametrizing over types only

Passing around values that embody modules is actually the most powerful form of this technique, corresponding to _first-class modules_, but this is probably the most natural form to express in Rust, because most programmers deal with values rather than types. Ideally, we would hope that the optimizer would remove the overhead of passing around a value which has no associated data.

One rarely needs to do this, but it’s possible to dispatch on the type only, and forbid even constructing a value. This is also pedagogically interesting as an example of type-directed code generation in Rust. To rewrite the above example without instantiating the `Backend`, we remove the `&self` parameter everywhere:

```rust
trait Backend {
    type Key;
    type Value;

    // We no longer take a value of type `&self`.
    fn compute(key: &Self::Key) -> Self::Value;
}

// In Rust, it's not possible to make a value of the type
// of an empty enum.
enum StrLenBackend {}

impl Backend for StrLenBackend {
    type Key = &'static str;
    type Value = usize;
    fn compute(key: &Self::Key) -> Self::Value {
        println!("Computing length of key {key:?}");
        key.len()
    }
}
```


Then adjust our `CachedBackend` to use `B` directly, instead of calling methods on a value of type `B`, such as calling `B::compute`:

```rust
// Note that we no longer have a member of type `B`.
struct CachedBackend<B: Backend> {
    cache: HashMap<B::Key, B::Value>,
}

impl<B: Backend> CachedBackend<B>
where
    B::Key: Eq + Hash,
{
    fn new() -> Self {
        Self {
            cache: Default::default(),
        }
    }

    fn compute_cached(&mut self, key: B::Key) -> &B::Value {
        self.cache
            .entry(key)
            .or_insert_with_key(|key| B::compute(key.clone()))
    }
}

type CachedStrLenBackend = CachedBackend<StrLenBackend>;

fn accepts_cached_str_len(mut cached_str_len: CachedStrLenBackend) {
    let key = "foo";

    // Prints:
    // Computing length of key "foo"
    // Cached len 1/2: 3
    println!("Cached len 1/2: {}", cached_str_len.compute_cached(key));

    // Cached len 2/2: 3
    println!("Cached len 2/2: {}", cached_str_len.compute_cached(key));
}

fn main() {
    // This weird syntax is equivalent to `CachedBackend<StrLenBackend>::new()`
    // in some other languages. It's written with an extra `::` due to
    // technical restrictions on the syntax.
    //
    // Note that, unlike before, we never pass a *value* into
    // the `CachedBackend`, only a type.
    let cached_str_len = CachedBackend::<StrLenBackend>::new();

    // We could also write the type annotation on the left side and let
    // type inference figure it out:
    let _also_works: CachedBackend<StrLenBackend> = CachedBackend::new();

    // Or we could use our previously-defined type alias:
    let _also_works = CachedStrLenBackend::new();

    accepts_cached_str_len(cached_str_len);
}
```

### Other encodings

ML-style modules include other features than the above. Here's a brief discussion of encoding those features:



* `include`:
    * You can use the previously-mentioned approaches, such as extension traits.
    * Or you can use macros — I have seen this done in production systems. (There are well-documented problems with macros that I will not discuss here.)
* Updating modules, i.e. creating a new definition of an existing module with one associated type redefined.
    * Other than macros, I haven't seen an encoding for this.
* [Structural typing](https://en.wikipedia.org/wiki/Structural_type_system):
    * Rust simply does not like allowing module-like objects to be structurally typed. You can try to convert your implicit structural types into an explicit trait hierarchy.
    * Or you can use macros.
* Applicative vs generative functors
    * See [https://stackoverflow.com/questions/52161048/applicative-vs-generative-functors](https://stackoverflow.com/q/52161048/344643)
    * It depends on the concrete encoding of the module. Type abstractions are manually introduced with associated types and always unequal, while types passed via generic type parameter can be considered equal. So if you want a generative functor, you can directly introduce a new abstract type via another layer of `trait` with an associated type.

See also [The AST typing problem](http://blog.ezyang.com/2013/05/the-ast-typing-problem/) for related questions on the practical encoding of modules.

{% include end_matter.md %}
