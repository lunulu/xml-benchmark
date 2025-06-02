import sys
import xml.etree.ElementTree as ET
from collections import defaultdict

if len(sys.argv) < 2:
    print("XML file is missing")
    sys.exit(1)

path = sys.argv[1]
tree = ET.parse(path)
root = tree.getroot()

orders = root.find('orders')
customers = root.find('customers')  # может быть None

active_count = 0
orders_per_customer = defaultdict(int)
items_per_customer = defaultdict(int)

for order in orders.findall('order'):
    customer_id = order.get('customer_id')
    status = order.get('status')
    if status == 'active':
        active_count += 1
    orders_per_customer[customer_id] += 1

    items = order.find('items')
    if items is not None:
        items_count = len(items.findall('item'))
        items_per_customer[customer_id] += items_count

total_customers = len(orders_per_customer)
total_orders = sum(orders_per_customer.values())
average_count = round(total_orders / total_customers, 2) if total_customers else 0

max_customer_id = max(items_per_customer.items(), key=lambda x: x[1], default=(None,))[0]
customer_email = None

if customers is not None and max_customer_id:
    for customer in customers.findall('customer'):
        if customer.get('id') == max_customer_id:
            email_elem = customer.find('email')
            if email_elem is not None and email_elem.text:
                customer_email = email_elem.text
            break

print(f"Active orders: {active_count}")
print(f"Average orders by customer: {average_count}")
print(f"Maximum items customer's email: {customer_email}")
