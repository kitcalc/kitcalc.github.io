import tables

type Code* = object
  short*, description*, long*: string
  
const rawcodes = [
  ["h", "Svarshuvud", "Provmaterial: Blod"],

  # remissorsaker
  ["uh", "Utredning inför väntelista hjärttx", "Utredning inför väntelista hjärttransplantation"],
  ["ul", "Utredning inför väntelista lung-tx", "Utredning inför väntelista lungtransplantation"],
  ["un", "Utredning inför väntelista njur-tx", "Utredning inför väntelista njurtransplantation"],
  ["up", "Utredning inför väntelista pankreas", "Utredning inför väntelista pankreastransplantation"],
  ["uö", "Utredning inför väntelista öceller", "Utredning inför väntelista öcellstransplantation"],
  ["uph", "Uppföljning efter hjärttx", "Uppföljning efter hjärttransplantation"],
  ["upl", "Uppföljning efter lungtx", "Uppföljning efter lungtransplantation"],
  ["upn", "Uppföljning efter njurtx", "Uppföljning efter njurtransplantation"],
  ["upp", "Uppföljning efter pankreastx", "Uppföljning efter pankreastransplantation"],
  ["upö", "Uppföljning efter öcellstx", "Uppföljning efter öcellstransplantation"],
  ["nn", "Nollprov vid njurtx", "Nollprov vid njurtransplantation"],
  ["nh", "Nollprov vid hjärttx", "Nollprov vid hjärttransplantation"],
  ["nl", "Nollprov vid lungtx", "Nollprov vid lungtransplantation"],
  ["np", "Nollprov vid pankreastx", "Nollprov vid pankreastransplantation"],
  ["nö", "Nollprov vid öcellstx", "Nollprov vid öcellstransplantation"],
  ["sta", "STAMP", "På väntelista för njurtransplantation, STAMP"],
  ["step", "STEP", "På väntelista för njurtransplantation, STEP"],
  ["vn", "På väntelista njure", "På väntelista för njurtransplantation"],
  ["vh", "På väntelista hjärta", "På väntelista för hjärttransplantation"],
  ["vl", "På väntelista lunga", "På väntelista för lungtransplantation"],
  ["vp", "På väntelista pankreas", "På väntelista för pankreastransplantation"],
  ["vö", "På väntelista öceller", "På väntelista för öcellstransplantation"],
  ["tfr", "Transfusionsreaktion", "Utredning av transfusionsreaktion"],
  ["trc", "Trombocytrefraktär", "Trombocytrefraktär"],
  ["trcd", "Trombocytdonator", "Trombocytdonator"],
  ["gran", "Granulocytgivare", "Granulocytgivare"],
  ["don", "Avliden donator", "Avliden donator"],
  ["pdon", "Potentiell donator", "Potentiell donator till (namn, personnummer)"],
  ["allo", "Utredning allogen SCT", "Utredning inför allogen stamcellstransplantation"],
  ["reg", "Utredning allogen SCT med registerdonator", "Utredning inför allogen SCT med registerdonator"],
  ["auto", "Utredning autolog SCT", "Utredning inför autolog SCT"],
  ["hap", "Utredning haploidentisk SCT", "Utredning inför allogen SCT med haploidentisk donator"],
  ["fam", "Familjeutredning", "Familjeutredning inför allogen stamscellstransplantation"],
  ["rel", "Familjerelation", "Syskon/far/mor till (Namn, personnr.)"],

  # LabScreen
  ["lsn", "LabScreen Single klass I och II negativ", """LabScreen Single Antigen:

  HLA klass I: Inga antikroppar påvisade.
  HLA-klass II: Inga antikroppar påvisade."""],
  ["min", "MICA positiv", """LabScreen Mixed:
  Inga antikroppar mot MICA påvisade."""],
  ["mip", "MICA negativ", """LabScreen Mixed:
  Antikroppar mot MICA påvisade."""],
  ["ls1", "LabScreen Single klass I positiv", """LabScreen Single Antigen:

HLA klass I: Antikroppar påvisade. Specificiteter listade i fallande reaktionsstyrka (MFI <XXX):
"""],
  ["ls1k", "LabScreen Single klass I positiv (fåtal)", """LabScreen Single Antigen:

HLA klass I: Antikroppar påvisade.
Specificiteter (MFI):"""],
  ["ls1n", "LabScreen Single klass I negativ", """LabScreen Single Antigen:

HLA klass I: Inga antikroppar påvisade."""],
  ["ls1s", "LabScreen Single klass I positiv (spädning)", """LabScreen Single Antigen:

HLA-antikroppar mot klass I påvisade i spädning 1:###. Specificiteter listade i fallande reaktionsstyrka (MFI <XXX):


HLA-antikroppar mot klass I påvisade i spädning 1:1. Specificiteter listade i fallande reaktionsstyrka (MFI <XXX):
"""],
  ["ls2", "LabScreen Single klass II positiv", """HLA klass II: Antikroppar påvisade. Specificiteter listade i fallande reaktionsstyrka (MFI <XXX):
"""],
  ["ls2k", "LabScreen Single klass II positiv (fåtal)", """HLA klass II: Antikroppar påvisade.
Specificiteter (MFI):"""],
  ["ls2n", "LabScreen Single klass II negativ", "HLA klass II: Inga antikroppar påvisade."],
  ["ls2s", "LabScreen Single klass II positiv (spädning 1:1 och 1:25)", """HLA-antikroppar mot klass II påvisade i spädning 1:###. Specificiteter listade i fallande reaktionsstyrka (MFI <XXX):


  HLA-antikroppar mot klass II påvisade i spädning 1:1. Specificiteter listade i fallande reaktionsstyrka (MFI <XXX):
"""],
  ["c1q", "C1q positiv", """Kompletterande analys C1q-bindande HLA-antikroppar:

HLA klass I: C1q-bindande antikroppar påvisade. Specificiteter listade i fallande reaktionsstyrka (MFI <XXX):


HLA klass II: C1q-bindande antikroppar påvisade. Specificiteter listade i fallande reaktionsstyrka (MFI <XXX):
"""],
  ["c1qn", "C1q negativ", """Kompletterande analys C1q-bindande HLA-antikroppar:

HLA klass I: Inga antikroppar påvisade.
HLA klass II: Inga antikroppar påvisade."""],

  # CDC
  ["cyn", "CDC negativ", "Cytotoxisk screen mot T- och B-celler (30 panelceller) är negativ."],
  ["cyb", "CDC positiv för B-celler", "Cytotoxisk screen mot B-celler är positiv mot ## av 30 panelceller."],
  ["cybn", "CDC negativ mot B-celler", "Cytotoxisk screen mot B-celler (30 panelceller) är negativ."],
  ["cyt", "CDC positiv för T-celler", "Cytotoxisk screen mot T-celler är positiv mot ## av 30 panelceller."],
  ["cytn", "CDC negativ för T-celler", "Cytotoxisk screen mot T-celler (30 panelceller) är negativ."],
  ["dtt", "CDC neg efter DTT-behandling", "Omsättning med DTT-behandlat serum mot minipanel av positiva celler (n=###) är negativ, vilket indikerar förekomst av IgM-antikroppar. Dessa saknar sannolikt klinisk signifikans."],
  ["dttp", "CDC pos efter DTT-behandling", "Omsättning med DTT-behandlat serum mot minipanel av positiva celler (n=###) är positiv, vilket indikerar förekomst av IgG-HLA-antikroppar. Dessa har sannolikt klinisk signifikans."],

  # HLA
  ["amb", "För info om HLA-kombinationer", "För information om HLA-kombinationer som inte helt kan uteslutas vänligen kontakta laboratoriet."],
  ["h1", "Kompletterande subtypning", "Kompletterande subtypning av avliden donator för att utesluta/bekräfta DSA hos recipient."],
  ["kon", "Kontrolltypning", "Kontrolltypning. Resultatet överensstämmer med tidigare HLA-typning."],

  # KIR
  ["kir", "KIR-typning", """KIR-genotypning

Donator till <Namn> <Personnummer>

Centromert genmotiv: Cen-X/X
Telomert genmotiv: Tel-X/X
B-content score: X
Donatorskategori (neutral/bättre/bäst): Neutral

Fullständig KIR-genotypning finns tillgänglig på laboratoriet.
Ref: Cooley S et al. Blood 2010", "116(14):2411-9.
Metod: PCR-SSP"""],
["kirl", "KIR-ligander (anpassa svaret)", """Patienten uttrycker: Bw4, Bw6, C1, C2
Pappan uttrycker: Bw4, Bw6, C1, C2
Mamman uttrycker: Bw4, Bw6, C1, C2

Bedömning:
Det föreligger KIR-ligand mismatch i GvH-riktningen mellan pappan (Bw4) och patienten.
Det föreligger KIR-ligand mismatch i HvG-riktningen mellan patienten (C1) och pappan samt mellan patienten (C2) och mamman.

Ref: IPD-KIR database (https://www.ebi.ac.uk/ipd/kir/ligand.html)"""],

  # korstest
  ["xn", "Negativ korstest", "Cytotoxisk korstest är negativ mot donatorns T- och B-celler."],
  ["xp", "Positiv korstest", "OBS! Cytotoxisk korstest är positiv."],
  
  # bedömning
  ["b", "Bedömning (tom rad)", "Bedömning:\n"],
  ["väs", "Bedömning - väsentligen oförändrat", "Väsentligen oförändrat status sedan föregående analystillfälle."],
  ["dsan", "Bedömning  - inga DSA påvisade", "Inga donatorsspecifika antikroppar påvisade."],
  ["dsa", "Bedömning DSA (lista)", "Donatorspecifika antikroppar påvisade (MFI): ## (##), ## (##)"],
  ["uppf", "Bedömning - uppföljning rekommenderas", "Uppföljning rekommenderas om X månader."],
  ["osp", "Svaga, ospecifika", "Svaga, sannolikt ospecifika antikroppar mot enstaka antigen."],
]


func initCode(short, description, long: string): Code =
  result = Code(short: short, description: description, long: long)

func genCodeTable*(): OrderedTable[string, Code] =
  ## Generate a code table
  for code in rawcodes:
    let
      short = code[0]
      description = code[1]
      long = code[2]
    result[short] = initCode(short, description, long)