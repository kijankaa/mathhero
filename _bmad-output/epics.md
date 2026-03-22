# MathHero — Development Epics

**Projekt:** MathHero
**Data:** 2026-03-21
**Platforma:** iPad Air 2 → Godot 4 HTML5 → PWA

---

## Epic Overview

| # | Epic | Zależności | Est. Stories |
|---|---|---|---|
| 1 | Fundament Techniczny | — | ~6 |
| 2 | Vertical Slice (MVP Core) | Epic 1 | ~8 |
| 3 | Pełna Konfiguracja Sesji | Epic 2 | ~10 |
| 4 | Wszystkie Działania Fazy 1 | Epic 3 | ~7 |
| 5 | Progresja i Nagrody | Epic 4 | ~9 |
| 6 | Galaktyka Misji | Epic 5 | ~8 |
| 7 | Statystyki i Historia | Epic 4 | ~6 |
| 8 | Polish i UX | Epic 7 | ~8 |

**Kolejność realizacji:** 1 → 2 → 3 → 4 → 5 → 7 → 6 → 8

---

## Epic 1: Fundament Techniczny

### Goal
Zbudować działającą strukturę projektu Godot 4 z eksportem HTML5, skonfigurować PWA na iPadzie Air 2 i zweryfikować cały pipeline techniczny przed budową gameplay'u.

### Scope

**Includes:**
- Projekt Godot 4.x — struktura folderów, sceny bazowe
- Eksport HTML5 — konfiguracja export templates
- PWA setup — manifest.json, Service Worker, ikony
- GitHub Pages — hosting i HTTPS
- localStorage wrapper — API do zapisu/odczytu danych
- Orientacja landscape — wymuszenie w CSS i Godot
- Test na iPad Air 2 — potwierdzenie działania audio, dotyku, PWA

**Excludes:**
- Jakikolwiek gameplay
- UI aplikacji
- Assety graficzne i dźwiękowe

### Dependencies
Brak — punkt startowy projektu.

### Deliverable
Działająca aplikacja PWA na iPadzie Air 2 wyświetlająca prostą scenę testową z dźwiękiem i zapisem do localStorage.

### Stories
- Jako developer, mogę uruchomić projekt Godot 4 i zobaczyć podstawową scenę
- Jako developer, mogę wyeksportować projekt jako HTML5 i uruchomić go lokalnie
- Jako developer, mogę zainstalować aplikację jako PWA na iPadzie Air 2
- Jako developer, aplikacja działa offline po pierwszym załadowaniu
- Jako developer, mogę zapisać i odczytać dane z localStorage
- Jako developer, aplikacja uruchamia się w trybie landscape z dźwiękiem

---

## Epic 2: Vertical Slice (MVP Core)

### Goal
Zbudować kompletną, grywalną pętlę dla jednego typu działania (dodawanie) — od ekranu startowego przez sesję do podsumowania.

### Scope

**Includes:**
- Ekran główny (prosty — 1 przycisk "Graj")
- Generator zadań: dodawanie, zakres 1-100
- Ekran sesji: wyświetlanie zadania, licznik pytań, wynik
- Wirtualna klawiatura numeryczna on-screen
- Przycisk backspace i zatwierdzenia
- Feedback: poprawna (zielony) / błędna (czerwony) odpowiedź
- Pokazanie prawidłowej odpowiedzi przy błędzie
- Licznik punktów (podstawowy: 1 pkt za poprawną)
- Ekran podsumowania: wynik, punkty, przycisk "Zagraj ponownie"
- Hardcoded: 10 pytań, bez limitu czasu

**Excludes:**
- Konfiguracja (hardcoded wartości)
- Profile użytkowników
- System nagród
- Dźwięki i animacje
- Inne działania matematyczne

### Dependencies
Epic 1 — działający projekt i PWA.

### Deliverable
Grywalna sesja dodawania na iPadzie: 10 pytań, klawiatura, feedback, podsumowanie. Pierwszy "vertical slice" projektu.

### Stories
- Jako gracz, widzę ekran główny z przyciskiem "Graj"
- Jako gracz, widzę zadanie dodawania w formacie `a + b = ?`
- Jako gracz, mogę wpisać odpowiedź używając klawiatury numerycznej on-screen
- Jako gracz, widzę natychmiastowy feedback czy odpowiedź jest poprawna
- Jako gracz, przy błędnej odpowiedzi widzę prawidłowy wynik
- Jako gracz, widzę swój aktualny wynik i postęp sesji (X/10)
- Jako gracz, po 10 pytaniach widzę ekran podsumowania z wynikiem
- Jako gracz, mogę rozpocząć nową sesję z ekranu podsumowania

---

## Epic 3: Pełna Konfiguracja Sesji

### Goal
Zastąpić hardcoded wartości w pełni konfigurowalnym panelem ustawień, dodać profile użytkowników i system presetów.

### Scope

