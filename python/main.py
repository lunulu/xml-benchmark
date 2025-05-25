import sys
import xml.etree.ElementTree as ET

if len(sys.argv) < 2:
    print("Нужен путь к XML-файлу")
    sys.exit(1)

path = sys.argv[1]
tree = ET.parse(path)
root = tree.getroot()

active_count = 0

for order in root.findall("order"):
    if order.get("status") == "active":
        active_count += 1

print(f"Найдено active заказов: {active_count}")
