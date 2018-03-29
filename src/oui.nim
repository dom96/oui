# oui
# Copyright Dominik Picheta
# Parser for the official OUI file.
# As shown here: http://standards-oui.ieee.org/oui/oui.txt
import strutils, tables, future, sequtils

type
  Oui* = array[3, uint8]

  OuiData* = distinct Table[Oui, OuiMeta]

  OuiMeta* = object
    oui*: Oui
    company*: string

proc toOctets(key: seq[string]): array[3, uint8] =
  for i in 0 ..< 3:
    result[i] = key[i].parseHexInt().uint8

proc parseOui*(filename: string): OuiData =
  var res = initTable[Oui, OuiMeta]()
  let file = open(filename)
  defer: file.close

  var i = 1
  var skip = false
  for line in file.lines():
    case i
    of 1:
      assert line.startsWith("OUI/MA-L")
    of 2:
      assert line.startsWith("company_id")
    of 3: discard
    of 4:
      assert line.len == 0
    else:
      case line
      of "":
        skip = false
      else:
        if not skip:
          let keyOctets = line[0 ..< 8].split('-')
          let company = line[18 .. ^1]
          let key = toOctets(keyOctets)
          res[key] = OuiMeta(oui: key, company: company)
          skip = true

    i.inc

  return res.OuiData

proc `[]`*(data: OuiData, key: array[3, uint8]): OuiMeta =
  let data = Table[Oui, OuiMeta](data)

  return data[key]

proc `[]`*(data: OuiData, key: string): OuiMeta =
  let s = key.split(':')
  doAssert s.len == 3

  return data[s.toOctets()]