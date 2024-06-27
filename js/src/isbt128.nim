## ISBT128 coding, standard version 6.2.2 (April 2023)
## See https://www.isbt128.org/tech-spec for the latest standard

import strutils, htmlgen

type
  DataStructure = enum  ## Data structures in ISBT128. From Table 2

    # 001
    donationIdentificationNumber,  # "Donation Identification Number"
    # 002
    bloodGroupsABORhD,  # "Blood Groups [ABO and RhD]"
    # 003
    productCode,  # "Product Code"
    # 004
    expirationDate,  # "Expiration Date"
    # 005
    expirationDateAndTime,  # "Expiration Date and Time"
    # 006
    collectionDate,  # "Collection Date"
    # 007
    collectionDateAndTime,  # "Collection Date and Time"
    # 008
    productionDate,  # "Production Date"
    # 009
    productionDateAndTime,  # "Production Date and Time"
    # 010
    specialTestingGeneral,  # "Special Testing: General"
    # 011 [RETIRED]
    specialTestingAntigensRetired,  # "Special Testing: Red Blood Cell Antigens"
    # 012
    specialTestingAntigensGeneral,  # "Special Testing: Red Blood Cell Antigens—General"
    # 013
    specialTestingAntigensFinnish,  # "Special Testing: Red Blood Cell Antigens—Finnish"
    # 014
    specialTestingPlatelet,  # "Special Testing: Platelet HLA and Platelet Specific Antigens"
    # 015 [RETIRED]
    specialTestingHLAAB,  # "Special Testing: HLA-A and -B Alleles"
    # 016 [RETIRED]
    specialTestingHLADRB1,  # "Special Testing: HLA-DRB1 Alleles"
    # 017
    containerManufacturerAndCatalogNumber,  # "Container Manufacturer and Catalog Number"
    # 018
    containerLotNumber,  # "Container Lot Number"
    # 019
    donorIdentificationNumber,  # "Donor Identification Number"
    # 020
    staffMemberIdentificationNumber,  # "Staff Member Identification Number"
    # 021
    manufacturerAndCatalogNumber,  # "Manufacturer and Catalog Number: Items Other Than Containers"
    # 022
    lotNumber,  # "Lot Number: Items Other Than Containers"
    # 023
    compoundMessage,  # "Compound Message"
    # 024
    patientDateOfBirth,  # "Patient Date of Birth"
    # 025
    patientIdentificationNumber,  # "Patient Identification Number"
    # 026
    expirationMonthAndYear,  # "Expiration Month and Year"
    # 027
    ttiMarker,  # "Transfusion Transmitted Infection Marker"
    # 028
    productConsignment,  # "Product Consignment"
    # 029
    dimensions,  # "Dimensions"
    # 030
    redCellAntigensWithTestHistory,  # "Red Cell Antigens with Test History"
    # 031
    flexibleDateAndTime,  # "Flexible Date and Time"
    # 032
    productDivisions,  # "Product Divisions"
    # 033
    processingFacilityInformationCode,  # "Processing Facility Information Code"
    # 034
    processorProductIdentificationCode,  # "Processor Product Identification Code"
    # 035
    mphoLotNumber,  # "MPHO Lot Number"
    # 036
    mphoSupplementalIdentificationNumber,  # "MPHO Supplemental Identification Number"
    # 037 [RETIRED]
    globalRegistrationIdentifierForDonorsRetired,  # "Global Registration Identifier for Donors"
    # 038
    singleEuropeanCode,  # "Single European Code"
    # 039
    globalRegistrationIdentifierForDonors,  # "Global Registration Identifier for Donors"
    # 040
    chainOfIdentityIdentifier,  # "Chain of Identity Identifier"

    # other non-ICCBA, not numbered

    # These data identifiers may be assigned by a facility or a regional,
    # national, or supranational authority
    nonIccba,  # "Data Structures Not Defined by ICCBBA"

    # Defined nationally
    reservedNationalDonorIdentificationNumber,  # "Reserved Data Identifiers for a Nationally Specified Donor Identification Number"

    # Defined nationally
    confidentialUnitExclusion  # "Confidential Unit Exclusion Status Data Structure"

