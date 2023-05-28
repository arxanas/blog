---
layout: post
title: Gdzie są moje funkcji Git’a z przyszłości?
permalink: git-ui-funkcji/
translations:
  en: "/git-ui-features/"
tags:
  - git
  - rant
  - software-engineering
hn:  https://news.ycombinator.com/item?id=34301543
lobsters: https://lobste.rs/s/7tnnbq/where_are_my_git_ui_features_from_future
---

 * toc
{:toc}

## Git jest do bani

[System kontroli wersji "Git"](https://git-scm.com/) od 15+ lat przynosi nam nieszczęście. Od momentu powstania, tysiące osób próbowało stworzyć nowe klienty Git’a aby poprawić jego użyteczność.

Jednak, prawie każda z nich skupiła się budować ładną fasadę nad Git’em, żeby robić te same operacji, które właśnie robi Git, jakby interfejs linii komend Git’a był szczytem użyteczności.

Nikt nie raczy się zastanowić: jakie są _przepływy pracy_, które osoby właśnie chcą wykonywać? Jakie są _funkcji_, ułatwiające takie przepływy pracy? Zamiast, dostajemy klienty, które uważają, że `git rebase -i` to najlepszy sposób, aby zmienić komunikat zatwierdzenia, aby edytować zatwierdzenie, aby rozdzielić zatwierdzenie — albo, że warto nawet pokazać w UI tę funkcję.


## Rubryka

Rozmyślałem o przepływach pracy, które często wykonuję, i sprawdziłem kilka klientów Git’a (niektóre z nich są GUIs, i niektóre TUIs), żebym zrozumiał, jak dobrze je obsługują.

Wielu z moich czytelników nie dba o tych przepływach pracy, ale to nie tylko sprawa samych przepływach pracy; chodzi o decyzję, by nie używać wadliwych prymitywnych oferowanych przez Git.

Przepływy pracy:



* **`reword`**: Trzeba być możliwe aktualizować komunikat zatwierdzenia, który nie jest wypożyczany.
    * Aktualizowanie komunikatu zatwierdzenia nie spowoduje konfliktu scalania, zatem nie jest potrzebny wymagać, że zatwierdzenie jest wypożyczany.
    * Też powinno być możliwe aktualizować komunikat zatwierdzenia, który jest przodkiem wielu gałęzi, bez porzucania niektórych z tych gałęzi, ale nie róbmy sobie nadziei…
* **`sync`**: Trzeba być możliwe synchronizować wszystkie moje gałęzi (albo dowolny podzbiór) przez scalanie lub zmianę bazy [ang. “rebase”], w jednej operacji!
    * Robię to cały czas! Praktycznie pierwsza rzecz każdego ranka przychodząc do pracy.
* **`split`**: Trzeba być szczególne polecenie, aby dzielić zatwierdzenie na dwa lub więcej zatwierdzeń, w tym zatwierdzenia, które nie są aktualnie wypożyczane.
    * Dzielenie zatwierdzenia nie spowoduje konfliktu scalania, zatem nie jest potrzebny wymagać, że zatwierdzenie jest wypożyczany.
    * Nie akceptuję rozwiązań za pomocą `git rebase -i`, ponieważ sprawdzanie stanu repozytorium podczas zmiany bazy jest bardzo mylące.
* **`preview`**: Przed wykonaniem scalania albo zmianą bazy, trzeba być możliwy podgląd wyniku, w tym ewentualne konflikty.
    * W ten sposób, nie muszę rozpoczynać scalania/zmiany bazy, żeby zobaczyć, czy się powiedzie, albo czy będzie trudno mi rozwiązać konflikty.
    * Konfliktami scalania może są najokropniejsza rzecz w używaniu Git’a, dlatego powinno być bardzo łatwiej zajmować się nimi (albo unikać zajmowania się nimi!).
* **`undo`**: Trzeba być możliwe cofnąć się z dowolnej operacji, najlepiej obejmujące śledzone-ale-niezatwierdzone zmiany.
    * To nie to samo, co cofnięcie [ang. “revert”] zatwierdzenia. Cofnięcie zatwierdzenia tworzy całkowicie nowe zatwierdzenie z odwrotnych zmian, ale cofnięcie operacji powinno przywrócić repozytorium do stanu, w jakim znajdowało się przed wykonaniem operacji, więc nie byłoby pierwotnego zatwierdzenia do przywrócenia.
* **`large-load`**: UI powinien szybko ładować duże repozytorium.
    * UI nie powinien zawieszać się w żadnym momencie i powinien pokazywać przydatne informacje zaraz po załadowaniu. Nie powinieneś czekać na załadowanie całego repozytorium, zanim będziesz mógł sprawdzić zatwierdzenia i gałęzi.
    * Program może działać wolno przy pierwszym wywołaniu w celu zbudowania niezbędnych pamięci podręcznych, ale musi reagować szybko na kolejne wywołania.
* **`large-ops`**: UI powinien reagować szybko podczas wykonywania różnych operacji, takich jak sprawdzanie zatwierdzeń i gałęzi, lub scalanie i zmianę bazy.

Dodatkowe punkty:



* Przyznam honorowe punkty ujemne każdemu klientowi, który ośmieli się potraktować git rebase -i tak, jakby był fundamentalnym prymitywem.
* Przyznam honorowe punkty bonusowe każdemu klientowi, który wydaje się szanować empiryczne badania użyteczności dla Git (lub innych VCS).
    * Gitless:[ https://gitless.com/](https://gitless.com/)
    * IASGE:[ https://investigating-archiving-git.gitlab.io/](https://investigating-archiving-git.gitlab.io/)

Z powodu, że nie zapisałem nic z tego, te kryteria są tylko po to, aby każdy sprzedawca tych klientów mógł wiedzieć, czy jestem pod wrażeniem, czy rozczarowany.


## Klienty

Wybrałem arbitralnie kilku klientów z tej listy klientów. Z pewnością mylę się co do niektórych z tych punktów (lub zmieniły się od ostatniego razu), więc skomentuj.



* Aktualizacja 2022-01-09: Dodałem IntelliJ.
* Aktualizacja 2022-01-10: Dodałem Tower.
* Aktualizacja 2023-05-28: Podniosłem ocenę `reword` dla Magit.

Załączyłem mój własny projekt git-branchless, ale się nie liczy jako przykład innowacji w branży. Tylko jest tu, aby pokazać, że wiele z tych przepływów pracy jest naprawdę możliwych.

<style type="text/css">
th.rotate {
  /* Something you can count on */
  height: 140px;
  white-space: nowrap;
}

th.rotate > div {
  transform: 
    translate(20px, 51px) /* magic numbers */
    rotate(320deg);
  width: 30px;
}
th.rotate > div > span {
  padding: 5px 10px;
}

#data th:nth-child(even) > div > span, #data td:nth-child(even) {
  background-color: #eee;
}

</style>

<table id="data">
<thead>
  <tr>
    <th></th>
    <th class="rotate"><div><span><a href="https://git-scm.com/">Git CLI</a></span></div></th>
    <th class="rotate"><div><span><a href="https://www.gitkraken.com/">GitKraken</a></span></div></th>
    <th class="rotate"><div><span><a href="https://git-fork.com/">Fork</a></span></div></th>
    <th class="rotate"><div><span><a href="https://www.sourcetreeapp.com/">Sourcetree</a></span></div></th>
    <th class="rotate"><div><span><a href="https://www.sublimemerge.com/">Sublime Merge</a></span></div></th>
    <th class="rotate"><div><span><a href="https://www.syntevo.com/smartgit/">SmartGit</a></span></div></th>
    <th class="rotate"><div><span><a href="https://www.git-tower.com/">Tower</a></span></div></th>
    <th class="rotate"><div><span><a href="https://gitup.co/">GitUp</a></span></div></th>
    <th class="rotate"><div><span><a href="https://www.jetbrains.com/idea/">IntelliJ</a></span></div></th>
    <th class="rotate"><div><span><a href="https://magit.vc/">Magit</a></span></div></th>
    <th class="rotate"><div><span><a href="https://github.com/jesseduffield/lazygit">Lazygit</a></span></div></th>
    <th class="rotate"><div><span><a href="https://github.com/extrawurst/gitui">Gitui</a></span></div></th>
    <th class="rotate"><div><span><a href="https://github.com/arxanas/git-branchless">git-branchless</a></span></div></th>
    <th class="rotate"><div><span><a href="https://github.com/martinvonz/jj">Jujutsu</a></span></div></th>
  </tr>
</thead>

<tbody>
  <tr>
    <th><code>reword</code></th>
    <td>❌&nbsp;<sup>1</sup></td> <!-- Git CLI -->
    <td>❌</td> <!-- GitKraken -->
    <td>❌</td> <!-- Fork -->
    <td>❌</td> <!-- Sourcetree -->
    <td>⚠️&nbsp;<sup>2</sup></td> <!-- Sublime Merge -->
    <td>❌</td> <!-- SmartGit -->
    <td>⚠️&nbsp;<sup>2</sup></td> <!-- Tower -->
    <td>✅</td> <!-- GitUp -->
    <td>⚠️&nbsp;<sup>2</sup></td> <!-- IntelliJ -->
    <td>❌</td> <!-- Magit -->
    <td>❌</td> <!-- Lazygit -->
    <td>❌</td> <!-- Gitui -->
    <td>✅</td> <!-- git-branchless -->
    <td>✅</td> <!-- jj -->
  </tr>
  
  <tr>
    <th><code>sync</code></th>
    <td>❌</td> <!-- Git CLI -->
    <td>❌</td> <!-- GitKraken -->
    <td>❌</td> <!-- Fork -->
    <td>❌</td> <!-- Sourcetree -->
    <td>❌</td> <!-- Sublime Merge -->
    <td>❌</td> <!-- SmartGit -->
    <td>❌</td> <!-- Tower -->
    <td>❌</td> <!-- GitUp -->
    <td>❌</td> <!-- IntelliJ -->
    <td>❌</td> <!-- Magit -->
    <td>❌</td> <!-- Lazygit -->
    <td>❌</td> <!-- Gitui -->
    <td>✅</td> <!-- git-branchless -->
    <td>❌</td> <!-- jj -->
  </tr>
  
  <tr>
    <th><code>split</code></th>
    <td>❌&nbsp;<sup>1</sup></td> <!-- Git CLI -->
    <td>❌</td> <!-- GitKraken -->
    <td>❌</td> <!-- Fork -->
    <td>❌</td> <!-- Sourcetree -->
    <td>❌</td> <!-- Sublime Merge -->
    <td>❌</td> <!-- SmartGit -->
    <td>❌</td> <!-- Tower -->
    <td>✅</td> <!-- GitUp -->
    <td>❌</td> <!-- IntelliJ -->
    <td>❌</td> <!-- Magit -->
    <td>❌</td> <!-- Lazygit -->
    <td>❌</td> <!-- Gitui -->
    <td>❌</td> <!-- git-branchless -->
    <td>✅</td> <!-- jj -->
  </tr>
  
  <tr>
    <th><code>preview</code></th>
    <td>❌</td> <!-- Git CLI -->
    <td>❌</td> <!-- GitKraken -->
    <td>⚠️&nbsp;<sup>3</sup></td> <!-- Fork -->
    <td>❌</td> <!-- Sourcetree -->
    <td>⚠️&nbsp;<sup>3</sup></td> <!-- Sublime Merge -->
    <td>❌</td> <!-- SmartGit -->
    <td>⚠️&nbsp;<sup>3</sup></td> <!-- Tower -->
    <td>❌</td> <!-- GitUp -->
    <td>❌</td> <!-- IntelliJ -->
    <td>✅&nbsp;<sup>4</sup></td> <!-- Magit -->
    <td>❌</td> <!-- Lazygit -->
    <td>❌</td> <!-- Gitui -->
    <td>⚠️&nbsp;<sup>5</sup></td> <!-- git-branchless -->
    <td>✅&nbsp;<sup>6</sup></td> <!-- jj -->
  </tr>

  <tr>
    <th><code>undo</code></th>
    <td>❌</td> <!-- Git CLI -->
    <td>✅</td> <!-- GitKraken -->
    <td>❓</td> <!-- Fork -->
    <td>✅</td> <!-- Sourcetree -->
    <td>✅</td> <!-- Sublime Merge -->
    <td>❌</td> <!-- SmartGit -->
    <td>✅</td> <!-- Tower -->
    <td>✅</td> <!-- GitUp -->
    <td>❌</td> <!-- IntelliJ -->
    <td>❌</td> <!-- Magit -->
    <td>⚠️&nbsp;<sup>7</sup></td> <!-- Lazygit -->
    <td>❌</td> <!-- Gitui -->
    <td>✅</td> <!-- git-branchless -->
    <td>✅</td> <!-- jj -->
  </tr>

  <tr>
    <th><code>large-load</code></th>
    <td>✅&nbsp;<sup>8</sup></td> <!-- Git CLI -->
    <td>❌</td> <!-- GitKraken -->
    <td>❌</td> <!-- Fork -->
    <td>❌</td> <!-- Sourcetree -->
    <td>✅</td> <!-- Sublime Merge -->
    <td>❌</td> <!-- SmartGit -->
    <td>❌</td> <!-- Tower -->
    <td>❌</td> <!-- GitUp -->
    <td>✅</td> <!-- IntelliJ -->
    <td>✅&nbsp;<sup>9</sup></td> <!-- Magit -->
    <td>✅</td> <!-- Lazygit -->
    <td>✅</td> <!-- Gitui -->
    <td>✅</td> <!-- git-branchless -->
    <td>❌</td> <!-- jj -->
  </tr>
  
  <tr>
    <th><code>large-ops</code></th>
    <td>✅&nbsp;<sup>8</sup></td> <!-- Git CLI -->
    <td>❌</td> <!-- GitKraken -->
    <td>❌</td> <!-- Fork -->
    <td>✅</td> <!-- Sourcetree -->
    <td>✅</td> <!-- Sublime Merge -->
    <td>❌</td> <!-- SmartGit -->
    <td>❌</td> <!-- Tower -->
    <td>✅</td> <!-- GitUp -->
    <td>✅</td> <!-- IntelliJ -->
    <td>✅&nbsp;<sup>9</sup></td> <!-- Magit -->
    <td>✅</td> <!-- Lazygit -->
    <td>✅</td> <!-- Gitui -->
    <td>✅</td> <!-- git-branchless -->
    <td>❌</td> <!-- jj -->
  </tr>
</tbody>
</table>

Uwagi:



* <sup>1</sup> Można to zrobić za pomocą `git rebase -i` lub odpowiednika, ale nie jest to ergonomiczne i działa tylko w przypadku zatwierdzeń osiągalnych z `HEAD`, a nie z innych gałęzi.
* <sup>2</sup> Zmiana komunikatu zatwierdzenia można wykonać bez wypożyczaniu zatwierdzenia, ale tylko na zatwierdzeń osiągalnych z `HEAD`. Może istnieją dodatkowe ograniczenia.
* <sup>3</sup> Częściowe wsparcie. Może pokazać, czy można przewijać scalanie do przodu, ale bez dodatkowych szczegołów.
* <sup>4</sup> Można to robić za pomocą `magit-merge-preview`.
* <sup>5</sup> Częściowe wsparcie. Jeśli operacja spowoduje konflikt scalania, i opcja `--merge` nie została przekazana, zamiast tego zostanie przerwana i pokaże liczbę plików w stanu konfliktu.
* <sup>6</sup> Jujutsu nie pozwala na podgląd konfliktów scalania, ale scalanie i rebase zawsze się udają, a konflikty są przechowywane w zatwierdzeniu, a potem możesz cofnąć operację, jeśli nie chcesz zajmować się konfliktami scalania. W razie potrzeby możesz nawet przywrócić starą wersję zatwierdzenia po przeprowadzeniu scalania/zmiany bazy. Pozwala to uniknąć przerywania przepływu pracy, co jest ostatecznym celem tej funkcji, dlatego oceniam, że wystarczy dla tej kategorii.
* <sup>7</sup> Obsługa cofania jest eksperymentalna i zależy na reflogu, który [nie może cofnąć wszystkich rodzajów operacji](https://github.com/arxanas/git-branchless/wiki/Architecture#comparison-with-the-reflog).
* <sup>8</sup> Git ma problemy z niektórymi operacjami na dużych repozytoriach i można je ulepszyć, ale uznamy to za podstawową wydajność dla dużych repozytoriów.
* <sup>9</sup> Chyba Magit ma taką samą wydajność jak Git, ale nie sprawdziłem, bo nie używam Emacs’a.


## Wyróżnienia

Pochwały:



* GitUp: najbardziej innowacyjny GUI dla Git’a spośród powyższych.
* GitKraken: wprowadza innowację w niektórych obszarach, takie jak ulepszona obsługa scentralizowanych przepływów pracy przez ostrzeganie o współbieżnie edytowanych plikach. Te obszary nie są napisane powyżej; Po prostu zauważyłem je przy innych okazjach.
* Sublime Merge: niesamowicie responsywny, jak można się spodziewać po ludziach odpowiedzialnych za [Sublime Text](https://www.sublimetext.com/).
* Tower: za przyjemną implementację cofania.

Wady:



* Fork: za utrudnienie wyszukiwania dokumentacji (bo “git fork undo” zazwyczaj produkuje wyniki cofania rozwidlenia w ogóle, a nie dla klienta Fork).
* SmartGit: z braki we wszystkich testowanych kategoriach.

{% include end_matter.md %}
