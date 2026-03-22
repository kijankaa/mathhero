---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
inputDocuments:
  - '_bmad-output/game-brief.md'
documentCounts:
  briefs: 1
  research: 0
  brainstorming: 0
  projectDocs: 0
workflowType: 'gdd'
lastStep: 0
project_name: 'Math Game'
user_name: 'Jarek'
date: '2026-03-21'
game_type: 'puzzle'
game_name: 'MathHero'
---

# MathHero - Game Design Document

**Author:** Jarek
**Game Type:** Puzzle (Educational Math Trainer)
**Target Platform(s):** iPad Air 2 (iPadOS) — Godot 4 HTML5 → PWA via Safari

---

## Executive Summary

### Core Concept

MathHero to edukacyjna gra matematyczna na iPada, osadzona w kosmicznym świecie, w której dziecko w wieku 9-18 lat rozwiązuje zadania arytmetyczne jako astronauta-bohater podróżujący przez galaktykę. Każda poprawna odpowiedź przybliża bohatera do odkrycia nowych planet i zdobycia tytułu MathHero.

Sercem projektu jest głęboka konfigurowalność — rodzic lub dziecko precyzyjnie definiuje każdy aspekt sesji: typy działań matematycznych, zakres liczb, czas odpowiedzi, liczbę pytań, tryb wpisywania odpowiedzi i zachowanie przy błędzie. System modułowy umożliwia rozbudowę o nowe typy zadań w kolejnych fazach projektu.

### Game Type

**Typ:** Puzzle (Educational Math Trainer)
**Framework:** Puzzle z elementami progression i reward system
**Kluczowe mechaniki:** Proceduralne generowanie zadań, konfiguracja sesji, system nagród, lokalne profile użytkowników

### Target Audience

Dziecko w wieku 9-18 lat (klasa 3 — liceum), ćwiczenia domowe na iPadzie Air 2. Min. 2 lokalne profile bez konta online.

### Unique Selling Points (USPs)

1. Pełna konfigurowalność każdego parametru sesji
2. Zero rozpraszaczy — czysta matematyka w angażującej kosmicznej oprawie
3. Architektura modułowa — rozszerzalna o nowe typy zadań
4. Profile lokalne — wiele dzieci, jedno urządzenie, bez internetu
5. Skalowalność wiekowa — ta sama aplikacja od klasy 3 do matury

---

## Target Platform(s)

### Primary Platform

iPad Air 2 (iPadOS) — ekran 9.7", rozdzielczość 2048x1536px, procesor A8X, 2GB RAM, obsługa Metal.

**Technologia:** Godot 4.x → eksport HTML5 → PWA instalowana via Safari (Dodaj do ekranu głównego)

**Hosting:** GitHub Pages (darmowy)

### Platform Considerations

- Tryb offline — wszystkie dane lokalnie (localStorage)
- Brak App Store — dystrybucja jako PWA
- Godot HTML5 + Safari: audio wymaga pierwszej interakcji użytkownika
- localStorage limit ~5MB — wystarczający dla profili i postępów
- Orientacja: pozioma (landscape) — optymalna dla UI matematycznego

### Control Scheme

- Dotyk (touch) — podstawowy sposób interakcji
- Wirtualna klawiatura numeryczna on-screen (własna, nie systemowa)
- Duże przyciski (min. 44x44pt) zgodne z wytycznymi Apple HIG
- Brak fizycznej klawiatury, brak myszki

---

## Target Audience

### Demographics

**Główny użytkownik:** Dziecko w wieku 9-18 lat (klasa 3 — liceum)
**Konfigurujący:** Dziecko lub rodzic
**Liczba profili:** Min. 2 lokalne profile na urządzeniu

### Gaming Experience

Casual — dziecko przyzwyczajone do dotykowych aplikacji na iPadzie, bez doświadczenia z grami PC/konsolowymi.

### Genre Familiarity

Brak — MathHero nie wymaga znajomości konwencji gatunkowych. UI musi być w pełni intuicyjny i samoobjaśniający się.

### Session Length

Konfigurowalna — od krótkich (5 min) do długich (30+ min) sesji, definiowanych przez liczbę pytań lub limit czasowy.

### Player Motivations

- Poczucie progresu i bycia "bohaterem"
- Rywalizacja z własnymi rekordami
- Odblokowanie nagród i elementów kosmicznego świata
- Ćwiczenie matematyki bez presji szkolnej

---

## Goals and Context

### Project Goals

1. **Edukacyjny:** Stworzyć narzędzie które realnie pomaga dziecku ćwiczyć matematykę i osiągać lepsze wyniki w szkole.
2. **Techniczny:** Zbudować działającą aplikację w Godot 4 z eksportem HTML5 działającym natywnie na iPad Air 2 via PWA.
3. **Osobisty:** Nauczyć się Godot i GDScript przez realizację konkretnego, użytecznego projektu.
4. **Produktowy:** Stworzyć aplikację której dziecko używa regularnie (min. 3x/tydzień) i samo o nią prosi.

### Background and Rationale