const dataStructureNames: array[DataStructure, string] =
  [
    # vissa fritt översatta alt från Handboken eller ProSang
    "Tappningsnummer (Donation Identification Number)",
    "Blodgrupp (ABO och RhD)",
    "Produktkod",
    "Utgångsdatum",
    "Utgångsdatum och tid",
    "Tappningsdatum",
    "Tappningsdatum och tid",
    "Produktionsdatum",
    "Produktionsdatum och tid",

    # ej översatta
    "Special Testing: General",
    "Special Testing: Red Blood Cell Antigens",
    "Special Testing: Red Blood Cell Antigens—General",
    "Special Testing: Red Blood Cell Antigens—Finnish",
    "Special Testing: Platelet HLA and Platelet Specific Antigens",
    "Special Testing: HLA-A and -B Alleles",
    "Special Testing: HLA-DRB1 Alleles",
    "Container Manufacturer and Catalog Number",
    "Container Lot Number",
    "Donor Identification Number",
    "Staff Member Identification Number",
    "Manufacturer and Catalog Number: Items Other Than Containers",
    "Lot Number: Items Other Than Containers",
    "Compound Message",
    "Patient Date of Birth",
    "Patient Identification Number",
    "Expiration Month and Year",
    "Transfusion Transmitted Infection Marker",
    "Product Consignment",
    "Dimensions",
    "Red Cell Antigens with Test History",
    "Flexible Date and Time",
    "Product Divisions",
    "Processing Facility Information Code",
    "Processor Product Identification Code",
    "MPHO Lot Number",
    "MPHO Supplemental Identification Number",
    "Global Registration Identifier for Donors",
    "Single European Code",
    "Global Registration Identifier for Donors",
    "Chain of Identity Identifier",
    "Data Structures Not Defined by ICCBBA",
    "Reserved Data Identifiers for a Nationally Specified Donor Identification Number",
    "Confidential Unit Exclusion Status Data Structure"
]

func classifyDataStructure(code: string): DataStructure =
  ## Returns the Data Structure associated with `code`, or a ValueError if
  ## prefix is unknown

  # From Table 2
  result = if code.startsWith('=') and code[1] in {'A'..'N', 'P'..'Z', '1'..'9'}:
      donationIdentificationNumber
    elif code.startsWith "=%": bloodGroupsABORhD
    elif code.startsWith "=<": productCode
    elif code.startsWith "=>": expirationDate
    elif code.startsWith "&>": expirationDateAndTime
    elif code.startsWith "=*": collectionDate
    elif code.startsWith "&*": collectionDateAndTime
    elif code.startsWith "=}": productionDate
    elif code.startsWith "&}": productionDateAndTime
    elif code.startsWith "&(": specialTestingGeneral
    elif code.startsWith "={": specialTestingAntigensRetired
    elif code.startsWith "=\\": specialTestingAntigensGeneral  # =\
    elif code.startsWith "&\\": specialTestingAntigensFinnish  # &\
    elif code.startsWith "&{": specialTestingPlatelet
    elif code.startsWith "=[": specialTestingHLAAB
    elif code.startsWith "=\"": specialTestingHLADRB1  # ="
    elif code.startsWith "=)": containerManufacturerAndCatalogNumber
    elif code.startsWith "&)": containerLotNumber
    elif code.startsWith "=;": donorIdentificationNumber
    elif code.startsWith "='": staffMemberIdentificationNumber
    elif code.startsWith "=-": manufacturerAndCatalogNumber
    elif code.startsWith "&-": lotNumber
    elif code.startsWith "=+": compoundMessage
    elif code.startsWith "=#": patientDateOfBirth
    elif code.startsWith "&#": patientIdentificationNumber
    elif code.startsWith "=]": expirationMonthAndYear
    elif code.startsWith "&\"": ttiMarker  # &"
    elif code.startsWith "=$": productConsignment
    elif code.startsWith "&$": dimensions
    elif code.startsWith "&%": redCellAntigensWithTestHistory
    elif code.startsWith "= ": flexibleDateAndTime
    elif code.startsWith "=,": productDivisions
    elif code.startsWith "&+": processingFacilityInformationCode
    elif code.startsWith "=/": processorProductIdentificationCode
    elif code.startsWith "&,1": mphoLotNumber
    elif code.startsWith "&,2": mphoSupplementalIdentificationNumber
    elif code.startsWith "&,3": globalRegistrationIdentifierForDonorsRetired
    elif code.startsWith "&,4": singleEuropeanCode
    elif code.startsWith "&):": globalRegistrationIdentifierForDonors
    elif code.startsWith "&/": chainOfIdentityIdentifier
    elif code.startsWith('&') and code[1] in {'a'..'z'}: nonIccba
    elif code.startsWith "&;": reservedNationalDonorIdentificationNumber
    elif code.startsWith "&!": confidentialUnitExclusion
    else:
      raise newException(ValueError, "okänt prefix: " & code)

