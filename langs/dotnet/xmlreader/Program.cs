using System;
using System.Collections.Generic;
using System.IO;
using System.Xml;

class Program
{
    static void Main(string[] args)
    {
        if (args.Length == 0)
        {
            Console.WriteLine("XML file is missing");
            return;
        }

        string path = args[0];
        if (!File.Exists(path))
        {
            Console.WriteLine("File not found");
            return;
        }

        var ordersPerCustomer = new Dictionary<string, int>();
        var itemsPerCustomer = new Dictionary<string, int>();
        int activeCount = 0;

        using var reader = XmlReader.Create(path, new XmlReaderSettings { IgnoreWhitespace = true });

        string? currentCustomerId = null;
        string? currentStatus = null;
        int currentItemCount = 0;

        while (reader.Read())
        {
            if (reader.NodeType == XmlNodeType.Element && reader.Name == "order")
            {
                currentCustomerId = reader.GetAttribute("customer_id");
                currentStatus = reader.GetAttribute("status");
                currentItemCount = 0;
            }
            else if (reader.NodeType == XmlNodeType.Element && reader.Name == "item")
            {
                var quantityAttr = reader.GetAttribute("quantity");
                if (int.TryParse(quantityAttr, out int quantity))
                    currentItemCount += quantity;
            }
            else if (reader.NodeType == XmlNodeType.EndElement && reader.Name == "order")
            {
                if (string.IsNullOrEmpty(currentCustomerId)) continue;

                if (currentStatus == "active")
                    activeCount++;

                ordersPerCustomer[currentCustomerId] = ordersPerCustomer.GetValueOrDefault(currentCustomerId) + 1;
                itemsPerCustomer[currentCustomerId] = itemsPerCustomer.GetValueOrDefault(currentCustomerId) + currentItemCount;

                currentCustomerId = null;
                currentStatus = null;
                currentItemCount = 0;
            }

            if (reader.NodeType == XmlNodeType.EndElement && reader.Name == "orders")
                break;
        }

        int totalCustomers = ordersPerCustomer.Count;
        int totalOrders = ordersPerCustomer.Values.Sum();
        double averageCount = totalCustomers == 0 ? 0 : Math.Round((double)totalOrders / totalCustomers, 2);

        string maxCustomerId = itemsPerCustomer.Count > 0
            ? itemsPerCustomer.Aggregate((a, b) => a.Value > b.Value ? a : b).Key
            : "";

        string customerEmail = "";

        while (reader.Read())
        {
            if (reader.NodeType == XmlNodeType.Element && reader.Name == "customer")
            {
                string? id = reader.GetAttribute("id");
                if (id == maxCustomerId)
                {
                    while (reader.Read())
                    {
                        if (reader.NodeType == XmlNodeType.Element && reader.Name == "email")
                        {
                            customerEmail = reader.ReadElementContentAsString();
                            break;
                        }
                        else if (reader.NodeType == XmlNodeType.EndElement && reader.Name == "customer")
                            break;
                    }
                    break;
                }
            }
        }

        Console.WriteLine($"Active orders: {activeCount}");
        Console.WriteLine($"Average orders by customer: {averageCount}");
        Console.WriteLine($"Maximum items customer's email: {customerEmail}");
    }
}
