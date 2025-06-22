#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <expat.h>
#include "uthash.h"

#define BUF_SIZE 8192

typedef struct {
    char id[64];         // customer_id
    int orders;
    int items;
    UT_hash_handle hh;
} Customer;

typedef struct {
    int active_orders;
    int total_orders;
    Customer *customers;
    char max_items_customer[64];
    int max_items;
    char max_items_email[128];

    // Current parse state
    char current_element[64];
    int in_email;
    int in_customer;
    char current_customer_id[64];
    char current_order_customer_id[64];
    char current_order_status[32];
    int current_items;
} ParserState;

static void XMLCALL start_element(void *userData, const char *name, const char **atts) {
    ParserState *s = userData;
    strcpy(s->current_element, name);

    if (strcmp(name, "order") == 0) {
        s->current_items = 0;
        s->current_order_customer_id[0] = '\0';
        s->current_order_status[0] = '\0';
        for (int i = 0; atts[i]; i += 2) {
            if (strcmp(atts[i], "customer_id") == 0)
                strcpy(s->current_order_customer_id, atts[i+1]);
            else if (strcmp(atts[i], "status") == 0)
                strcpy(s->current_order_status, atts[i+1]);
        }
        if (strcmp(s->current_order_status, "active") == 0)
            s->active_orders++;
        s->total_orders++;
    } else if (strcmp(name, "item") == 0) {
        for (int i = 0; atts[i]; i += 2) {
            if (strcmp(atts[i], "quantity") == 0)
                s->current_items += atoi(atts[i+1]);
        }
    } else if (strcmp(name, "customer") == 0) {
        s->in_customer = 1;
        for (int i = 0; atts[i]; i += 2) {
            if (strcmp(atts[i], "id") == 0)
                strcpy(s->current_customer_id, atts[i+1]);
        }
    } else if (strcmp(name, "email") == 0 && s->in_customer) {
        s->in_email = 1;
    }
}

static void XMLCALL end_element(void *userData, const char *name) {
    ParserState *s = userData;
    s->current_element[0] = '\0';

    if (strcmp(name, "order") == 0 && s->current_order_customer_id[0]) {
        Customer *c = NULL;
        HASH_FIND_STR(s->customers, s->current_order_customer_id, c);
        if (!c) {
            c = malloc(sizeof(Customer));
            strcpy(c->id, s->current_order_customer_id);
            c->orders = 0;
            c->items = 0;
            HASH_ADD_STR(s->customers, id, c);
        }
        c->orders += 1;
        c->items += s->current_items;

        if (c->items > s->max_items) {
            s->max_items = c->items;
            strcpy(s->max_items_customer, c->id);
        }
    } else if (strcmp(name, "customer") == 0) {
        s->in_customer = 0;
    } else if (strcmp(name, "email") == 0) {
        s->in_email = 0;
    }
}

static void XMLCALL character_data(void *userData, const char *s, int len) {
    ParserState *state = userData;
    if (state->in_customer && state->in_email &&
        strcmp(state->current_customer_id, state->max_items_customer) == 0) {
        strncpy(state->max_items_email, s, len);
        state->max_items_email[len] = '\0';
    }
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "XML file is missing\n");
        return 1;
    }

    FILE *file = fopen(argv[1], "r");
    if (!file) {
        perror("fopen");
        return 1;
    }

    ParserState state = {0};

    XML_Parser parser = XML_ParserCreate(NULL);
    XML_SetUserData(parser, &state);
    XML_SetElementHandler(parser, start_element, end_element);
    XML_SetCharacterDataHandler(parser, character_data);

    char buf[BUF_SIZE];
    int done;

    do {
        size_t len = fread(buf, 1, sizeof(buf), file);
        done = len < sizeof(buf);
        if (XML_Parse(parser, buf, len, done) == XML_STATUS_ERROR) {
            fprintf(stderr, "Parse error: %s\n",
                    XML_ErrorString(XML_GetErrorCode(parser)));
            return 1;
        }
    } while (!done);

    fclose(file);
    XML_ParserFree(parser);

    int customer_count = HASH_COUNT(state.customers);
    double avg = customer_count ? (double)state.total_orders / customer_count : 0;

    printf("Active orders: %d\n", state.active_orders);
    printf("Average orders by customer: %.2f\n", avg);
    printf("Maximum items customer's email: %s\n", state.max_items_email);

    // Cleanup
    Customer *c, *tmp;
    HASH_ITER(hh, state.customers, c, tmp) {
        HASH_DEL(state.customers, c);
        free(c);
    }

    return 0;
}
