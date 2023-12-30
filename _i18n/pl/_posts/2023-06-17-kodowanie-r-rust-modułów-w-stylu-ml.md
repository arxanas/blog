---
layout: post
title: Kodowanie w Rust modułów w stylu ML
permalink: kodowanie-w-rust-modułów-w-stylu-ml/
translations:
  en: "/encoding-ml-style-modules-in-rust/"
tags:
  - rust
---

<div class="publication-notes">
  <table>
    <tr>
      <td>Docelowi odbiorcy</td>
      <td><ul>
        <li>Programiści OCaml/SML uczący się języka Rust.</li>
        <li>Programiści funkcjonalni, którzy wcześniej nie mieli styczności z języków takimi jak OCaml czy Haskell, ale mogą być zainteresowani pewną techniką abstrakcji.</li>
        <ul><li>
        Należy zauważyć, że termin “moduł w stylu ML” odnosi się do <a href="https://en.wikipedia.org/wiki/ML_(programming_language)">rodziny języków programowania ML</a>, a nie do <a href="https://pl.wikipedia.org/wiki/Uczenie_maszynowe">uczenia maszynowego</a>.
        </li></ul>
      </ul>
      </td>
    </tr>
    <tr>
      <td>Pochodzenie</td>
      <td><ul>
        <li>Doświadczenie w OCaml i Rust.</li>
        <li>Doświadczenie w teorii typów.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Nastrój</td>
      <td>Pomocny</td>
    </tr>
    {% include translation_notice.html %}
  </table>
</div>

* toc
{:toc}


## Stwierdzenie problemu

Problem: chcesz dodać do istniejącego typu implementującego pewnego trait nową działalność, która będzie wymagała używania wewnętrznego stanu.

Problem: chcesz wziąć istniejący typ spełniający jakąś cechę i rozszerzyć go o nową funkcjonalność — w tym nowy stan wewnętrzny.

Jeśli nie chcesz dodać wewnętrznego stanu, istnieje kilka możliwych rozwiązań:



* Używać domyślnych implementacji metod trait.
* Używać "extension traits".
* Używać `impl dyn` _(uwaga techniczna: będzie to wymagać dynamicznego wywoływania na czasie wykonywania)_.
* Używać wolnych (globalnych) funkcji, które są generyczne i akceptują dowolny typ implementujący trait.

Na przykład: implementowanie warstwa cachowania [ang. "caching"] tylko _raz_, które mogło wtedy zastosować się do _dowolnej_ implementacji jakiegoś trait `Backend`.

Moduły w stylu ML są naturalnym rozwiązaniem dla tego rodzaju problemów. Bardziej wydajne są one niż tradycyjne "moduły", jak uważa się w popularnych językach programowania. Zarówno moduły w stylu ML, jak i tradycyjne moduły obsługują:



* Rozdzielanie kodu na logiczne przestrzenie nazw [ang. "namespaces"].
* Definiowanie interfejsów.
* Abstrahowanie typów danych i ukrywanie szczegółów implementacji.

Ponadto moduły w stylu ML mogą być parametryzowane na _typach_ (podobnie szablonom [ang. "templates"] lub typom generycznym w innych językach programowania), a także _innych modułach _(omówione w tym artykule).

