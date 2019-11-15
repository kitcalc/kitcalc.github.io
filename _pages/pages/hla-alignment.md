title: HLA-alignment
created: 2019-11-15
summary: Verktyg och tips för hur man kan jämföra HLA-alleler
---

Sedan [dbMHC Sequence Alignment
Viewer](https://www.ncbi.nlm.nih.gov/gv/mhc/?cmd=aligndisplay&user_id=0&probe_id=0&source_id=0&locus_id=0&locus_group=1&proto_id=0&kit_id=0&banner=1)
lades ned har inget uppenbart online-alternativ för att se alignment mellan
HLA-alleler funnits. Via IPD-IMGT/HLA finns [Sequence Alignment
Tool](https://www.ebi.ac.uk/ipd/imgt/hla/align.html) som är mer svårarbetat.
Här följer ett tips på hur ett lokalt program kan användas, tillsammans med
rådata från IPD-IMGT/HLA.


## Jalview

Vi använder [Jalview](http://www.jalview.org/), ett Java-program för att
visualiera alignments. Om Java Webstart fungerar kan det räcka med att trycka
[på den här länken](http://www.jalview.org/old/v2_10_5/jalview.jnlp), annars
får man installera lokalt.


## Alignmentdata

Följande alignments är relevanta för transplantation. Länkar kan kopieras och
går till senaste publicerade version i MSF-format. Andra format och loci finns
[här](http://hla.alleles.org/alleles/text_index.html) och via
[github](https://github.com/ANHIG/IMGTHLA).

| Locus | Genomisk | cDNA | Protein |
|-------|----------|------|---------|
| *HLA-A* | [A_gen.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/A_gen.msf) | [A_nuc.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/A_nuc.msf) | [A_prot.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/A_prot.msf) |
| *HLA-B* | [B_gen.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/B_gen.msf) | [B_nuc.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/B_nuc.msf) | [B_prot.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/B_prot.msf) |
| *HLA-C* | [C_gen.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/C_gen.msf) | [C_nuc.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/C_nuc.msf) | [C_prot.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/C_prot.msf) |
| *HLA-DRB1* | [DRB1_gen.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DRB1_gen.msf) | [DRB1_nuc.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DRB1_nuc.msf) | [DRB1_prot.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DRB1_prot.msf) |
| *HLA-DRB3* | [DRB3_gen.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DRB1_gen.msf) | [DRB345_nuc.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DRB345_nuc.msf) | [DRB345_prot.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DRB345_prot.msf) |
| *HLA-DRB4* | [DRB4_gen.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DRB4_gen.msf) | [DRB345_nuc.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DRB345_nuc.msf) | [DRB345_prot.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DRB345_prot.msf) |
| *HLA-DRB5* | [DRB5_gen.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DRB5_gen.msf) | [DRB345_nuc.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DRB345_nuc.msf) | [DRB345_prot.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DRB345_prot.msf) |
| *HLA-DQA1* | [DQA1_gen.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DQA1_gen.msf) | [DQA1_nuc.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DQA1_nuc.msf) | [DQA1_prot.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DQA1_prot.msf) |
| *HLA-DQB1* | [DQB1_gen.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DQB1_gen.msf) | [DQB1_nuc.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DQB1_nuc.msf) | [DQB1_prot.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DQB1_prot.msf) |
| *HLA-DPA1* | [DPA1_gen.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DPA1_gen.msf) | [DPA1_nuc.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DPA1_nuc.msf) | [DPA1_prot.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DPA1_prot.msf) |
| *HLA-DPB1* | [DPB1_gen.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DPB1_gen.msf) | [DPB1_nuc.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DPB1_nuc.msf) | [DPB1_prot.msf](https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/msf/DPB1_prot.msf) |


## Se alignment

1. Öppna Jalview och stäng alla fönster utom huvudfönstret.
2. Kopiera länk till den alignment du vill se från tabellen ovan. 
3. Välj *File* – *Input alignment* – *from URL* och klistra in länken.
4. För att se endast ett urval av alleler, välj de du vill se (Ctrl och
   musklick) och tryck *View* – *Hide* – *All but Selected Region
   (Shift+Ctrl+H)*

Färger för aminosyror/nukleotider kan ställas in via menyn *Colour*. 

