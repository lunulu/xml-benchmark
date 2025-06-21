import org.xml.sax.*;
import org.xml.sax.helpers.DefaultHandler;

import javax.xml.parsers.SAXParserFactory;
import java.io.File;
import java.util.*;

public class Main {
    public static void main(String[] args) throws Exception {
        if (args.length == 0) {
            System.out.println("XML file is missing");
            System.exit(1);
        }

        String path = args[0];
        SAXParserFactory factory = SAXParserFactory.newInstance();
        var saxParser = factory.newSAXParser();

        MyHandler handler = new MyHandler();
        saxParser.parse(new File(path), handler);

        int totalCustomers = handler.ordersPerCustomer.size();
        int totalOrders = handler.ordersPerCustomer.values().stream().mapToInt(i -> i).sum();
        double averageCount = totalCustomers == 0 ? 0 : Math.round((double) totalOrders / totalCustomers * 100.0) / 100.0;

        String maxCustomerId = handler.itemsPerCustomer.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse(null);

        String email = maxCustomerId != null ? handler.customerEmails.get(maxCustomerId) : null;

        System.out.println("Active orders: " + handler.activeCount);
        System.out.println("Average orders by customer: " + averageCount);
        System.out.println("Maximum items customer's email: " + email);
    }

    static class MyHandler extends DefaultHandler {
        int activeCount = 0;
        Map<String, Integer> ordersPerCustomer = new HashMap<>();
        Map<String, Integer> itemsPerCustomer = new HashMap<>();
        Map<String, String> customerEmails = new HashMap<>();

        String currentCustomerId = null;
        String currentOrderCustomerId = null;
        boolean insideEmail = false;
        StringBuilder emailBuffer = new StringBuilder();

        @Override
        public void startElement(String uri, String localName, String qName, Attributes attributes) {
            switch (qName) {
                case "order":
                    currentOrderCustomerId = attributes.getValue("customer_id");
                    String status = attributes.getValue("status");
                    if ("active".equalsIgnoreCase(status)) {
                        activeCount++;
                    }
                    ordersPerCustomer.merge(currentOrderCustomerId, 1, Integer::sum);
                    break;

                case "item":
                    String quantityStr = attributes.getValue("quantity");
                    int quantity = quantityStr != null ? Integer.parseInt(quantityStr) : 0;
                    itemsPerCustomer.merge(currentOrderCustomerId, quantity, Integer::sum);
                    break;

                case "customer":
                    currentCustomerId = attributes.getValue("id");
                    break;

                case "email":
                    insideEmail = true;
                    emailBuffer.setLength(0);
                    break;
            }
        }

        @Override
        public void characters(char[] ch, int start, int length) {
            if (insideEmail) {
                emailBuffer.append(ch, start, length);
            }
        }

        @Override
        public void endElement(String uri, String localName, String qName) {
            if ("email".equals(qName) && currentCustomerId != null) {
                customerEmails.put(currentCustomerId, emailBuffer.toString().trim());
                insideEmail = false;
            }
        }
    }
}
