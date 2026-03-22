---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
inputDocuments: []
documentCounts:
  brainstorming: 0
  research: 0
  notes: 0
workflowType: 'game-brief'
lastStep: 0
project_name: 'Math Game'
user_name: 'Jarek'
date: '2026-03-21'
game_name: 'MathHero'
---

# Game Brief: MathHero

**Date:** 2026-03-21
**Author:** Jarek
**Status:** Draft for GDD Development

---

## Executive Summary

MathHero to platforma ćwiczeń matematycznych z pełną kontrolą ustawień dla rodzica i systemem nagród motywującym dziecko.

**Target Audience:** Jedno dziecko w wieku 9-18 lat (klasa 3 — liceum), ćwiczenia domowe na iPadzie Air 2.

**Core Pillars:** Konfigurowalność > Dopasowanie > Motywacja > Prostota obsługi

**Key Differentiators:** Głęboka konfigurowalność, zero rozpraszaczy, profile lokalne, skalowalność wiekowa, architektura modułowa

**Platform:** iPad Air 2 → Godot 4 HTML5 → PWA via Safari

**Success Vision:** Dziecko regularnie (3x/tydzień) samo prosi o sesję i osiąga realny postęp w matematyce szkolnej.

---

## Game Vision

### Core Concept

Platforma ćwiczeń matematycznych z pełną kontrolą ustawień dla rodzica i systemem nagród motywującym dziecko.

### Elevator Pitch

MathHero to gra edukacyjna na iPada, w której dzieci od klasy 3 rozwiązują zadania matematyczne — dodawanie, odejmowanie, mnożenie, dzielenie i potęgowanie — w angażującym środowisku z nagrodami i animacjami. Rodzic lub nauczyciel ma pełną kontrolę: zakres liczb, poziom trudności, czas na odpowiedź, liczba pytań, typy działań i system punktacji. Dziecko widzi bohatera, który rośnie wraz z postępami — dorosły widzi narzędzie precyzyjnie dopasowane do etapu nauki.

### Vision Statement

MathHero ma sprawić, że ćwiczenie matematyki przestanie być obowiązkiem, a stanie się codziennym rytuałem, na który dziecko czeka — dzięki temu, że poziom wyzwania jest zawsze idealnie dopasowany, a każdy sukces jest świętowany. Dla rodzica i nauczyciela MathHero to pewność, że żadne dziecko nie ćwiczy zbyt łatwo ani nie frustruje się zbyt trudnym materiałem.

---

## Target Market

### Primary Audience

Jedno dziecko — użytkownik od klasy 3 szkoły podstawowej do liceum (wiek 9-18 lat), używające aplikacji do samodzielnych ćwiczeń domowych.

**Demografia:**
Dziecko w wieku szkolnym (9-18 lat), korzystające z iPada w domu.

**Preferencje:**
Użytkownik mobilny przyzwyczajony do dotykowego interfejsu. Poziom zaangażowania zależy od atrakcyjności systemu nagród i dopasowania trudności do aktualnych umiejętności.

**Motywacje:**
Skuteczne ćwiczenie matematyki w angażującej formie; poczucie progresu i bycia "bohaterem".

### Secondary Audience

Brak — projekt prywatny, bez planów dystrybucji.

### Market Context

Projekt użytku prywatnego tworzony na potrzeby konkretnego dziecka. Brak wymagań rynkowych, dystrybucyjnych ani monetyzacyjnych. Głównym miernikiem sukcesu jest regularne używanie aplikacji przez dziecko i realny postęp w nauce matematyki.

**Przewaga nad gotowymi rozwiązaniami:**
Pełna konfigurowalność niedostępna w żadnej aplikacji ze sklepu — precyzyjne dostosowanie do aktualnego etapu nauki konkretnego dziecka.

---

## Game Fundamentals

### Core Gameplay Pillars

1. **Konfigurowalność** — każdy parametr sesji jest kontrolowany przez użytkownika: zakres liczb, typy działań, czas odpowiedzi, liczba pytań, powtórki, nawiasy, system punktacji i tryb odpowiedzi.

2. **Motywacja** — system nagród, odznak i rozwijającej się postaci bohatera utrzymuje zaangażowanie dziecka i nagradza regularność ćwiczeń.

3. **Dopasowanie** — poziomy trudności i precyzyjna konfiguracja zapewniają, że wyzwanie jest zawsze adekwatne do aktualnych umiejętności dziecka.