import datastructures/datastructure001
import datastructures/datastructure002
import datastructures/datastructure003
import datastructures/datastructure004
import datastructures/datastructure005
import datastructures/datastructure006
import datastructures/datastructure007
import datastructures/datastructure008
import datastructures/datastructure009
import datastructures/datastructure010
import datastructures/datastructure011
import datastructures/datastructure012
import datastructures/datastructure013

#[

proc parseSpecialTestingPlatelet(number: string) =
  ## Parse Data Structure 014, "Special Testing: Platelet HLA and Platelet Specific Antigens"
  discard "not implemented"


proc parseSpecialTestingHLAAB(number: string) =
  ## Parse Data Structure 015, "Special Testing: HLA-A and -B Alleles"
  discard "not implemented"


proc parseSpecialTestingHLADRB1(number: string) =
  ## Parse Data Structure 016, "Special Testing: HLA-DRB1 Alleles"
  discard "not implemented"


proc parseContainerManufacturerAndCatalogNumber(number: string) =
  ## Parse Data Structure 017, "Container Manufacturer and Catalog Number"
  discard "not implemented"


proc parseContainerLotNumber(number: string) =
  ## Parse Data Structure 018, "Container Lot Number"
  discard "not implemented"


proc parseDonorIdentificationNumber(number: string) =
  ## Parse Data Structure 019, "Donor Identification Number"
  discard "not implemented"


proc parseStaffMemberIdentificationNumber(number: string) =
  ## Parse Data Structure 020, "Staff Member Identification Number"
  discard "not implemented"


proc parseManufacturerAndCatalogNumber(number: string) =
  ## Parse Data Structure 021, "Manufacturer and Catalog Number: Items Other Than Containers"
  discard "not implemented"


proc parseLotNumber(number: string) =
  ## Parse Data Structure 022, "Lot Number: Items Other Than Containers"
  discard "not implemented"


proc parseCompoundMessage(number: string) =
  ## Parse Data Structure 023, "Compound Message"
  discard "not implemented"


proc parsePatientDateOfBirth(number: string) =
  ## Parse Data Structure 024, "Patient Date of Birth"
  discard "not implemented"


proc parsePatientIdentificationNumber(number: string) =
  ## Parse Data Structure 025, "Patient Identification Number"
  discard "not implemented"


proc parseExpirationMonthAndYear(number: string) =
  ## Parse Data Structure 026, "Expiration Month and Year"
  discard "not implemented"


proc parseTtiMarker(number: string) =
  ## Parse Data Structure 027, "Transfusion Transmitted Infection Marker"
  discard "not implemented"


proc parseProductConsignment(number: string) =
  ## Parse Data Structure 028, "Product Consignment"
  discard "not implemented"


proc parseDimensions(number: string) =
  ## Parse Data Structure 029, "Dimensions"
  discard "not implemented"


proc parseRedCellAntigensWithTestHistory(number: string) =
  ## Parse Data Structure 030, "Red Cell Antigens with Test History"
  discard "not implemented"


proc parseFlexibleDateAndTime(number: string) =
  ## Parse Data Structure 031, "Flexible Date and Time"
  discard "not implemented"


proc parseProductDivisions(number: string) =
  ## Parse Data Structure 032, "Product Divisions"
  discard "not implemented"


proc parseProcessingFacilityInformationCode(number: string) =
  ## Parse Data Structure 033, "Processing Facility Information Code"
  discard "not implemented"


proc parseProcessorProductIdentificationCode(number: string) =
  ## Parse Data Structure 034, "Processor Product Identification Code"
  discard "not implemented"