MathHero powstaje z prostej obserwacji: dostępne aplikacje matematyczne albo są zbyt ogólne i rozpraszające (Prodigy, Khan Academy), albo wymagają konta online i płatności. Żadna nie daje rodzicowi pełnej kontroli nad tym CO dziecko ćwiczy i w JAKI SPOSÓB — przy jednoczesnym zachowaniu motywującej, gamifikowanej formy.

Projekt jest odpowiedzią na konkretną, osobistą potrzebę — narzędzie dla własnego dziecka, dopasowane do jego aktualnego etapu nauki, bez kompromisów narzucanych przez model biznesowy komercyjnych aplikacji.

---

## Unique Selling Points (USPs)

1. **Głęboka konfigurowalność** — zakres liczb, typy działań, czas odpowiedzi, liczba pytań, tryb odpowiedzi, zachowanie przy błędzie, system punktacji — wszystko definiowalne przez użytkownika.
2. **Zero rozpraszaczy** — brak fabuły, reklam, modelu freemium, powiadomień, konta online. Czysta matematyka w angażującej kosmicznej oprawie.
3. **Architektura modułowa** — 5 typów działań w Fazie 1, rozszerzalne do 12+ bez przebudowy aplikacji.
4. **Profile lokalne offline** — min. 2 dzieci na jednym urządzeniu, bez internetu, bez konta.
5. **Skalowalność wiekowa** — ta sama aplikacja działa od klasy 3 do matury dzięki precyzyjnej konfiguracji.

### Competitive Positioning

MathHero nie konkuruje z App Store — to prywatne narzędzie edukacyjne przewyższające dostępne aplikacje w jednym wymiarze: precyzji dopasowania do konkretnego dziecka.

---

## Core Gameplay

### Game Pillars

1. **Konfigurowalność** — każdy parametr sesji jest w rękach użytkownika. Żadna decyzja projektowa nie może tego ograniczać.
2. **Dopasowanie** — poziom trudności zawsze adekwatny do umiejętności. Ani za łatwo, ani za trudno.
3. **Motywacja** — każda poprawna odpowiedź jest nagrodzona. System nagród utrzymuje zaangażowanie przez całą sesję.
4. **Prostota obsługi** — dziecko uruchamia sesję samodzielnie. UI jest czytelny bez instrukcji.

**Priorytet filarów:** Konfigurowalność > Dopasowanie > Motywacja > Prostota obsługi

### Core Gameplay Loop

Gracz konfiguruje sesję → Widzi zadanie matematyczne → Wpisuje/wybiera odpowiedź → Otrzymuje natychmiastowy feedback → Zbiera punkty/traci serię → Widzi następne zadanie → Po ostatnim pytaniu: ekran podsumowania → Motywacja do kolejnej sesji.

```
[KONFIGURUJ SESJĘ]
        ↓
  [ZADANIE MATEMATYCZNE]
        ↓
[ODPOWIEDŹ GRACZA]
    ↙         ↘
[POPRAWNA]   [BŁĘDNA]
    ↓              ↓
[+punkty]    [config: pokaż wynik / 2. szansa / -punkty / koniec]
    ↓              ↓
[NASTĘPNE ZADANIE lub KONIEC SESJI]
        ↓
[PODSUMOWANIE + NAGRODY]
        ↓
[MOTYWACJA DO POWROTU]
```

**Czas jednego cyklu:** 5-30 sekund (zależnie od trudności i skonfigurowanego limitu czasu)

**Zmienność iteracji:** Losowo generowane liczby, różne typy działań w jednej sesji (konfigurowalne), powracające błędne odpowiedzi jako powtórki.

### Win/Loss Conditions

#### Victory Conditions

- **Ukończenie sesji** — gracz odpowiedział na wszystkie skonfigurowane pytania (zawsze osiągalne)
- **Wynik doskonały** — 100% poprawnych odpowiedzi w sesji
- **Rekord osobisty** — pobicie własnego najlepszego wyniku
- **Seria** — X poprawnych odpowiedzi z rzędu bez błędu

#### Failure Conditions

Konfigurowalne — użytkownik wybiera zachowanie przy błędzie:

| Tryb | Zachowanie |
|---|---|
| **Łagodny** | Błąd = pokaż prawidłową odpowiedź, kontynuuj |
| **Standardowy** | Błąd = utrata serii, -punkty, kontynuuj |
| **Druga szansa** | Błąd = możliwość drugiej próby, potem kontynuuj |
| **Surowy** | X błędów = koniec sesji (X konfigurowalne) |

#### Failure Recovery

Sesja zawsze może być ukończona (poza trybem Surowym). Błąd nigdy nie blokuje progresu — maksymalnie resetuje serię lub odejmuje punkty. Dziecko zawsze widzi podsumowanie i może spróbować ponownie.

---

## Game Mechanics

### Primary Mechanics

**1. ROZWIĄZYWANIE ZADAŃ** (główna mechanika, ~80% czasu sesji)
- Gracz widzi zadanie matematyczne i musi podać wynik
- Tryb odpowiedzi (konfigurowalny): klawiatura numeryczna on-screen LUB multiple choice (4 opcje)
- Testuje: wiedzę matematyczną, szybkość myślenia
- Feel: natychmiastowy, responsywny, bez opóźnień

