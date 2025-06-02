package main

import (
	"encoding/xml"
	"fmt"
	"os"
	"runtime"
)

type Data struct {
	XMLName   xml.Name   `xml:"data"`
	Orders    Orders     `xml:"orders"`
	Customers []Customer `xml:"customers>customer"`
}

type Orders struct {
	Orders []Order `xml:"order"`
}

type Order struct {
	ID         string `xml:"id,attr"`
	CustomerID string `xml:"customer_id,attr"`
	Status     string `xml:"status,attr"`
	Items      []Item `xml:"items>item"`
}

type Item struct {
	ID       string  `xml:"id,attr"`
	Quantity int     `xml:"quantity,attr"`
	Name     string  `xml:"name"`
	Price    float64 `xml:"price"`
}

type Customer struct {
	ID      string `xml:"id,attr"`
	Name    string `xml:"name"`
	Email   string `xml:"email"`
	Address struct {
		Street string `xml:"street"`
		City   string `xml:"city"`
		Zip    string `xml:"zip"`
	} `xml:"address"`
}

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

	var data Data
	if err := xml.Unmarshal(file, &data); err != nil {
		fmt.Println("Error parsing XML:", err)
		os.Exit(1)
	}

	activeCount := 0
	ordersPerCustomer := map[string]int{}
	itemsPerCustomer := map[string]int{}

	for _, order := range data.Orders.Orders {
		if order.Status == "active" {
			activeCount++
		}
		ordersPerCustomer[order.CustomerID]++
		for _, item := range order.Items {
			itemsPerCustomer[order.CustomerID] += item.Quantity
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
	for _, customer := range data.Customers {
		if customer.ID == maxCustomerID {
			customerEmail = customer.Email
			break
		}
	}

	fmt.Printf("Active orders: %d\n", activeCount)
	fmt.Printf("Average orders by customer: %.2f\n", averageCount)
	fmt.Printf("Maximum items customer's email: %s\n", customerEmail)
}
