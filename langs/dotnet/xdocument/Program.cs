using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Xml.Linq;

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

        XDocument doc = XDocument.Load(path);

        var orders = doc.Descendants("order").ToList();
        var customers = doc.Descendants("customer").ToList();

        int activeCount = 0;
        var ordersPerCustomer = new Dictionary<string, int>();
        var itemsPerCustomer = new Dictionary<string, int>();

        foreach (var order in orders)
        {
            string customerId = order.Attribute("customer_id")?.Value ?? "";
            string status = order.Attribute("status")?.Value ?? "";

            if (status == "active")
                activeCount++;

            if (!ordersPerCustomer.ContainsKey(customerId))
                ordersPerCustomer[customerId] = 0;
            ordersPerCustomer[customerId]++;

            var items = order.Descendants("item");
            int itemsCount = items.Sum(i =>
            {
                var attr = i.Attribute("quantity");
                return attr != null ? int.Parse(attr.Value) : 0;
            });

            if (!itemsPerCustomer.ContainsKey(customerId))
                itemsPerCustomer[customerId] = 0;
            itemsPerCustomer[customerId] += itemsCount;
        }

        int totalCustomers = ordersPerCustomer.Keys.Count;
        int totalOrders = ordersPerCustomer.Values.Sum();
        double averageCount = totalCustomers == 0 ? 0 : Math.Round((double)totalOrders / totalCustomers, 2);

        string maxCustomerId = itemsPerCustomer.OrderByDescending(kvp => kvp.Value).FirstOrDefault().Key ?? "";

        string customerEmail = customers
            .FirstOrDefault(c => c.Attribute("id")?.Value == maxCustomerId)?
            .Element("email")?.Value ?? "";


        Console.WriteLine($"Active orders: {activeCount}");
        Console.WriteLine($"Average orders by customer: {averageCount}");
        Console.WriteLine($"Maximum items customer's email: {customerEmail}");
    }
}
