<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
         pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <link rel="stylesheet" type="text/css" href="images/acls.css"
              media="screen">
        <link rel="stylesheet" type="text/css" href="images/aclsprint.css"
              media="print">
    </head>

    <body>

        <%@ page import="java.sql.*" isThreadSafe="false"%>
        <%@ page import="java.util.*" isThreadSafe="false"%>
        <%@ page import="com.mks.api.*" isThreadSafe="false"%>
        <%@ page import="com.mks.api.response.*" isThreadSafe="false"%>
        <%@ page import="com.mks.api.util.ResponseUtil" isThreadSafe="false"%>
        <%@ page import="utils.*" isThreadSafe="false"%>
        <%@ page import="api.*" isThreadSafe="false"%>

        <%
            Html.initReport("Currently Unused Fields");
            out.println(Html.getTitle());

            Response respo;

            // CmdRunner cmdRunner = null;
            // IntegrationPoint integrationPoint;
            // Session apiSession;
            IntegritySession intSession = new IntegritySession();
            intSession.readAllFields(null);

            // get the type if provided as paramater
            // String typeName = request.getParameter("type");
            // all type information
            Command cmd = new Command(Command.IM, "types");
            cmd.addOption(new Option("fields", "name,visibleFields,systemManagedFields"));
            respo = intSession.execute(cmd);
            WorkItemIterator wii = respo.getWorkItems();
            // ResponseUtil.printResponse(respo, 1, System.out);

            Map<String, String> allUsedFields = new HashMap<String, String>();

            while (wii.hasNext()) {
                WorkItem wi = wii.next();
                Field fld = wi.getField("visibleFields");
                if (fld != null && fld.getList() != null) {
                    @SuppressWarnings(  "rawtypes")
                    ListIterator li = fld.getList().listIterator();
                    while (li.hasNext()) {
                        Item it = (Item) li.next(); // im.PhaseList.Entry
                        // out.println(it.getId());
                        allUsedFields.put(it.getId(), it.getId());
                    }
                }
                fld = wi.getField("systemManagedFields");
                if (fld != null && fld.getList() != null) {
                    @SuppressWarnings(  "rawtypes")
                    ListIterator li = fld.getList().listIterator();
                    while (li.hasNext()) {
                        Item it = (Item) li.next(); // im.PhaseList.Entry
                        // out.println(it.getId());
                        allUsedFields.put(it.getId(), it.getId());
                    }
                }
            }
            // out.println("" + allUsedFields.size());

            for (Object usedField : allUsedFields.keySet()) {
                intSession.allFieldsSorted.remove(usedField.toString());
            }
          // out.println("" + intSession.allFields.size());

            // sorted list by key
            // Does not work:  Map<String, WorkItem> allUnusedFieldsSorted = new TreeMap<String, WorkItem>(intSession.allFields);
            // name,type,displayName,description
            out.println("<hr><table border=1>");
            out.println("<tr><th>Pos</th><th>Name</th><th>Type</th><th>Display Name</th><th>Description</th></tr>");

            int countAll = intSession.allFields.size();
            int countUnused = intSession.allFieldsSorted.size();

            // HashMap<String, WorkItem> allUnusedFieldsSorted = intSession.allFields;
            for (Object unusedField : intSession.allFieldsSorted.keySet()) {
                WorkItem wi = intSession.allFieldsSorted.get(unusedField.toString());
                String position = wi.getField("position").getValueAsString();
                String name = wi.getField("name").getValueAsString();
                String type = wi.getField("type").getValueAsString();
                String displayName = wi.getField("displayName").getValueAsString();
                String description = wi.getField("description").getValueAsString();
                out.println("<tr><td>" + position + "</td><td>" + name + "</td><td>" + type + "</td><td>"
                        + displayName + "</td><td>" + description + "</td></tr>");
            }

            // add table footer
            out.println("<tr><td colspan=2>" + countUnused + "/" + countAll + " objects</td></tr>");
            out.println("</table>");
            out.println(intSession.getAbout(Html.getTitleAndVersion()));
            intSession.release();
        %>

    </body>
</html>