**Includes:**
- Panel konfiguracji przed sesją (wszystkie parametry)
- Parametry: typ działań, zakres liczb, liczba pytań, limit czasu, tryb odpowiedzi (klawiatura/multiple choice), zachowanie przy błędzie, składniki punktacji, liczba powtórek błędów
- Tryb multiple choice (4 opcje odpowiedzi)
- System presetów: presety systemowe (~5 gotowych) + zapis własnych presetów
- Profile użytkowników: min. 2 profile, ekran wyboru profilu, nazwa + avatar
- Zapis konfiguracji per profil w localStorage
- Walidacja parametrów (zakres min/max, sensowne wartości)
- Format zadania: poziomy / kolumnowy (do wyboru)

**Excludes:**
- Inne działania (tylko dodawanie z Epic 2)
- System nagród i progresji
- Galaktyka misji

### Dependencies
Epic 2 — działający gameplay core.

### Deliverable
Użytkownik może wybrać profil, skonfigurować sesję dowolnymi parametrami, zapisać preset i uruchomić sesję z konfiguracją.

### Stories
- Jako gracz, mogę wybrać profil użytkownika na ekranie głównym
- Jako gracz, mogę stworzyć profil z nazwą i avatarem
- Jako gracz, widzę panel konfiguracji przed każdą sesją
- Jako gracz, mogę ustawić zakres liczb (min/max)
- Jako gracz, mogę ustawić liczbę pytań (5-100)
- Jako gracz, mogę włączyć/wyłączyć limit czasowy i ustawić jego wartość
- Jako gracz, mogę wybrać tryb odpowiedzi (klawiatura lub multiple choice)
- Jako gracz, mogę ustawić zachowanie przy błędzie (4 tryby)
- Jako gracz, mogę skonfigurować składniki systemu punktacji
- Jako gracz, mogę wybrać preset systemowy jednym kliknięciem
- Jako gracz, mogę zapisać swoją konfigurację jako preset z własną nazwą

---

## Epic 4: Wszystkie Działania Fazy 1

### Goal
Rozszerzyć aplikację o pozostałe 4 typy działań matematycznych Fazy 1, implementując architekturę modułową.

### Scope

**Includes:**
- Architektura plug-in dla modułów działań
- Odejmowanie: `a - b = ?` (wynik ≥ 0)
- Mnożenie: `a × b = ?`
- Dzielenie: `a ÷ b = ?` (wyniki całkowite)
- Kolejność działań: `a + b × c = ?` (z opcjonalnymi nawiasami)
- Mieszane sesje: losowe działania z wybranych typów
- Konfiguracja per typ działania (zakres liczb)
- Constraint system (dzielenie całkowite, odejmowanie ≥ 0)

**Excludes:**
- Działania Fazy 2+ (ułamki, procenty, potęgowanie, pierwiastki)
- System nagród (Epic 5)

### Dependencies
Epic 3 — pełna konfiguracja sesji.

### Deliverable
Kompletna Faza 1: użytkownik może ćwiczyć wszystkie 5 typów działań z pełną konfiguracją. MVP jest funkcjonalnie kompletny.

### Stories
- Jako developer, system generowania zadań jest modułowy (plug-in)
- Jako gracz, mogę ćwiczyć odejmowanie
- Jako gracz, mogę ćwiczyć mnożenie
- Jako gracz, mogę ćwiczyć dzielenie (zawsze wynik całkowity)
- Jako gracz, mogę ćwiczyć kolejność działań (z/bez nawiasów)
- Jako gracz, mogę wybrać mieszaną sesję z kilku typów działań
- Jako gracz, mogę ustawić zakres liczb osobno dla każdego typu działania

---

## Epic 5: Progresja i Nagrody

### Goal
Zbudować kompletny system motywacyjny: gwiazdki kosmiczne, poziomy bohatera, sklep kostiumu i odznaki osiągnięć.

### Scope

**Includes:**
- Gwiazdki kosmiczne — przyznawanie po sesji (wg wyniku)
- 6 poziomów bohatera: Rekrut → Kosmonauta → Pilot → Kapitan → MathHero → Legenda Galaktyki
- Bohater astronauta na ekranie — widoczny z aktualnym kostiumem
- Sklep nagród: elementy kostiumu (hełm, skafander, plecak, buty, rękawice) + kolory
- Automatyczne odznaki za milestony (np. "Pierwsza sesja", "Seria 10", "100 sesji")
- Ekran kolekcji (odznaki + kostium)
- Efekt odblokowania nagrody (animacja + dźwięk)
- Zapis stanu progresji per profil w localStorage

**Excludes:**
- Galaktyka misji (Epic 6)
- Statystyki historyczne (Epic 7)

### Dependencies
Epic 4 — kompletna Faza 1.

### Deliverable
Po każdej sesji gracz widzi nagrody, może wydawać gwiazdki w sklepie i obserwuje wzrost poziomu bohatera.

