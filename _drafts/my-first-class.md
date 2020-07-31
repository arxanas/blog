---
layout: post
title: "I wrote my first OCaml class at work today"
permalink: my-first-ocaml-class/
tags:
  - programming-languages
  - software-engineering
---

Today, after almost four years of professional software development in [OCaml], I wrote
my first [class] at work.

  [OCaml]: https://en.wikipedia.org/wiki/OCaml
  [class]: https://en.wikipedia.org/wiki/Class_(computer_programming)

That's a bit of a fabrication. I once had to implement a couple of methods for a class somebody else had written (using the [visitor pattern][visitors]). But it was my first time writing my own substantial, non-derived class.

  [visitors]: https://en.wikipedia.org/wiki/Visitor_pattern

It turns out classes... just aren't that useful in many kinds of programming. They're basically

## Why did I have to use an object?

* associated types
* friend methods

## What are objects good for?

The book [Real-World OCaml][ocaml-objects] has this to say on the matter:

  [ocaml-objects]: https://dev.realworldocaml.org/objects.html

> There are five fundamental properties that differentiate OOP from other styles:
>
> Abstraction
> * The details of the implementation are hidden in the object, and the external interface is just the set of publicly accessible methods.
>
> Dynamic lookup
>
> * When a message is sent to an object, the method to be executed is determined by the implementation of the object, not by some static property of the program. In other words, different objects may react to the same message in different ways.
>
> Subtyping
> * If an object a has all the functionality of an object b, then we may use a in any context where b is expected.
>
> Inheritance
> * The definition of one kind of object can be reused to produce a new kind of object. This new definition can override some behavior, but also share code with its parent.
>
> Open recursion
> * An object’s methods can invoke another method in the same object using a special variable (often called self or this). When objects are created from classes, these calls use dynamic lookup, allowing a method defined in one class to invoke methods defined in another class that inherits from the first.

The first three points are what object-oriented programmers primarily rely on. They basically constitute the ability to separate an implementation from its interface. In many cases, we'll

Some good cases:

  * default implementations
  * inherit implementations (but prefer composition over inheritance!)
  * template-like patterns
  * mutual recursion

## What if we didn't have objects?
