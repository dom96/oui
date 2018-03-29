import oui

let data = parseOui("tests/oui.txt")

doAssert data["00:CD:FE"].company == "Apple, Inc."
doAssert data["C0:EE:FB"].company == "OnePlus Tech (Shenzhen) Ltd"