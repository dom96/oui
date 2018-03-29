# oui
# Copyright Dominik Picheta
# Parser for the official OUI file.
# As shown here: http://standards-oui.ieee.org/oui/oui.txt
import strutils, tables, future

type
  Oui* = array[3, uint8]

  OuiData* = distinct Table[Oui, OuiData]

  OuiMetaData* = object
    oui*: Oui
    company*: string

proc parseOui*(filename: string): OuiData =
  var res = initTable[Oui, OuiData]()
  let file = open(filename)
  defer: file.close

  var i = 1
  for line in file.splitLines():
    case i
    of 1:
      assert line.startsWith("OUI/MA-L")
    of 2:
      assert line.startsWith("company_id")
    of 3: discard
    of 4:
      assert line.len == 0
    else:
      let keyOctets = line[0 ..< 8].split('-')
      let company = line[17 .. ^1]
      let key = keyOctets.map(i => i.parseHexInt().uint8)
      res[key] = OuiMetaData(oui: key, company: company)

    i.inc

  return res.OuiData

proc `[]`*(data: OuiData, key: array[3, uint8]): OuiMetaData =
  let data = data.Table[Oui, OuiData]

  return data[key]

proc `[]`*(data: OuiData, key: string): OuiMetaData =
  let s = key.split(':')
  doAssert s.len == 3

  return data[s.map(i => i.parseHexInt().uint8)]