**2. KONFIGURACJA SESJI** (przed każdą sesją)
- Użytkownik definiuje wszystkie parametry sesji
- Parametry: typ działań, zakres liczb, liczba pytań, limit czasu na odpowiedź, tryb odpowiedzi, zachowanie przy błędzie, składniki punktacji, tryb powtórek
- Dostęp: ekran konfiguracji przed startem sesji
- Możliwość zapisania presetów konfiguracji

**3. ZBIERANIE PUNKTÓW** (przez całą sesję)
- W pełni konfigurowalny system punktacji:
  - Punkty bazowe za poprawną odpowiedź (on/off)
  - Bonus czasowy — im szybciej, tym więcej (on/off)
  - Mnożnik serii — seria poprawnych = x2, x3... (on/off)
  - Kara za błąd — odejmowanie punktów (on/off)
- Wynik widoczny na bieżąco podczas sesji

**4. SYSTEM POWTÓREK** (konfigurowalny)
- Błędne odpowiedzi wracają w tej samej sesji (liczba powtórek konfigurowalna: 0, 1, 2, aż do poprawnej)
- Priorytetyzacja słabszych obszarów w kolejnych sesjach

**5. ODBLOKOWANIE NAGRÓD** (po sesji)
- Punkty przeliczane na "gwiazdki kosmiczne" / walutę nagród
- Odblokowanie: elementy stroju bohatera, nowe planety w galaktyce postępów, odznaki osiągnięć

**6. ŚLEDZENIE POSTĘPÓW** (ekran statystyk)
- Historia sesji: wyniki, czas, procent poprawnych
- Rekordy osobiste per typ działania
- Galaktyka postępów — wizualna mapa odkrytych "planet"

### Mechanic Interactions

- Bonus czasowy + mnożnik serii = wysoka nagroda za szybką i bezbłędną grę
- System powtórek + kara za błąd = motywacja do skupienia przy drugiej szansie
- Konfiguracja trudności ↔ system nagród — trudniejsza sesja = więcej punktów bazowych

### Mechanic Progression

- Faza 1: 5 typów działań — każdy jako osobny moduł
- Fazy 2-5: nowe moduły działań dodawane plug-in
- Brak "levelingu" mechanik — konfiguracja zastępuje progresję unlock

---

## Controls and Input

### Control Scheme (iPad Air 2 — Touch)

| Akcja | Kontrolka |
|---|---|
| Wpisanie cyfry odpowiedzi | Dotyk wirtualnej klawiatury numerycznej |
| Wybór opcji (multiple choice) | Dotyk dużego przycisku odpowiedzi |
| Skasowanie cyfry | Przycisk backspace na klawiaturze |
| Zatwierdzenie odpowiedzi | Przycisk "OK" / "Zatwierdź" |
| Nawigacja po menu | Dotyk przycisków nawigacyjnych |
| Wybór profilu | Dotyk avatara/nazwy profilu |
| Konfiguracja sesji | Suwaki, przełączniki, pola liczbowe |

### Input Feel

- Zero opóźnień — odpowiedź wizualna natychmiast po dotyku
- Duże strefy dotyku (min. 60x60pt dla cyfr klawiatury)
- Haptic feedback przy poprawnej/błędnej odpowiedzi (jeśli obsługiwane przez PWA/Safari)
- Brak "fat finger" problemów — przyciski z marginesem

### Accessibility Controls

- Rozmiar czcionki: duży (czytelny dla 9-latka)
- Wysoki kontrast kolorów (tekst na tle)
- Brak wymagania precyzyjnych gestów (tylko tap)
- Orientacja: wyłącznie landscape (zablokowana)

---

## Puzzle Specific Design

### Core Puzzle Mechanics

**Format zadania (konfigurowalny):**
- Poziomy: `12 × 7 = ?`
- Kolumnowy (jak w zeszycie szkolnym)
- Użytkownik wybiera preferowany format w ustawieniach

**Struktura zadania:**
- Jeden składnik "?" — zawsze wynik działania (Faza 1)
- Zakres liczb wspólny dla obu składników działania
- Zakres konfigurowalny osobno per typ działania
- Liczby generowane losowo w zdefiniowanym zakresie

**Typy zadań — Faza 1:**
- Dodawanie: `a + b = ?`
- Odejmowanie: `a - b = ?`
- Mnożenie: `a × b = ?`
- Dzielenie: `a ÷ b = ?` (wyniki całkowite)
- Kolejność działań: `a + b × c = ?` (z nawiasami opcjonalnie)

**Constraint system:**
- Dzielenie: zawsze generuje wyniki całkowite
- Odejmowanie: wynik zawsze ≥ 0 (chyba że użytkownik włączy liczby ujemne — opcja zaawansowana)
- Zakres: min 1, max 9999 (per składnik)

### Puzzle Progression

**Automatyczna sugestia trudności:**
- Po ukończeniu sesji aplikacja analizuje wyniki
- Jeśli wynik ≥ 80% poprawnych → sugestia: "Spróbuj trudniejszego zakresu!"
- Jeśli wynik ≤ 40% poprawnych → sugestia: "Może łatwiejszy zakres na następną sesję?"
- Sugestia wyświetlana na ekranie podsumowania — użytkownik może ją zaakceptować lub zignorować

