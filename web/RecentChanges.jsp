<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
         pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <link rel="stylesheet" type="text/css" href="images/acls.css"
              media="screen">
        <link rel="stylesheet" type="text/css" href="images/aclsprint.css"
              media="print">
        <title>Integrity Recently Changed Objects</title>
    </head>

    <body>

        <%@ page import="java.sql.*" isThreadSafe="false"%>
        <%@ page import="java.util.*" isThreadSafe="false"%>
        <%@ page import="java.util.Date" isThreadSafe="false"%>
        <%@ page import="com.mks.api.*" isThreadSafe="false"%>
        <%@ page import="com.mks.api.response.*" isThreadSafe="false"%>
        <%@ page import="com.mks.api.util.ResponseUtil" isThreadSafe="false"%>
        <%@ page import="api.IntegritySession" isThreadSafe="false"%>
        <%@ page import="utils.Html" isThreadSafe="false"%>

        <%
            Html.initReport("Recently Changed Objects");
            out.println(Html.getTitle());
            Response respo;

            IntegritySession intSession = new IntegritySession();

            String days = request.getParameter("days");
            if ((days == null) || (days.contentEquals( new StringBuffer("")))) {
                days = "1";
            }

          // set this to true if the DB is from Oracle
            // this will make some minor changes to the sql command
            Boolean dbIsOracle = false;

          // set it to true if you also like to see added/changed items
            //
            Boolean includeItems = false;

            String whoColumns = ",[CreatedDate] ";
            whoColumns = whoColumns
                    + ",(select [Name] FROM [Users] where [ID] = d.[CreatedUser]) \"CreatedUser\" ";
            whoColumns = whoColumns + ",[ModifiedDate] ";
            whoColumns = whoColumns
                    + ",(select [Name] FROM [Users] where [ID] = d.[ModifiedUser]) \"ModifiedUser\" ";

            String sql = "SELECT 'User' \"Object\", [ID]";
            sql = sql + ",[Name] ";
            sql = sql + ",str([Active]) \"Active\" ";
            sql = sql + whoColumns;
            sql = sql + "FROM [Users] d ";
            sql = sql + "where [ModifiedDate] > DATEADD(DAY,-1,GETDATE() ) ";
            sql = sql + "union all ";
            sql = sql + "SELECT 'Group', [ID] ";
            sql = sql + ",[Name] ";
            sql = sql + ",str([Active]) ";
            sql = sql + whoColumns;
            sql = sql + "FROM [Groups] d ";
            sql = sql + "where [ModifiedDate] > DATEADD(DAY,-1,GETDATE() ) ";
            sql = sql + "union all ";
            sql = sql + "SELECT 'Project', [ID] ";
            sql = sql + ",[Name] ";
            sql = sql + ", str([Active]) ";
            sql = sql + whoColumns;
            sql = sql + "FROM [Projects] d ";
            sql = sql + "where [ModifiedDate] > DATEADD(DAY,-1,GETDATE() ) ";
            sql = sql + "union all ";
            sql = sql + "SELECT 'State', [ID] ";
            sql = sql + ",[Name] ";
            sql = sql + ",str([Active]) ";
            sql = sql + whoColumns;
            sql = sql + "FROM [States] d ";
            sql = sql + "where [ModifiedDate] > DATEADD(DAY,-1,GETDATE() ) ";
            sql = sql + "union all ";
            sql = sql + "SELECT 'Type', [ID] ";
            sql = sql + ",[Name] ";
            sql = sql + ",str([Active]) ";
            sql = sql + whoColumns;
            sql = sql + "FROM [Types] d ";
            sql = sql + "where [ModifiedDate] > DATEADD(DAY,-1,GETDATE() ) ";
            sql = sql + "union all ";
            sql = sql + "SELECT 'Field', [ID] ";
            sql = sql + ",[Name] ";
            sql = sql + ",str([Active]) ";
            sql = sql + whoColumns;
            sql = sql + "FROM [Fields] d ";
            sql = sql + "where [ModifiedDate] > DATEADD(DAY,-1,GETDATE() ) ";
            sql = sql + "union all ";
            sql = sql + "SELECT 'Trigger', [ID] ";
            sql = sql + ",[Name] ";
            sql = sql + ",str([Active]) ";
            sql = sql + whoColumns;
            sql = sql + "FROM [triggers] d ";
            sql = sql + "where [ModifiedDate] > DATEADD(DAY,-1,GETDATE() ) ";
            sql = sql + "union all ";
            sql = sql + "SELECT 'TestVerdict', [ID] ";
            sql = sql + ",[Name] ";
            sql = sql + ",str([Active]) ";
            sql = sql + whoColumns;
            sql = sql + "FROM [TestVerdicts] d ";
            sql = sql + "where [ModifiedDate] > DATEADD(DAY,-1,GETDATE() ) ";
            sql = sql + "union all ";
            sql = sql + "SELECT 'Chart', [ID] ";
            sql = sql + ",[Name] ";
            sql = sql + ",str([Active]) ";
            sql = sql + whoColumns;
            sql = sql + "FROM [Charts] d ";
            sql = sql + "where [ModifiedDate] > DATEADD(DAY,-1,GETDATE() ) ";
            sql = sql + "union all ";
            sql = sql + "SELECT 'Dashboard', [ID] ";
            sql = sql + ",[Name] ";
            sql = sql + ",str([Active]) ";
            sql = sql + whoColumns;
            sql = sql + "FROM [Dashboards] d ";
            sql = sql + "where [ModifiedDate] > DATEADD(DAY,-1,GETDATE() ) ";
            sql = sql + "union all ";
            sql = sql + "SELECT 'Query', [ID] ";
            sql = sql + ",[Name] ";
            sql = sql + ",str([Active]) ";
            sql = sql + whoColumns;
            sql = sql + "FROM [Queries] d ";
            sql = sql + "where [ModifiedDate] > DATEADD(DAY,-1,GETDATE() ) ";
            sql = sql + "union all ";
            sql = sql + "SELECT 'Report', [ID] ";
            sql = sql + ",[Name] ";
            sql = sql + ",str([Active]) ";
            sql = sql + whoColumns;
            sql = sql + "FROM [Reports] d ";
            sql = sql + "where [ModifiedDate] > DATEADD(DAY,-1,GETDATE() ) ";
            if (includeItems) {
                sql = sql + "union all ";
                sql = sql + "SELECT 'Items', [ID] ";
                sql = sql + ",(select [Name] FROM [Types] where [ID] = d.[TypeID]) ";
                sql = sql + ",'' /* (select [Name] FROM [States] where [ID] = d.[StateID]) Name */ ";
                sql = sql + whoColumns;
                sql = sql + "FROM [Issues] d ";
                sql = sql + "where [ModifiedDate] > DATEADD(DAY,-1,GETDATE() ) ";
            }

            out.println("<hr>");

            // check, if it's Oracle
            try {
                Command cmd = new Command(Command.IM, "diag");
                cmd.addOption(new Option("diag", "runsql"));
                cmd.addOption(new Option("param", "select 1 from dual"));
                intSession.execute(cmd);
                
                System.out.print("IMConfig: Oracle DB identified ...");

                sql = sql.replaceAll("DATEADD(DAY,-1,GETDATE() )", "sysdate-1");
                sql = sql.replaceAll("[", "");
                sql = sql.replaceAll("]", "");
                sql = sql.replaceAll("str(", "to_char(");

            } catch (Exception ex) {
                // just leave it like it is;
                System.out.print("IMConfig: MSSQL DB identified ...");
            }

          // manipulate the sql for Oracle or MSSQL
            // if (dbIsOracle) {
            // }
            // set the correct day range
            if (days != null && !days.equals("")) {
                sql = sql.replaceAll(",-1,", ",-" + days + ",");
            }

            // set the command to execute
            Command cmd = new Command(Command.IM, "diag");
            cmd.addOption(new Option("diag", "runsql"));
            cmd.addOption(new Option("param", sql));

            // define the selection list for the days
            out.println("<table border=1>");
            out.println("<tr>");
            out.println("<form name=form1>");
            out.println("<td>");
            out.println("Display objects modified within the previous");
            out.println("</td>");
            out.println("<td>");
            out.println("<select name=days onChange='this.form.submit()'>");
            out.println("<option value='1'>1 day");
            for (int i = 2; i < 11; i++) {
                if (days != null && days.equals(i + "")) {
                    out.println("<option selected value='" + i + "'>" + i + " days");
                } else {
                    out.println("<option value='" + i + "'>" + i + " days");
                }
            }
            out.println("</select>");
            out.println("</td>");
            out.println("<td>");
            out.println("<input type=\"submit\" value=\"Refresh\">");
            out.println("</td>");
            out.println("</form>");
            out.println("</tr>");
            out.println("</table>");

            Date currentDate = new Date();

            try {
                // execute the command
                respo = intSession.execute(cmd);
                // ResponseUtil.printResponse(respo,1,System.out);

                int count = 0;
                if (respo.getExitCode() == 0) {
                    Result result = respo.getResult();
                    String message = result.getMessage();
                    String[] rows = message.split("\n");

                    out.println("<hr>");
                    out.println("<table border=1>");
                    // analyse the output
                    for (int i = 0; i < rows.length; i++) {
                        // out.println(rows[i]);
                        if (i < 2) {
                            String[] rowTitle = rows[i].split("\\t");
                            if (rowTitle.length > 2) {
                                out.println("<tr><th></th>");
                                for (int j = 0; j < rowTitle.length; j++) {
                                    out.println("<th>" + rowTitle[j].replaceAll("\\s+$", "") + "</th>");
                                    if (j == 2) {
                                        out.println("<th>Description</th>");
                                    }
                                }
                                out.println("</tr>");
                            }
                        } else {
                            String[] values = rows[i].split("\\t");
                            if (!(values[0].indexOf("-----")>-1)) {
                                count++;
                                out.println("<tr>");
                                for (int j = 0; j < values.length; j++) {
                                    String value = values[j].replaceAll("\\s+$", "");
                                    if (j == 0) {
                                        out.println("<td><img src='images/" + value + ".png' alt='" + value
                                                + "'></td><td>" + value + "</td>");
                                    } else {
                                        out.println("<td>" + value + "</td>");
                                    }
                                    if (j == 2) {
                                        String type = values[0].replaceAll("\\s+$", "").toLowerCase();
                                        try {
                                            // get the object description, if available
                                            if (type.equals("testverdict")) {
                                                cmd = new Command(Command.TM, "viewverdict");
                                            } else {
                                                cmd = new Command(Command.IM, "view" + type);
                                            }
                                            cmd.addSelection(value);
                                            respo = intSession.execute(cmd);
                                            WorkItem wi = respo.getWorkItem(value);
                                            try {
                                                String descr = wi.getField("description").getValueAsString();
                                                if (descr == null || descr.equals("null")) {
                                                    descr = "-";
                                                }
                                                out.println("<td>" + descr + "</td>");
                                            } catch (NoSuchElementException ex) {
                                                out.println("<td>n/a</td>");
                                            }
                                        } catch (APIException ce) {
                                            // no description field, then just print nothing
                                            out.println("<td>n/a</td>");
                                        }
                                    }
                                }
                                out.println("</tr>");
                            }
                        }
                    }

                    // additional handling for viewset changes
                    cmd = new Command(Command.INTEGRITY, "viewsets");
                    respo = intSession.execute(cmd);
                    WorkItemIterator wii = respo.getWorkItems();
                    // ResponseUtil.printResponse(respo,1,System.out);
                    while (wii.hasNext()) {
                        WorkItem wi = wii.next();
                        if (wi.getField("publishedState").getValueAsString().equals("Published (Server)")) {
                            Date compareDate = new Date(currentDate.getTime() - Integer.parseInt(days) * 1000
                                    * 60 * 60 * 24);
                            // if the change has happend between now and now - days;
                            if (wi.getField("modifiedDate").getDateTime().after(compareDate)) {
                                count++;
                                out.println("<tr>");
                                out.println("<td><img src='images/ViewSet.png' alt='ViewSet'></td><td>ViewSet</td>");
                                out.println("<td>-</td>");
                                out.println("<td>" + wi.getField("name").getValueAsString() + "</td>");
                                out.println("<td>" + wi.getField("description").getValueAsString() + "</td>");
                                out.println("<td>-</td>");
                                out.println("<td>-</td>");
                                out.println("<td>" + wi.getField("creator").getValueAsString() + "</td>");
                                out.println("<td>" + wi.getField("modifiedDate").getDateTime().toString()
                                        + "</td>");
                                out.println("<td>-</td>");
                                out.println("</tr>");
                            }
                        }
                    }

                    // add table footer
                    out.println("<tr><td colspan=2>" + count + " objects</td></tr>");
                    // close the table
                    out.println("</table>");
                    out.println("<hr>");
                }

            } catch (APIException e) {

                // Report the command level Exception
                out.println("The command failed");
                out.println(Html.logException(e));
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