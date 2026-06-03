# Trillingsdempende bekerhouder voor mensen met Parkinson

**NLT – Technisch Ontwerpen** · Bram, Ruben, Wander & Jelle · Spinoza20First – HAVO 4

Dit is het **visuele/fysieke product** bij ons ontwerpverslag: het definitieve
ontwerp **V3** uitgewerkt als 3D-model. Je kunt de bestanden direct laten
**3D-printen** of openen in **Tinkercad** om aan te passen.

![Overzicht](img/overzicht.png)

---

## 1. Het idee in het kort

Een 3D-geprinte **ring in twee helften** klemt met een **siliconen binnenrand**
om de beker. Aan de zijkant zit een **handvat** dat via **één bout** vrij kan
draaien ten opzichte van de ring.

> **Werking:** de gebruiker houdt het handvat vast. Trilt of draait de hand, dan
> draait het *handvat* mee, maar de *ring en de beker* blijven door het vrije
> draaipunt en de zwaartekracht hangen. Zo wordt de trilling van de hand niet
> doorgegeven aan de beker (een soort gimbal-/slingerprincipe).

| Aanzicht | Beeld |
|---|---|
| Op een beker | ![assemblage](img/assemblage.png) |
| Product los | ![product](img/product.png) |
| Explosietekening | ![exploded](img/explosietekening.png) |

---

## 2. Wat zit er in deze map?

```
bekerhouder-parkinson/
├── src/bekerhouder.scad      ← het bronontwerp (parametrisch, OpenSCAD)
├── stl/                      ← printklare / Tinkercad-bestanden
│   ├── ring_helft_A.stl      ← Ring helft A (met vork voor het handvat)
│   ├── ring_helft_B.stl      ← Ring helft B (vlak)
│   ├── handvat.stl           ← Handvat
│   └── printplaat_compleet.stl  ← alle 3 de delen in één bestand
├── img/                      ← afbeeldingen voor het verslag
└── render.sh                 ← script dat alle plaatjes + STL's opnieuw maakt
```

De **3 printdelen** komen precies overeen met onze stuklijst:
Ring helft A, Ring helft B en het Handvat.

---

## 3. Stuklijst (zelfde als in het verslag)

| Nr. | Onderdeel | Materiaal | Aantal | Verkrijgen via |
|----|------------------------|-----------|--------|----------------|
| 1 | Ring helft A | PLA | 1× | 3D-printer (`ring_helft_A.stl`) |
| 2 | Ring helft B | PLA | 1× | 3D-printer (`ring_helft_B.stl`) |
| 3 | Handvat | PLA | 1× | 3D-printer (`handvat.stl`) |
| 4 | Bout M5 × 30 mm | Staal | 1× | Bouwmarkt |
| 5 | Zelfborgende moer M5 | Nylon | 1× | Bouwmarkt |
| 6 | Sluitring M5 | Staal | 2× | Bouwmarkt |
| 7 | Siliconen binnenrand | Silicoon | 1× | Bouwmarkt |
| 8 | Contactlijm | – | 1× | Bouwmarkt |

---

## 4. 3D-printen

**Aanbevolen instellingen (PLA):**

| Instelling | Waarde |
|---|---|
| Laaghoogte | 0,2 mm |
| Wanden / perimeters | 3 |
| Vulling (infill) | 30–40 % |
| Support | **Ja**, voor de vork van helft A en de uitstekende pennen |
| Brim | Aan te raden (ringhelften staan smal op de plaat) |

**Print-oriëntatie:**
- **Ringhelften:** rechtop, met de onderrand op de printplaat.
- **Handvat:** plat liggend, met de tong op de plaat.

> 💡 De ringhelften klikken met **pennen** in elkaar. Past het te strak of te
> los? Pas in de slicer de schaal ~0,5 % aan, of wijzig `peg_hole` in het
> ontwerp (zie §6). Dit testen-en-bijstellen hoort bij het prototypen — een mooi
> punt voor hoofdstuk 7 & 8 van het verslag.

---

## 5. Aanpassen in **Tinkercad**

1. Ga naar [tinkercad.com](https://www.tinkercad.com) → log in.
2. Maak een nieuw ontwerp → knop **Import** (rechtsboven).
3. Kies een `.stl`-bestand uit de map `stl/` (bv. `ring_helft_A.stl`).
4. Het onderdeel verschijnt als bewerkbare vorm; je kunt schalen, gaten
   toevoegen, tekst graveren (bv. jullie namen), enzovoort.
5. Importeer de drie delen apart als je het geheel wilt samenstellen.

> Tinkercad importeert ook `printplaat_compleet.stl` als je alles in één keer
> wilt zien.

---

## 6. Maten aanpassen (parametrisch ontwerp)

Het bronbestand `src/bekerhouder.scad` is **parametrisch**: bovenaan staan de
belangrijkste maten. De belangrijkste om aan te passen:

| Variabele | Betekenis | Standaard |
|---|---|---|
| `cup_d` | buitendiameter van jullie beker | 75 mm |
| `liner_t` | dikte siliconen binnenrand | 3 mm |
| `wall` | wanddikte van de ring | 5 mm |
| `ring_h` | hoogte van de ring | 26 mm |
| `bolt_d` / `hole_d` | boutmaat + gat | M5 |

**Belangrijk:** meet je eigen beker en zet die maat in `cup_d`. De ring schaalt
dan automatisch mee.

Opnieuw genereren (met [OpenSCAD](https://openscad.org) geïnstalleerd):

```bash
./render.sh        # maakt alle img/*.png én stl/*.stl opnieuw
```

Of open `src/bekerhouder.scad` in OpenSCAD en exporteer met **File → Export → STL**.

---

## 7. Montage

1. **Siliconen binnenrand** in beide ringhelften lijmen met **contactlijm** (deel 8).
2. Beker tussen de twee ringhelften plaatsen en de helften met de **pennen**
   in elkaar drukken tot ze klikken.
3. **Handvat** met de tong in de vork van helft A schuiven.
4. **Bout** met een **sluitring** door de vork + tong steken, aan de andere kant
   een **sluitring** en de **zelfborgende moer**.
5. Moer net zo ver aandraaien dat het handvat **soepel vrij kan draaien**
   (niet vastzetten!). Dat vrije draaipunt is precies wat de trilling dempt.

---

## 8. Hoe dit aansluit op het programma van eisen

| Eis | Hoe het ontwerp hieraan voldoet |
|---|---|
| 1. Trillingen dempen | Vrij draaiend handvat ontkoppelt hand van beker |
| 2. Stabiliteit | Ring klemt rondom; beker hangt uitgebalanceerd |
| 3. Licht gewicht | Holle PLA-print, ~30–40 % vulling |
| 4. Comfort | Afgeronde, ergonomische greep |
| 5. Universeel | `cup_d` aanpasbaar + siliconen rand vangt verschil op |
| 6. Eenvoud | Klik de ring dicht, klaar |
| 7. Maakbaarheid | 3 simpele printdelen + standaard boutje |
| 8. Veiligheid | Geen scherpe randen, alles afgerond |
| 9. Betaalbaar | Weinig PLA + 1 boutje, makkelijk te reproduceren |
| 10. Uiterlijk | Strakke ring + handvat, valt niet op als "hulpmiddel" |
