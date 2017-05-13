/*
 * Copyright:      Copyright 2017 (c) Parametric Technology GmbH
 * Product:        PTC Integrity Lifecycle Manager
 * Author:         Volker Eckardt, Principal Consultant ALM
 * Purpose:        Custom Developed Code
 * **************  File Version Details  **************
 * Revision:       $Revision: 1.3 $
 * Last changed:   $Date: 2017/05/13 21:22:50CEST $
 */
package api;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;

import com.mks.api.CmdRunner;
import com.mks.api.Command;
import com.mks.api.IntegrationPoint;
import com.mks.api.IntegrationPointFactory;
import com.mks.api.Option;
import com.mks.api.Session;
import com.mks.api.response.APIConnectionException;
import com.mks.api.response.APIException;
import com.mks.api.response.ApplicationConnectionException;
import com.mks.api.response.Field;
import com.mks.api.response.InvalidCommandOptionException;
import com.mks.api.response.Item;
import com.mks.api.response.ItemList;
import com.mks.api.response.Response;
import com.mks.api.response.WorkItem;
import com.mks.api.response.WorkItemIterator;
import com.mks.api.util.ResponseUtil;
import static java.lang.System.out;
import java.util.NoSuchElementException;
import java.util.TreeMap;
import java.util.logging.Level;
import java.util.logging.Logger;

import utils.Html;

public class IntegritySession {

    public enum IMCommands {

        types, fields, users, triggers, reports, states, queries
    }

    public Map<String, WorkItem> allFields = new HashMap<>();
    public Map<String, WorkItem> allFieldsSorted = new TreeMap<>();
    public Map<String, WorkItem> allFieldsById = new HashMap<>();
    public Map<String, WorkItem> allTriggers = new HashMap<>();
    public Map<String, WorkItem> allTypes = new LinkedHashMap<>();
    // public Map<String, Type> allTypes2 = new LinkedHashMap<>();
    public Map<String, WorkItem> allUsers = new LinkedHashMap<>();
    public Map<String, WorkItem> allIMProjects = new LinkedHashMap<>();
    public Map<String, WorkItem> allTestObjectives = new LinkedHashMap<>();
    public Map<String, DynamicGroup> allDynamicGroups = new LinkedHashMap<>();
    public Map<String, StaticGroup> allStaticGroups = new LinkedHashMap<>();
    public Map<String, String[]> solutionProperties; // =
    // intSession.getProperties(null,
    // "ALM_MKS Solution");

    // private CmdRunner cmdRunner = null;
    // private String commandUsed;
    private IntegrationPoint integrationPoint = null;
    private Session apiSession = null;
    private ConnectionDetails connection = new ConnectionDetails();

    public IntegritySession() throws APIException, IOException {
        IntegrationPointFactory ipf = IntegrationPointFactory.getInstance();
        try {

            integrationPoint = ipf.createIntegrationPoint(connection.getHostname(), connection.getPort(), 4, 11);
            apiSession = integrationPoint.createNamedSession(null, null, connection.getUser(), connection.getPassword());
            apiSession.setDefaultUsername(connection.getUser());
            apiSession.setDefaultPassword(connection.getPassword());

            out.println(connection.getLoginInfo());
            // System.out.println("IMConfig: Current Dir: " + System.getProperty("user.dir"));

            Command cmd = new Command(Command.IM, "connect");
            // cmd.addOption(new Option("gui"));
            execute(cmd);

        } catch (APIConnectionException ce) {
            out.println("IMConfig: Unable to connect to Integrity Server");
            throw ce;
        } catch (ApplicationConnectionException ace) {
            out.println("IMConfig: Integrity Client unable to connect to Integrity Server");
            throw ace;
        } catch (APIException apiEx) {
            out.println("IMConfig: Unable to initialize");
            throw apiEx;
        }
    }

//    public IntegritySession() throws APIException, IOException {
//
//        IntegrationPointFactory ipf = IntegrationPointFactory.getInstance();
//        try {
//
//            integrationPoint = ipf.createIntegrationPoint(hostname, port, 4, 11);
//            apiSession = integrationPoint.createNamedSession(null, null, username, password);
//            apiSession.setDefaultUsername(username);
//            apiSession.setDefaultPassword(password);
//
//            System.out.println("IMConfig: Logging in " + hostname + ":" + port + " with " + username + " ..");
//            // System.out.println("IMConfig: Current Dir: " + System.getProperty("user.dir"));
//
//            // cmdRunner = apiSession.createCmdRunner();
//            // cmdRunner.setDefaultHostname(host);
//            // cmdRunner.setDefaultPort(port);
//            // cmdRunner.setDefaultUsername("veckardt");
//            // cmdRunner.setDefaultPassword("");
//            // }
//            // apiSession = integrationPoint.getCommonSession();
//            Command cmd = new Command(Command.IM, "connect");
//            // cmd.addOption(new Option("gui"));
//            this.execute(cmd);
//
//        } catch (APIConnectionException ce) {
//            System.out.println("IMConfig: Unable to connect to Integrity Server");
//            throw ce;
//        } catch (ApplicationConnectionException ace) {
//            System.out.println("IMConfig: Integrity Client unable to connect to Integrity Server");
//            throw ace;
//        } catch (APIException apiEx) {
//            System.out.println("IMConfig: Unable to initialize");
//            throw apiEx;
//        }
//    }
    public Response execute(Command cmd) throws APIException {
        long timestamp = System.currentTimeMillis();
        CmdRunner cmdRunner = apiSession.createCmdRunner();
        cmdRunner.setDefaultUsername(connection.getUser());
        cmdRunner.setDefaultPassword(connection.getPassword());
        cmdRunner.setDefaultHostname(connection.getHostname());
        cmdRunner.setDefaultPort(connection.getPort());
        // commandUsed = cmd.getCommandName();
        // OptionList ol = cmd.getOptionList();
        // for (int i=0; i<ol.size(); i++);
        //    Iterator o = ol.getOptions();
        //    o.

        Response response = cmdRunner.execute(cmd);
        cmdRunner.release();
        timestamp = System.currentTimeMillis() - timestamp;
        System.out.println("IMConfig - API: " + response.getCommandString() + " [" + timestamp + "ms]");
        return response;
    }

