<%-- 
    Document   : StaticGroups
    Created on : Mar 28, 2017, 11:31:23 AM
    Author     : veckardt
--%>


<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
         pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <link rel="stylesheet" type="text/css" href="images/acls.css"
              media="screen">
        <link rel="stylesheet" type="text/css" href="images/aclsprint.css"
              media="print">
        <title>Integrity Static Groups</title>
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
            Report report = Html.initReport("Static Group Details");
            out.println(Html.getTitle());

            String group = request.getParameter("group");
            if (group == null) {
                group = "All";
            }
            String showReferences = request.getParameter("showReferences");
            if (showReferences == null) {
                showReferences = "No";
            }

            IntegritySession intSession = new IntegritySession();
            intSession.readAllStaticGroups();
            String[] showReferencesDefiniton = new String[]{"Show References", "showReferences", showReferences, "Yes", "No"};
            out.println(Html.itemSelectField("group", intSession.allStaticGroups, true, group, showReferencesDefiniton, report.getExcelFileName()));
            intSession.readStaticGroups(group, showReferences);

            Excel.openExcel(report.getExcelFileName());
            Excel.newRow();
            Excel.newRow(Excel.newTitleCell(report.getTitle()));

            for (String name : intSession.allStaticGroups.keySet()) {

                Excel.newRow();

                out.println("<br>");
                StaticGroup staticGroup = intSession.allStaticGroups.get(name);
                out.println("<table border=1>");
                // out.println("<tr><th>" + "Static Group:</th><td>" + name + "</td><td>" + staticGroup.getDescription() + "</td></tr>");
                out.println(Excel.newRow(Excel.newHeaderCellLeft("Static Group:")
                        + Excel.newCell(name) + Excel.newCell(staticGroup.getDescription())));

                // out.println("<tr><th>Membership</th><th>Type</th><th>Member</th></tr>");
                out.println(Excel.newRow(Excel.newHeaderCell("Membership") + Excel.newHeaderCell("Type") + Excel.newHeaderCell("Member")));

                if (staticGroup.getMembership().isEmpty()) {
                    // out.println("<tr><td>" + name + "</td><td></td><td>No User or Group Membership</td></tr>");
                    out.println(Excel.newRow(Excel.newCell(name) + Excel.newCell("") + Excel.newCell("No User or Group Membership")));

                } else {
                    String membership = staticGroup.getMembership();
                    for (String line : membership.split("\n")) {
                        if (!line.isEmpty()) {
                            String data = "";
                            for (String value : line.split(";")) {
                                data = data + Excel.newCell(value.replaceAll(",", ", "));
                            }
                            out.println(Excel.newRow(data));
                        }
                    }
                    // out.println("<tr>");
                    // out.println("<td>" + membership.replaceAll("\n", "</td></tr><tr><td>").replaceAll(";", "</td><td>").replaceAll(",", ", ") + "</td>");
                    // out.println("</tr>");
                }

                String[] elementClasses = new String[]{"Type", "Field", "Query", "Report", "Chart", "Dashboard", "Change Package Type", "Project", "Dynamic Group", "Other"};
                for (String element : elementClasses) {
                    if (staticGroup.getReferences(element, elementClasses).isEmpty()) {
//                        out.println("<tr><th>" + element + " References</th><tr>");
//                        out.println("<tr><td>No " + element + " References</td></tr>");
                    } else {
                        // out.println("<tr><th>" + element + " References</th><th>Object</th><th>Name</th></tr>");
                        out.println(Excel.newRow(Excel.newHeaderCell(element) + Excel.newHeaderCell("Object") + Excel.newHeaderCell("Name")));
                        String references = staticGroup.getReferences(element, elementClasses);
                        for (String line : references.split("\n")) {
                            if (!line.isEmpty()) {
                                String data = "";
                                for (String value : line.split(";")) {
                                    data = data + Excel.newCell(value);
                                }
                                out.println(Excel.newRow(data));
                            }
                        }
                        // out.println("<tr>");
                        // out.println("<td>" + staticGroup.getReferences(element, elementClasses).replaceAll("\n", "</td></tr><tr><td>").replaceAll(";", "</td><td>") + "</td>");
                        // out.println("</tr>");
                    }
                }
                out.println("</table>");

            }
            out.println(intSession.getAbout(Html.getTitleAndVersion()));
            intSession.release();

            Excel.closeExcel();
        %>

    </body>
</html>          
