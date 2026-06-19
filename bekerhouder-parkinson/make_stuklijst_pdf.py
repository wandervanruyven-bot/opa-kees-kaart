#!/usr/bin/env python3
"""Genereert stuklijst.pdf met de ingevulde maten (V3 + V4)."""
from fpdf import FPDF
from fpdf.fonts import FontFace

BLUE = (15, 58, 95)
HEAD_FILL = (214, 228, 242)
GRAY = (95, 99, 104)
STRIPE = (247, 250, 253)
NOTE_BG = (238, 244, 251)
NOTE_BAR = (47, 111, 176)

FONT = "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf"
FONT_B = "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf"
FONT_I = "/usr/share/fonts/truetype/liberation/LiberationSans-Italic.ttf"

COLS = (12, 39, 21, 74, 13, 18)   # Nr, Onderdeel, Materiaal, Maat, Aantal, Via
ALIGN = ("CENTER", "LEFT", "LEFT", "LEFT", "CENTER", "LEFT")
HEADERS = ["Nr.", "Onderdeel", "Materiaal", "Maat", "Aantal", "Verkrijgen via"]

V3 = [
    ["1", "Ring helft A", "PLA", "Ø 91 mm buiten · Ø 81 mm binnen · h 26 mm · wand 5 mm (halve ring + vork)", "1×", "3D-printer"],
    ["2", "Ring helft B", "PLA", "Ø 91 mm buiten · Ø 81 mm binnen · h 26 mm · wand 5 mm (halve ring)", "1×", "3D-printer"],
    ["3", "Handvat", "PLA", "greep Ø 28 mm · lengte ca. 124 mm", "1×", "3D-printer"],
    ["4", "Bout", "Staal", "M5 × 30 mm", "1×", "Bouwmarkt"],
    ["5", "Stop moer", "Nylon", "M5 (zelfborgend)", "1×", "Bouwmarkt"],
    ["6", "Sluitringen", "Staal", "M5 (Ø 5,3 × Ø 10 × 1 mm)", "2×", "Bouwmarkt"],
    ["7", "Siliconen binnenkant", "Silicoon", "dikte 3 mm · breed 26 mm · voor beker Ø 75 mm", "1×", "Bouwmarkt"],
    ["8", "Contactlijm", "–", "1 tube (~20 ml)", "1×", "Bouwmarkt"],
]

V4 = [
    ["1", "Binnenring (bekerklem)", "PLA", "Ø 91 mm buiten · Ø 81 mm binnen · h 24 mm · oogjes op de X-as", "1×", "3D-printer"],
    ["2", "Middenring (gimbalring)", "PLA", "Ø 119 mm buiten · Ø 109 mm binnen · h 16 mm · trunnions op de Y-as", "1×", "3D-printer"],
    ["3", "Beugel", "PLA", "144 mm breed · 88 mm diep · h 14 mm (halve hoepel)", "1×", "3D-printer"],
    ["4", "Lusgreep (handvat)", "PLA", "ca. 141 mm lang · 78 mm breed · 20 mm dik", "1×", "3D-printer"],
    ["5", "Bout M4 (draaipunten)", "Staal", "M4 × 20 mm", "4×", "Bouwmarkt"],
    ["6", "Zelfborgende moer M4", "Nylon", "M4", "4×", "Bouwmarkt"],
    ["7", "Bout M3 (greep vast)", "Staal", "M3 × 20 mm", "1×", "Bouwmarkt"],
    ["8", "Zelfborgende moer M3", "Nylon", "M3", "1×", "Bouwmarkt"],
    ["9", "Siliconen binnenrand", "Silicoon", "dikte 3 mm · breed 24 mm · voor beker Ø 75 mm", "1×", "Bouwmarkt"],
    ["10", "Contactlijm", "–", "1 tube (~20 ml)", "1×", "Bouwmarkt"],
]


class PDF(FPDF):
    def footer(self):
        self.set_y(-14)
        self.set_font("Lib", "I", 7.5)
        self.set_text_color(*GRAY)
        self.cell(0, 5, "Maten afgeleid uit het parametrische ontwerp (OpenSCAD) en opgemeten aan de STL-bestanden.", align="C")


