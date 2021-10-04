---
layout: post
title: How to parse contextual keywords in a programming language
permalink: parsing-contextual-keywords/
tags:
  - programming-languages
---

* toc
{:toc}

*Thanks to Lucian Wischik for reviewing this article.*

## What's the problem with contextual keywords?

Ordinarily in a programming language, a keyword isn't usable as an identifier.
For example, you often can't name a variable `int`, because `int` is the keyword
used to denote the integral numeric type.

Sometimes, you want to add a new keyword to a language, but can't break backward
compatibility. For example, when C# added async/await, they needed to retain
`async` as an identifier, so that old programs that used variables or classes
named `async` would still compile.

For example, you may have written code that used `async` as an identifier in a
program written for a previous version of C#:

```cs
bool async = true;
```

But you should now also be able to write code using `async` with its special
meaning as a keyword:

```cs
async Task<void> foo()
{
  // ...
}
```

That is to say, the token `async` should be treated as an identifier under some
circumstances, and as a keyword under others. A keyword with this property is
called a "contextual keyword" in C#. Other languages have identical concepts,
such as `override` and `final` in C++.

Lexing is typically strictly separated from parsing. Then the question is: when
should we lex the string "async" appearing in the source code as an identifier,
and when should we lex it as the `async` token? We need information about the
surrounding tokens to decide that, but we don't have that until the parsing
phase, which runs later.

### Parsing can be difficult when there is ambiguity

Sometimes, a keyword has no ambiguity during parsing. If the `async` keyword
can never be used in a place where a valid identifier could appear, and vice
versa, then the problem can be solved in a straightforward manner, discussed
shortly.

Unfortunately, this isn't the case in many languages with async/await. For
example, consider the following code snippet of C#:

```cs
async(foo, bar)
```

Depending on the following token, this could be either a function call or a
lambda declaration. If an operator follows in such away that this appears to be
expression, then we have a function call:

```cs
async(foo, bar) + 3 // calling the function named `async`
```

But if a double-arrow follows, then it must be a lambda:

```cs
async(foo, bar) => foo + bar // declaring an async lambda
```

You would have to look ahead an arbitrary number of tokens (from the `async`
keyword to the next operator) in order to disambiguate these two cases, so
oftentimes implementing a contextual keyword can't be solved with a small
change to the grammar.

## Approachs

I asked some coworkers who have worked on languages how this is implemented,
and detailed how various languages (mainly C#) implement contextual keywords,
with examples.

### Parsing `partial` directly in the grammar

C# has the `partial` keyword which is used to mark a class as being implemented
in multiple source files. The grammar is such that the `partial` keyword only
appears before the `class` keyword in a class definition. For example:

```cs
partial class Foo {
  void DoSomething() {
    int partial = 3;
    // ...
  }
}
```

The `partial` keyword can be parsed unambiguously, because an identifier can't
appear as a modifier when declaring a class, and the `partial` token can't
appear anywhere the grammar expects an identifier.

The idea is allow the `partial` token to be a valid value for an identifier.
This is especially useful for generated parsers, since it requires only a
grammar change, and doesn't fundamentally change lexing or parsing.

It can be done by amending your grammar as follows:

```ebnf
partial ::= "partial"
ident_ ::= [a-zA-Z]+
ident ::=
  | ident_
  | partial
  | /* any other contextual keywords... */
```

This allows you to write `partial` anywhere you need an identifier, but also
have access to the partial keyword. When extracting the actual identifier name
from the identifier node in the parse tree, you just need to handle the case of
the identifier being the `partial` token, and return the literal string
"partial" in that case.

### Having special syntax for a verbatim identifier

C# supports prefixing any identifier with the `@` symbol to use any name as an
identifier, regardless of conflicts with keywords. For example, you could write
`@for` to refer to an identifier named "for".

The `@` symbol used in this way is unambiguous in the C# grammar, so it's
easily implemented. However, it doesn't actually solve the
backward-compatibility problem, since any new keywords you minted will still be
parsed incorrectly in older programs.

Verbatim identifiers are useful mostly in a case such as interoperating with
another language where the identifier in question is not a keyword. Depending
on your needs, this may be sufficient, and will obviate reworking the grammar
of your language.

### Parsing `async` syntactically using arbitrary lookahead

C# and [Flow], probably among others, use a purely-syntactic approach to
disambiguate the `async` token from an identifier named "async". The idea is to
scan ahead in the token stream until you see a token that disambiguates whether
it's a keyword or an identifier. The exact implementation will depend on the
details of the grammar in question, but you can find the [current
implementation of parsing `async` in C# here][cs-parsing-async].

  [flow]: https://flow.org/
  [cs-parsing-async]: https://github.com/dotnet/roslyn/blob/614299ff83da9959fa07131c6d0ffbc58873b6ae/src/Compilers/CSharp/Portable/Parser/LanguageParser.cs#L1371-L1440

### Parsing `var` using semantic information

C# uses the `var` keyword in the place of an actual type name to tell the
compiler to infer the type of the given variable. That is, you can type

```cs
var foo = MakeAnInt();
```

and the compiler will determine from the return type of `MakeAnInt` that the
variable `foo` should be of type `int`.

Fundamentally, this can't be resolved in a purely syntactic way. By definition,
`var` is allowed to appear in a strict subset of places where an identifier
(referring to a type name) could appear.

C# solves this problem by [looking up the `var` symbol in the semantic
analyzer][var-semantics], and only treating it as the `var` keyword if there is
no type named `var` in the current scope.

  [var-semantics]: https://ericlippert.com/2009/05/11/reserved-and-contextual-keywords/

### Parsing `async` syntactically using constant lookahead

[The Hack language][hack-language] added `async` with the same
backward-compatibility issues present in other languages that also added it. In
particular, the lambda syntax is hard to parse in the same way that it's hard
to parse in C# and Javascript.  For example, the following is hard to parse:

  [hack-language]: http://hacklang.org/

```php
async ($foo, $bar)
```

It could be a function call:

```php
async ($foo, $bar) + 3
```

Or it could be lambda syntax:

```php
async ($foo, $bar) ==> $foo + $bar
```

Hack "solves" this problem while only needing constant lookahead. If there is a
space after `async`, it is parsed as the `async` keyword. Otherwise it is
parsed as an identifier. Thus, the above example is unambiguous: it is parsed
as a lambda.

This has serious consequences, because a developer has to be aware of this
implementation detail, or otherwise incorrectly add spaces to their code and
get inscrutable parse errors.

But hey --- "if it compiles, it works", right?

{% include end_matter.md %}
