from lxml import etree
tree = etree.parse(open('component.xml'))
root = tree.getroot()
spirit = "{http://www.spiritconsortium.org/XMLSchema/SPIRIT/1685-2009}"
xilinx = "{http://www.xilinx.com}"
busInterfaces = root.find(spirit+'busInterfaces')

for busInterface in busInterfaces:
    name = busInterface.find(spirit+'name')
    if 'axis' in name.text: name.text = name.text.upper()
    print name.text

def getbiname(bi): return bi.find(spirit+'name').text
sortedBusInterfaces = sorted(busInterfaces, key=getbiname)

for i, sbi in enumerate(sortedBusInterfaces):
    busInterfaces.remove(sbi)
    busInterfaces.insert(i, sbi)

    name = sbi.find(spirit+'name')
    if 'AXIS' in name.text:
        oldExt = sbi.find(spirit+'vendorExtensions')
        if oldExt is not None: sbi.remove(oldExt)

        if name.text.startswith('S'): IO = 'INPUTS'
        if name.text.startswith('M'): IO = 'OUTPUTS'
        index = int(name.text.split('_')[0][1:])

        vendorExtensions = etree.Element(spirit+'vendorExtensions')
        busInterfaceInfo = etree.Element(xilinx+'busInterfaceInfo')
        enablement = etree.Element(xilinx+'enablement')
        presence = etree.Element(xilinx+'presence')
        presence.text = 'optional'
        isEnabled = etree.Element(xilinx+'isEnabled')
        isEnabled.text = 'true'
        isEnabled.attrib[xilinx+'resolve'] = 'dependent'
        isEnabled.attrib[xilinx+'dependency'] = '$NUM_%s > %d'%(IO, index)

        vendorExtensions.append(busInterfaceInfo)
        busInterfaceInfo.append(enablement)
        enablement.append(presence)
        enablement.append(isEnabled)

        sbi.append(vendorExtensions)


#print etree.tostring(root, pretty_print=True)
open('component.xml', 'w').write(etree.tostring(root, pretty_print=True))
