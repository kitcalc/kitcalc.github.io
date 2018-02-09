import strutils

type
  Locus* = enum
    ABC,
    DRB,
    DQA1,
    DQB1,
    DPA1,
    DPB1

proc parseLocus*(locusstr: string): Locus =
  ## Parse the locus string.
  result = parseEnum[Locus](locusstr)