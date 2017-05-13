<%-- 
    Document   : UserGroupAssignment
    Created on : Apr 17, 2017, 12:26:06 PM
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
        <title>Integrity User Assignment</title>
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
            Html.initReport("User (Dynamic) Group Assignment");
            out.println(Html.getTitle());

            String user = request.getParameter("user");
            if (user == null) {
                user = "All";
            }
            String showDetails = request.getParameter("showDetails");
            if (showDetails == null) {
                showDetails = "No";
            }

            IntegritySession intSession = new IntegritySession();
            intSession.readAllUsers();
            String[] showDetailsDefiniton = new String[]{"Show Details", "showDetails", showDetails, "Yes", "No"};
            out.println(Html.itemSelectField("user", intSession.allUsers, true, user, showDetailsDefiniton));

            // single user only
            intSession.readUser(user);

            intSession.readStaticGroups("", "No");
            intSession.readDynamicGroups("", "No");

            for (String name : intSession.allUsers.keySet()) {
                out.println("<br><h4>Static Group Assignment:</h4>");
                // StaticGroup staticGroup = intSession.allUsers.get(name);

                String staticGroups = intSession.getStaticGroupsForUser(name);
                // out.println("<h1>Groups where the user " + name + " is directly assigned: " + staticGroups + "</h1>");

                out.println("<table border=1>");

                boolean assigned = false;
                for (String staticGroup : intSession.allStaticGroups.keySet()) {
                    StaticGroup baseGroup = intSession.allStaticGroups.get(staticGroup);
                    if (baseGroup.isMemberOfGroup(name, staticGroups)) {
                        assigned = true;
                        // staticGroups = staticGroups + "," + baseGroup.getName();

                        out.println("<tr><th>" + "Static Group:</th><td>" + baseGroup.getName() + "</td><td>" + baseGroup.getDescription() + "</td></tr>");
                        if (showDetails.equals("Yes")) {
                            out.println("<tr><th>Membership</th>");
                            out.println("<th>Type</th><th>Member</th></tr>");

                            out.println("<tr>");
                            out.println("<td>" + baseGroup.getMembership().replaceAll("\n", "</td></tr><tr><td>").replaceAll(";", "</td><td>").replaceAll(",", ", ") + "</td>");
                            out.println("</tr>");
                        }

                        // out.println("SG '" + name + "': " + baseGroup.getMembership() + baseGroup.getReferences("Type", elementClasses) + baseGroup.getReferences("Field", elementClasses));
                    }
                }

                if (!assigned) {
                    out.println("<tr><td>" + name + "</td><td></td><td>No User or Group Membership</td></tr>");
                }
                out.println("</table>");

                out.println("<br><h4>Dynamic Group Assignment:</h4><table border=1>");
                assigned = false;
                for (String dynName : intSession.allDynamicGroups.keySet()) {
                    DynamicGroup dynGroup = intSession.allDynamicGroups.get(dynName);
                    // out.println("MAIN: Checking group '" + group.getName() + "' ...");
                    if (dynGroup.isMemberOfGroup(name, staticGroups)) {
                        assigned = true;
                        out.println("<tr><th>" + "Dynamic Group:</th><td>" + dynGroup.getName() + "</td><td>" + dynGroup.getDescription() + "</td></tr>");
                        out.println("<tr><th>Membership</th>");
                        out.println(Html.th("Project"));
                        if (showDetails.equals("Yes")) {
                            out.println(Html.th("Users") + Html.th("Groups"));
                        }
                        out.println("</tr><tr>");
                        out.println("<td>" + dynGroup.getMembership(name, staticGroups, showDetails.equals("Yes")).replaceAll("\n", "</td></tr><tr><td>").replaceAll(";", "</td><td>").replaceAll(",", ", ") + "</td>");
                        out.println("</tr>");

                    }
                }
                if (!assigned) {
                    out.println("<tr><td>No User or Group Membership</td></tr>");
                }
                out.println("</table>");
            }
            out.println(intSession.getAbout(Html.getTitleAndVersion()));
            intSession.release();
        %>

    </body>
</html>          