proc parseMphoLotNumber(number: string) =
  ## Parse Data Structure 035, "MPHO Lot Number"
  discard "not implemented"


proc parseMphoSupplementalIdentificationNumber(number: string) =
  ## Parse Data Structure 036, "MPHO Supplemental Identification Number"
  discard "not implemented"


proc parseGlobalRegistrationIdentifierForDonorsRetired(number: string) =
  ## Parse Data Structure 037, "Global Registration Identifier for Donors"
  discard "not implemented"


proc parseSingleEuropeanCode(number: string) =
  ## Parse Data Structure 038, "Single European Code"
  discard "not implemented"


proc parseGlobalRegistrationIdentifierForDonors(number: string) =
  ## Parse Data Structure 039, "Global Registration Identifier for Donors"
  discard "not implemented"


proc parseChainOfIdentityIdentifier(number: string) =
  ## Parse Data Structure 040, "Chain of Identity Identifier"
  discard "not implemented"


proc parseNonIccba(number: string) =
  ## Parse Data Structure 041, "Data Structures Not Defined by ICCBBA"
  discard "not implemented"


proc parseReservedNationalDonorIdentificationNumber(number: string) =
  ## Parse Data Structure 042, "Reserved Data Identifiers for a Nationally Specified Donor Identification Number"
  discard "not implemented"


proc parseConfidentialUnitExclusion(number: string) =
  ## Parse Data Structure 043, "Confidential Unit Exclusion Status Data Structure
  discard "not implemented"

]#

# Main parsing proc
proc parseDataStructure(dataStructureType: DataStructure, code: string): string =
  ## Determines data structure type and returns HTML from the appropiate parser
  case dataStructureType
  of donationIdentificationNumber:
    result = parseDonationIdentificationNumber(code).toHtml
  of bloodGroupsABORhD:
    result = parseBloodGroupsABORhD(code).toHtml
  of productCode:
    result = parseProductCode(code).toHtml
  of expirationDate:
    result = parseExpirationDate(code).toHtml
  of expirationDateAndTime:
    result = parseExpirationDateAndTime(code).toHtml
  of collectionDate:
    result = parseCollectionDate(code).toHtml
  of collectionDateAndTime:
    result = parseCollectionDateAndTime(code).toHtml
  of productionDate:
    result = parseProductionDate(code).toHtml
  of productionDateAndTime:
    result = parseProductionDateAndTime(code).toHtml
  of specialTestingGeneral:
    result = parseSpecialTestingGeneral(code).toHtml
  of specialTestingAntigensRetired:
    result = parseSpecialTestingAntigensRetired(code).toHtml
  of specialTestingAntigensGeneral:
    result = parseSpecialTestingAntigensGeneral(code).toHtml
  of specialTestingAntigensFinnish:
    result = parseSpecialTestingAntigensFinnish(code).toHtml
  else:
    result = "Tolkning är inte implementerad för datatypen: " & $dataStructureType


when defined(js):
  import dom

  proc interpretCode*() {.exportc.} =
    ## Interpret code and output results

    # clear output TODO: is there a cleaner way?
    document.getElementById("isbt128out").innerHtml = ""

    try:
      let
        code = $document.getElementById("code").value
        dataStructure = classifyDataStructure(code)
        html = parseDataStructure(dataStructure, code)
        # clean '<' as it causes problems with html
        cleanCode = code.replace("<", "&lt;")
        name = dataStructureNames[dataStructure]
        contents = h2(name) & p(cleanCode) & html
        # to save in history; input code and name as label, table shown when expanded
        toHist = details(summary(cleanCode & " &ndash; " & name), html).cstring

      # reset the form, restore focus; to allow for sequential inputs
      document.getElementById("codeinputform").reset()
      document.getElementById("code").focus()

      # set contents as active output
      document.getElementById("isbt128out").innerHtml = contents.cstring

      # save contents in history
      # we prepend to previous results in div by using insertAdjacentHTML
      document.getElementById("isbt128history").insertAdjacentHTML("afterbegin", toHist)
    except:
      let s = "Fel vid tolkning: " & getCurrentExceptionMsg()
      document.getElementById("isbt128out").innerHtml = s.cstring