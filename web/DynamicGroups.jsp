<%-- 
    Document   : DynamicGroups.jsp
    Created on : Mar 27, 2017, 10:31:50 PM
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
            Html.initReport("Dynamic Group Details");
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
            intSession.readAllDynamicGroups();
            String[] showReferencesDefiniton = new String[]{"Show References", "showReferences", showReferences, "Yes", "No"};
            out.println(Html.itemSelectField("group", intSession.allDynamicGroups, true, group, showReferencesDefiniton));
            intSession.readDynamicGroups(group, showReferences);

            for (String name : intSession.allDynamicGroups.keySet()) {
                out.println("<br>");
                DynamicGroup dynGroup = intSession.allDynamicGroups.get(name);
                out.println("<table border=1>");
                out.println("<tr><th>" + "Dynamic Group:</th><td>" + name + "</td><td>" + dynGroup.getDescription() + "</td></tr>");
                out.println("<tr><th>Membership</th>");
                out.println("<th>Project</th><th>Users</th><th>Groups</th></tr>");
                if (dynGroup.getMembership().isEmpty()) {
                    out.println("<tr><td>No User or Group Membership</td></tr>");
                } else {
                    out.println("<tr>");
                    out.println("<td>" + dynGroup.getMembership().replaceAll("\n", "</td></tr><tr><td>").replaceAll(";", "</td><td>").replaceAll(",", ", ") + "</td>");
                    out.println("</tr>");
                }

                String[] elementClasses = new String[]{"Type", "Field", "Query", "Report", "Chart", "Dashboard", "Change Package Type", "Project", "Dynamic Group", "Other"};
                for (String element : elementClasses) {
                    if (dynGroup.getReferences(element, elementClasses).isEmpty()) {
//                        out.println("<tr><th>" + element + " References</th><tr>");
//                        out.println("<tr><td>No " + element + " References</td></tr>");
                    } else {
                        out.println("<tr><th>" + element + " References</th>");
                        out.println("<th>Object</th><th>Name</th></tr>");
                        out.println("<tr>");
                        out.println("<td>" + dynGroup.getReferences(element, elementClasses).replaceAll("\n", "</td></tr><tr><td>").replaceAll(";", "</td><td>") + "</td>");
                        out.println("</tr>");
                    }
                }
                out.println("</table>");
            }
            out.println(intSession.getAbout(Html.getTitleAndVersion()));
            intSession.release();
        %>

    </body>
</html>          