    // properties
    public Map<String, String[]> getProperties(WorkItem wi, String typeName) throws APIException {
        Map<String, String[]> properties = new LinkedHashMap<>();
        Field fld;

        if (wi == null) {
            Command cmd = new Command(Command.IM, "viewtype");
            cmd.addOption(new Option("showProperties"));
            cmd.addSelection(typeName.replace("+", " "));
            Response respo = this.execute(cmd);
            WorkItem wit = respo.getWorkItem(typeName.replace("+", " "));
            fld = wit.getField("properties");
        } else {
            fld = wi.getField("properties");
        }

        if (fld != null && fld.getList() != null) {
            @SuppressWarnings("rawtypes")
            ListIterator li = fld.getList().listIterator();
            while (li.hasNext()) {
                Item it = (Item) li.next();
                String pName = Html.toHtml(it.getField("name").getValueAsString());
                String pDescription = Html.toHtml("" + it.getField("description").getValueAsString());
                String pValue = Html.toHtml("" + it.getField("value").getValueAsString());
                properties.put(pName, new String[]{pValue, pDescription});
            }
        }
        return properties;
    }

    public Map<String, WorkItem> getIMProjects() throws APIException {
        Command cmd = new Command(Command.IM, "projects");
        // cmd.addOption(new Option("showProperties"));
        // cmd.addSelection(typeName.replace("+", " "));
        Response respo = this.execute(cmd);
        WorkItemIterator wit = respo.getWorkItems();
        while (wit.hasNext()) {
            WorkItem wi = wit.next();
            allIMProjects.put(wi.getId(), wi);
        }
        return allIMProjects;
    }

    public Map<String, WorkItem> getTestObjectives(String project) throws APIException {
        Command cmd = new Command(Command.IM, "issues");
        // im issues --query="All Test Objectives"
        // --fieldFilter=project=/Projects/Release2
        cmd.addOption(new Option("query", "All Test Objectives"));
        cmd.addOption(new Option("fieldFilter", "project=" + project));
        // cmd.addSelection(typeName.replace("+", " "));
        Response respo = this.execute(cmd);
        WorkItemIterator wit = respo.getWorkItems();
        while (wit.hasNext()) {
            WorkItem wi = wit.next();
            allTestObjectives.put(wi.getId(), wi);
        }
        return allTestObjectives;
    }

    public void setEditProperty(Map<String, String[]> properties,
            Map<String, String[]> typeEditProps, String propKey) {
        if (properties.containsKey(propKey)) {
            String field = solutionProperties.get(propKey.replace("ility.", "ilityField."))[0];
            String fieldDisplayName = this.allFields.get(field).getField("displayName")
                    .getValueAsString();
            typeEditProps.put(fieldDisplayName, new String[]{properties.get(propKey)[0], field});
        }
    }

