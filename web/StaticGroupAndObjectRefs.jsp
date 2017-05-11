<%-- 
    Document   : DynamicGroupAndObjectLinks
    Created on : Apr 30, 2017, 12:30:37 PM
    Author     : veckardt
--%>

<%@page import="api.IntegritySession.IMCommands"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
         pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <link rel="stylesheet" type="text/css" href="images/acls.css"
              media="screen">
        <link rel="stylesheet" type="text/css" href="images/aclsprint.css"
              media="print">
        <title>Integrity Dynamic Groups</title>
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
            Html.initReport("Static Group and Object Refs");
            out.println(Html.getTitle());
            String[] elementClasses = new String[]{"Type", "Field"};

            String group = request.getParameter("group");
            if (group == null) {
                group = "All";
            }
            String showAllTypes = request.getParameter("showAllTypes");
            if (showAllTypes == null) {
                showAllTypes = "No";
            }

            String showReferences = "Yes";

            IntegritySession intSession = new IntegritySession();
            intSession.readAllStaticGroups();

            String[] showAllTypesDefiniton = new String[]{"Show all Types", "showAllTypes", showAllTypes, "Yes", "No"};
            out.println(Html.itemSelectField("group", intSession.allStaticGroups, true, group, showAllTypesDefiniton));
            intSession.readStaticGroups(group, showReferences);
            // read names and description only
            intSession.readAllObjects(IMCommands.types, intSession.allTypes);

            int height = "System Requirement Document".length() * 7;

            // Place to store used Types only
            Map<String, WorkItem> allUsedTypes = new LinkedHashMap<String, WorkItem>();
            intSession.readAllTypes();

            // Fill map for used types
            for (String groupName : intSession.allStaticGroups.keySet()) {
                StaticGroup dynGroup = intSession.allStaticGroups.get(groupName);
                String typeRefs = dynGroup.getReferences("Type", elementClasses);
                String fieldRefs = dynGroup.getReferences("Field", elementClasses);

                // out.println(groupName + ": " + references);
                for (String typeName : intSession.allTypes.keySet()) {
                    Type type = intSession.getType(typeName);
                    if (typeRefs.indexOf(typeName) > 0 || type.containsAtLeastOneFieldOf(fieldRefs)) {
                        allUsedTypes.put(typeName, type);
                    }
                }
            }
            // Show all Types, turn back to all then?
            if (showAllTypes.endsWith("Yes")) {
                allUsedTypes = intSession.allTypes;
            }

            out.println("<br><table border=1>");
            out.println("<tr>" + Html.th(""));

            // print table header
            for (String typeName : allUsedTypes.keySet()) {
                if (!typeName.startsWith("Shared") && !typeName.startsWith("MKS")) {
                    typeName = typeName.replaceAll(" ", "&nbsp;");
                    out.println(("<th style=\"height:" + height + "px\"><div class=\"verticalText\">" + typeName + "</div></th>"));
                }
            }
            out.println("</tr>");

            // print table data
            for (String groupName : intSession.allStaticGroups.keySet()) {
                StaticGroup staticGroup = intSession.allStaticGroups.get(groupName);

                out.println("<tr>");
                out.println(Html.td(groupName));

                // String references = staticGroup.getReferences("Type", elementClasses);
                for (String typeName : allUsedTypes.keySet()) {
                    if (!typeName.startsWith("Shared") && !typeName.startsWith("MKS")) {
                        // if (references.indexOf(typeName) > 0) {
                        Type type = intSession.getType(typeName);
                        out.println(Html.td(type.getUsedString(groupName)));
                        // } else {
                        // out.println(Html.td(""));
                        // }
                    }
                }
                out.println("</tr>");
            }
            out.println("</table>");

            out.println("<br><table border=1>");
            out.println("<tr>" + Html.th("Legend") + "</tr>");

            out.println("<tr>" + Html.td("A") + Html.td("Used in Type Administrators") + "</tr>");
            out.println("<tr>" + Html.td("E") + Html.td("Used in Type Editability Rule") + "</tr>");
            out.println("<tr>" + Html.td("P") + Html.td("Used in Type Permitted Groups") + "</tr>");
            out.println("<tr>" + Html.td("W") + Html.td("Used in Type Workflow Transitions") + "</tr>");
            out.println("<tr>" + Html.td("C") + Html.td("Used in Type Constraints") + "</tr>");
            out.println("<tr>" + Html.td("FE") + Html.td("Used in Field Editability") + "</tr>");
            out.println("<tr>" + Html.td("FR") + Html.td("Used in Field Relevance") + "</tr>");
            out.println("</table>");

            out.println(intSession.getAbout(Html.getTitleAndVersion()));
            intSession.release();
        %>

    </body>
</html>              
