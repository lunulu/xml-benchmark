const fs = require('fs');
const sax = require('sax');

if (process.argv.length < 3) {
    console.log('XML file is missing');
    process.exit(1);
}

const path = process.argv[2];
const stream = fs.createReadStream(path, { encoding: 'utf8' });

const parser = sax.createStream(true);

let currentTag = null;
let inOrder = false;
let inItems = false;
let currentCustomerId = null;
let currentStatus = null;
let itemCount = 0;

let inCustomer = false;
let currentCustomerNodeId = null;
let currentEmail = null;
let collectingEmail = false;

let activeCount = 0;
const ordersPerCustomer = {};
const itemsPerCustomer = {};
const emailsById = {};

parser.on('opentag', node => {
    currentTag = node.name;

    if (node.name === 'order') {
        inOrder = true;
        currentCustomerId = node.attributes.customer_id;
        currentStatus = node.attributes.status;
        itemCount = 0;
    }

    if (inOrder && node.name === 'items') {
        inItems = true;
    }

    if (inItems && node.name === 'item') {
        const quantity = parseInt(node.attributes.quantity || '1', 10);
        itemCount += quantity;
    }

    if (node.name === 'customer') {
        inCustomer = true;
        currentCustomerNodeId = node.attributes.id;
    }

    if (inCustomer && node.name === 'email') {
        collectingEmail = true;
        currentEmail = '';
    }
});

parser.on('text', text => {
    if (collectingEmail) {
        currentEmail += text.trim();
    }
});

parser.on('closetag', tag => {
    if (tag === 'order') {
        if (currentStatus === 'active') activeCount++;
        ordersPerCustomer[currentCustomerId] = (ordersPerCustomer[currentCustomerId] || 0) + 1;
        itemsPerCustomer[currentCustomerId] = (itemsPerCustomer[currentCustomerId] || 0) + itemCount;

        inOrder = false;
        inItems = false;
        currentCustomerId = null;
        currentStatus = null;
        itemCount = 0;
    }

    if (tag === 'email') {
        if (collectingEmail && currentCustomerNodeId) {
            emailsById[currentCustomerNodeId] = currentEmail;
        }
        collectingEmail = false;
    }

    if (tag === 'customer') {
        inCustomer = false;
        currentCustomerNodeId = null;
        currentEmail = null;
    }
});

parser.on('end', () => {
    const totalCustomers = Object.keys(ordersPerCustomer).length;
    const totalOrders = Object.values(ordersPerCustomer).reduce((a, b) => a + b, 0);
    const averageCount = totalCustomers === 0 ? 0 : +(totalOrders / totalCustomers).toFixed(2);

    let maxCustomerId = null;
    let maxItems = -1;
    for (const [id, count] of Object.entries(itemsPerCustomer)) {
        if (count > maxItems) {
            maxItems = count;
            maxCustomerId = id;
        }
    }

    const customerEmail = emailsById[maxCustomerId] || null;

    console.log(`Active orders: ${activeCount}`);
    console.log(`Average orders by customer: ${averageCount}`);
    console.log(`Maximum items customer's email: ${customerEmail}`);
});

stream.pipe(parser);