    public List<String> getFieldList(WorkItem wi, String fieldName) {

        List<String> fieldList = new ArrayList<>();
        Field fld = wi.getField(fieldName);
        @SuppressWarnings("rawtypes")
        ListIterator li = fld.getList().listIterator();
        while (li.hasNext()) {
            Item it = (Item) li.next();
            fieldList.add(it.getId());
        }
        return fieldList;
    }

    public String getTypeDescription(String typeName) {
        WorkItem wi = allTypes.get(typeName.trim());
        if (wi != null && wi.getField("description") != null) {
            return wi.getField("description").getValueAsString();
        } else {
            return "";
        }
    }

    // fill the simple String map
    public Map<String, String> getFieldMap(WorkItem wi, String fieldName) {
        Map<String, String> fieldMap = new HashMap<>();
        Field fld = wi.getField(fieldName);
        if (fld != null && fld.getList() != null) {
            @SuppressWarnings("rawtypes")
            ListIterator li = fld.getList().listIterator();
            while (li.hasNext()) {
                Item it = (Item) li.next();
                if (!it.getId().equals("Unspecified")) {
                    fieldMap.put(it.getId(), it.getId());
                }
            }
        }
        return fieldMap;
    }

    public String getStaticGroupsForUser(String userName) {
        try {
            String staticGroups = "";
//        for (String name : allStaticGroups.keySet()) {
//            StaticGroup group = allStaticGroups.get(name);
//            if (group.isMemberOfGroup(userName, "")) {
//                staticGroups = staticGroups + (staticGroups.isEmpty() ? "" : ",") + group.getName();
//            }
//        }
            Command cmd = new Command(Command.AA, "users");
            cmd.addOption(new Option("groups"));
            cmd.addSelection(userName);
            // System.out.println("Reading " + fieldName + " ..");
            Response respo = this.execute(cmd);
            // ResponseUtil.printResponse(respo, 1, System.out);
            WorkItem wi = respo.getWorkItem(userName);
            staticGroups = wi.getField("groups").getValueAsString();

            return staticGroups;
        } catch (APIException ex) {
            Logger.getLogger(IntegritySession.class.getName()).log(Level.SEVERE, ex.getMessage(), ex);
            return "";
        }
    }

    public void readAllUsers() throws APIException {
        readAllObjects(IMCommands.users, allUsers);
    }

    public void readUser(String userName) throws APIException {
        Map<String, WorkItem> oneUser = new LinkedHashMap<>();
        readAllObjects(IMCommands.users, allUsers);
        for (String name : allUsers.keySet()) {
            if (name.equals(userName)) {
                oneUser.put(name, allUsers.get(userName));
                break;
            }
        }
        allUsers = oneUser;
    }

    public void readAllObjects(IMCommands type, Map<String, WorkItem> targetMap) throws APIException {
        targetMap.clear();
        Command cmd = new Command(Command.IM, type.name());
        // limit the fields to make this query fast, even if someone would have 2000
        // of each
        switch (type) {
            case triggers:
                cmd.addOption(new Option("fields", "name,rule,query,description,type"));
                break;
            case types:
                cmd.addOption(new Option("fields", "id,name,description"));
                break;
            case users:
                cmd.addOption(new Option("fields", "name,description,email,fullname,image,isActive,isInRealm"));
                break;
            default:
                cmd.addOption(new Option("fields", "id,name"));
                break;
        }

        Response respo = this.execute(cmd);
        // ResponseUtil.printResponse(respo, 1, System.out);
        WorkItemIterator wii = respo.getWorkItems();
        while (wii.hasNext()) {
            WorkItem wi = wii.next();
            if (type.equals(IMCommands.reports)) {
                targetMap.put(wi.getId().replaceAll(" ", "\\+"), wi);
            } else {
                targetMap.put(wi.getId(), wi);
            }
            // if (type.contentEquals("fields"))
            // allFieldsById.put(wi.getField("id").getValueAsString(), wi);
        }
    }

    public void readAllSIObjects(String type, Map<String, WorkItem> targetMap) throws APIException {
        targetMap.clear();
        Command cmd = new Command(Command.SI, type);
        // limit the fields to make this query fast, even if someone would have 2000
        // of each

        Response respo = this.execute(cmd);
        // ResponseUtil.printResponse(respo, 1, System.out);
        WorkItemIterator wii = respo.getWorkItems();
        while (wii.hasNext()) {
            WorkItem wi = wii.next();
            targetMap.put(wi.getId(), wi);
        }
    }

