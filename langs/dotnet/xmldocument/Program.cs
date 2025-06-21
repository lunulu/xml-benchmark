using System;
using System.Collections.Generic;
using System.Linq;
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
        var doc = new XmlDocument();
        doc.Load(path);

        var orderNodes = doc.SelectNodes("/data/orders/order") ?? new XmlNodeListWrapper();
        var customerNodes = doc.SelectNodes("/data/customers/customer") ?? new XmlNodeListWrapper();

        int activeCount = 0;
        var ordersPerCustomer = new Dictionary<string, int>();
        var itemsPerCustomer = new Dictionary<string, int>();

        foreach (XmlNode order in orderNodes.Cast<XmlNode>())
        {
            var customerId = GetAttr(order, "customer_id");
            var status = GetAttr(order, "status");

            if (status == "active") activeCount++;

            ordersPerCustomer[customerId] = ordersPerCustomer.GetValueOrDefault(customerId) + 1;

            var itemNodes = order.SelectNodes("items/item") ?? new XmlNodeListWrapper();
            int itemsCount = itemNodes
                .Cast<XmlNode>()
                .Sum(item => int.TryParse(GetAttr(item, "quantity"), out int q) ? q : 0);

            itemsPerCustomer[customerId] = itemsPerCustomer.GetValueOrDefault(customerId) + itemsCount;
        }

        int totalCustomers = ordersPerCustomer.Count;
        int totalOrders = ordersPerCustomer.Values.Sum();
        double averageCount = totalCustomers == 0 ? 0 : Math.Round((double)totalOrders / totalCustomers, 2);

        string maxCustomerId = itemsPerCustomer.OrderByDescending(x => x.Value).FirstOrDefault().Key;
        string customerEmail = customerNodes
            .Cast<XmlNode>()
            .FirstOrDefault(c => GetAttr(c, "id") == maxCustomerId)?
            .SelectSingleNode("email")?.InnerText ?? "";


        Console.WriteLine($"Active orders: {activeCount}");
        Console.WriteLine($"Average orders by customer: {averageCount}");
        Console.WriteLine($"Maximum items customer's email: {customerEmail}");
    }

    static string GetAttr(XmlNode node, string name)
        => node.Attributes?[name]?.Value ?? "";
}

class XmlNodeListWrapper : XmlNodeList
{
    public override int Count => 0;
    public override XmlNode? Item(int index) => null;
    public override System.Collections.IEnumerator GetEnumerator() => Enumerable.Empty<XmlNode>().GetEnumerator();
}
