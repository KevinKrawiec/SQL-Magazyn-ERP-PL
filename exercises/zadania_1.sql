-- Zadanie A: Liczenie rekordów
-- Wyświetl listę nazw kategorii oraz informację, ile produktów znajduje się w każdej z nich.
SELECT K.Nazwa AS Kategoria, COUNT(P.Kod_EAN) AS Liczba_Produktow
FROM KATEGORIE AS K
INNER JOIN PRODUKTY AS P ON K.ID_Kategorii = P.ID_Kategorii
GROUP BY K.Nazwa;

-- Zadanie B: Filtrowanie grup
-- Wyświetl nazwy tych dostawców, od których kupujemy więcej niż 3 różne produkty.
SELECT D.Nazwa_Firmy, COUNT(*) AS Produkty
FROM DOSTAWCY AS D
INNER JOIN PRODUKTY AS P
	ON D.NIP = P.NIP_Dostawcy
GROUP BY D.Nazwa_Firmy
HAVING COUNT(*) > 3;

-- Zadanie C: Często proszą Cię o raport zamówień. Zrób sobie skrót!
-- Stwórz widok o nazwie VW_SZCZEGOLY_ZAMOWIEN, który będzie łączył tabele ZAMOWIENIA i PRODUKTY.
-- Widok ma pokazywać: Numer zamówienia, Datę, Nazwę produktu, Ilość sztuk oraz Wartość Całkowitą
CREATE VIEW VW_SZCZEGOLY_ZAMOWIEN AS
SELECT
    Z.Numer_Zamowienia,
    Z.Data_Zlozenia,
    P.Nazwa,
    Z.Ilosc_Sztuk,
    Z.Ilosc_Sztuk * P.Cena_Netto AS Wartosc_calkowita
FROM PRODUKTY AS P
INNER JOIN ZAMOWIENIA AS Z
    ON P.Kod_EAN = Z.Kod_Produktu;

SELECT *
FROM VW_SZCZEGOLY_ZAMOWIEN;

-- Zadanie D: Analiza braków
-- Znajdź wszystkie produkty (nazwy), które nigdy nie zostały zamówione.
SELECT NAZWA
FROM PRODUKTY
WHERE Kod_EAN NOT IN (SELECT Kod_Produktu FROM ZAMOWIENIA);

/*
--------------------------------------------------------------------------------
PROJEKT: System Zarządzania Magazynem
ZADANIE 1: Analityka Wartościowa i Stanów Magazynowych

OPIS BIZNESOWY:
Przygotowanie widoku raportowego dla działu logistyki i zakupów, umożliwiającego
analizę poziomu zatowarowania oraz średnich kosztów netto produktów w podziale 
na kategorie i dostawców. Raport służy do monitorowania kluczowego asortymentu.

WYMAGANIA TECHNICZNE:
1. Obiekt: Stworzenie widoku (VIEW) 'VW_RAPORT_STANOW_I_DOSTAWCOW'.
2. Integracja: Połączenie danych z 4 tabel: PRODUKTY, KATEGORIE, DOSTAWCY, STANY_MAGAZYNOWE.
3. Filtrowanie: Uwzględnienie jedynie produktów o cenie netto powyżej 20 PLN.
4. Agregacja:
   - Grupowanie po nazwie kategorii oraz nazwie firmy dostawcy.
   - Obliczenie łącznego stanu magazynowego (SUM).
   - Wyznaczenie średniej ceny jednostkowej netto (AVG).
5. Prezentacja: Wyniki przygotowane do sortowania według ilości dostępnych sztuk.
--------------------------------------------------------------------------------
*/
CREATE VIEW VW_RAPORT_STANOW_I_DOSTAWCOW AS 
SELECT
    K.Nazwa AS Kategoria,
    D.Nazwa_Firmy AS Dostawca,
    SUM(S.Ilosc_Dostepna) AS Ilosc_Sztuk,
    AVG(P.Cena_Netto) AS Srednia_Cena
FROM PRODUKTY AS P
INNER JOIN KATEGORIE AS K
    ON P.ID_Kategorii = K.ID_Kategorii
INNER JOIN DOSTAWCY AS D
    ON P.NIP_Dostawcy = D.NIP
INNER JOIN STANY_MAGAZYNOWE AS S
    ON P.Kod_EAN = S.Kod_Produktu
WHERE P.Cena_Netto > 20
GROUP BY K.Nazwa, D.Nazwa_Firmy;

SELECT *
FROM VW_RAPORT_STANOW_I_DOSTAWCOW
ORDER BY Ilosc_Sztuk DESC;

/*
--------------------------------------------------------------------------------
PROJEKT: System Zarządzania Magazynem
ZADANIE 2: Segmentacja Zamówień i Analiza Wartościowa Sprzedaży

OPIS BIZNESOWY:
Przygotowanie raportu dla działu handlowego, który pozwoli na ocenę wielkości 
zamówień oraz ich wartości. Raport ma segmentować zamówienia na 'Hurtowe' 
i 'Detaliczne' oraz oceniać ich status finansowy, co pozwoli na lepsze 
zarządzanie priorytetami wysyłek.

WYMAGANIA TECHNICZNE:
1. Obiekt: Stworzenie widoku (VIEW) 'VW_ANALIZA_ZAMOWIEN'.
2. Integracja: Połączenie tabel ZAMOWIENIA, PRODUKTY i KATEGORIE.
3. Logika CASE:
   - Kolumna 'Typ_Zamowienia': Jeśli Ilosc_Sztuk > 10 to 'HURT', w przeciwnym razie 'DETAL'.
   - Kolumna 'Klasa_Cenowa': Jeśli Cena_Netto > 1000 to 'PREMIUM', w przeciwnym razie 'STANDARD'.
4. Agregacja: Sumowanie wartości netto zamówienia (Ilosc_Sztuk * Cena_Netto).
5. Filtrowanie: Uwzględnienie tylko zamówień o statusie innym niż 'Anulowane'.
6. Porządkowanie: Wyniki posortowane od najdroższych zamówień.
--------------------------------------------------------------------------------
*/
CREATE VIEW VW_ANALIZA_ZAMOWIEN AS
SELECT
    Z.Numer_Zamowienia,
    K.ID_Kategorii,
    CASE
        WHEN Z.Ilosc_Sztuk > 10 THEN 'HURT'
        ELSE 'DETAL'
    END AS Typ_Zamowienia,
    CASE
        WHEN P.Cena_Netto > 1000 THEN 'PREMIUM'
        ELSE 'STANDARD'
    END AS Klasa_Cenowa,
    Z.Ilosc_Sztuk * P.Cena_Netto AS Wartosc
FROM ZAMOWIENIA AS Z
INNER JOIN PRODUKTY AS P
    ON Z.Kod_Produktu = P.Kod_EAN
INNER JOIN KATEGORIE AS K
    ON P.ID_Kategorii = K.ID_Kategorii
WHERE Z.Status_Realizacji <> 'Anulowane';

SELECT *
FROM VW_ANALIZA_ZAMOWIEN
ORDER BY Wartosc DESC;