### Stories
- Jako gracz, po ukończeniu sesji widzę ile gwiazdek zarobiłem
- Jako gracz, mój bohater ma widoczny poziom i tytuł
- Jako gracz, mogę wejść do sklepu i zobaczyć dostępne elementy kostiumu
- Jako gracz, mogę kupić element kostiumu za gwiazdki
- Jako gracz, mogę ubrać swojego bohatera w zakupione elementy
- Jako gracz, zdobywam odznaki za osiągnięcia automatycznie
- Jako gracz, widzę animację odblokowania gdy zdobywam nagrodę
- Jako gracz, mój kostium i gwiazdki są zapisane między sesjami
- Jako gracz, widzę kolekcję moich odznak i kostiumu

---

## Epic 6: Galaktyka Misji

### Goal
Dodać opcjonalną ścieżkę nagradzaną: mapę galaktyki z predefiniowanymi misjami, codzienne wyzwanie i tryb "Pobij Rekord".

### Scope

**Includes:**
- Ekran Galaktyki — wizualna mapa planet
- System misji: predefiniowane wymagania per planeta
- Odblokowanie planet sekwencyjne (misja N → planeta N+1)
- Codzienne Wyzwanie — automatyczna sesja dnia z odznaką
- Tryb "Pobij Rekord" — szybki dostęp do ostatniej konfiguracji + rekord do pobicia
- Losowe misje bonusowe po sesji
- Zapis postępów galaktyki per profil

**Excludes:**
- Misje Bossów Galaktycznych (Faza 2+)

### Dependencies
Epic 5 — system nagród (galaktyka nagradza gwiazdkami).

### Deliverable
Gracz ma opcjonalną ścieżkę misji z wizualną mapą galaktyki, codzienne wyzwanie i tryb rywalizacji z własnym rekordem.

### Stories
- Jako gracz, widzę mapę galaktyki z planetami
- Jako gracz, mogę zobaczyć wymagania każdej misji
- Jako gracz, ukończenie misji odblokowuje kolejną planetę
- Jako gracz, codziennie dostępne jest wyzwanie dnia z odznaką
- Jako gracz, mogę szybko uruchomić ostatnią sesję w trybie "Pobij Rekord"
- Jako gracz, po sesji widzę losową misję bonusową
- Jako gracz, moje postępy w galaktyce są zapisane

---

## Epic 7: Statystyki i Historia

### Goal
Dodać ekran postępów z historią sesji, rekordami osobistymi i automatycznymi sugestiami trudności.

### Scope

**Includes:**
- Ekran statystyk per profil
- Historia sesji: data, typ działań, wynik %, punkty, czas
- Rekordy osobiste per typ działania
- Wykresy / wizualizacja postępów (opcjonalnie uproszczone)
- Automatyczna sugestia trudności (≥80% → trudniej, ≤40% → łatwiej)
- Sugestia wyświetlana na ekranie podsumowania

**Excludes:**
- Porównanie między profilami (prywatność)

### Dependencies
Epic 4 — kompletna Faza 1 (potrzebne dane z różnych typów działań).

### Deliverable
Gracz i rodzic mogą przeglądać historię i postępy, a aplikacja sugeruje odpowiedni poziom trudności.

### Stories
- Jako gracz, widzę historię swoich ostatnich sesji
- Jako gracz, widzę swoje rekordy per typ działania
- Jako gracz, na ekranie podsumowania widzę sugestię trudności
- Jako gracz, mogę zaakceptować sugestię i jest ona aplikowana do konfiguracji
- Jako rodzic, mogę sprawdzić postępy dziecka w ekranie statystyk

---

## Epic 8: Polish i UX

### Goal
Dopracować całą aplikację wizualnie i dźwiękowo: animacje, efekty, onboarding i kosmiczny styl.

### Scope

**Includes:**
- Pełna biblioteka dźwięków (poprawna/błędna/seria/fanfara/kliknięcia)
- Muzyka ambientowa kosmiczna (loop)
- Efekty cząsteczkowe (gwiazdy przy poprawnej, iskry przy serii)
- Animacje UI: przejścia między ekranami, animacje przycisków
- Animacja bohatera (idle, reakcja na poprawną/błędną)
- Onboarding: 3-4 ekrany wprowadzające przy pierwszym uruchomieniu
- Tooltips w panelu konfiguracji
- Dopracowanie kolorystyki i typografii
- Ekran splash/start (rozwiązanie audio autoplay policy Safari)
- Testy końcowe na iPad Air 2

**Excludes:**
- Nowe funkcjonalności gameplay

### Dependencies
Epic 7 — wszystkie funkcje gotowe przed polish.

### Deliverable
MathHero w wersji finalnej Fazy 1 — kompletna, dopracowana aplikacja gotowa do codziennego użytku.

### Stories
- Jako gracz, słyszę dźwięki feedbacku podczas sesji
- Jako gracz, słyszę muzykę ambientową w tle
- Jako gracz, widzę efekty cząsteczkowe przy poprawnych odpowiedziach
- Jako gracz, przejścia między ekranami są płynne
- Jako gracz, mój bohater reaguje animacją na moje odpowiedzi
- Jako nowy gracz, onboarding pokazuje mi jak korzystać z aplikacji
- Jako gracz, każdy parametr konfiguracji ma tooltip z wyjaśnieniem
- Jako developer, aplikacja przechodzi testy końcowe na iPad Air 2
