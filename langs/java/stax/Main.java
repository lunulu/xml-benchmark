import javax.xml.stream.*;
import java.io.FileInputStream;
import java.util.*;

public class Main {
    public static void main(String[] args) throws Exception {
        if (args.length == 0) {
            System.out.println("XML file is missing");
            System.exit(1);
        }

        String path = args[0];
        XMLInputFactory factory = XMLInputFactory.newInstance();
        XMLStreamReader reader = factory.createXMLStreamReader(new FileInputStream(path));

        int activeCount = 0;
        Map<String, Integer> ordersPerCustomer = new HashMap<>();
        Map<String, Integer> itemsPerCustomer = new HashMap<>();
        Map<String, String> customerEmails = new HashMap<>();

        String currentElement = null;
        String currentOrderCustomerId = null;
        String currentCustomerId = null;
        String currentEmail = null;

        while (reader.hasNext()) {
            int event = reader.next();

            if (event == XMLStreamConstants.START_ELEMENT) {
                currentElement = reader.getLocalName();

                switch (currentElement) {
                    case "order":
                        currentOrderCustomerId = reader.getAttributeValue(null, "customer_id");
                        String status = reader.getAttributeValue(null, "status");
                        if ("active".equalsIgnoreCase(status)) {
                            activeCount++;
                        }
                        ordersPerCustomer.merge(currentOrderCustomerId, 1, Integer::sum);
                        break;

                    case "item":
                        String quantityStr = reader.getAttributeValue(null, "quantity");
                        int quantity = quantityStr != null ? Integer.parseInt(quantityStr) : 0;
                        itemsPerCustomer.merge(currentOrderCustomerId, quantity, Integer::sum);
                        break;

                    case "customer":
                        currentCustomerId = reader.getAttributeValue(null, "id");
                        break;

                    case "email":
                        currentEmail = "";
                        break;
                }

            } else if (event == XMLStreamConstants.CHARACTERS) {
                if ("email".equals(currentElement)) {
                    currentEmail += reader.getText().trim();
                }

            } else if (event == XMLStreamConstants.END_ELEMENT) {
                if ("email".equals(reader.getLocalName()) && currentCustomerId != null && currentEmail != null) {
                    customerEmails.put(currentCustomerId, currentEmail);
                }

                if ("customer".equals(reader.getLocalName())) {
                    currentCustomerId = null;
                    currentEmail = null;
                }
            }
        }

        int totalCustomers = ordersPerCustomer.size();
        int totalOrders = ordersPerCustomer.values().stream().mapToInt(i -> i).sum();
        double averageCount = totalCustomers == 0 ? 0 : Math.round((double) totalOrders / totalCustomers * 100.0) / 100.0;

        String maxCustomerId = itemsPerCustomer.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse(null);

        String maxEmail = maxCustomerId != null ? customerEmails.get(maxCustomerId) : null;

        System.out.println("Active orders: " + activeCount);
        System.out.println("Average orders by customer: " + averageCount);
        System.out.println("Maximum items customer's email: " + maxEmail);
    }
}
