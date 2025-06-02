import sys
from lxml import etree
from collections import defaultdict

if len(sys.argv) < 2:
    print("XML file is missing")
    sys.exit(1)

path = sys.argv[1]
tree = etree.parse(path)
root = tree.getroot()

orders = root.xpath("orders/order")
customers = root.xpath("customers/customer")

active_count = 0
orders_per_customer = defaultdict(int)
items_per_customer = defaultdict(int)

for order in orders:
    customer_id = order.get("customer_id")
    status = order.get("status")
    if status == "active":
        active_count += 1
    orders_per_customer[customer_id] += 1

    items = order.xpath("items/item")
    items_count = 0
    for item in items:
        quantity = item.get("quantity")
        items_count += int(quantity) if quantity is not None else 1
    items_per_customer[customer_id] += items_count


total_customers = len(orders_per_customer)
total_orders = sum(orders_per_customer.values())
average_count = round(total_orders / total_customers, 2) if total_customers else 0

max_customer_id = max(items_per_customer.items(), key=lambda x: x[1], default=(None,))[0]
customer_email = None

if max_customer_id:
    for customer in customers:
        if customer.get("id") == max_customer_id:
            email_elem = customer.find("email")
            if email_elem is not None and email_elem.text:
                customer_email = email_elem.text
            break

print(f"Active orders: {active_count}")
print(f"Average orders by customer: {average_count}")
print(f"Maximum items customer's email: {customer_email}")
