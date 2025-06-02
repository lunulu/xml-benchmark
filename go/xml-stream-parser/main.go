package main

import (
    "bufio"
	"fmt"
	"os"
	"runtime"
	"strconv"

	xmlparser "github.com/tamerh/xml-stream-parser"
)

func main() {
	runtime.GOMAXPROCS(1)

	if len(os.Args) < 2 {
		fmt.Println("XML file is missing")
		os.Exit(1)
	}
	path := os.Args[1]

	file, err := os.Open(path)
	if err != nil {
		fmt.Println("Error opening file:", err)
		os.Exit(1)
	}
	defer file.Close()

	parser := xmlparser.NewXMLParser(bufio.NewReader(file), "order", "customer")

	activeCount := 0
	ordersPerCustomer := map[string]int{}
	itemsPerCustomer := map[string]int{}
	customerEmails := map[string]string{}

	for xmlNode := range parser.Stream() {
		switch xmlNode.Name {
		case "order":
			customerID := xmlNode.Attrs["customer_id"]
			status := xmlNode.Attrs["status"]

			if status == "active" {
				activeCount++
			}
			ordersPerCustomer[customerID]++

			items := xmlNode.Childs["items"]
			for _, itemsNode := range items {
				for _, itemNode := range itemsNode.Childs["item"] {
					qtyStr := itemNode.Attrs["quantity"]
					qty, err := strconv.Atoi(qtyStr)
					if err == nil {
						itemsPerCustomer[customerID] += qty
					}
				}
			}

		case "customer":
			id := xmlNode.Attrs["id"]
			emailNodes := xmlNode.Childs["email"]
			if len(emailNodes) > 0 {
				customerEmails[id] = emailNodes[0].InnerText
			}
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

	maxCustomerID := ""
	maxItems := -1
	for id, items := range itemsPerCustomer {
		if items > maxItems {
			maxItems = items
			maxCustomerID = id
		}
	}

	customerEmail := customerEmails[maxCustomerID]

	fmt.Printf("Active orders: %d\n", activeCount)
	fmt.Printf("Average orders by customer: %.2f\n", averageCount)
	fmt.Printf("Maximum items customer's email: %s\n", customerEmail)
}
