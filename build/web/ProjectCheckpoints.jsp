<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
         pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <link rel="stylesheet" type="text/css" href="images/acls.css"
              media="screen">
        <link rel="stylesheet" type="text/css" href="images/aclsprint.css"
              media="print">
        <title>Integrity Project Checkpoints</title>
    </head>

    <body>

        <%@ page import="java.sql.*" isThreadSafe="false"%>
        <%@ page import="java.util.*" isThreadSafe="false"%>
        <%@ page import="com.mks.api.*" isThreadSafe="false"%>
        <%@ page import="com.mks.api.response.*" isThreadSafe="false"%>
        <%@ page import="com.mks.api.util.ResponseUtil" isThreadSafe="false"%>
        <%@ page import="utils.Html" isThreadSafe="false"%>
        <%@ page import="api.*" isThreadSafe="false"%>

        <%
            Html.initReport("Project Checkpoints");
            out.println(Html.getTitle());
          // out.println(request.getParameter("fields")+"<br>");
            // out.println(request.getParameter("sortby")+"<br>");

            // String param1 = request.getParameter("fields");
            // String[] fields;
            // if (param1 == null || param1.contentEquals(""))
            String fields = "author,date,description,labels,revision,state";
            String[] fieldList = fields.split(",");
            // else
            //		fields = request.getParameter("fields").split(",");

            String project = request.getParameter("project");
            if (project == null || project.contentEquals(new StringBuffer(""))) {
                project = ""; // at the beginning show nothing	  
            }
            Response respo;

            IntegritySession intSession = new IntegritySession();
            Map<String, WorkItem> projectList = new LinkedHashMap<String, WorkItem>();
            intSession.readAllSIObjects("projects", projectList);

            out.println(Html.itemSelectField("project", projectList, false, project, ""));

            // if a type is provided or selected
            if (project != null && !project.contentEquals(new StringBuffer(""))) {

                try {
                    // ResponseUtil.printResponse(respo,1,System.out);

                    out.println("<br><table border=1>");
                    out.println("<tr>");
                    for (int i = 0; i < fieldList.length; i++) {
                        out.println("<th>" + Html.capitalize(fieldList[i]) + "</th>");
                    }
                    out.println("</tr>");

                    // si viewprojecthistory --fields=associatedIssues,author,date,description,labels,revision,state --project=/Integrity/project.pj
                    Command cmd = new Command(Command.SI, "viewprojecthistory");
                    cmd.addOption(new Option("fields", fields));
                    cmd.addOption(new Option("project", project));

                    respo = intSession.execute(cmd);
                    // ResponseUtil.printResponse(respo,1,System.out);
                    WorkItemIterator wiip = respo.getWorkItems();
                    while (wiip.hasNext()) {
                        WorkItem wip = wiip.next();
                        // returns: 1.3,1.2,1.1
                        Field fld = wip.getField("revisions");
                        @SuppressWarnings(  "rawtypes")
                        ListIterator li = fld.getList().listIterator();
                        while (li.hasNext()) {
                            Item item = (Item) li.next();
                            out.println("<tr>");
                            for (int i = 0; i < fieldList.length; i++) {
                                out.println("<td>" + item.getField(fieldList[i]).getValueAsString() + "</td>");
                            }
                            out.println("</tr>");
                        }
                    }
                    out.println("</table>");

                    // if (issue.getAPIException() != null) {
                    //     out.println("Issue " + id + " does not exist.");
                    //
                    // } else {
                    //
                } catch (APIException e) {

                    // Report the command level Exception
                    out.println("The command failed");
                    out.println(Html.logException(e));
                }
            }
            out.println(intSession.getAbout(Html.getTitleAndVersion()));
            // Execute disconnect
            try {
                intSession.release();
            } catch (APIException ex) {
                out.println(Html.logException(ex));
            }
        %>
    </body>
</html>