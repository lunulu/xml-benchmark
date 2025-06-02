import sys
import xmltodict
from collections import defaultdict

if len(sys.argv) < 2:
    print("XML file is missing")
    sys.exit(1)

path = sys.argv[1]

with open(path, 'r', encoding='utf-8') as f:
    data = xmltodict.parse(f.read())

orders = data['data']['orders']['order']
orders = orders if isinstance(orders, list) else [orders]

# Может не быть customers — добавь в XML для финальной проверки
customers = data['data'].get('customers', {}).get('customer', [])
if not isinstance(customers, list):
    customers = [customers]

active_count = 0
orders_per_customer = defaultdict(int)
items_per_customer = defaultdict(int)

for order in orders:
    customer_id = order['@customer_id']
    status = order.get('@status')
    if status == 'active':
        active_count += 1
    orders_per_customer[customer_id] += 1

    items = order.get('items', {}).get('item', [])
    if not isinstance(items, list):
        items = [items]
    items_per_customer[customer_id] += len(items)

total_customers = len(orders_per_customer)
total_orders = sum(orders_per_customer.values())
average_count = round(total_orders / total_customers, 2) if total_customers else 0

max_customer_id = max(items_per_customer.items(), key=lambda x: x[1], default=(None,))[0]
customer_email = None

for customer in customers:
    if customer.get('@id') == max_customer_id:
        email = customer.get('email')
        if isinstance(email, dict):  # например <email><value>...</value></email>
            email = list(email.values())[0]
        customer_email = email
        break

print(f"Active orders: {active_count}")
print(f"Average orders by customer: {average_count}")
print(f"Maximum items customer's email: {customer_email}")
