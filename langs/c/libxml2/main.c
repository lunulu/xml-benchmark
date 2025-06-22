#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libxml/parser.h>
#include <libxml/xpath.h>
#include <glib.h>

typedef struct {
    int orders;
    int items;
} CustomerStats;

void die(const char *msg) {
    fprintf(stderr, "%s\n", msg);
    exit(1);
}

xmlXPathObjectPtr safe_xpath(xmlDocPtr doc, xmlXPathContextPtr ctx, const char *xpath) {
    xmlXPathObjectPtr result = xmlXPathEvalExpression((xmlChar *)xpath, ctx);
    if (!result || !result->nodesetval) {
        fprintf(stderr, "❌ XPath failed: %s\n", xpath);
        exit(1);
    }
    return result;
}

char *get_attr(xmlNodePtr node, const char *name) {
    xmlChar *val = xmlGetProp(node, (const xmlChar *)name);
    if (!val) return NULL;
    char *str = strdup((const char *)val);
    xmlFree(val);
    return str;
}

int main(int argc, char **argv) {
    if (argc < 2) die("XML file is missing");

    xmlInitParser();
    xmlDocPtr doc = xmlParseFile(argv[1]);
    if (!doc) die("Failed to parse XML");

    xmlXPathContextPtr ctx = xmlXPathNewContext(doc);
    if (!ctx) die("Failed to create XPath context");

    xmlXPathObjectPtr orders = safe_xpath(doc, ctx, "//data/orders/order");
    xmlXPathObjectPtr customers = safe_xpath(doc, ctx, "//data/customers/customer");

    int active_count = 0, total_orders = 0;
    GHashTable *stats = g_hash_table_new(g_direct_hash, g_direct_equal);

    for (int i = 0; i < orders->nodesetval->nodeNr; i++) {
        xmlNodePtr order = orders->nodesetval->nodeTab[i];
        char *customer_id_str = get_attr(order, "customer_id");
        char *status = get_attr(order, "status");

        if (!customer_id_str || !status) {
            free(customer_id_str);
            free(status);
            continue;
        }

        int customer_id = atoi(customer_id_str);
        if (strcmp(status, "active") == 0)
            active_count++;

        gpointer key = GINT_TO_POINTER(customer_id);
        CustomerStats *cs = g_hash_table_lookup(stats, key);
        if (!cs) {
            cs = g_new0(CustomerStats, 1);
            g_hash_table_insert(stats, key, cs);
        }
        cs->orders++;

        xmlXPathSetContextNode(order, ctx);
        xmlXPathObjectPtr items = safe_xpath(doc, ctx, "items/item");

        for (int j = 0; j < items->nodesetval->nodeNr; j++) {
            xmlNodePtr item = items->nodesetval->nodeTab[j];
            char *qty_str = get_attr(item, "quantity");
            if (qty_str) {
                cs->items += atoi(qty_str);
                free(qty_str);
            }
        }

        xmlXPathFreeObject(items);
        free(customer_id_str);
        free(status);
    }

    int unique_customers = 0;
    int max_items = -1;
    int max_id = -1;

    GHashTableIter iter;
    gpointer key, value;
    g_hash_table_iter_init(&iter, stats);
    while (g_hash_table_iter_next(&iter, &key, &value)) {
        int id = GPOINTER_TO_INT(key);
        CustomerStats *cs = (CustomerStats *)value;

        total_orders += cs->orders;
        unique_customers++;
        if (cs->items > max_items) {
            max_items = cs->items;
            max_id = id;
        }
    }

    char *email = NULL;
    if (max_id >= 0) {
        for (int i = 0; i < customers->nodesetval->nodeNr; i++) {
            xmlNodePtr customer = customers->nodesetval->nodeTab[i];
            char *id_str = get_attr(customer, "id");
            if (id_str && atoi(id_str) == max_id) {
                xmlXPathSetContextNode(customer, ctx);
                xmlXPathObjectPtr email_nodes = safe_xpath(doc, ctx, "email");
                if (email_nodes->nodesetval->nodeNr > 0)
                    email = (char *)xmlNodeGetContent(email_nodes->nodesetval->nodeTab[0]);
                xmlXPathFreeObject(email_nodes);
                free(id_str);
                break;
            }
            free(id_str);
        }
    }

    printf("Active orders: %d\n", active_count);
    printf("Average orders by customer: %.2f\n", unique_customers ? (float)total_orders / unique_customers : 0.0);
    printf("Maximum items customer's email: %s\n", email ? email : "not found");

    xmlFree(email);
    g_hash_table_destroy(stats);
    xmlXPathFreeObject(orders);
    xmlXPathFreeObject(customers);
    xmlXPathFreeContext(ctx);
    xmlFreeDoc(doc);
    xmlCleanupParser();

    return 0;
}