4. **Prostota obsługi** — dziecko uruchamia i przeprowadza sesję samodzielnie; interfejs jest czytelny i nie wymaga pomocy dorosłego.

**Priorytet filarów:** Gdy filary kolidują — Konfigurowalność > Dopasowanie > Motywacja > Prostota obsługi.

### Primary Mechanics

- **Odpowiada** — wpisuje odpowiedź przez wirtualną klawiaturę numeryczną LUB wybiera z opcji multiple choice (tryb do konfiguracji).
- **Konfiguruje** — ustawia parametry sesji przed startem (zakres liczb, działania, czas, liczba pytań itp.).
- **Zbiera punkty** — za poprawne odpowiedzi, szybkość reakcji i serie bezbłędnych odpowiedzi.
- **Odblokowuje** — nagrody, odznaki i elementy wyglądu postaci bohatera.
- **Śledzi postępy** — przegląda historię wyników, statystyki i rekordy.

**Core Loop:** Konfiguruj sesję → Rozwiązuj zadania → Zbieraj punkty → Odblokowuj nagrody → Śledź postępy → Konfiguruj kolejną sesję.

**Błędna odpowiedź:** zachowanie konfigurowalne — natychmiastowe pokazanie prawidłowej odpowiedzi lub druga szansa (do wyboru przez użytkownika).

### Player Experience Goals

- **Mistrzostwo i wzrost** — dziecko czuje realny postęp i dumę z bycia "MathHero".
- **Przepływ (flow)** — sesja jest wciągająca, poziom wyzwania zawsze optymalny.
- **Rywalizacja z samym sobą** — bicie własnych rekordów jako główna motywacja.
- **Zabawa** — nagrody i animacje wprowadzają element humoru i radości.
- **Spokój** — brak przymusu; timer można wyłączyć, sesja bez stresu gdy potrzeba.

**Emotional Journey:** Start z ciekawością → skupienie podczas sesji → satysfakcja z poprawnych odpowiedzi → duma z odblokowanych nagród → chęć powrotu jutro.

---

## Scope and Constraints

### Target Platforms

**Primary:** iPad Air 2 (iPadOS) — obsługa dotykowa, pełny ekran
**Technologia:** Godot 4.x → eksport HTML5 → PWA via Safari
**Secondary:** Brak

### Development Timeline

Do ustalenia — projekt hobbystyczny bez sztywnego harmonogramu.

### Budget Considerations

Projekt w pełni bezbudżetowy (prywatny użytek):
- Godot 4 — darmowy
- GitHub Pages (hosting) — darmowy
- Assety graficzne i dźwiękowe — darmowe zasoby online lub AI-generated
- Brak kosztów dystrybucji (poza App Store)

### Team Resources

**Zespół:** 1 osoba (Jarek) — sole developer
**Dostępność:** Czas wolny / wieczory
**Doświadczenie:** Podstawy programowania, Godot — nowość

**Skill Gaps:**
- GDScript (język Godot) — do nauczenia się w trakcie projektu
- Godot export pipeline (HTML5/PWA) — do skonfigurowania
- Projektowanie UI dla dzieci — wymaga uwagi

### Technical Constraints

- **Silnik:** Godot 4.x (GDScript)
- **Eksport:** HTML5 → PWA, hostowany na GitHub Pages
- **Urządzenie docelowe:** iPad Air 2 (A8X, 2GB RAM, Metal GPU)
- **Tryb:** Offline — dane zapisane lokalnie na urządzeniu (localStorage)
- **Profile użytkowników:** Minimum 2 lokalne profile dziecka, przełączane z poziomu ekranu głównego
- **Brak backendu:** Żadnego serwera, bazy danych ani konta online
- **Dostępność:** Duże przyciski, czytelna czcionka, wysoki kontrast — wymagane dla młodszych użytkowników

### Scope Realities

- Projekt hobbystyczny — zakres MVP musi być ściśle ograniczony
- Nauka Godot w trakcie rozwoju = wolniejsze tempo na początku
- HTML5 export z Godot może wymagać testowania kompatybilności z Safari/iPadOS
- Dźwięki i grafika z darmowych źródeł mogą wymagać dopasowania stylistycznego

---

## Reference Framework

### Inspiration Games

**Prodigy Math**
- Bierzemy: system rozwijającego się bohatera jako motywacja
- Unikamy: agresywnego modelu premium, rozpraszającej fabuły RPG

**Khan Academy Kids**
- Bierzemy: przyjazny dzieciom UI, czytelne animacje nagradzające
- Unikamy: zbyt szerokiego zakresu tematów, braku kontroli rodzica