**Ręczna zmiana trudności:**
- Pełna kontrola nad konfiguracją przed każdą sesją
- Użytkownik zawsze może zmienić dowolny parametr

### Level Structure

**Warstwa 1 — Presety systemowe:**
Gotowe konfiguracje jednym kliknięciem:
- "Dodawanie — Starter" (1-10, 10 pytań, bez limitu czasu)
- "Mnożenie — Klasa 3" (1-10, 20 pytań, 30s limit)
- "Mieszane — Zaawansowane" (1-100, 30 pytań, 15s limit)
- itd. — kilkanaście presetów pokrywających typowe potrzeby

**Warstwa 2 — Własne presety:**
- Użytkownik konfiguruje sesję i może ją zapisać jako preset
- Nadaje własną nazwę (np. "Mój trening czwartkowy")
- Presety per profil użytkownika
- Edycja i usuwanie własnych presetów

**Warstwa 3 — Galaktyka Misji:**
Opcjonalna ścieżka nagradzana:
- Każda "planeta" = predefiniowana misja z wymaganiami (np. "Zdobądź 90% w mnożeniu 1-10, 20 pytań")
- Ukończenie misji → odblokowanie planety w galaktyce
- Planety ułożone wg rosnącej trudności
- Galaktyka rozbudowywana w kolejnych fazach projektu
- Wolna konfiguracja zawsze dostępna niezależnie od galaktyki

### Player Assistance

**Feedback przy błędzie (konfigurowalny):**
- Natychmiastowe pokazanie prawidłowej odpowiedzi
- Podświetlenie błędnej odpowiedzi na czerwono
- Animacja "shake" przy błędzie

**Pauza sesji:**
- Przycisk pauzy zawsze dostępny podczas sesji
- Ekran pauzy ukrywa zadanie (zapobiega "ściąganiu")
- Timer zatrzymany podczas pauzy

**Porzucenie sesji:**
- Możliwość wyjścia z sesji w dowolnym momencie
- Pytanie potwierdzające: "Czy na pewno chcesz zakończyć?"
- Częściowe wyniki zapisywane do statystyk
- Brak kary — postępy w galaktyce misji nie cofają się

**Brak systemu "żyć":**
- Sesja zawsze może być ukończona
- Błąd = feedback + kontynuacja (poza trybem Surowym)

### Replayability

**Codzienne Wyzwanie:**
- Predefiniowana sesja generowana każdego dnia
- Identyczna dla wszystkich profili na urządzeniu
- Specjalna odznaka za ukończenie wyzwania dnia
- Historia ukończonych wyzwań w statystykach

**Tryb "Pobij Rekord":**
- Szybki dostęp do ostatnio używanej konfiguracji
- Wyświetla aktualny rekord do pobicia
- Motywuje do powtarzania tej samej konfiguracji

**Losowe Misje:**
- Po ukończeniu sesji: losowa "misja bonusowa" (np. "Zrób 5 poprawnych odpowiedzi pod rząd!")
- Małe bonusy punktowe za wykonanie misji
- Nowa misja co sesję

---

## Progression and Balance

### Player Progression

MathHero łączy trzy typy progresji:
- **Skill** — gracz realnie poprawia swoje umiejętności matematyczne przez regularne ćwiczenia
- **Content** — nowe planety w galaktyce, presety misji i tryby odblokowywane przez ukończenie sesji
- **Collection** — elementy kostiumu bohatera, odznaki, tytuły zbierane przez całą grę

#### Progression Types

**Meta-progresja (między sesjami):**
- Gwiazdki kosmiczne zbierane per sesja
- Poziomy bohatera: Rekrut → Kosmonauta → Pilot → Kapitan → MathHero → Legenda Galaktyki
- Odblokowane planety w Galaktyce Misji
- Kolekcja elementów kostiumu i odznak

**Progresja w sesji:**
- Narastająca seria poprawnych odpowiedzi
- Mnożnik punktów rosnący z serią (jeśli włączony)
- Pasek postępu sesji (X/N pytań)

#### Progression Pacing

- Pierwsze nagrody odblokowane po 1-3 sesjach (szybka gratyfikacja dla nowego gracza)
- Poziom bohatera rośnie wolniej — motywacja długoterminowa
- Legenda Galaktyki = cel na wiele miesięcy regularnej gry

### Difficulty Curve

**Typ krzywej: Player-controlled (z sugestią)**

Trudność w MathHero jest w pełni kontrolowana przez użytkownika — aplikacja nie narzuca progresji. System sugestii (≥80% → trudniej, ≤40% → łatwiej) pełni rolę miękkiego przewodnika.

#### Challenge Scaling

Parametry skalowania trudności (od łatwego do trudnego):

| Parametr | Łatwy | Średni | Trudny |
|---|---|---|---|
| Zakres liczb | 1-10 | 1-50 | 1-100+ |
| Limit czasu | brak | 30s | 10s |
| Typy działań | 1 | 2-3 | 4-5 mieszane |
| Punkty za błąd | brak kary | -punkty | koniec sesji |
| Powtórki błędów | 0 | 1 | do poprawnej |

