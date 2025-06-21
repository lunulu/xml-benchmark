<?php

if ($argc < 2) {
    echo "XML file is missing\n";
    exit(1);
}

$path = $argv[1];
$reader = new XMLReader();

if (!$reader->open($path)) {
    echo "Failed to open XML file\n";
    exit(1);
}

$activeCount = 0;
$ordersPerCustomer = [];
$itemsPerCustomer = [];
$customers = [];

$currentElement = null;

while ($reader->read()) {
    if ($reader->nodeType === XMLReader::ELEMENT) {
        switch ($reader->name) {
            case 'order':
                $customerId = $reader->getAttribute('customer_id');
                $status = $reader->getAttribute('status');

                if ($status === 'active') {
                    $activeCount++;
                }

                $ordersPerCustomer[$customerId] = ($ordersPerCustomer[$customerId] ?? 0) + 1;

                $itemsCount = 0;
                $depth = $reader->depth;

                while ($reader->read() && ($reader->depth > $depth || $reader->nodeType !== XMLReader::END_ELEMENT)) {
                    if ($reader->nodeType === XMLReader::ELEMENT && $reader->name === 'item') {
                        $quantity = $reader->getAttribute('quantity') ?? 0;
                        $itemsCount += (int)$quantity;
                    }
                }

                $itemsPerCustomer[$customerId] = ($itemsPerCustomer[$customerId] ?? 0) + $itemsCount;
                break;

            case 'customer':
                $id = $reader->getAttribute('id');
                $customerNode = simplexml_load_string($reader->readOuterXML());
                $email = (string) $customerNode->email;
                $customers[$id] = $email;
                $reader->next();
                break;
        }
    }
}

$reader->close();

$totalCustomers = count($ordersPerCustomer);
$totalOrders = array_sum($ordersPerCustomer);
$averageCount = $totalCustomers === 0 ? 0 : round($totalOrders / $totalCustomers, 2);

$maxCustomerId = array_keys($itemsPerCustomer, max($itemsPerCustomer))[0] ?? null;
$customerEmail = $customers[$maxCustomerId] ?? null;

echo "Active orders: $activeCount\n";
echo "Average orders by customer: $averageCount\n";
echo "Maximum items customer's email: $customerEmail\n";
