#include <expat.h>
#include <iostream>
#include <fstream>
#include <unordered_map>
#include <vector>
#include <cstring>
#include <cstdlib>
#include <iomanip>

struct ParserContext {
    int active_count = 0;
    int current_items = 0;
    std::string current_order_customer_id;
    std::string current_customer_id;
    std::string max_customer_id;
    std::string current_element;
    std::string current_email;
    std::string max_email;
    bool in_order = false;
    bool in_email = false;

    std::unordered_map<std::string, int> orders_per_customer;
    std::unordered_map<std::string, int> items_per_customer;
};

void startElement(void *userData, const char *name, const char **attrs) {
    ParserContext *ctx = static_cast<ParserContext *>(userData);
    ctx->current_element = name;

    if (strcmp(name, "order") == 0) {
        ctx->in_order = true;
        ctx->current_items = 0;
        for (int i = 0; attrs[i]; i += 2) {
            if (strcmp(attrs[i], "customer_id") == 0) {
                ctx->current_order_customer_id = attrs[i + 1];
            } else if (strcmp(attrs[i], "status") == 0 && strcmp(attrs[i + 1], "active") == 0) {
                ctx->active_count++;
            }
        }
    } else if (strcmp(name, "item") == 0 && ctx->in_order) {
        for (int i = 0; attrs[i]; i += 2) {
            if (strcmp(attrs[i], "quantity") == 0) {
                ctx->current_items += std::atoi(attrs[i + 1]);
            }
        }
    } else if (strcmp(name, "customer") == 0) {
        for (int i = 0; attrs[i]; i += 2) {
            if (strcmp(attrs[i], "id") == 0) {
                ctx->current_customer_id = attrs[i + 1];
            }
        }
    } else if (strcmp(name, "email") == 0) {
        ctx->in_email = true;
        ctx->current_email.clear();
    }
}

void endElement(void *userData, const char *name) {
    ParserContext *ctx = static_cast<ParserContext *>(userData);

    if (strcmp(name, "order") == 0) {
        const std::string &id = ctx->current_order_customer_id;
        ctx->orders_per_customer[id]++;
        ctx->items_per_customer[id] += ctx->current_items;

        if (ctx->items_per_customer[id] > ctx->items_per_customer[ctx->max_customer_id]) {
            ctx->max_customer_id = id;
        }

        ctx->in_order = false;
    } else if (strcmp(name, "email") == 0 && ctx->in_email) {
        if (ctx->current_customer_id == ctx->max_customer_id) {
            ctx->max_email = ctx->current_email;
        }
        ctx->in_email = false;
    }
}

void charData(void *userData, const char *s, int len) {
    ParserContext *ctx = static_cast<ParserContext *>(userData);
    if (ctx->in_email) {
        ctx->current_email.append(s, len);
    }
}

int main(int argc, char **argv) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " file.xml\n";
        return 1;
    }

    std::ifstream file(argv[1], std::ios::binary);
    if (!file) {
        perror("open");
        return 1;
    }

    ParserContext ctx;

    XML_Parser parser = XML_ParserCreate(nullptr);
    XML_SetUserData(parser, &ctx);
    XML_SetElementHandler(parser, startElement, endElement);
    XML_SetCharacterDataHandler(parser, charData);

    char buf[8192];
    while (file) {
        file.read(buf, sizeof(buf));
        std::streamsize len = file.gcount();
        if (XML_Parse(parser, buf, static_cast<int>(len), file.eof()) == XML_STATUS_ERROR) {
            std::cerr << "Parse error at line "
                      << XML_GetCurrentLineNumber(parser) << ": "
                      << XML_ErrorString(XML_GetErrorCode(parser)) << '\n';
            XML_ParserFree(parser);
            return 1;
        }
    }

    XML_ParserFree(parser);

    int total_orders = 0;
    for (const auto &[_, count] : ctx.orders_per_customer) total_orders += count;
    int customer_count = ctx.orders_per_customer.size();
    double average = customer_count > 0 ? (double)total_orders / customer_count : 0.0;

    std::cout << "Active orders: " << ctx.active_count << '\n';
    std::cout << "Average orders by customer: " << std::fixed << std::setprecision(2) << average << '\n';
    std::cout << "Maximum items customer's email: " << (ctx.max_email.empty() ? "(none)" : ctx.max_email) << '\n';

    return 0;
}