**Mathletics**
- Bierzemy: przejrzyste statystyki postępów, rywalizacja z samym sobą
- Unikamy: wymogu konta online, zbyt szkolnego interfejsu

**Quizlet**
- Bierzemy: system powtórek — błędne odpowiedzi wracają w sesji
- Unikamy: ogólności, braku skupienia na matematyce

### Competitive Analysis

**Bezpośrednia konkurencja:** Prodigy, Khan Academy, Mathletics
**Co robią dobrze:** Angażujący UI, system nagród, treści edukacyjne
**Czego im brakuje:** Pełna konfigurowalność parametrów sesji, działanie offline, brak wymogu konta, profile lokalne

### Key Differentiators

1. **Głęboka konfigurowalność** — pełna kontrola nad każdym parametrem sesji niedostępna w żadnej konkurencyjnej aplikacji
2. **Zero rozpraszaczy** — brak fabuły, reklam, modelu premium i konta online — czysta matematyka w angażującej oprawie
3. **Profile lokalne** — wiele dzieci na jednym urządzeniu bez kont i bez internetu
4. **Skalowalność wiekowa** — ta sama aplikacja od klasy 3 do liceum dzięki precyzyjnej konfiguracji trudności

**Unique Value Proposition:**
MathHero to jedyna aplikacja matematyczna, która daje rodzicowi/nauczycielowi pełną kontrolę nad każdym aspektem ćwiczenia — bez konta, bez internetu, bez kompromisów.

---

## Content Framework

### World and Setting

MathHero rozgrywa się w przestrzeni kosmicznej. Gracz wciela się w astronautę-bohatera, który podróżuje przez galaktykę, odkrywa planety i zdobywa tytuły rozwiązując zadania matematyczne. Każdy poziom trudności to nowy obszar kosmosu do odkrycia.

### Narrative Approach

Minimalna — fabuła pełni rolę dekoracyjną, nie rozpraszającą. Kosmos jest tłem i motywacją wizualną, nie historią do śledzenia. Brak dialogów, cutscen ani tekstu fabularnego.

**Story Delivery:** Wizualna — poprzez animacje bohatera, odblokowane planety i elementy kostiumu/statku kosmicznego.

### Content Volume

- 5 typów działań matematycznych na start (dodawanie, odejmowanie, mnożenie, dzielenie, potęgowanie)
- **Architektura modułowa** — system zadań zaprojektowany jako plug-in, umożliwiający dodawanie nowych typów zadań w przyszłości (ułamki, pierwiastki, równania, procenty, geometria itp.) bez przebudowy aplikacji
- Nieskończona liczba zadań (generowane proceduralnie)
- System nagród: odznaki, elementy stroju bohatera, odblokowane "planety" w galaktyce postępów
- Min. 2 profile użytkowników lokalnych

---

## Art and Audio Direction

### Visual Style

AI-generated 2D — styl kosmiczny, kolorowy i przyjazny dzieciom. Assety generowane narzędziami AI (Midjourney / DALL-E / Stable Diffusion), ręcznie dopasowywane dla spójności stylistycznej.

**Paleta kolorów:** Głęboki granat kosmosu + jasne akcenty (złoto, cyan, fiolet) — wysoki kontrast dla czytelności na iPadzie.

**Animacje:** Proste, 2D — poprawna odpowiedź = efekt cząsteczkowy (gwiazdy/iskry), błąd = krótkie potrząśnięcie, nagroda = fanfara z animacją bohatera.

**References:** Midjourney prompt style: "flat vector space game UI, child-friendly, colorful astronaut hero, vibrant"

### Audio Style

- **Muzyka:** Ambientowa kosmiczna w tle podczas sesji (spokojne syntezatory, przestrzenne brzmienie)
- **Efekty dźwiękowe:** Kliknięcia UI, fanfara za poprawną odpowiedź, krótki sygnał błędu, wielka fanfara za ukończenie sesji
- **Voice acting:** Brak

### Production Approach

- Grafika: AI-generated + darmowe zasoby (OpenGameArt.org, Kenney.nl)
- Muzyka: Darmowe utwory z licencją CC0 (np. FreeMusicArchive)
- Efekty dźwiękowe: Darmowe (Freesound.org, Kenney.nl)

---

## Risk Assessment

### Key Risks

