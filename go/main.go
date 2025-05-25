package main

import (
	"encoding/xml"
	"fmt"
	"os"
)

type Order struct {
	ID     string `xml:"id,attr"`
	Status string `xml:"status,attr"`
	Customer string `xml:"customer"`
}

type Orders struct {
	XMLName xml.Name `xml:"orders"`
	Orders  []Order  `xml:"order"`
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Нужен путь к XML-файлу")
		return
	}

	file, err := os.Open(os.Args[1])
	if err != nil {
		fmt.Println("Ошибка при открытии файла:", err)
		return
	}
	defer file.Close()

	var orders Orders
	decoder := xml.NewDecoder(file)
	err = decoder.Decode(&orders)
	if err != nil {
		fmt.Println("Ошибка при разборе XML:", err)
		return
	}

	count := 0
	for _, order := range orders.Orders {
		if order.Status == "active" {
			count++
		}
	}

	fmt.Printf("Найдено active заказов: %d\n", count)
}