#### Difficulty Options

- Pełna konfiguracja przed każdą sesją
- Presety systemowe jako punkty startowe
- Sugestia automatyczna po sesji (akceptowalna/ignorowalna)
- Brak "Game Over" w trybach Łagodnym i Standardowym

### Economy and Resources

**Gwiazdki Kosmiczne** — główna waluta progresji

#### Resources

| Zasób | Źródło | Zastosowanie |
|---|---|---|
| Gwiazdki Kosmiczne | Za każdą sesję (ilość zależna od wyniku) | Sklep nagród + auto-odblokowania |
| Punkty Sesji | Za poprawne odpowiedzi w sesji | Ranking, rekordy, misje |
| Odznaki | Za osiągnięcia (np. "100 sesji", "seria 20") | Kolekcja, prestiż |

#### Economy Flow

**Automatyczne odblokowania** (za osiągnięcia):
- Odznaki — za konkretne milestony (bez wydawania gwiazdek)
- Tytuły bohatera — za poziomy (Rekrut → Legenda)
- Planety misji — za ukończenie wymagań misji

**Sklep Nagród** (za gwiazdki kosmiczne):
- Elementy kostiumu bohatera: hełm, skafander, plecak rakietowy, buty, rękawice
- Kolory i wzory każdego elementu
- Tła i efekty ekranu sesji
- Gracz sam wybiera kolejność odblokowywania

**Balans ekonomii:**
- Gwiazdki nie "psują się" — brak presji czasowej
- Brak możliwości utraty gwiazdek
- Każda sesja nagradza — nawet słaby wynik = kilka gwiazdek

---

## Level Design Framework

### Structure Type

**Puzzle Sets + Procedural (Endless)**

MathHero nie ma tradycyjnych poziomów przestrzennych. Treść to nieskończenie generowane zadania matematyczne zorganizowane w:
- Sesje (konfigurowane przez użytkownika)
- Misje w Galaktyce (predefiniowane wyzwania)
- Presety (zapisane zestawy konfiguracji)

### Level Types

**Typ 1 — Sesja Wolna**
Użytkownik konfiguruje wszystko samodzielnie.
Czas trwania: 5-60 min (zależnie od liczby pytań).
Dostępna zawsze, bez ograniczeń.

**Typ 2 — Misja Galaktyczna**
Predefiniowane wymagania (typ działania, zakres, minimalny wynik). Czas: zazwyczaj 10-20 min.
Odblokowanie kolejnych misji po zaliczeniu.

**Typ 3 — Preset**
Zapisana konfiguracja sesji wolnej.
Uruchamiana jednym kliknięciem.

**Typ 4 — Codzienne Wyzwanie**
Specjalna sesja generowana każdego dnia.
Czas: ~10 min (stała liczba pytań).

#### Tutorial Integration

Brak osobnego tutorialu — podejście "ucz przez grę":
- Przy pierwszym uruchomieniu: krótki onboarding (3-4 ekrany pokazujące UI)
- Pierwszy preset systemowy to "Starter — Dodawanie 1-10" (najłatwiejszy możliwy)
- Interfejs konfiguracji z tooltipami przy każdym parametrze

#### Special Levels

**Codzienne Wyzwanie** — specjalna sesja z odznaką za ukończenie.
**Misje Bossów Galaktycznych** — co kilka planet: trudna misja z wyjątkową nagrodą (planowane w Fazie 2+).

### Level Progression

**Model: Open Selection + Score/Star Unlock**

- Sesje Wolne: zawsze dostępne, bez unlock
- Presety systemowe: wszystkie dostępne od startu
- Galaktyka Misji: linearna — ukończenie misji N odblokowuje misję N+1
- Codzienne Wyzwanie: dostępne codziennie automatycznie

#### Unlock System

- Misje galaktyczne: ukończenie z wymaganym wynikiem
- Sklep kostiumu: za gwiazdki kosmiczne
- Odznaki: za milestony (automatyczne)
- Nowe typy działań: dodawane w kolejnych fazach projektu

#### Replayability

- Każda sesja jest odtwarzalna dowolną liczbę razy
- Misje galaktyczne można powtarzać dla lepszego wyniku
- Codzienne Wyzwanie resetuje się każdego dnia
- Tryb "Pobij Rekord" — ta sama konfiguracja, lepszy wynik

### Level Design Principles

- **Natychmiastowy start** — od ekranu głównego do pierwszego zadania w max 3 kliknięciach
- **Zawsze wróć** — z każdego ekranu można wrócić do poprzedniego bez utraty danych
- **Postęp widoczny zawsze** — pasek postępu sesji i wynik zawsze na ekranie podczas sesji
- **Żadnego ślepego zaułka** — sesja zawsze ma koniec, nigdy nie "utkniesz"

---

## Art and Audio Direction

### Art Style

**AI-Generated 2D — styl kosmiczny, przyjazny dzieciom**

