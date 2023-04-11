---
layout: post
title: "Szybkie formatowanie stosu zatwierdzeń"
permalink: formatowanie-stosu-zatwierdzeń/
translations:
  en: "/formatting-a-commit-stack/"
tags:
  - git
  - software-engineering
---

_Docelowi odbiorcy: inżynierowie oprogramowanie pracujący z Git, którzy używają "patch stacks"/"stacked diffs", na przykład w jaki sposób Git jest używany w projektach Git i Linux, a także w wielu firmach wprowadzających "[trunk-based development](https://trunkbaseddevelopment.com/)"; ale nie użytkownicy Git, który uważają, że graf zatwierdzeń Git powinien odzwierciedlać rzeczywisty proces rozwijania._

Pewna kategoria programistów używa Git z przypływem pracy "patch stack", na którym zbierają ciąg małych, indywidualnie przeglądanych zatwierdzeń, które razem realizują znaczną zmianę. W takich przykładach, często przydatne jest uruchamianie linters lub formatters na każdym zatwierdzeniu w stosie i zastosowanie wyników. Może to być jednak żmudne, a naiwne podejście może powodować niepotrzebne konflikty scalania. (Jednym z obejść jest zastosowanie formatter na każdym zatwierdzeniu w stosie _wstecz_.)

Komenda `git test` z git-branchless przedstawia rozwiązanie do szybkiego uruchamiania formatters, itd., na całym stosie zatwierdzeń bez produkowania konfliktów scalania. Dodatkowo, może to zostać wykonywany równoległe, i zapisuje wyniki, żeby ponowne formatowania tego samego zatwierdzenia zostawił pominięte. Możesz zobaczyć [post z ogłoszeniem](https://github.com/arxanas/git-branchless/discussions/803) lub [dokumentację `git test`](https://github.com/arxanas/git-branchless/wiki/Command:-git-test).

Oto demonstracja formatowania zatwierdzeń w stosie (przewiń do 0:35, aby zobaczyć tylko demonstrację `git test fix`):

<video src="https://user-images.githubusercontent.com/454057/219904589-79657aed-9356-4f87-a0e4-bdcfbe691621.mov" controls="controls" muted="muted"></video>

Ja zwykle ustawiam `git` fmt na alias na coś takiego

```
git test run --exec 'cargo fmt --all' --strategy worktree --jobs 8
```

{% include end_matter.md %}