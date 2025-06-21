<?php

if ($argc < 2) {
    echo "XML file is missing\n";
    exit(1);
}

$path = $argv[1];

$doc = new DOMDocument();
$doc->load($path);

$xpath = new DOMXPath($doc);

$orderNodes = $xpath->query('/data/orders/order');
$customerNodes = $xpath->query('/data/customers/customer');

$activeCount = 0;
$ordersPerCustomer = [];
$itemsPerCustomer = [];

foreach ($orderNodes as $order) {
    $customerId = $order->getAttribute('customer_id');
    $status = $order->getAttribute('status');

    if ($status === 'active') {
        $activeCount++;
    }

    if (!isset($ordersPerCustomer[$customerId])) {
        $ordersPerCustomer[$customerId] = 0;
        $itemsPerCustomer[$customerId] = 0;
    }

    $ordersPerCustomer[$customerId]++;

    $items = $xpath->query('items/item', $order);
    foreach ($items as $item) {
        $qty = $item->getAttribute('quantity');
        $itemsPerCustomer[$customerId] += (int)$qty;
    }
}

$totalCustomers = count($ordersPerCustomer);
$totalOrders = array_sum($ordersPerCustomer);
$averageCount = $totalCustomers === 0 ? 0 : round($totalOrders / $totalCustomers, 2);

$maxCustomerId = null;
$maxItems = 0;
foreach ($itemsPerCustomer as $customerId => $count) {
    if ($count > $maxItems) {
        $maxItems = $count;
        $maxCustomerId = $customerId;
    }
}

$customerEmail = null;
foreach ($customerNodes as $customer) {
    if ($customer->getAttribute('id') === (string)$maxCustomerId) {
        $emailNode = $xpath->query('email', $customer)->item(0);
        if ($emailNode && $emailNode->nodeValue) {
            $customerEmail = trim($emailNode->nodeValue);
        }
        break;
    }
}


echo "Active orders: $activeCount\n";
echo "Average orders by customer: $averageCount\n";
echo "Maximum items customer's email: $customerEmail\n";
