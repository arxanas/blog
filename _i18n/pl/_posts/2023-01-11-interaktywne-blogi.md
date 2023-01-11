---
layout: post
title: Interaktywne blogi
permalink: interaktywne-blogi/
translations:
  en: "/interactive-blogs/"
tags:
  - rant
  - writing
---

* toc
{:toc}

Dla mnie, najlepszym platformą na blogging jest [Google Docs](https://www.google.com/docs), bo obsługuje poniższe:



* Współpracować na żywo.
* Pozostawiać komentarze bezpośrednio w tekście, a nie w ograniczonym obszarze.
* Sugerować zmiany bezpośrednio w tekście. Cóż miły sposób na poprawianie tekstu!
    * Z tego powodu również wolę Wikis od Git’a, jeśli chodzi o pisanie dokumentacji, bo bariera wejścia jest znacznie mniejsza.

Niestety, Google Docs nie jest zwłaszcza dostępny:



* Wydaje się, że nie będzie indeksowany przez wyszukiwarki?
* Wymaga Javascript.
* Wymaga Google, czemu niektórzy ludzie sprzeciwiają się ze względu na prywatność.

Dlatego nie wydaję w ten sposób postów na blogu.

<style type="text/css">
@keyframes hypermedia {
  0%, 100% {
    left: -1em;
    top: 0.4em;
    z-index: 1;
    font-size: normal;
  }
  
  25% {
    font-size: 1.3em;
  }
  
  75% {
    font-size: 0.7em;
  }

  50% {
    left: 97%;
    top: -0.6em;
    z-index: 1;
    font-size: normal;
  }
  
  51%, 99% {
    z-index: -1;
  }
}

.hypermedia {
  letter-spacing: 0.1em;
  position: relative;
  font-variant: small-caps;
}

.hypermedia::before {
  content: "✨";
  position: absolute;
  animation-name: hypermedia;
  animation-duration: 6s;
  animation-iteration-count: infinite;
  animation-timing-function: ease-in-out;
}
</style>

Ale w dobie <span class="hypermedia">hipermediów</span> te funkcje powinny być standardem! Powinniśmy <span class="hypermedia">dyskutować</span>, a nie wyrzucać artykuły <span class="hypermedia">w próżnię</span>!

Medium wyświetlało komentarze w tekście, ale [już tego nie robi](https://medium.com/@jashan/how-to-make-the-best-of-a-broken-commenting-system-113c8cc1fe71) (nie żebym chciał wydawać posty na Medium). Nie widziałem wielu innych blogów, które zapraszają do dyskusji za pomocą interaktywnych funkcji.

Kiedyś czytałem _[Real World OCaml](https://dev.realworldocaml.org/)_, kiedy jego drugie wydanie było w wersji roboczej. Po każdym zdaniu znajdował się link na pozostawianie komentarza. To jest naprawdę fajny sposób na pisanie książki! Dlaczego akurat książka jest bardziej interaktywna niż nasze blogi?


## Niech żyje ten blog

Od niedawna można pozostawiać komentarze na akapitach mojego blogu, najeżdżając/dotykając i klikając link “Skomentuj”, który się pojawi.



* Inne rozwiązania:
    * [https://utteranc.es](https://utteranc.es)
    * [Disqus](https://disqus.com/)
        * Używany już do komentarzy na tym blogu, chociaż jest trochę podejrzany, jeśli chodzi o korzystanie plików cookie.
    * Każda z tych opcji wymaga tworzenie własnego wątku komentarza dla każdego akapitu, na którym można skomentować.
        * Ich UIs nie zostały zaprojektowane tak, aby były zwarte, więc nie pasują dobrze między akapitami na blogu. Byłoby ogromny formularz po każdym akapitu.
        * Spowodowałoby to niepotrzebne obciążenie serwerów komentarzy, trochę niegrzecznie dla nich.
        * Spowodowałoby to wolniejsze ładowanie strony podczas zapytania do kilku wątków komentarzy.
    * Możesz czerpać inspirację z projektu takiego jak SideComments.js.
    * Moja implementacja niestety opiera się na GitHub jako dostawcy uwierzytelniania i bazie danych. Jestem pewien, że wielu czytelników nie będzie miało kont GitHub’a.
        * To był dla mnie najłatwiejszy sposób na zaimplementowanie.
        * GitHub API jest wystarczająco wyrazisty, aby wysłać zapytanie o wszystkie komentarze dla pewnego dokumentu w jednym żądaniu.
        * GitHub API nie wymaga uwierzytelniania ani klucza API do wysyłania żądań!
            * Przypuszczalnie będziesz ograniczany bardziej agresywnie niż w przypadku uwierzytelnienia.
        * Otwarcie nowej strony GitHub Issues’a w celu pozostawiania komentarza jest niewygodnie.
        * Patrząc wstecz, być może powinienem był użyć GitHub Discussions’a zamiast GitHub Issues’a jako bazy daty, ponieważ są to… dyskusje.
    * Akapity są identyfikowane za pomocą permalinku/”slug” i poprzez pobranie kilku pierwszych znormalizowanych bajtów danych w akapicie i zakodowanie jako base64.
        * Teoretycznie identyfikatory akapitów nie są zatem stabilne, jeśli treść zmienia się później, ale wydaje się, że jest to niewielki problem.
    * Oto implementacja w momencie pisania tego tekstu (137 linii kodu): [github-comment-links.js](https://github.com/arxanas/blog/blob/c34f0e18b81ed1d1b22636eaef2cabe7b6afd77e/scripts/github-comment-links.js).
        * Nowoczesne API przeglądarki sprawiają, że zapytanie do API GitHub’a jest dość proste.

{% include end_matter.md %}
