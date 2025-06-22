#include <iostream>
#include "pugixml.hpp"
#include <unordered_map>
#include <string>
#include <numeric>
#include <iomanip>

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cerr << "XML file is missing" << std::endl;
        return 1;
    }

    const char* path = argv[1];
    pugi::xml_document doc;
    pugi::xml_parse_result result = doc.load_file(path);

    if (!result) {
        std::cerr << "Failed to load XML file: " << result.description() << std::endl;
        return 1;
    }

    auto orders = doc.select_nodes("/data/orders/order");
    auto customers = doc.select_nodes("/data/customers/customer");

    int active_count = 0;
    std::unordered_map<std::string, int> orders_per_customer;
    std::unordered_map<std::string, int> items_per_customer;

    for (const auto& order_node : orders) {
        pugi::xml_node order = order_node.node();
        std::string customer_id = order.attribute("customer_id").value();
        std::string status = order.attribute("status").value();

        if (status == "active") {
            ++active_count;
        }

        ++orders_per_customer[customer_id];

        int item_count = 0;
        for (pugi::xml_node item : order.child("items").children("item")) {
            item_count += item.attribute("quantity").as_int();
        }
        items_per_customer[customer_id] += item_count;
    }

    int total_customers = orders_per_customer.size();
    int total_orders = 0;
    for (const auto& [_, count] : orders_per_customer) {
        total_orders += count;
    }

    double average = total_customers == 0 ? 0 : static_cast<double>(total_orders) / total_customers;

    std::string max_customer_id;
    int max_items = -1;
    for (const auto& [cid, count] : items_per_customer) {
        if (count > max_items) {
            max_items = count;
            max_customer_id = cid;
        }
    }

    std::string customer_email;
    for (const auto& cust_node : customers) {
        pugi::xml_node customer = cust_node.node();
        if (customer.attribute("id").value() == max_customer_id) {
            customer_email = customer.child("email").child_value();
            break;
        }
    }

    std::cout << "Active orders: " << active_count << std::endl;
    std::cout << "Average orders by customer: " << std::fixed << std::setprecision(2) << average << std::endl;
    std::cout << "Maximum items customer's email: " << customer_email << std::endl;

    return 0;
}