def heading(pdf, txt):
    pdf.ln(2)
    pdf.set_font("Lib", "B", 13)
    pdf.set_text_color(*BLUE)
    pdf.cell(0, 7, txt, new_x="LMARGIN", new_y="NEXT")
    y = pdf.get_y()
    pdf.set_draw_color(*BLUE)
    pdf.set_line_width(0.5)
    pdf.line(pdf.l_margin, y, pdf.w - pdf.r_margin, y)
    pdf.ln(1.5)


def note_box(pdf, parts):
    pdf.ln(1.5)
    lh = 4.3
    w = pdf.epw
    pad = 2.5
    inner_w = w - 2 * pad - 2
    pdf.set_font("Lib", "", 8.5)
    plain = "".join(t for t, _ in parts)
    lines = pdf.multi_cell(inner_w, lh, plain, dry_run=True, output="LINES")
    h = len(lines) * lh + 2 * pad
    x0, y0 = pdf.l_margin, pdf.get_y()
    pdf.set_fill_color(*NOTE_BG)
    pdf.rect(x0, y0, w, h, style="F")
    pdf.set_fill_color(*NOTE_BAR)
    pdf.rect(x0, y0, 1.4, h, style="F")
    pdf.set_xy(x0 + pad + 2, y0 + pad)
    pdf.set_text_color(40, 40, 40)
    for txt, bold in parts:
        pdf.set_font("Lib", "B" if bold else "", 8.5)
        pdf.write(lh, txt)
    pdf.set_xy(x0, y0 + h)
    pdf.ln(0.5)


def table(pdf, rows):
    pdf.set_font("Lib", "", 9)
    pdf.set_text_color(30, 30, 30)
    pdf.set_draw_color(185, 196, 207)
    pdf.set_line_width(0.2)
    pdf.set_fill_color(*STRIPE)
    head_style = FontFace(emphasis="BOLD", color=BLUE, fill_color=HEAD_FILL)
    with pdf.table(col_widths=COLS, text_align=ALIGN, width=pdf.epw,
                   line_height=4.6, headings_style=head_style,
                   cell_fill_mode="EVEN_ROWS", cell_fill_color=STRIPE) as t:
        hr = t.row()
        for hcell in HEADERS:
            hr.cell(hcell)
        for r in rows:
            row = t.row()
            for c in r:
                row.cell(c)


pdf = PDF(orientation="P", unit="mm", format="A4")
pdf.set_margins(16, 14, 16)
pdf.set_auto_page_break(True, margin=13)
pdf.add_font("Lib", "", FONT)
pdf.add_font("Lib", "B", FONT_B)
pdf.add_font("Lib", "I", FONT_I)
pdf.add_page()

pdf.set_font("Lib", "B", 18)
pdf.set_text_color(*BLUE)
pdf.cell(0, 8, "Stuklijst – Trillingsdempende bekerhouder", new_x="LMARGIN", new_y="NEXT")
pdf.set_font("Lib", "", 10.5)
pdf.set_text_color(*GRAY)
pdf.cell(0, 5.5, "NLT · Technisch Ontwerpen   |   Bram, Ruben, Wander & Jelle   |   Spinoza20First – HAVO 4",
         new_x="LMARGIN", new_y="NEXT")

heading(pdf, "Stuklijst V3 – ring in twee helften (ons verslagontwerp)")
table(pdf, V3)
note_box(pdf, [
    ("Ontworpen voor een beker van ", False), ("Ø 75 mm", True),
    (". Meet je eigen beker; wijkt die af, dan veranderen de ring-diameters mee: ", False),
    ("binnen-Ø = beker + 6 mm", True), (", ", False),
    ("buiten-Ø = beker + 16 mm", True), (".", False),
])

heading(pdf, "Stuklijst V4 – gimbal met lushandvat (de geprinte versie)")
table(pdf, V4)
note_box(pdf, [
    ("Verschil V3 / V4: ", True),
    ("V3 dempt om één as (1 bout). V4 is een echte gimbal met ", False),
    ("twee loodrechte draaiassen", True),
    (" (4 M4-bouten), zodat de beker in alle richtingen waterpas blijft.", False),
])

pdf.output("stuklijst.pdf")
print("OK -> stuklijst.pdf")
