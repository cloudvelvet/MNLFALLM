from __future__ import annotations

from pathlib import Path

from docx import Document


SRC = Path(r"C:\chen_bauer_2024\docx_work\required_publication_fixes.docx")
OUT = Path(r"C:\chen_bauer_2024\docx_work\required_publication_fixes_final.docx")


def set_text(p, text: str) -> None:
    for run in p.runs:
        run.text = ""
    if p.runs:
        p.runs[0].text = text
    else:
        p.add_run(text)


def insert_before(paragraph, text: str):
    from docx.oxml import OxmlElement
    from docx.text.paragraph import Paragraph

    new_p = OxmlElement("w:p")
    paragraph._p.addprevious(new_p)
    p = Paragraph(new_p, paragraph._parent)
    p.style = paragraph.style
    p.add_run(text)
    return p


doc = Document(SRC)

for p in doc.paragraphs:
    if "bootstrop" in p.text:
        set_text(p, p.text.replace("bootstrop", "bootstrap"))

# Ensure the two new references are present in the reference list, not only cited in text.
ref_items = [
    "Gilardi, F., Alizadeh, M., & Kubli, M. (2023). ChatGPT outperforms crowd workers for text-annotation tasks. *Proceedings of the National Academy of Sciences, 120*(30), e2305016120.",
    "Sandoval, J., & Miille, M. P. W. (1980). Accuracy of judgments of WISC-R item difficulty for minority groups. *Journal of Consulting and Clinical Psychology, 48*(2), 249-253.",
]
all_text = "\n".join(p.text for p in doc.paragraphs)
anchor = None
for p in doc.paragraphs:
    if p.text.strip().startswith("신동훈"):
        anchor = p
        break
if anchor is None:
    anchor = doc.paragraphs[-1]
for ref in reversed(ref_items):
    unique = ref.split("). ")[0] + ")."
    # Count only reference-list occurrences; text citation alone should not suppress insertion.
    if ref not in all_text:
        insert_before(anchor, ref)

doc.save(OUT)
print(OUT)