Pomimo, że Rust pochodzi z OCaml, nie dziedziczy systemu modułów w stylu ML. Zamiast, system "trait" w Rust przypomina [typeclasses z Haskell](https://en.wikipedia.org/wiki/Type_class). Jednak, korzystający dodatkowych funkcji, możemy symulować w Rust moduły w stylu ML.

_(Uwaga pedagogiczna: przykładem kanonicznym modułów w stylu ML nad typeclasses chyba jest utworzenie nowego typu "tree-set", który akceptuje inne kolejności, a nie ogranicza się do jednej kolejności na typ. Sądzę, że ten przykład się nudzi, bo nie rozwiązuje Prawdziwych Problemów Inżynierii, i bo rozwiązanie typeclasses — utworzenie "typ opakowania" [ang. "wrapper type"] z nową kolejnością — wymaga mniej więcej tyle samo pracy dla programisty, co używanie modułów.)_


## Cachowanie funkcji

Załóżmy, że mamy kosztowne obliczenia, które chcemy cachować (być może wysyłania zapytania do bazy danych lub wykonują dużo pracy związanej z procesorem [ang. "CPU-bound"]). Dla przykładu użyjemy funkcji, która oblicza długość łańcucha:

```rust
fn str_len(s: &str) -> usize {
    println!("Called expensive function str_len");
    s.len()
}
```


### Cachowanie indywidualnej funkcji

Jak napisać funkcję która działa jak `str_len`, ale cachuje wyniki w pamięci podręcznej w taki sposób, że nigdy nie obliczy dwukrotnie tej samej pary klucz-wartość? Jednym ze sposobów jest wygenerowanie funkcji opakowania z zmiennym wewnętrznym pamięcią podręczną i wywołanie podstawowe funkcji `str_len` kiedy klucza nie ma w pamięci podręcznej:


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

Oczywiście, możliwe jest również utworzenie `struct`, która cachuje wewnętrzną pamięcię podręczną i po prostu wymaganie wywołującemu wywołania opakowaną funkcję za pomocą metody `.call` _(uwaga techniczna: Rust obecnie nie obsługuje przeciążania operatora wywołania funkcji)_.


### Cachowanie funkcji generyczne

A teraz abstrahujemy o jeden poziom: a jak chcemy napisać funkcję generyczną do cachowania, która może cachować wyniki _dowolnej_ funkcji, a nie tylko konkretnie `str_len`? _(Uwaga techniczna: aby uprościć sytuację, ograniczymy się do cachowania wyników tylko tych funkcji, które akceptują dokładnie jeden parametr, ponieważ Rust obecnie nie obsługuje "variadic generics".)_ Możemy to osiągnąć za pomocą funkcji generycznej:

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


A potem nieznacznie dostosowujemy podany parametr, żeby działały typy w tym przykładzie:

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


### Uważanie funkcji jako wartość

Oczywiście z powodu, że zadaliśmy sobie tyle trudu, aby stworzyć tą pamięcię podrzęczną, pewnie chcemy podać ją przekazywać i używać. Idealnie moglibyśmy pisać to tak:


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


Niestety, produkuje ten błąd:

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

Nie możemy używać `impl Fn` w "type alias", więc musimy to wypisać:

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

Czyli każde użycie naszej typu funkcji musi zawierać również parametry generycznych typów. To "zaraźliwe" zachowanie szybko staje się nieporęczne w praktyce dla programów nawet o średniej wielkości.


## Kodowanie modułów


### Moduły w OCaml

Moduły w stylu ML mogą ukrywać typy generyczne w sposób, w jaki same funkcje generyczne nie mogą osiągać _(uwaga techniczna: używają pewnej formę [typów "existential"](https://en.wikipedia.org/wiki/Type_system#Existential_types))_. Aby wyrazić podobny przykład za pomocą modułów w stylu ML, możesz przejrzeć (i chyba nie zrozumieć) następujący kod OCaml:

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

Ostatecznie chodzi o to, że możesz napisać funkcję taką jak `accepts_cached_str_len`, za pomocą typu niegenerycznego, takiego jak `CachedStrLenBackend.t`:
 
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

### "Associated" typy

Aby osiągnąć coś podobnego do modułów w stylu ML, możemy używać [Rust typy "associated"](https://doc.rust-lang.org/rust-by-example/generics/assoc_items/types.html) [ang. "associated types"]. Najpierw, zmieniamy nasze typy funkcji w traits _(uwaga techniczna: ostatecznie, to jest pewną formą "[defunctionalization](https://en.wikipedia.org/wiki/Defunctionalization)")._
 
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

A teraz stworzymy naszą funkcję `str_len` jako nowy typ i implementację trait `Backend`:

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

Jak definiujemy generyczną wersję cachowanego backend, który działa dla dowolnego rodzaju `Backend`? Prosta wersja funkcji generycznej tak jak `compute_cached&lt;B: Backend>` nie działa, bo chcemy, żeby przechowywał stan. Zamiast tego deklarujemy inny typ, który jest sparametryzowany na typie `Backend`:

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

Następnie skonstruujemy wartości tych typów i przekazujemy je dalej. Inaczej niż wcześniej, możemy nawet stwarzać "type aliases" dla cachowanego typu funkcji — bez konieczności ponownego określenia parametrów typów generycznych w każdym miejscu.

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


### Parametryzowanie tylko nad typami

Przekazywanie dalej wartości, które ucieleśniają moduły jest właściwie najpotężniejszą formą tej techniki, odpowiadające "modułom pierwszej-klasy" [ang. "first-class modules"], ale jest to prawdopodobnie  najbardziej naturalna forma wyrażania w Rust, ponieważ większość programistów zajmuje się raczej wartościami niż typami. Idealnie byłoby, gdyby optimizer wyeliminował narzut związany z przekazywaniem wartości, która nie zawiera danych.

Rzadko trzeba to robić, ale można wywoływać tylko na podstawie typu i zakazywać nawet budować wartości. Jest to również interesujące z pedagogicznego punktu widzenia jako przykład "kierowanego-przez-typ" [ang. "type-directed"] generowania kodu w Rust. Aby przepisać powyższy przykład bez tworzenia `Backend`, usuniemy wszędzie parametr `&self`:

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

Następnie dostosujemy  nasz `CachedBackend`, żeby bezpośrednio użył `B`, zamiast wywołać metody na wartości typu `B`, tak jak wywołanie `B::compute`:

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

### Inne kodowania

Moduły w stylu ML obejmują inne funkcje niż powyższe. Oto krótka dyskusja o kodowaniu tamtych funkcji:



* `include`:
    * Można używać poprzednio dyskutowane sposoby, tak jak "extension traits".
    * Albo możesz używać makr — widziałem to w systemach produkcyjnych. (Istnieją dobrze udokumentowane problemy z makrami, których tutaj nie omówię.)
* Aktualizowanie modułów, czyli tworzenie nowej definicji istniejącego modułu z przedefiniowanym jednym z typów "associated".
    * Poza makrami, nie widziałem kodowania na to.
* Typowanie strukturalne [ang. "[structural typing](https://en.wikipedia.org/wiki/Structural_type_system)"]
    * Rust po prostu nie pozwala strukturalnego typowania obiektów podobnych do modułów. Możesz spróbować zmienić swoje implicytne strukturalne typy na eksplicytne hierarchię traits.
    * Albo możesz używać makr.
* "Applicative" vs "generative" funktory
    * Zobacz [https://stackoverflow.com/questions/52161048/applicative-vs-generative-functors](https://stackoverflow.com/q/52161048/344643)
    * Zależy od konkretnego kodowania modułu. Abstrakcje typów są wprowadzone ręcznie typami "associated" i zawsze są nierówne, podczas gdy typy przekazywane przez parametr typu generycznego mogą być uważane równe. Więc jeśli chcesz funktor generatywnego, możesz bezpośrednio wprowadzić nowy typ abstrakcyjny poprzez kolejną warstwę `trait` z typem "associated".

Zobacz też [The AST typing problem](http://blog.ezyang.com/2013/05/the-ast-typing-problem/), abe znaleźć powiązane pytania dotyczące praktycznego kodowania modułów.

{% include end_matter.md %}
