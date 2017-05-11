/*
 * Copyright:      Copyright 2017 (c) Parametric Technology GmbH
 * Product:        PTC Integrity Lifecycle Manager
 * Author:         Volker Eckardt, Principal Consultant ALM
 * Purpose:        Custom Developed Code
 * **************  File Version Details  **************
 * Revision:       $Revision: 1.1 $
 * Last changed:   $Date: 2017/05/02 12:18:39CEST $
 */
package api;

import com.mks.api.response.Item;
import com.mks.api.response.ItemList;
import com.mks.api.response.WorkItem;
import static java.lang.System.out;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.NoSuchElementException;

/**
 *
 * @author veckardt
 */
public class StaticGroup {

    // WorkItem groupWorkItem;
    ItemList membership = null;
    ItemList references = null;
    String description;
    String name;

    public StaticGroup(WorkItem wi) {
        // groupWorkItem = wi;
        description = wi.getField("description").getValueAsString();
        name = wi.getId();
        try {
            references = (ItemList) wi.getField("references").getList();
        } catch (NoSuchElementException ex) {

        }
    }

    public StaticGroup(WorkItem wi, ItemList membershipFromMKS) {
        description = wi.getField("description").getValueAsString();
        name = wi.getId();
        if (membershipFromMKS != null) {
            membership = membershipFromMKS;
        }
        try {
            references = (ItemList) wi.getField("references").getList();
        } catch (NoSuchElementException ex) {

        }
    }

    public String getDescription() {
        return description;
    }

    public String getName() {
        return name;
    }

    public String getMembership() {
        String data;
        String users = "";
        String groups = "";
        if (membership != null) {
            Iterator it = membership.getItems();
            while (it.hasNext()) {
                Item item = (Item) it.next();
                if (item.getModelType().equals("user")) {
                    users += (users.isEmpty() ? "" : ",") + item.getId();
                }
                if (item.getModelType().equals("group")) {
                    groups += (groups.isEmpty() ? "" : ",") + item.getId();
                }
            }
            data = "\n" + getName() + ";Users" + ";" + (users.isEmpty() ? "-" : users);
            data = data + "\n" + getName() + ";Groups" + ";" + (groups.isEmpty() ? "-" : groups);
            return data;
        }
        return "";
    }

    public Boolean isMemberOfGroup(String userName, String groupNames) {
        String data;
        String users = "";
        String groups = "";
        if (membership != null) {
            Iterator it = membership.getItems();
            while (it.hasNext()) {
                Item item = (Item) it.next();
                if (item.getModelType().equals("user")) {
                    users += (users.isEmpty() ? "" : ",") + item.getId();
                }
                if (item.getModelType().equals("group")) {
                    groups += (groups.isEmpty() ? "" : ",") + item.getId();
                }
            }
            if (userName.isEmpty() || containsOneOf(users, userName)) {
                return true;
            }
            // out.println("Checking " + groupNames + " in " + groups + " ...");

            if (containsOneOf(groups, groupNames)) {
                return true;
            }

        }
        return false;
    }

    public String getReferences(String object, String[] elementClasses) {
        List<String[]> elementList = new ArrayList<>();

        String data = "";
        String elementType = "";
        String elementName = "";
        if (references != null) {
            Iterator it = references.getItems();
            while (it.hasNext()) {
                Item item = (Item) it.next();
                String element = item.getId();
                // out.println(element);
                elementType = element.split(":")[0];
                elementName = element.split(":")[1];
                if (elementType.contains(object)) {
                    elementList.add(new String[]{elementType, elementName});
                }
                if (object.equals("Other") && !hasElement(elementClasses, elementType.replaceAll("Admin ", ""))) {
                    elementList.add(new String[]{elementType, elementName});
                }
            }
            // java.util.Collections.sort(elementList);
            for (String[] element : elementList) {
                data = data + "\n;" + element[0] + ";" + element[1];
            }
            return data;
        }
        return "";
    }

    boolean hasElement(String[] array, String element) {
        for (String elem : array) {
            if (element.contains(elem)) {
                return true;
            }
        }
        return false;
    }

    boolean containsOneOf(String baseList, String checkList) {
        if (!baseList.isEmpty() && !checkList.isEmpty()) {
            for (String group : checkList.split(",")) {
                if (("," + baseList + ",").contains("," + group + ",")) {
                    return true;
                }
            }
        }
        return false;
    }

}