    public void readAllFields(String typeCriteria) throws APIException {
        Command cmd = new Command(Command.IM, "fields");
        cmd.addOption(new Option(
                "fields",
                "id,position,name,type,displayName,description,computation,maxLength,backedBy,default,relevanceRule"));

        Response respo = this.execute(cmd);
        // ResponseUtil.printResponse(respo, 1, System.out);
        WorkItemIterator wii = respo.getWorkItems();
        while (wii.hasNext()) {
            WorkItem wi = wii.next();
            if (typeCriteria == null || wi.getField("type").getValueAsString().equals(typeCriteria)) {
                allFields.put(wi.getId(), wi);
                allFieldsById.put(wi.getField("id").getValueAsString(), wi);
                allFieldsSorted.put(wi.getId(), wi);
            }
        }
    }

    // im viewfield "Shared Category"
    // im viewfield "ALM_Task Phase"
    public void readField(String fieldName, Map<String, Field> targetMap, String entryName,
            String descrField) throws APIException {
        targetMap.clear();
        Command cmd = new Command(Command.IM, "viewfield");
        cmd.addSelection(fieldName);
        // System.out.println("Reading " + fieldName + " ..");
        Response respo = this.execute(cmd);
        // ResponseUtil.printResponse(respo, 1, System.out);
        WorkItem wi = respo.getWorkItem(fieldName);
        Field picks = wi.getField(entryName);
        @SuppressWarnings("rawtypes")
        ListIterator li = picks.getList().listIterator();
        while (li.hasNext()) {
            Item it = (Item) li.next();
            targetMap.put(it.getId(), it.getField(descrField));
        }
    }

//    public void readTypeField(String typeName, String fieldName, Map<String, WorkItem> targetMap) throws APIException {
//        // targetMap.clear();
//        Command cmd = new Command(Command.IM, "viewfield");
//        cmd.addOption(new Option("overrideforType", typeName));
//        cmd.addSelection(fieldName);
//        // System.out.println("Reading field '" + fieldName + "' for type '" +typeName+ "' ..");
//        Response respo = this.execute(cmd);
//        // ResponseUtil.printResponse(respo, 1, System.out);
//        WorkItem wi = respo.getWorkItem(fieldName);
//        targetMap.put(wi.getId(), wi);
//    }
    // List<String> fieldList
    public void readTypeFields(String typeName, List<String> fieldList, Map<String, WorkItem> targetMap) throws APIException {
        // targetMap.clear();
        Command cmd = new Command(Command.IM, "viewfield");
        cmd.addOption(new Option("overrideforType", typeName));
        for (String fieldName : fieldList) {
            cmd.addSelection(fieldName);
        }
        // System.out.println("Reading field '" + fieldName + "' for type '" +typeName+ "' ..");
        Response respo = this.execute(cmd);
        // ResponseUtil.printResponse(respo, 1, System.out);
        WorkItemIterator li = respo.getWorkItems();
        while (li.hasNext()) {
            WorkItem it = li.next();
            targetMap.put(it.getId(), it);
        }
    }

    public void readAllDynamicGroups() throws APIException {
        allDynamicGroups.clear();
        Command cmd;
        cmd = new Command(Command.IM, "dynamicgroups");
        cmd.addOption(new Option("fields", "description,id,image,name"));

        Response respo = this.execute(cmd);
        // ResponseUtil.printResponse(respo, 1, System.out);
        WorkItemIterator wit = respo.getWorkItems();
        while (wit.hasNext()) {
            WorkItem dynGroup = wit.next();
            allDynamicGroups.put(dynGroup.getId(), new DynamicGroup(dynGroup));
        }
    }

    public void readAllTypes() throws APIException {
        Command cmd = new Command(Command.IM, "viewtype");
        for (String typeName : allTypes.keySet()) {
            cmd.addSelection(typeName);
        }
        Response respo = this.execute(cmd);
        // ResponseUtil.printResponse(respo, 1, System.out);
        WorkItemIterator wii = respo.getWorkItems();
        while (wii.hasNext()) {
            WorkItem wi = wii.next();
            Type type = new Type(this, wi);
            allTypes.put(type.getId(), type);
        }
    }

    public Type readType(String typeName) throws APIException {
        Command cmd = new Command(Command.IM, "viewtype");
        cmd.addSelection(typeName);

        Response respo = this.execute(cmd);
        // ResponseUtil.printResponse(respo, 1, System.out);
        WorkItem wi = respo.getWorkItem(typeName);
        Type type = new Type(this, wi);
        allTypes.put(type.getId(), type);
        return type;
    }

    public Type getType(String typeName) {
        return (Type) allTypes.get(typeName);
    }

