import sys
from lxml import etree
from collections import defaultdict

if len(sys.argv) < 2:
    print("XML file is missing")
    sys.exit(1)

path = sys.argv[1]

orders_per_customer = defaultdict(int)
items_per_customer = defaultdict(int)
active_count = 0

context = etree.iterparse(path, events=("end",), tag=("order", "customer"))

customer_email_map = {}

for event, elem in context:
    if elem.tag == "order":
        customer_id = elem.get("customer_id")
        status = elem.get("status")
        if status == "active":
            active_count += 1
        orders_per_customer[customer_id] += 1

        items = elem.findall("items/item")
        items_count = 0
        for item in items:
            quantity = item.get("quantity")
            items_count += int(quantity) if quantity is not None else 1
        items_per_customer[customer_id] += items_count


        elem.clear()
        while elem.getprevious() is not None:
            del elem.getparent()[0]

    elif elem.tag == "customer":
        customer_id = elem.get("id")
        email_elem = elem.find("email")
        if email_elem is not None and email_elem.text:
            customer_email_map[customer_id] = email_elem.text

        elem.clear()
        while elem.getprevious() is not None:
            del elem.getparent()[0]

total_customers = len(orders_per_customer)
total_orders = sum(orders_per_customer.values())
average_count = round(total_orders / total_customers, 2) if total_customers else 0

max_customer_id = max(items_per_customer.items(), key=lambda x: x[1], default=(None,))[0]
customer_email = customer_email_map.get(max_customer_id)

print(f"Active orders: {active_count}")
print(f"Average orders by customer: {average_count}")
print(f"Maximum items customer's email: {customer_email}")
