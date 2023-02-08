---
layout: post
title: "Ulepszenie przyrostowe czasy testowaniaRust"
permalink: rust-przyrostowe-czasy-testowania/
translations:
  en: "/rust-incremental-test-times/"
tags:
  - rust
  - software-engineering
---

_Docelowi odbiorcy: potencjalni i średnio-zaawansowani deweloperzy Rust, którzy martwią się wolnymi czasami kompilacji, ich skalą i praktykami zapobiegawczymi; zaawansowani deweloperzy Rust, którzy pomogą mi poprawić czas kompilacji._

Rust jest znany z wolnego czasu kompilacji. Spędziłem dużo czasu próbując poprawić przyrostowe czasy kompilacji testowania dla mojego projektu [git-branchless](https://github.com/arxanas/git-branchless) w [https://github.com/arxanas/git-branchless/pull/650](https://github.com/arxanas/git-branchless/pull/650). Oto dyskusja wyników.

* toc
{:toc}

## Streszczenie wykonawcze



* “Przyrostowe testowania” odnosi się tylko do zmiany kodu testu integracyjnego i przebudowanie. Kod źródłowy pozostaje niezmienony.
* Ostatecznie udało mi się skrócić przyrostowy czas testowania z ~6.9sek do ~1.7sek (~4x). Inne sposoby na skrócenie czasu kompilacji przyniosły niewielką lub żadną poprawę.

W celach informacyjnych, oto najlepsze artykuły dotyczące konceptualnego zrozumienia modelu kompilacji Rust i poprawy czasu kompilacji:



* [Fast Rust Builds](https://matklad.github.io/2021/09/04/fast-rust-builds.html) ([matklad.github.io](https://matklad.github.io), 2021)
* [How to Test](https://matklad.github.io/2021/05/31/how-to-test.html) ([matklad.github.io](https://matklad.github.io), 2021)
* [Why is my Rust build so slow?](https://fasterthanli.me/articles/why-is-my-rust-build-so-slow) ([fasterthanli.me](https://fasterthanli.me/), 2021)
* [Tips for Faster Rust Builds](https://endler.dev/2020/rust-compile-times/) ([endler.dev](https://endler.dev), 2020-2022)
    * W rzeczywistości, wówczas nie czytałem tego artykułu, ale przeczytałem kiedy napisałem ten artykuł.


## Szczegóły projektu

Oto jak duży był mój projekt [git-branchless](https://github.com/arxanas/git-branchless) przed pull request:



* `git-branchless/src`: 12060 linii.
* `git-branchless/tests`: 12897 linii.
    * Zauważ, że w dużej mierze opiera się na “snapshot testing”, więc większość tych linii kodu to “multiline string literals”.
* `git-branchless-lib/src`: 12406 linii.

 Dopuszczalne są długie czasy kompilacji i łączenia [ang. “linking”], ale aby zoptymalizować sprzężenie zwrotnego programowania, potrzebuję szybkich czasów testowania. W szczególności chcę iterować nad pracowaniem pewnego testu. ([IntelliJ](https://www.jetbrains.com/idea/) ma fajną funkcję automatycznego ponownego uruchamiania danego testu, gdy występuje zmiana w kodu źródła ale trwanie zbyt długo ponownej kompilacji zmniejsza jej przydatność.)

Na początek zbudowanie binary `test_amend` (który testuje subcommand `amend`) po dodaniu pojedynczego komentarza do jego pliku testu (bez zmian w library!) wymaga ~6.9sek:

```bash
$ hyperfine --warmup 3 --prepare 'echo "// @nocommit test" >>git-branchless/tests/command/test_amend.rs' 'cargo test --test mod --no-run'   
Benchmark 1: cargo test --test mod --no-run
  Time (mean ± σ):      6.927 s ±  0.123 s    [User: 7.652 s, System: 1.738 s]
  Range (min … max):    6.754 s …  7.161 s    10 runs
```

Tragedia! To nie duży projekt, a zmieniamy tylko testy, więc nie powinno to wymagać tak długiego czasu iteracji.


## Podzielenie się na więcej crates

W pull request wyodrębniłem do dodatkowych dziewięciu crates, co daje przyrostowy czas kompilacji testu wynoszący ~1.7sek (~4x poprawa).

```bash
$ hyperfine --warmup 3 --prepare 'echo "// @nocommit test" >>git-branchless/tests/test_amend.rs' 'cargo test --test test_amend --no-run'   
Benchmark 1: cargo test --test test_amend --no-run
  Time (mean ± σ):  	1.771 s ±  0.012 s	[User: 1.471 s, System: 0.330 s]
  Range (min … max):	1.750 s …  1.793 s	10 runs
```

Jeśli chodzi o poprawę relatywną, to znaczna, ale jeśli chodzi o poprawę absolutną, sądzę, że jest raczej słaba. Bym oczekiwał 100-200ms na parsing, macro expansion, typechecking, i code generation (bez optimacji) dla pliku tego rozmiaru (~1k linii, głownie długi wartości łańcuchowe).

Dodatkowe, dzielenie na wiele crates utrudnia rozpowszechnianie projektu za pośrednictwem [crates.io](https://crates.io/):



* Każdy crate wymaga indywidualnego publikowania na crates.io (nie można opublikować crate z zależnościami Git w crates.io).
    * Dlatego muszę zarządzać wersjami i licencji każdego crate.
* Według mojej ankiety wśród użytkowników, większość moich użytkowników instaluje przez `cargo`. Na pytanie “Jak zainstalowałeś git-branchless?”, odpowiedzi są następujące (stan na ):
    * 7/18 (38.9%): przez `cargo install git-branchless`.
    * 4/18 (22.2%): za pośrednictwem tradycyjnego systemowego menedżera pakietów.
    * 4/18 (22.2%): przez Nix lub NixOS
    * 2/18 (11.1%): klonując repozytorium i ręcznie budując i instalując.
    * 1/18 (5.6%): przez artefakt kompilacji z GitHub Actions

Niestety, muszę publicznie udostępniać wewnętrzne moduły na crates.io tylko po to, aby uzyskać rozsądne czasy kompilacji.


## Czas bez operacji

Wtedy, mierzę czas bez operacji [ang. “no-op”] na ~350ms dla mniejszej crate testowania z niewieloma zależności:

```bash
$ hyperfine --warmup 3 'cargo test -p git-branchless-test --no-run' 		 
Benchmark 1: cargo test -p git-branchless-test --no-run
  Time (mean ± σ):     344.2 ms ±   3.5 ms    [User: 246.2 ms, System: 91.9 ms]
  Range (min … max):   340.4 ms … 351.0 ms    10 runs
```

To jest nieoczekiwane. Spodziewałbym się, że czas na kompilację bez operacji będzie podobny do `git status`, może 15ms:

```bash
$ hyperfine --warmup 3 'git status'
Benchmark 1: git status
  Time (mean ± σ): 	 13.5 ms ±   2.5 ms    [User: 4.9 ms, System: 6.1 ms]
  Range (min … max):    11.1 ms …  24.7 ms    197 runs
```

Tu może być jakiś głębszy problem. Dokumentacji `cargo nextest` ostrzega, że niektóre systemy przeciw malware mogą wprowadzać sztuczne opóźnienie uruchamiania podczas sprawdzania plików wykonywalnych:

> A typical sign of this happening is even the simplest of tests in cargo nextest run taking more than 0.2 seconds.

Zgodnie z dokumentacją, oznaczyłem moje oprogramowanie terminala jako “Developer Tools” w systemie macOS, ale nie udało mi się skrócić czasu kompilacji bez operacji.


## Koniec profilowania?

Spróbowalem z subcommand crate, który niedawno stworzyłem bez dużo zaleźności:

```bash
$ hyperfine --warmup 3 --prepare 'echo "// @nocommit test" >>git-branchless-test/tests/test_test.rs' 'cargo test -p git-branchless-test --no-run'
Benchmark 1: cargo test -p git-branchless-test --no-run
  Time (mean ± σ):  	1.855 s ±  0.034 s	[User: 1.476 s, System: 0.335 s]
  Range (min … max):	1.831 s …  1.939 s	10 runs
```

Wykres czasu kompilacji według `cargo build` nie pomaga. Tylko pokazuje to, że budowany test wymaga 100% czasu:

{% image cargo-timings-git-branchless-test-crate.png "The timing graph for building the `git-branchless-test` crate." %}



## Koniec kolejnych pomysłów?

Oto niektóre pomysły, które nie zadziałały:



* Połączenie testów integracyjnych w jeden binary. (W każdym razie chętnie uruchamiam indywidualne binaries, jeśli to konieczne.)
* Zmniejszenie głównych monomorfozacji (wywołania `AsRef` itp. Pojawiły się w `cargo llvm-lines`, ale ich zmniejszenie nie wydawało się poprawę czasu kompilacji).
* Używanie [`sccache`](https://github.com/mozilla/sccache).
* Używanie [`cargo nextest`](https://nexte.st/).
* Używanie [zld](https://github.com/michaeleisel/zld)/[mold](https://github.com/rui314/mold)/[sold](https://github.com/bluewhalesystems/sold).
* Ustawienie `profile.dev.split-debuginfo = “unpacked”` (dla systemu macOS).
* Ustawienie `profile.dev.build-override.opt-level = 3`.
    * Niestety, są dużo makr proceduralnych, zwłaszcza `#[instrument]` z crate [`tracing`](https://docs.rs/tracing/latest/tracing/).
* Ustawienie `profile.dev.debug = 0`. W rzeczywistości skraca czas kompilacji o 20ms, ale samo w sobie nie wystarczy.

Więc teraz utknąłem. To najwięcej, co mogę skrócić przyrostowe czasy testowania Rust. Daj znać, jeśli masz jakieś inne pomysły.

{% include end_matter.md %}
