const fs = require('fs');
const { XMLParser } = require('fast-xml-parser');

if (process.argv.length < 3) {
    console.log('XML file is missing');
    process.exit(1);
}

const path = process.argv[2];
const xmlContent = fs.readFileSync(path, 'utf-8');

const parser = new XMLParser({ ignoreAttributes: false });
const doc = parser.parse(xmlContent);

const orders = doc.data.orders?.order || [];
const customers = doc.data.customers?.customer || [];

let activeCount = 0;
const ordersPerCustomer = {};
const itemsPerCustomer = {};

const ordersArray = Array.isArray(orders) ? orders : [orders];
ordersArray.forEach(order => {
    const customerId = order['@_customer_id'];
    const status = order['@_status'];
    if (status === 'active') activeCount++;

    ordersPerCustomer[customerId] = (ordersPerCustomer[customerId] || 0) + 1;

    const items = order.items?.item || [];
    const itemCount = Array.isArray(items) ? items.length : 1;
    itemsPerCustomer[customerId] = (itemsPerCustomer[customerId] || 0) + itemCount;
});

const customerIds = Object.keys(ordersPerCustomer);
const totalCustomers = customerIds.length;
const totalOrders = Object.values(ordersPerCustomer).reduce((a, b) => a + b, 0);
const averageCount = totalCustomers === 0 ? 0 : +(totalOrders / totalCustomers).toFixed(2);

let maxCustomerId = null;
let maxItems = -1;

for (const [customerId, count] of Object.entries(itemsPerCustomer)) {
    if (count > maxItems) {
        maxItems = count;
        maxCustomerId = customerId;
    }
}

let customerEmail = null;
const customersArray = Array.isArray(customers) ? customers : [customers];
for (const customer of customersArray) {
    if (customer['@_id'] === maxCustomerId) {
        const email = customer.email;
        customerEmail = Array.isArray(email) ? email[0] : email;
        break;
    }
}

console.log(`Active orders: ${activeCount}`);
console.log(`Average orders by customer: ${averageCount}`);
console.log(`Maximum items customer's email: ${customerEmail}`);
