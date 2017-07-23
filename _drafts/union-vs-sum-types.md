---
layout: post
title: Null-tracking, or the difference between union and sum types
permalink: union-vs-sum-types/
tags:
  - programming-languages
typeset_math: true
---

 * toc
{:toc}

Functional programming features have been making their way into mainstream
languages lately, such as with new programming languages like Scala and Rust, or
new type systems for existing languages like TypeScript or Flow.

One popular feature is null-tracking: the compiler statically ensures that null
values are handled explicitly, instead of allowing failure at runtime with the
equivalent of a null-pointer exception. This can make it easier to reason about
the correctness of code.

Null-tracking is typically implemented in one of two ways:

  * with a **union type**, requiring *type refinement* to extract the non-null
    value;
  * or with a **sum type**, requiring *pattern matching* to extract the
    non-null value.

Union types and sum types are different beasts! But for some reason, there
doesn't seem to be any treatment of the subject available with a quick Google
search.

In this article, I explain the difference between union and sum types and how
they differ in practice. I discuss both of these approaches for null-tracking,
but also cover how they differ for other purposes.

## Union types

### In TypeScript

TypeScript is a new statically-typed language by Microsoft that compiles down to
Javascript. It uses union types for null-tracking.

The syntax is mostly a superset of Javascript's, but you can also annotate your
variables with types:

```ts
function greet(name: string): string {
  return "Hello, " + name + "!";
}
```

We can denote a union type using `|`. A type of `A | B` means "any value which
is either an A or a B (or both)". We can express a nullable type by writing
`null | A` for any type `A`:

```ts
function filterString(str: string): null | string {
  if (str === "filtered") {
    return null;
  } else {
    return str;
  }
}
```

Then the following code is rejected by the typechecker because of the
possibility that `name` is null:

```ts
const name: string = readNameFromUser();
greet(filterString(name));
// error: `filterString` returns a `null | string`,
//        but `greet` takes a `string`.
```

We could fix this by rewriting `greet` to take a nullable string and handle it
explicitly:

```ts
function greet(name: null | string): string {
  if (name === null) {
    // The type of `name` has been refined to `null` in this branch.
    return "Hello, no-name!";
  } else {
    // The type of `name` has been refined to `string` in this branch.
    return "Hello, " + name + "!";
  }
}
```

When seeing a special construct like `=== null` in an if-condition, the
typechecker knows to *refine* the type of `name` within the branch. Within that
branch, the type of `name` is known to be a more specific subset of its type
outside that branch.

### Theory

Let's think of a type as a set of values. For example, the integer type could be
defined as the infinite set

{% katex display %}
\text{int} = \left\{\cdots, -2, -1, 0, 1, 2, \cdots\right\}
{% endkatex %}

A *union type* between two types {% katex %}A{% endkatex %} and {% katex %}B{%
endkatex %} is simply the union of the two sets, denoted as {% katex %}A \cup
B{% endkatex %} So

{% katex display %}
\text{bool} \cup \text{int} = \left\{\text{true}, \text{false}, \cdots, -2,
-1, 0, 1, 2, \cdots \right\}
{% endkatex %}

The null type is the set containing one value, the null value. For clarity,
we'll denote the null value as {% katex %}\emptyset{% endkatex %}, and the null
type as {% katex %}\text{null}{% endkatex %}:

{% katex display %}
\text{null} = \left\{\emptyset\right\}
{% endkatex %}

So the type of `null | int` is

{% katex display %}
\text{null} \cup \text{int} = \left\{\emptyset, \cdots, -2, -1, 0, 1, 2,
\cdots\right\}
{% endkatex %}

## Sum types

### In OCaml

OCaml is a mature functional programming language that uses the [Hindley-Milner
type system][hm type system]. In OCaml, null-checking uses sum types.

  [hm type system]: https://en.wikipedia.org/wiki/Hindley%E2%80%93Milner_type_system

ML-family languages represent the absence of a value using an [algebraic data
type]. The following sum type is built into OCaml:

  [algebraic data type]: https://en.wikipedia.org/wiki/Algebraic_data_type

```ocaml
type 'a option =
  | Some of 'a
  | None
```

The `option` type takes a generic type parameter `'a`, and can take on either
the value `Some` containing that value, or `None`, containing no value.

