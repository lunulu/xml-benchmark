import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.*;
import java.io.File;
import java.util.*;

public class Main {
    public static void main(String[] args) throws Exception {
        if (args.length == 0) {
            System.out.println("XML file is missing");
            System.exit(1);
        }

        String path = args[0];
        Document doc = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(new File(path));
        doc.getDocumentElement().normalize();

        Element root = doc.getDocumentElement();
        NodeList rootChildren = root.getChildNodes();

        Map<String, Integer> ordersPerCustomer = new HashMap<>();
        Map<String, Integer> itemsPerCustomer = new HashMap<>();
        Map<String, String> customerEmails = new HashMap<>();
        int activeCount = 0;

        for (int i = 0; i < rootChildren.getLength(); i++) {
            Node node = rootChildren.item(i);
            if (!(node instanceof Element)) continue;

            Element section = (Element) node;
            if (section.getTagName().equals("orders")) {
                NodeList orders = section.getChildNodes();
                for (int j = 0; j < orders.getLength(); j++) {
                    Node oNode = orders.item(j);
                    if (!(oNode instanceof Element)) continue;
                    Element order = (Element) oNode;

                    String customerId = order.getAttribute("customer_id");
                    String status = order.getAttribute("status");
                    if ("active".equalsIgnoreCase(status)) activeCount++;

                    ordersPerCustomer.merge(customerId, 1, Integer::sum);

                    int itemCount = 0;
                    NodeList orderChildren = order.getChildNodes();
                    for (int k = 0; k < orderChildren.getLength(); k++) {
                        Node itemsNode = orderChildren.item(k);
                        if (!(itemsNode instanceof Element)) continue;
                        Element items = (Element) itemsNode;
                        if (!items.getTagName().equals("items")) continue;

                        NodeList itemList = items.getChildNodes();
                        for (int m = 0; m < itemList.getLength(); m++) {
                            Node itemNode = itemList.item(m);
                            if (!(itemNode instanceof Element)) continue;
                            Element item = (Element) itemNode;
                            String qStr = item.getAttribute("quantity");
                            if (!qStr.isEmpty()) {
                                itemCount += Integer.parseInt(qStr);
                            }
                        }
                    }

                    itemsPerCustomer.merge(customerId, itemCount, Integer::sum);
                }
            } else if (section.getTagName().equals("customers")) {
                NodeList customers = section.getChildNodes();
                for (int j = 0; j < customers.getLength(); j++) {
                    Node cNode = customers.item(j);
                    if (!(cNode instanceof Element)) continue;
                    Element customer = (Element) cNode;

                    String id = customer.getAttribute("id");
                    NodeList cChildren = customer.getChildNodes();
                    for (int k = 0; k < cChildren.getLength(); k++) {
                        Node cField = cChildren.item(k);
                        if (cField instanceof Element && ((Element) cField).getTagName().equals("email")) {
                            String email = cField.getTextContent().trim();
                            customerEmails.put(id, email);
                            break;
                        }
                    }
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

        String customerEmail = maxCustomerId != null ? customerEmails.get(maxCustomerId) : null;

        System.out.println("Active orders: " + activeCount);
        System.out.println("Average orders by customer: " + averageCount);
        System.out.println("Maximum items customer's email: " + customerEmail);
    }
}
