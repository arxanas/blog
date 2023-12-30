---
layout: post
title: Używanie `tracing` w aplikacji Rust CLI
permalink: śledzenie-aplikacji-rust-cli/
translations:
  en: "/tracing-rust-cli-apps/"
tags:
  - rust
  - software-engineering
---

<div class="publication-notes">
  <table>
    <tr>
      <td>Docelowi odbiorcy</td>
      <td>Użytkownicy Rust.</td>
    </tr>
    <tr>
      <td>Pochodzenie</td>
      <td><ul>
        <li><a href="https://github.com/arxanas/git-branchless/discussions/732">Mój post na GitHub</a>.</li>
        <li>Moje doświadczenie w Rust.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Nastrój</td>
      <td>Informujący.</td>
    </tr>
    {% include translation_notice.html %}
  </table>
</div>

 * toc
{:toc}

[@epage](https://github.com/epage) w [https://github.com/arxanas/git-branchless/discussions/732](https://github.com/arxanas/git-branchless/discussions/732) zapytał:

 	Widzę, że mówią o `tracing`, ale głównie z perspektywy “web” i jestem ciekawy, jak to doświadczenie przekłada się na CLI. Zamierzam zastosować go w niektórych mniejszych CLI, żeby zdobyć trochę doświadczenia, aby zrozumieć, w jaki sposób może pomóc `cargo`.

Ponownie publikuję moją odpowiedź tutaj, [w formie wypunktowanej](https://blog.waleedkhan.name/on-bullet-points/):


## Dla Cargo

W przypadku Cargo chciałbym podkreślić następujące punkty:



* Zachęca do robienia właściwych rzeczy za pomocą makr do ustrukturyzowanego logowania [ang. "structured logging"]. Dodatkowe obliczenia nie są przeprowadzane, jeśli nie zostaną używane przez subskrybenta, co w przeciwnym razie mogłoby spowodować regres wydajności.
* Śledzenie “spantraces” w celu profilowania jest niewygodne, ponieważ trzeba ręcznie dodawać adnotacje do każdej funkcji, która ma być śledzona. Nie wiem, czy można to poprawić za pomocą “stack traces”.
* Można łatwo wysyłać dane do wielu różnych subskrybentów, w tym do niestandardowych (…jeśli wiadomo, jakie funkcje wywołać). Na przykład, `tracing_subscriber::fmt_layer::Layer::with_writer` pozwala zbudować warstwę, która zużywa sformatowane informacje logowania i zapisuje je w dowolnym miejscu.
    * Można używać gotowych komponentów, takich jak subskrybent śledzenia Chrome [ang. “Chrome tracing”, jakaś].
* Ktoś może to skonfigurować raz, a inni nie muszą się tym zbytnio przejmować.
* Dla mnie, profilowanie okazało się bardzo skuteczne.


## Pełne notatki



* Przez używanie `eyre`/`color_eyre` można dołączyć parametry funkcji do “spantraces”. Jest to dość cenne podczas debugowania, ponieważ widzę m.in. OID zatwierdzenia [ang. “commit OID”] w “spantrace” dla zatwierdzenia, które powoduje problemy, bez konieczności ręcznego wyodrębniania go przez dodanie większej liczby logów.
* Konfigurowanie `tracing` po raz pierwszy jest uciążliwe, ale po tym w dużej mierze nie musisz go dotykać.
    * Oto moja funkcja, która to robi: [https://github.com/arxanas/git-branchless/blob/4b76af669258e80a6f6eb4ddf45bbb358da80248/git-branchless/src/commands/mod.rs#L437](https://github.com/arxanas/git-branchless/blob/4b76af669258e80a6f6eb4ddf45bbb358da80248/git-branchless/src/commands/mod.rs#L437)
    * Z powodzeniem skonfigurowałem instrukcje logowania do drukowania za pomocą mojego własnego typu (`Effects`), zamiast drukowania bezpośrednio na stdout/stderr, ponieważ może to blokować liczniki postępu [ang. “progress meters”] lub inne interaktywnie dane wyjście.
    * Skonfigurowałem go tak, że podprocesy nie zostaną zawarte w śledzeniu nadrzędnym; otrzymują własne pliki wyjściowe. Szczerze mówiąc, nie sądzę, żebym musiał badać śledzenie podprocesów.
    * Kiedyś było to mniej ergonomiczne, ale ostatnio ulepszyli coś związanego z kompozycją warstw, na przykład filtrowanie jednej warstwy na podstawie innej warstwy; zobacz [https://github.com/arxanas/git-branchless/commit/5428f1b9dbed356accf854774cad053c22d19b1f](https://github.com/arxanas/git-branchless/commit/5428f1b9dbed356accf854774cad053c22d19b1f)
    * Niektóre komunikaty o błędach dotyczące kompozycji warstw mogą być nieczytelne z powodu domyślnego użycia polimorfizmu statycznego. Na przykład trudno jest warunkowo skonstruować warstwę do włączenia. Typy stają się bardzo długimi łańcuchami zagnieżdżonych parametrów typu ogólnego [ang. “generic type parameters”].
        * Na szczęście `Option<Layer>` jest również warstwą, więc możesz przekazać `Some(layer)` lub `None` w zależności od stosownego warunku, zamiast próbować bezpośrednio wywoływać metody rejestru.
* Makro `#[instrument]` to jedyny realistyczny sposób dołączania funkcji do “spantraces” dla `eyre`/`color_eyre`.
    * Niszczy to autopoprawki [ang. “autofixes”, tak jak w IDE] (prawdopodobnie należy to uznać za błąd w `rust-analyzer`).
    * Może to wymazać lokalizację błędów, ponieważ czasami błąd jest przypisywany do funkcji jako całości, a nie do konkretnej linii.
    * Może to wydłużyć czas kompilacji, ponieważ jest to makro proceduralne [ang. “procedural macro”, [pojęcia z Rusta](https://doc.rust-lang.org/reference/procedural-macros.html)]. Jak być może wiesz, procedury makr proceduralnych, takie jak `syn` [ang. [Rust crate zwany “syn”](https://crates.io/crates/syn), nie ma czegoś wspólnego z słowem “syn”], zwykle znajdują się na ścieżce krytycznej [ang. “critical path”] kompilacji, ale jeśli zobowiążesz się w ogóle nie używać makr proceduralnych, możesz je pominąć.
* Profilowanie poprzez zrzut do warstwy śledzenia Chrome jest skuteczne.
    * Spójrz na [https://github.com/arxanas/git-branchless/wiki/Runbook#profiling](https://github.com/arxanas/git-branchless/wiki/Runbook#profiling), aby uzyskać szczegółowe informacje na temat procedur profilowania.
    * Wielokrotnie korzystałem z tego systemu do debugowania problemów/regresji w związku wydajnością. Istniejące wizualizatory śledzenia Chrome są całkiem przydatne do analizy podziału spędzonego czasu.
    * Zawarcie parametrów funkcji było wyjątkowo przydatne, ponieważ mogłem bezpośrednio zobaczyć wycinek danych wyjściowych profilowania, który trwał zbyt długo, i sprawdzić odpowiedni OID zatwierdzenia, dzięki czemu mogłem zbadać i przetestować to konkretne zatwierdzenie.
* Spróbowałem użyć śledzenia jako danych wejściowych do mojego własnego systemu raportowania postępów (tak, aby wywołania funkcji były bezpośrednio powiązane z paskami postępu, które pojawiają się na ekranie). Było to możliwe, ale ostatecznie zrezygnowałem z tego podejścia, ponieważ operacje logiczne nie odpowiadały dokładnie jeden do jednego wywołaniom funkcji, a zbyt łatwo było zapomnieć o poprawnym opatrzeniu metodą adnotacją.
* W ogóle nie próbowałem śledzenia z async/.await.
* W ogóle nie próbowałem [https://github.com/tokio-rs/console](https://github.com/tokio-rs/console), ale chciałbym wiedzieć, czy jest to dla Was przydatne.
* Ustrukturyzowane logowanie jest świetne.
    * Samo użycie makr ustrukturyzowanego logowania z reprezentacjami debugowania (np. `warn(?var, "Message")`) jest znacznie bardziej ergonomiczne niż ręczne interpolowanie wartości do stringów.
    * Obsługuje również takie rzeczy, jak renderowanie znaków niedrukowalnych, gdzie wcześniej musiałbym uważać, aby uwzględnić wartości stringów w cudzysłowach itp.
    * Zasadniczo można zobaczyć te zdarzenia i ich wartości w wynikach profilowania, chociaż nie musiałem profilować na podstawie pojedynczych zdarzeń, tylko na podstawie całego zakresu.
    * Jest to bardziej wydajne, ponieważ nie będziemy budować sznurów, jeśli wartości nie zostaną zużyte przez żadnego subskrybenta w czasie wykonywania.
* Istnieje dziwna niezgodność między wersją `tracing_subscriber` używaną przez mój kod i `color_eyre`, co oznacza, że ​​zablokowałem ją w znanej dobrej wersji tutaj: [https://github.com/arxanas/git-branchless/pull/533/ zatwierdzenia/e97954a9a9fab4039ad269d6b8982bb8bd95b133](https://github.com/arxanas/git-branchless/pull/533/).
    * Myślę, że `color_eyre` musi po prostu zaktualizować swoją wersję śledzenia-subskrybenta, ale od tamtej pory się tym nie zajmowałem.

{% include end_matter.md %}