1. **[WYSOKI] Kompatybilność HTML5 z Safari/iPadOS** — Godot HTML5 export może mieć problemy z dźwiękiem i localStorage na Safari — wymaga wczesnego testowania.
2. **[WYSOKI] Krzywa uczenia Godot** — Sole developer bez doświadczenia z Godot — ryzyko spowolnienia lub porzucenia projektu.
3. **[ŚREDNI] Spójność stylu AI-generated** — Assety z różnych generacji AI mogą wyglądać niespójnie — wymaga konsekwentnych promptów i ręcznej selekcji.
4. **[NISKI] Zakres funkcji (feature creep)** — Bogata konfigurowalność może prowadzić do rozrostu zakresu MVP poza możliwości projektu hobbystycznego.

### Technical Challenges

- Godot HTML5 → Safari audio autoplay policy (wymaga interakcji użytkownika przed pierwszym dźwiękiem)
- localStorage limit (~5MB) wystarczający dla profili i postępów, ale wymaga monitorowania
- Responsywny UI dostosowany do ekranu iPad Air 2 (9.7", 2048x1536px)

### Market Risks

Brak — projekt prywatny, bez dystrybucji.

### Mitigation Strategies

- Testować HTML5 export na iPadzie od pierwszego dnia projektu
- Zacząć od małego MVP (1 działanie, podstawowy UI) zanim dodamy wszystkie funkcje
- Używać konsekwentnego zestawu promptów AI dla spójności assetów
- Zdefiniować twardy zakres MVP i nie rozszerzać go przed ukończeniem wersji podstawowej

---

## Success Criteria

### MVP Definition

**Faza 1 (MVP):**
- 5 typów działań: dodawanie, odejmowanie, mnożenie, dzielenie, kolejność działań
- 2 profile użytkowników lokalnych
- Pełna konfiguracja sesji: zakres liczb, liczba pytań, czas odpowiedzi, tryb odpowiedzi (klawiatura / multiple choice), zachowanie przy błędzie
- Podstawowy system punktów i seria bezbłędnych odpowiedzi
- Prosty UI kosmiczny z efektami dźwiękowymi
- Działający eksport HTML5 na iPad Air 2

**Faza 2:**
Ułamki, procenty, potęgowanie, pierwiastkowanie

**Faza 3:**
Równania z niewiadomą, geometria, przeliczanie jednostek

**Faza 4:**
Skale, stężenie roztworów

**Faza 5+:**
Otwarta — do zdefiniowania w przyszłości

**Zasada architektoniczna:** System zadań modułowy (plug-in) od pierwszego dnia — każda faza dodaje moduły bez przebudowy aplikacji.

### Success Metrics

- Dziecko używa aplikacji regularnie (min. 3x w tygodniu)
- Dziecko samo prosi o sesję (nie tylko na polecenie rodzica)
- Zauważalny postęp w wynikach szkolnych z matematyki

### Launch Goals

Działająca Faza 1 na iPadzie Air 2, używana przez dziecko w codziennej rutynie domowej.

---

## Next Steps

### Immediate Actions

1. Zainstalować Godot 4.x na PC
2. Stworzyć projekt testowy i przetestować eksport HTML5 na iPadzie Air 2 (walidacja techniczna ryzyka #1)
3. Uruchomić workflow `gds-create-gdd` — stworzenie pełnego Game Design Document
4. Zaprojektować architekturę modułową systemu zadań

### Research Needs

- Kompatybilność Godot 4 HTML5 z Safari na iPadOS
- Dostępne darmowe assety kosmiczne (Kenney.nl, OpenGameArt.org)
- Darmowa muzyka ambientowa kosmiczna (CC0)
- Midjourney prompty dla spójnego stylu kosmicznego

### Open Questions

- Jak wygląda dokładny system odblokowywania nagród (co odblokowuje i kiedy)?
- Czy galaktyka postępów to osobny ekran czy element głównego UI?
- Jak szczegółowe są statystyki postępów (per działanie, per sesja, historycznie)?

---

## Appendices

### A. Research Summary

Brak formalnych dokumentów badawczych — projekt prywatny.

### B. Stakeholder Input

Autor: Jarek. Użytkownik końcowy: dziecko w wieku szkolnym (9-18 lat).

### C. References

- Inspiracje: Prodigy Math, Khan Academy Kids, Mathletics, Quizlet
- Technologia: Godot 4.x, GitHub Pages, Midjourney/DALL-E
- Zasoby: OpenGameArt.org, Kenney.nl, Freesound.org

---

_This Game Brief serves as the foundational input for Game Design Document (GDD) creation._

_Next Steps: Use the `workflow gdd` command to create detailed game design documentation._