Note that although both union types and sum types are denoted with `|` in their
respective languages, these do not represent the same thing. This can be a
source of confusion for someone acquainted with languages in both families.

We can use this algebraic data type to force the programmer to check for null
when unpacking an `option`. For example:

```ocaml
let filter_string (str : string) : string option =
  if str = "filtered"
  then None
  else Some str

let greet (name : string option) : unit =
  (* It wouldn't compile to just write

     Printf.printf "Hello, %s!" name

     here, because `printf` is expecting a `string` but will have received a
     `string option`. *)
  match name with
  | None -> Printf.printf "Hello, no-name!"
  | Some name_ ->
    (* We've pattern-matched a `string` called `name_` out of the
       `string option` called `name`. Note that we could also call this
       variable `name` and shadow the outer `name`, but I don't here for
       clarity. *)
    Printf.printf "Hello, %s!" name_
```

Instead of type refinement, where the compiler recognizes a special syntactic
pattern in order to do type inference, the language uses pattern-matching to
extract a value with the appropriate type out of an algebraic data type.

### Theory

A sum type is like a union type, but every type in the sum type is accompanied
by a *label*, which is a unique identifier for this element of the sum type.  If
we have types {% katex %}A{% endkatex %} and {% katex %}B{% endkatex %}, and
labels {% katex %}l_A{% endkatex %} and {% katex %}l_B{% endkatex %}, then we
can define the sum type {% katex %}A + B{% endkatex %} as

{% katex display %}
A + B = \left(\left\{l_A\right\} \times A\right)
  \cup \left(\left\{l_B\right\} \times B\right)
{% endkatex %}

where {% katex %}\times{% endkatex %} denotes [Cartesian product].

This overall operation is called [disjoint union]. Basically, it can be
summarized as "a union, but each element remembers what set it came from".

  [cartesian product]: https://en.wikipedia.org/wiki/Cartesian_product
  [disjoint union]: https://en.wikipedia.org/wiki/Disjoint_union

As a concrete example, consider this data type:

```ocaml
type identifier =
  | Name of string
  | IdNumber of int
```

This represents an identifier which is either a name or an ID number. Here are
the corresponding variables:

{% katex display %}
\begin{aligned}
A &= \text{string} \\
B &= \text{int} \\
l_A &= \text{"name"} \\
l_B &= \text{"id number"}
\end{aligned}
{% endkatex %}

Then the sum type {% katex %}A + B{% endkatex %} using these labels is the
the set of all values depicted below:

{% katex display %}
\begin{aligned}
(\text{"name"},& &\text{""}) \\
(\text{"name"},& &\text{"a"}) \\
(\text{"name"},& &\text{"aa"}) \\
(\text{"name"},& &\text{"ab"}) \\
& \vdots &
\end{aligned}\quad\cup\quad\begin{aligned}
(\text{"id number"},& & 0) \\
(\text{"id number"},& & 1) \\
(\text{"id number"},& & 2) \\
(\text{"id number"},& & 3) \\
& \vdots &
\end{aligned}
{% endkatex %}

In the `option` type, the labels are `Some` and `None`. Note that labels must be
unique across all sum types (or at least they must reside in different
namespaces). That is, this wouldn't compile in OCaml:

```ocaml
type foo =
  | Foo

type foo_or_bar =
  | Foo
  | Bar
```

## Variant types

Sometimes you may hear about "variant types". Please don't call either sum or
union types "variant types". This terminology is confusing and can mean either
union or sum types, depending on the language and environment. For example, in
C++, [`std::variant`][stdvariant] describes a union type, but in OCaml, "variant
types" are sum types.

  [stdvariant]: http://en.cppreference.com/w/cpp/utility/variant

## Differences

### Singleton null versus a null for every type

In the union type scheme, there is one null value that is shared across every
type. This can have some practical disadvantages. For example, let's say that
you have a map that, when looking up a value, returns `null` if the key is not
found. Then there may be some ambiguity in a case like this:

```ts
const key: string = getKey();
const map: Map<string, null | int> = getMap();

// Returns `null | null | string`, which is the same as `null | string`.
const value: null | int = map.get(key);

if (value === null) {
  // Was this value not found, or was the value actually "null"?
}
```