Assety generowane narzędziami AI (Midjourney / DALL-E / Stable Diffusion), ręcznie selekcjonowane i dopasowywane dla spójności stylistycznej. Styl: kolorowy, energetyczny, przystępny — nie realistyczny, nie pikselowy.

#### Visual References

- Prodigy Math Game — przyjazny dzieciom UI edukacyjny
- Khan Academy Kids — czyste, kolorowe elementy interfejsu
- Midjourney prompt direction: "flat vector space game UI, child-friendly, colorful astronaut hero, vibrant, 2D"

#### Color Palette

- **Tło:** Głęboki granat / czerń kosmosu (#0A0A2E, #1A1A4E)
- **Akcenty:** Złoto (#FFD700), Cyan (#00E5FF), Fiolet (#9B59B6)
- **Poprawna odpowiedź:** Zielony (#2ECC71)
- **Błędna odpowiedź:** Czerwony (#E74C3C)
- **UI / tekst:** Biały (#FFFFFF) na ciemnym tle
- Wysoki kontrast — czytelność priorytetem

#### Camera and Perspective

- **2D, widok frontalny** — płaski interfejs
- Brak perspektywy 3D, brak parallax scrollingu
- UI pełnoekranowy, landscape (9.7" iPad)
- Bohater widoczny jako postać 2D w prawym dolnym lub górnym rogu ekranu sesji

### Audio and Music

#### Music Style

**Ambient kosmiczny** — spokojne syntezatory, przestrzenne brzmienie, subtelny rytm elektroniczny. Muzyka nie dominuje — jest tłem sprzyjającym skupieniu.

Źródło: darmowe utwory CC0 (FreeMusicArchive, OpenGameArt.org) w stylu ambient/space elektronika.

#### Sound Design

| Zdarzenie | Dźwięk |
|---|---|
| Poprawna odpowiedź | Krótka, radosna fanfara (2-3 nuty) |
| Błędna odpowiedź | Krótki sygnał negatywny (1 nuta) |
| Seria bezbłędna | Narastający efekt "combo" |
| Ukończenie sesji | Triumfalna fanfara (3-4 sekundy) |
| Odblokowanie nagrody | Efekt "gwiezdny" / sparkle |
| Kliknięcie UI | Subtelny klik / pop |
| Odliczanie timera | Tykanie przyspieszające przy <5s |

Źródło: darmowe efekty CC0 (Freesound.org, Kenney.nl)

#### Voice/Dialogue

Brak voice actingu. Ewentualnie krótkie "wykrzyknienia" tekstowe (np. "Świetnie!", "Super!", "Spróbuj jeszcze raz!") jako animowany tekst.

### Aesthetic Goals

- **Konfigurowalność** → Czysty, przejrzysty UI bez zbędnych dekoracji — każdy element ma funkcję
- **Motywacja** → Kolorowe nagrody, efekty cząsteczkowe i fanfary wzmacniają pozytywny feedback
- **Prostota obsługi** → Duże elementy, wysoki kontrast, natychmiastowa czytelność dla 9-latka i 18-latka
- **Dopasowanie** → Kosmiczny klimat skaluje się wizualnie wraz z progresją (więcej planet, bogatszy kostium)

---

## Technical Specifications

### Performance Requirements

Aplikacja edukacyjna z prostym 2D UI — wymagania wydajnościowe są niskie, iPad Air 2 obsługuje je z zapasem.

#### Frame Rate Target

**60 fps** — płynne animacje feedbacku i efektów nagród.
Minimum akceptowalne: 30 fps (UI matematyczny nie wymaga więcej).

#### Resolution Support

- **Natywna:** 2048x1536px (iPad Air 2 Retina)
- **Docelowa orientacja:** Landscape (pozioma), zablokowana
- Godot HTML5 skaluje automatycznie do rozdzielczości ekranu

#### Load Times

- Czas startu aplikacji (PWA): < 3 sekundy (po pierwszym załadowaniu)
- Pierwsze uruchomienie (download PWA): < 10 sekund (Wi-Fi)
- Przejście między ekranami: natychmiastowe (< 0.5s)

### Platform-Specific Details

#### iPad Air 2 (iPadOS / Safari PWA) Requirements

- **iOS minimum:** iPadOS 14+ (Safari z pełnym PWA support)
- **Orientacja:** Landscape wymuszona (CSS + Godot)
- **Offline:** Wymagane — Service Worker cachuje wszystkie assety
- **localStorage:** Używany do zapisu profili i postępów (~1-2MB)
- **Audio:** Wymaga interakcji użytkownika przed pierwszym odtworzeniem (Safari autoplay policy) — rozwiązane przez ekran splash/start
- **Brak IAP:** Żadnych płatności w aplikacji
- **Brak konta:** Zero integracji z Apple ID / Game Center
- **Hosting:** GitHub Pages (HTTPS wymagane dla PWA/Service Worker)

### Asset Requirements

#### Art Assets

| Kategoria | Szacowana ilość | Źródło |
|---|---|---|
| Tło kosmiczne (ekrany) | 5-8 wariantów | AI-generated |
| Postać bohatera (astronauta) | 1 base + 20+ elementów kostiumu | AI-generated |
| Ikony działań matematycznych | 5 (Faza 1) | AI-generated / vector |
| Planety galaktyki | 20-30 | AI-generated |
| Odznaki osiągnięć | 15-20 | AI-generated / vector |
| Efekty cząsteczkowe (gwiazdy) | 3-5 animacji | Godot particles |
| UI elementy (przyciski, ramki) | ~30 elementów | AI-generated / vector |

#### Audio Assets

| Kategoria | Szacowana ilość | Źródło |
|---|---|---|
| Muzyka ambientowa | 2-3 utwory (loop) | CC0 (OpenGameArt) |
| Efekty dźwiękowe | 8-12 dźwięków | CC0 (Freesound, Kenney) |

#### External Assets

- Czcionka: darmowa, czytelna, bez-szeryfowa (np. Nunito, Fredoka One)
- Wszystkie assety: licencja CC0 lub AI-generated (brak roszczeń autorskich)
- Brak asset store (budżet zero)

### Technical Constraints

- **Silnik:** Godot 4.x (GDScript) → HTML5 export
- **Przechowywanie danych:** localStorage (offline, bez backendu)
- **Generowanie zadań:** Proceduralne, w runtime (bez bazy zadań)
- **Rozmiar buildu:** Cel < 30MB (ograniczenie PWA cache)
- **Brak serwera:** Statyczny hosting (GitHub Pages)
- **Brak analytics:** Zero trackingu danych użytkownika

---

## Development Epics

### Epic Overview

| # | Epic | Zakres | Zależności | Stories |
|---|---|---|---|---|
| 1 | Fundament Techniczny | Godot, HTML5, PWA, localStorage | — | ~6 |
| 2 | Vertical Slice (MVP Core) | Generator zadań, ekran sesji, feedback | Epic 1 | ~8 |
| 3 | Pełna Konfiguracja Sesji | Panel config, presety, profile | Epic 2 | ~10 |
| 4 | Wszystkie Działania Fazy 1 | Odejmowanie, mnożenie, dzielenie, kolejność | Epic 3 | ~7 |
| 5 | Progresja i Nagrody | Gwiazdki, poziomy bohatera, sklep, odznaki | Epic 4 | ~9 |
| 6 | Galaktyka Misji | Mapa, misje, odblokowania, codzienne wyzwanie | Epic 5 | ~8 |
| 7 | Statystyki i Historia | Postępy, historia, rekordy, sugestie | Epic 4 | ~6 |
| 8 | Polish i UX | Animacje, dźwięki, onboarding, wizualia | Epic 7 | ~8 |

### Recommended Sequence

1 → 2 → 3 → 4 → 5 → 7 → 6 → 8

- Epic 1 jako fundament nieblokujący
- Epic 2 jako najszybszy dowód działania (vertical slice)
- Epic 3-4 buduje pełną Fazę 1
- Epic 5+7 równolegle po Epic 4
- Epic 6 po systemie nagród (Epic 5)
- Epic 8 (polish) zawsze na końcu

### Vertical Slice

**Pierwsza grywalna wersja po Epic 2:**
Dodawanie liczb 1-100, 10 pytań, klawiatura numeryczna, natychmiastowy feedback poprawna/błędna, podstawowe punkty. Działające na iPadzie Air 2 via Safari PWA.

---

## Success Metrics

### Technical Metrics

#### Key Technical KPIs

| Metryka | Cel | Metoda pomiaru |
|---|---|---|
| Frame rate | ≥ 60 fps | Godot debugger podczas testów |
| Czas startu PWA | < 3 sekundy | Ręczny pomiar na iPadzie |
| Rozmiar buildu | < 30 MB | Godot export stats |
| Działanie offline | 100% funkcji | Ręczny test (tryb samolotowy) |
| localStorage zapis/odczyt | 0 błędów | Testy manualne |
| Audio na Safari | Brak autoplay błędów | Test na iPadzie |

### Gameplay Metrics

#### Key Gameplay KPIs

| Metryka | Cel | Metoda pomiaru |
|---|---|---|
| Regularność użycia | Min. 3x/tydzień | Obserwacja rodzica |
| Sesje z własnej inicjatywy | Dziecko prosi samo | Obserwacja rodzica |
| Ukończenie sesji | > 90% rozpoczętych | Historia w aplikacji |
| Postęp wyników | Rosnący % poprawnych | Ekran statystyk |
| Retencja tygodniowa | Aktywne użycie po miesiącu | Obserwacja |

### Qualitative Success Criteria

- Dziecko samo prosi o sesję (nie tylko na polecenie)
- Dziecko nie rezygnuje z sesji w połowie
- Dziecko pokazuje aplikację i swoje wyniki z dumą
- Rodzic widzi realny postęp w wynikach szkolnych
- Konfiguracja jest intuicyjna — dziecko radzi sobie samodzielnie
- Aplikacja nie wywołuje frustracji ani płaczu

### Metric Review Cadence

Projekt prywatny — brak automatycznego zbierania danych. Przegląd co 2-4 tygodnie przez obserwację i rozmowę z dzieckiem. Ekran statystyk w aplikacji jako główne źródło danych.

---

## Out of Scope

Poniższe elementy są celowo **poza zakresem MathHero v1.0 (Faza 1)**. Nie są odrzucone — są odłożone na późniejsze fazy lub wersje.

### Poza zakresem v1.0

**Funkcje:**
- Tryb multiplayer / współzawodnictwo online
- Globalny ranking / tabele wyników
- Porównanie postępów między profilami
- Więcej niż 2 profile użytkowników
- Eksport danych / raportowanie dla rodziców (poza ekranem statystyk)
- Synchronizacja danych z chmurą / konto online
- Powiadomienia push / przypomnienia

**Platforma:**
- Android (nie planowany)
- iOS natywny (wymaga Mac + Xcode — poza możliwościami technicznymi)
- Wersja desktopowa jako oddzielna aplikacja
- Konsole i urządzenia TV

**Produkcja:**
- Voice-over / nagrania lektora
- Orkiestralna ścieżka muzyczna (tylko ambient loop)
- Pełna lokalizacja na inne języki niż polski

### Deferred to Post-Launch

| Wersja | Funkcja | Opis |
|---|---|---|
| Faza 2 | Ułamki i liczby dziesiętne | Po ukończeniu i przetestowaniu Fazy 1 |
| Faza 2 | Procenty | Po ukończeniu i przetestowaniu Fazy 1 |
| Faza 2 | Potęgowanie i pierwiastkowanie | Po ukończeniu i przetestowaniu Fazy 1 |
| Faza 3 | Równania i wyrażenia algebraiczne | Starsze dzieci / liceum |
| Faza 3 | Geometria (pola, obwody) | Wymaga nowego formatu zadań |
| Faza 4 | Przeliczanie jednostek | Wymaga nowego formatu zadań |
| Faza 4 | Skale i stężenia roztworów | Wymaga nowego formatu zadań |
| Faza 5 | Rozszerzenia do ustalenia | Na podstawie potrzeb i postępów |
| v2.0 | Więcej niż 2 profile użytkowników | Jeśli pojawi się potrzeba |
| v2.0 | Misje Bossów Galaktycznych | Rozszerzenie Epic 6 |
| v2.0 | Multiplayer / ranking rodzinny | Jeśli pojawi się potrzeba |

---

## Assumptions and Dependencies

### Key Assumptions

**Techniczne:**
- Godot 4.x pozostanie stabilny przez cały czas rozwoju projektu
- Safari na iPadOS 14+ obsługuje PWA (Service Worker, manifest) i Web Audio API
- localStorage (~5MB limit) wystarczy dla 2 profili i historii sesji
- GitHub Pages zapewni stabilny, darmowy hosting z HTTPS przez cały czas trwania projektu
- Godot HTML5 export działa poprawnie na procesorze A8X (iPad Air 2)

**Zespołu:**
- Projekt rozwijany solo z pomocą AI (bez dedykowanego zespołu)
- Godot to nowa technologia dla dewelopera — krzywa nauki wliczona w harmonogram
- Grafika generowana przez AI (brak potrzeby zatrudnienia grafika)
- Muzyka ambient — jeden gotowy loop na licencji free/CC (brak kompozytora)

**Użytkowania:**
- Aplikacja używana wyłącznie prywatnie (rodzic + dziecko) — brak potrzeby certyfikacji App Store
- Brak budżetu na zewnętrzne usługi płatne / backend
- iPad Air 2 pozostaje głównym urządzeniem przez cały czas Fazy 1

### External Dependencies

| Zależność | Typ | Ryzyko | Alternatywa |
|---|---|---|---|
| Godot 4.x | Silnik (open source) | Niskie | — |
| GitHub Pages | Hosting (darmowy) | Niskie | Netlify, Vercel |
| Safari PWA support | Platforma | Średnie | Brak — wymagane |
| Narzędzie AI do grafiki | Produkcja | Niskie | Inne narzędzie AI |
| Muzyka ambient (CC/free) | Treść | Niskie | Inne źródło free |
| Web Audio API | Technologia | Średnie | Degradacja graceful |

### Risk Factors

| Ryzyko | Prawdopodobieństwo | Wpływ | Mitygacja |
|---|---|---|---|
| Safari zmieni obsługę PWA | Niskie | Wysokie | Monitorowanie iOS release notes |
| localStorage overflow | Niskie | Średnie | Rotacja historii (maks. 100 sesji) |
| Godot HTML5 wolny na iPad Air 2 | Średnie | Wysokie | Profiling na urządzeniu w Epic 1 |
| Audio autoplay policy Safari | Wysokie | Średnie | Ekran splash wymuszający interakcję |
| Krzywa nauki Godot | Wysokie | Średnie | Epic 1 jako fundament techniczny |

---

## Document Information

**Dokument:** MathHero — Game Design Document
**Wersja:** 1.0
**Data:** 2026-03-21
**Autor:** Jarek
**Status:** Kompletny

### Change Log

| Wersja | Data | Zmiany |
|---|---|---|
| 1.0 | 2026-03-21 | Inicjalny GDD — kompletny (kroki 1-14) |