    public void readDynamicGroups(String dynGroupName, String showReferences) throws APIException {
        allDynamicGroups.clear();
        Command cmd;
        if (dynGroupName.isEmpty() || dynGroupName.equals("All")) {
            cmd = new Command(Command.IM, "dynamicgroups");
            if (showReferences.equals("Yes")) {
                cmd.addOption(new Option("fields", "description,id,image,membership,name,references"));
            } else {
                cmd.addOption(new Option("fields", "description,id,image,membership,name"));
            }

        } else {
            cmd = new Command(Command.IM, "viewdynamicgroup");
            if (showReferences.equals("Yes")) {
                cmd.addOption(new Option("showReferences"));
            }
            cmd.addSelection(dynGroupName);
        }

        Response respo = this.execute(cmd);
        // ResponseUtil.printResponse(respo, 1, System.out);
        WorkItemIterator wit = respo.getWorkItems();
        while (wit.hasNext()) {
            WorkItem dynGroup = wit.next();
            allDynamicGroups.put(dynGroup.getId(), new DynamicGroup(dynGroup));
        }
    }

    public void readAllStaticGroups() throws APIException {
        allStaticGroups.clear();
        Command cmd;
        cmd = new Command(Command.IM, "groups");
        cmd.addOption(new Option("fields", "description,id,image,name"));

        Response respo = this.execute(cmd);
        // ResponseUtil.printResponse(respo, 1, System.out);
        WorkItemIterator wit = respo.getWorkItems();
        while (wit.hasNext()) {
            WorkItem dynGroup = wit.next();
            allStaticGroups.put(dynGroup.getId(), new StaticGroup(dynGroup));
        }
    }

    public void readStaticGroups(String staticGroupName, String showReferences) throws APIException {
        allStaticGroups.clear();
        Command cmd;
        if (staticGroupName.isEmpty() || staticGroupName.equals("All")) {
            cmd = new Command(Command.IM, "groups");
            if (showReferences.equals("Yes")) {
                cmd.addOption(new Option("fields", "description,email,id,image,isActive,isInRealm,name,notificationRule,queryTimeout,references,sessionLimit"));
            } else {
                cmd.addOption(new Option("fields", "description,email,id,image,isActive,isInRealm,name,notificationRule,queryTimeout,sessionLimit"));
            }
        } else {
            cmd = new Command(Command.IM, "viewgroup");
            if (showReferences.equals("Yes")) {
                cmd.addOption(new Option("showReferences"));
            }
            cmd.addSelection(staticGroupName);
        }

        Response respo = this.execute(cmd);
        // ResponseUtil.printResponse(respo, 1, System.out);
        WorkItemIterator wit = respo.getWorkItems();
        while (wit.hasNext()) {
            WorkItem staticGroup = wit.next();

            ItemList membership = null;

            try {
                Command cmdStatic = new Command(Command.INTEGRITY, "viewmksdomaingroup");
                cmdStatic.addSelection(staticGroup.getId());
                Response respoStatic = this.execute(cmdStatic);
                // ResponseUtil.printResponse(respoStatic, 1, System.out);
                WorkItem staticMKSGroup = respoStatic.getWorkItem(staticGroup.getId());

                membership = (ItemList) staticMKSGroup.getField("Members").getList();
            } catch (InvalidCommandOptionException | NoSuchElementException ex) {

            }

            allStaticGroups.put(staticGroup.getId(), new StaticGroup(staticGroup, membership));
        }
    }

    public void release() throws APIException, IOException {
        if (1 == 1) {
            if (apiSession != null) {
                apiSession.release();
            }
            if (integrationPoint != null) {
                integrationPoint.release();
            }
        }
    }

    public String getAbout(String sectionName) {

        String result = "<hr><div style=\"font-size:x-small;white-space: nowrap;text-align:center;\">"
                + sectionName + "<br>Current User: " + connection.getUser()
                + "<br>Copyright &copy; 2013, 2017 PTC Inc.<br>Author: Volker Eckardt, email: veckardt@ptc.com<br>";
        Command cmd = new Command("im", "about");
        try {
            Response response = this.execute(cmd);
            WorkItem wi = response.getWorkItem("ci");
            // get the details
            result = result + wi.getField("title").getValueAsString();
            result = result + ", Version: " + wi.getField("version").getValueAsString();
            // result = result + ", Patch-Level: " +
            // wi.getField("patch-level").getValueAsString();
            result = result + ", API Version: " + wi.getField("apiversion").getValueAsString();

            return result + "</div>";
        } catch (APIException | NullPointerException ex) {
            // Logger.getLogger(APISession.class.getName()).log(Level.SEVERE, null,
            // ex);
        }
        return result;
    }
}
