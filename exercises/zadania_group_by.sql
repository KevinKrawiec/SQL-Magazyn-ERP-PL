/*
--------------------------------------------------------------------------------
ZADANIE A: Liczebność asortymentu w kategoriach
WYMAGANIA: GROUP BY, COUNT
OPIS: Prosta analiza ilościowa bazy produktów w podziale na identyfikatory kategorii.
--------------------------------------------------------------------------------
*/
SELECT
	ID_Kategorii,
	COUNT(*) AS Ilosc_Produktów
FROM PRODUKTY
GROUP BY ID_Kategorii;

/*
--------------------------------------------------------------------------------
ZADANIE B: Sumaryczne obciążenie lokalizacji magazynowych
WYMAGANIA: GROUP BY, SUM
OPIS: Obliczenie łącznej liczby sztuk towaru składowanego na poszczególnych regałach.
--------------------------------------------------------------------------------
*/
SELECT
	Lokalizacja_Regal,
	SUM(Ilosc_Dostepna) AS Suma
FROM STANY_MAGAZYNOWE
GROUP BY Lokalizacja_Regal;

/*
--------------------------------------------------------------------------------
ZADANIE C: Zagęszczenie sieci dostawców
WYMAGANIA: GROUP BY, COUNT
OPIS: Zestawienie liczby partnerów handlowych w podziale na miasta siedziby.
--------------------------------------------------------------------------------
*/
SELECT Miasto, COUNT(*)
FROM DOSTAWCY
GROUP BY Miasto;

/*
--------------------------------------------------------------------------------
ZADANIE D: Średnia wartość netto w kategoriach
WYMAGANIA: GROUP BY, AVG
OPIS: Analiza średniego poziomu cenowego produktów wewnątrz poszczególnych kategorii.
--------------------------------------------------------------------------------
*/
SELECT
	ID_Kategorii,
	AVG(Cena_Netto) AS Średnia_Cena_Netto
FROM PRODUKTY
GROUP BY ID_Kategorii;

/*
--------------------------------------------------------------------------------
ZADANIE E: Rozpiętość cenowa u dostawców
WYMAGANIA: GROUP BY, MIN, MAX
OPIS: Wyznaczenie ekstremów cenowych (najtańszy/najdroższy produkt) dla każdego dostawcy.
--------------------------------------------------------------------------------
*/
SELECT
	NIP_Dostawcy,
	MIN(Cena_Netto) AS Najniższa_Cena_Netto,
	MAX(Cena_Netto) AS Najwyższa_Cena_Netto
FROM PRODUKTY
GROUP BY NIP_Dostawcy;

/*
--------------------------------------------------------------------------------
ZADANIE F: Ranking popularności produktów
WYMAGANIA: GROUP BY, COUNT, ORDER BY
OPIS: Identyfikacja najczęściej zamawianych pozycji asortymentowych na podstawie liczby zleceń.
--------------------------------------------------------------------------------
*/
SELECT
	Kod_Produktu,
	COUNT(*) AS Liczba_Wystąpień
FROM ZAMOWIENIA
GROUP BY Kod_Produktu
ORDER BY 2 DESC;

/*
--------------------------------------------------------------------------------
ZADANIE G: Identyfikacja kluczowych ośrodków logistycznych
WYMAGANIA: GROUP BY, HAVING, COUNT
OPIS: Wyfiltrowanie miast, w których firma posiada więcej niż jednego dostawcę.
--------------------------------------------------------------------------------
*/
SELECT Miasto, COUNT(*)
FROM DOSTAWCY
GROUP BY Miasto
HAVING COUNT(*) > 1;

/*
--------------------------------------------------------------------------------
ZADANIE H: Precyzyjna analiza cenowa kategorii
WYMAGANIA: INNER JOIN, GROUP BY, ROUND, AVG
OPIS: Raport średnich cen z czytelnym nazewnictwem kategorii, zaokrąglony do 2 miejsc po przecinku.
--------------------------------------------------------------------------------
*/
SELECT
	K.Nazwa AS Kategoria,
	ROUND(AVG(P.Cena_Netto), 2) AS Średnia_Cena
FROM PRODUKTY AS P
INNER JOIN KATEGORIE AS K
	ON P.ID_Kategorii = K.ID_Kategorii
GROUP BY K.Nazwa;

/*
--------------------------------------------------------------------------------
ZADANIE I: Wycena kapitału zamrożonego w towarze
WYMAGANIA: 3-way JOIN (PRODUKTY, KATEGORIE, STANY), SUM, GROUP BY
OPIS: Obliczenie całkowitej wartości netto zapasów dla każdej kategorii produktowej.
--------------------------------------------------------------------------------
*/
SELECT 
	K.Nazwa AS Kategoria,
	SUM(S.Ilosc_Dostepna * P.Cena_Netto) AS Wartość_Netto
