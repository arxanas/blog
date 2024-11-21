---
layout: post
title: "System kontroli wersja Yandex Arc"
permalink: yandex-arc/
translations:
  en: "/yandex-arc/"
tags:
  - git
  - software-engineering
---

<div class="publication-notes">
  <table>
    <tr>
      <td>Docelowi odbiorcy</td>
      <td>Deweloperzy systemów kontroli źródła, tak jak Git i Mercurial.</td>
    </tr>
    <tr>
      <td>Pochodzenie</td>
      <td><ul>
        <li><a href="https://discord.com/channels/1042895022950994071/1042907270473850890/1068630001240514691">Moje notatki w Discordzie</a>.</li>
        <li>Moje doświadczenie w programowaniu dla systemów kontroli źródła.</li>
        <li><a href="https://habr.com/ru/company/yandex/blog/482926/">Oficjalny blog Yandex</a>.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Nastrój</td>
      <td>Lekko zainteresowany.</td>
    </tr>
    {% include translation_notice.html %}
  </table>
</div>

{% include toc.md %}

Ostatnio był przeciek koda z [Yandex](https://pl.wikipedia.org/wiki/Yandex). Ja nie spradzałem plików, ale temat właśnie przypomina nam, że Yandex utrzymuje swoje duże [monorepo](https://monorepo.tools/), a nawet zbudował własny [system kontroli źródła](https://pl.wikipedia.org/wiki/System_kontroli_wersji) [ang. “source control system”], żeby sobie z tym radzić, o nazwie “Arc”.

Oryginalny artykuł z Yandex (2020): [https://habr.com/ru/company/yandex/blog/482926/](https://habr.com/ru/company/yandex/blog/482926/)

Krótkie notatki (pierwotnie opublikowane na [Discordzie](https://discord.com/channels/1042895022950994071/1042907270473850890/1068630001240514691)):



* Wydaje się, że jest oparty nad [SVN](https://subversion.apache.org/) na back-end.
* Prowadzają [trunk-based development](https://trunkbaseddevelopment.com/).
* 6 mln zatwierdzeń, 2 mln plików, 2TB rozmiar repo.
* Wypróbowali [Mercurial](https://www.mercurial-scm.org/), ale nie rozwiązał problemów wydajności.
* Używają numery generacji [ang. “generation numbers”] do obliczania “merge-bases”.
    * Jest to teraz dostępne w Gitu poprzez [mechanizm commit-graph](https://git-scm.com/docs/commit-graph).
* Prawdopodobnie oparty nad Gitem do front-end UI, ale narzekają, że UI Gita jest zły, więc go ulepszają.
* Używany wewnętrznie przez 20% deweloperzy w momencie napisania.
* Ciężko używa [wirtualnego system plików](https://en.wikipedia.org/wiki/Virtual_file_system) [ang. “virtual filesystem”, “VFS”].
    * Używają [FUSE](https://en.wikipedia.org/wiki/Filesystem_in_Userspace) na macOS, chociaż wsparcie VFS’ów na macOS jest niestabilne w tym czasie; może zmienili od tamtego czasu?
* Używa [Yandex Database](https://cloud.yandex.com/en/services/ydb) (YDB) jako bazę danych na back-end, z jakimś narzędziem przekładania z SVN’a.
* W ramach systemu code review, zatwierdzenie Arc’a będzie przedkładane w zatwierdzenie SVN’a, w tym dodatkowe metadane z Arc’a.
* Niezauważalnie używa zatwierdzenia dla “working copy” aby przeprowadzać niektóre algorytmy, który zawierać “untracked” pliki, ponieważ zaopatrzywa VFS.
    * Wspomniałem o tym w kontekście [Jujutsu VCS](https://github.com/martinvonz/jj).

W sumie, nie wydaje mi się, że ma wiele do awansowania systemów kontroli wersji w porównaniu z dużymi firmami tech, takimi jak Google i Meta.

{% include end_matter.md %}