This can be circumvented by having an additional null-like sentinel values, like
`undefined` in Javascript, but it can get confusing to remember the exact
semantics of them all, and still doesn't let you store `undefined` in an
unambiguous way.

Sum types wrap their values in such a way that there is no ambiguity. For
example:

```ocaml
let key : string = get_key () in
let map : string (int option) map = get_map () in

(* Note the double `option` -- the map wraps the result in another option. *)
let value : int option option = Map.get key map in
match value with
| None -> Printf.printf "Map did not contain key"
| Some x ->
  match x with
  | Some x -> Printf.printf "Map had value %d" x
  | None -> Printf.printf "Map had None"
```

### Distinguishing identical types via labels

With a union type between {% katex %}A{% endkatex %} and {% katex %}B{% endkatex
%}, if {% katex %}A{% endkatex %} and {% katex %}B{% endkatex %} are the same,
there is no way to distinguish between elements from {% katex %}A{% endkatex %}
versus elements from {% katex %}B{% endkatex %}.

For example, we can express this in OCaml:

```ocaml
type file =
  | Filename of string
  | FileContents of string
```

This gives us some type-safety because then we can never mix the two up:

```ocaml
let print_file_contents file =
  let contents =
    match file with
    | Filename filename -> read_file_from_disk filename
    | FileContents file_contents -> file_contents
  in
  Printf.printf "File contents: %s" contents
```

However, sum types can be implemented in terms of union types, as described
later.

### Ad-hoc polymorphism

Union types can be used to implement a form of function overloading:

```ts
function printAnything(value: int | string | bool): void {
  if (typeof value === "int") {
    console.log("The int was ", value);
  } else if (typeof value === "string") {
    console.log("The string was ", value);
  } else {
    console.log("The bool was ", value);
  }
}
```

OCaml does not support [ad-hoc polymorphism] like this. Indeed, one of the warts
of the language that it needs two different operators `+` and `+.` for addition
between integers and floats, respectively.

  [ad-hoc polymorphism]: https://en.wikipedia.org/wiki/Ad-hoc_polymorphism

### Mixing labels of different types

In a sum type, the labels of different sum types are not interchangeable. You
cannot write this in OCaml:

```ocaml
type foo =
  | Foo of string

type bar =
  | Bar of int

let takes_a_foo_or_bar foo_or_bar =
  match foo_or_bar with
  | Foo foo -> Printf.printf "Got string %s" foo
  | Bar bar -> Printf.printf "Got int %d" bar
```

This can be worked around with so-called [polymorphic variants] in OCaml, but
they are not a general staple of ML-family languages. (SML doesn't have them.)

  [polymorphic variants]: https://realworldocaml.org/v1/en/html/variants.html#polymorphic-variants

### Adding fields to an existing record type

Union types are usually accompanied by intersection types. We can use an
intersection type to add fields to an existing record type:

```ts
type User = { name: string } | { id: number }

// Same as the `User` type, but every record also has an `email` field.
type UserWithEmail = User & { email: string }
```

This is especially useful for processing data in stages and attaching additional
fields to records as we determine their values. For example, in a compiler, we
might start with a container of all the variables in the programs, and then
attach the type to each variable as we determine it.

With sum types (even polymorphic variants, as in OCaml), we can't add new fields
to existing record types. We can only create new sum types with the added
fields, and convert between the two. This is more difficult to work with in some
situations, since one has to implement boilerplate code to convert from one to
the other.

## Implementing sum types in terms of union types

The definition of sum type involves a union. So if we can add a label to our
union types, we can emulate a sum type. The general technique is as follows:

```ts
interface Filename {
  label: "filename";
  filename: string;
}

interface FileContents {
  label: "file_contents";
  contents: string;
}

type File = Filename | FileContents

function printFileContents(file: File): void {
  switch (file.label) {
    case "filename":
      console.log("File contents: ", readFileFromDisk(file.filename));
      break;
    case "file_contents":
      console.log("File contents: ", file.contents);
      break;
    default:
      // We need this to enforce an exhaustiveness check by the compiler, so
      // that we don't forget a case.
      const _exhaustiveCheck: never = file;
  }
}
```

On the other hand, we can't implement union types in terms of sum types.
Therefore union types are strictly more flexible than sum types, but the
ergonomics of each approach depends on the use-case.