FROM PRODUKTY AS P
INNER JOIN KATEGORIE AS K
	ON P.ID_Kategorii = K.ID_Kategorii
INNER JOIN STANY_MAGAZYNOWE AS S
	ON P.Kod_EAN = S.Kod_Produktu
GROUP BY K.Nazwa;

/*
--------------------------------------------------------------------------------
ZADANIE J: Analiza trendów czasowych zamówień
WYMAGANIA: CAST to DATE, GROUP BY, COUNT
OPIS: Zestawienie dziennej liczby zamówień, pozwalające na ocenę dynamiki sprzedaży.
--------------------------------------------------------------------------------
*/
SELECT
	CAST(Data_Zlozenia AS DATE) AS Dzień,
	COUNT(Numer_Zamowienia) AS Liczba_Zamówień
FROM ZAMOWIENIA
GROUP BY CAST(Data_Zlozenia AS DATE);

/*
--------------------------------------------------------------------------------
ZADANIE K: Matryca dywersyfikacji dostawców
WYMAGANIA: Multi-level GROUP BY, INNER JOIN
OPIS: Szczegółowy raport liczby produktów oferowanych przez poszczególnych dostawców w ramach konkretnych kategorii.
--------------------------------------------------------------------------------
*/
SELECT
	K.Nazwa AS Kategoria,
	D.Nazwa_Firmy AS Firma,
	COUNT(P.Nazwa) AS Liczba_Produktów
FROM PRODUKTY AS P
INNER JOIN DOSTAWCY AS D
	ON P.NIP_Dostawcy = D.NIP
INNER JOIN KATEGORIE AS K
	ON P.ID_Kategorii = K.ID_Kategorii
GROUP BY K.Nazwa, D.Nazwa_Firmy;

/*
--------------------------------------------------------------------------------
ZADANIE L: Selekcja kluczowych kategorii asortymentowych
WYMAGANIA: JOIN, GROUP BY, HAVING COUNT
OPIS: Wyodrębnienie kategorii o szerokim asortymencie (minimum 5 produktów).
--------------------------------------------------------------------------------
*/
SELECT
	K.Nazwa AS Kategoria,
	COUNT(P.Nazwa) AS Liczba_Produktów
FROM PRODUKTY AS P
INNER JOIN KATEGORIE AS K
	ON P.ID_Kategorii = K.ID_Kategorii
GROUP BY K.Nazwa
HAVING COUNT(*) >= 5;

/*
--------------------------------------------------------------------------------
ZADANIE M: Ranking wartościowy partnerów strategicznych
WYMAGANIA: 3-way JOIN, SUM, ORDER BY DESC
OPIS: Identyfikacja dostawców generujących największą wartość magazynową towarów.
--------------------------------------------------------------------------------
*/
SELECT
	D.Nazwa_Firmy,
	SUM(S.Ilosc_Dostepna*P.Cena_Netto) AS Wartość_Netto_Produktów
FROM PRODUKTY AS P
INNER JOIN DOSTAWCY AS D
	ON P.NIP_Dostawcy = D.NIP
INNER JOIN STANY_MAGAZYNOWE AS S
	ON P.Kod_EAN = S.Kod_Produktu
GROUP BY D.Nazwa_Firmy
ORDER BY Wartość_Netto_Produktów DESC;

/*
--------------------------------------------------------------------------------
ZADANIE N: Strukturalna analiza cenowa dostawców (Pivoting)
WYMAGANIA: Conditional Aggregation (SUM + CASE), JOIN, GROUP BY
OPIS: Zaawansowany podział portfela produktów dostawcy na segmenty "tanie" (<100) i "drogie" (>100).
--------------------------------------------------------------------------------
*/
SELECT
	D.Nazwa_Firmy,
	SUM(CASE WHEN P.Cena_Netto < 100 THEN 1 ELSE 0 END) AS Liczba_Tanich,
	SUM(CASE WHEN P.Cena_Netto >= 100 THEN 1 ELSE 0 END) AS Liczba_Drogich
FROM PRODUKTY AS P
INNER JOIN DOSTAWCY AS D
	ON P.NIP_Dostawcy = D.NIP
GROUP BY D.Nazwa_Firmy;

/*
--------------------------------------------------------------------------------
ZADANIE O: Monitoring aktualności danych magazynowych
WYMAGANIA: GROUP BY, MAX
OPIS: Raport wskazujący datę ostatniej inwentaryzacji/aktualizacji dla każdego regału w magazynie.
--------------------------------------------------------------------------------
*/
SELECT
	Lokalizacja_Regal,
	MAX(Data_Ostatniej_Aktualizacji) AS Data_Ostatniej_Aktualizacji
FROM STANY_MAGAZYNOWE
GROUP BY Lokalizacja_Regal;
