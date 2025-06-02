package main

import (
	"fmt"
	"os"
	"runtime"
	"strconv"

	"github.com/clbanning/mxj/v2"
)

func main() {
	runtime.GOMAXPROCS(1)

	if len(os.Args) < 2 {
		fmt.Println("XML file is missing")
		os.Exit(1)
	}
	path := os.Args[1]

	file, err := os.ReadFile(path)
	if err != nil {
		fmt.Println("Error reading file:", err)
		os.Exit(1)
	}

	mv, err := mxj.NewMapXml(file)
	if err != nil {
		fmt.Println("Error parsing XML:", err)
		os.Exit(1)
	}

	orders, _ := mv.ValuesForPath("data.orders.order")
	customers, _ := mv.ValuesForPath("data.customers.customer")

	activeCount := 0
	ordersPerCustomer := map[string]int{}
	itemsPerCustomer := map[string]int{}

	for _, o := range orders {
		order := o.(map[string]interface{})
		status := order["-status"].(string)
		customerID := order["-customer_id"].(string)

		if status == "active" {
			activeCount++
		}
		ordersPerCustomer[customerID]++

		var items []interface{}
		switch val := order["items"].(map[string]interface{})["item"].(type) {
		case []interface{}:
			items = val
		case map[string]interface{}:
			items = []interface{}{val}
		}

		for _, it := range items {
			item := it.(map[string]interface{})
			qtyStr := fmt.Sprintf("%v", item["-quantity"])
			qty, _ := strconv.Atoi(qtyStr)
			itemsPerCustomer[customerID] += qty
		}
	}

	totalCustomers := len(ordersPerCustomer)
	totalOrders := 0
	for _, count := range ordersPerCustomer {
		totalOrders += count
	}
	averageCount := 0.0
	if totalCustomers > 0 {
		averageCount = float64(totalOrders) / float64(totalCustomers)
	}

	var maxCustomerID string
	maxItems := -1
	for id, items := range itemsPerCustomer {
		if items > maxItems {
			maxItems = items
			maxCustomerID = id
		}
	}

	var customerEmail string
	for _, c := range customers {
		cust := c.(map[string]interface{})
		if cust["-id"] == maxCustomerID {
			customerEmail = fmt.Sprintf("%v", cust["email"])
			break
		}
	}

	fmt.Printf("Active orders: %d\n", activeCount)
	fmt.Printf("Average orders by customer: %.2f\n", averageCount)
	fmt.Printf("Maximum items customer's email: %s\n", customerEmail)
}
