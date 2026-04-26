# SQL-Magazyn-ERP-PL
# Mini-System Magazynowy (ERP Lite)

## O projekcie
Projekt ten to funkcjonalna baza danych SQL stworzona do celów edukacyjnych i treningowych. 

**Kluczowe informacje:**
* **Geneza:** Projekt bazuje na strukturze bazy danych "SZKOŁA", którą tworzyłem podczas studiów. Została ona przeorientowana na system typu ERP Lite (zarządzanie magazynem).
* **Dane:** Rekordy i dane testowe zostały wygenerowane przy użyciu AI, co pozwoliło na stworzenie bogatego zbioru danych do testowania zapytań (ponad 50 rekordów, powtarzające się kategorie, marki i miasta).
* **Język:** Całość projektu (nazewnictwo tabel, kolumn oraz opis) jest w języku polskim ze względu na lokalne zastosowanie.

## Struktura bazy danych
Baza składa się z następujących tabel:
* `KATEGORIE` – grupy produktów.
* `DOSTAWCY` – informacje o firmach dostarczających towar.
* `PRODUKTY` – katalog towarów z przypisanymi cenami i kodami EAN.
* `STANY_MAGAZYNOWE` – informacja o ilościach i fizycznej lokalizacji towaru (regały).
* `ZAMOWIENIA` – historia operacji magazynowych i sprzedaży.

## Cel nauki
Baza została zaprojektowana tak, aby umożliwić ćwiczenie:
* Zaawansowanych złączeń (`JOIN`).
* Agregacji i grupowania danych (`GROUP BY`, `HAVING`).
* Filtrowania tekstowego (`LIKE`, `BETWEEN`).
* Tworzenia raportów sprzedażowych i logistycznych.
