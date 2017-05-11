
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
         pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <title>Document Release Matrix</title>
        <link rel="stylesheet" type="text/css" href="images/acls.css"
              media="screen">
        <link rel="stylesheet" type="text/css" href="images/aclsprint.css"
              media="print">
    </head>
    <body>
        <%@ page import="api.IntegritySession"%>
        <%@ page import="java.sql.*" isThreadSafe="false"%>
        <%@ page import="java.util.*" isThreadSafe="false"%>
        <%@ page import="com.mks.api.*" isThreadSafe="false"%>
        <%@ page import="com.mks.api.response.*" isThreadSafe="false"%>
        <%@ page import="com.mks.api.util.ResponseUtil" isThreadSafe="false"%>

        <%!
            static Map<Integer, Item> allPicValues = new TreeMap<>();

            private static String logException(APIException ae) {
                return ("<br><br>Exception logging " + "<br> message:     "
                        + ae.getMessage() + "<br> class:       "
                        + ae.getClass().getName() + "<br> exceptionId: " + ae.getExceptionId());
            }

            private static void tableData(String text) {
                System.out.println("<td>" + text + "</td>");
            }

            private static String capitalize(String text) {
                return Character.toUpperCase(text.charAt(0)) + text.substring(1);
            }%>


        <%
            String ID = "162";

            out.println("<div align=right><script language=JavaScript>");
            out.println("date=Date()");
            out.println("document.write(date)");
            out.println("</script></div>");

            out.println("<h1>Integrity Workflow & Documents - Release Matrix</h1>");
            out.println("<h3>Release Information for Document " + ID + ":</h3>");

            String[] fields = {"label", "value", "active"};
            String[] headerFields = {"name", "displayName", "description",
                "default", "relevanceRule"};

            Response respo;

            IntegritySession intSession = new IntegritySession();;

            Command cmd = new Command(Command.IM, "viewfield");
            cmd.addSelection("Priority");
            respo = intSession.execute(cmd);
            WorkItemIterator wiip = respo.getWorkItems();
            while (wiip.hasNext()) {
                WorkItem wip = wiip.next();
                Field fld = wip.getField("picks");
                ListIterator li = fld.getList().listIterator();
                while (li.hasNext()) {
                    Item item = (Item) li.next();
                    // out.println(item.getField("label").getString()+"<br>");
                    allPicValues.put(item.getField("value").getInteger(), item);
                }
            }

            cmd = new Command(Command.IM, "viewsegment");
            cmd.addOption(new Option("fields", "Section,Text,Release,Priority"));
            cmd.addOption(new Option("filterQueryDefinition", "(field[Category] = \"Heading\")"));
            cmd.addSelection(ID);

            Integer[] intArray = new Integer[100];
            String[] baseFields = {"Section", "Text", "Priority"};

            try {
                out.println("<table border=1><tr>");
                for (int i = 0; i < baseFields.length; i++) {
                    out.println("<th>" + baseFields[i] + "</th>");
                }
                for (Item pick : allPicValues.values()) {
                    out.println("<th>" + pick.getField("label").getString() + "</th>");
                }
                int k = 0;
                for (Item pick : allPicValues.values()) {
                    intArray[k++] = 0;
                }

                out.println("</tr>");
                // execute the command
                respo = intSession.execute(cmd);
                WorkItemIterator wii = respo.getWorkItems();
                wii = respo.getWorkItems();
                wii.next();
                while (wii.hasNext()) {
                    WorkItem wi = wii.next();
                    out.println("<tr>");
                    for (int i = 0; i < baseFields.length; i++) {
                        out.println("<td>" + wi.getField(baseFields[i]).getValueAsString() + "</td>");
                    }
                    k = 0;
                    for (Item pick : allPicValues.values()) {
                        if (pick.getField("label").getString().contentEquals(wi.getField("Priority").getValueAsString())) {
                            out.println("<td style='text-align:center;'>x</td>");

                            intArray[k] = intArray[k] + 1;
                        } else {
                            out.println("<td>&nbsp;</td>");
                        }
                        k++;
                    }

                    out.println("</tr>");
                }
                // Footer:
                out.println("<tr bgcolor=\"darkblue\">");
                for (int i = 0; i < baseFields.length; i++) {
                    out.println("<td>" + (baseFields.length - 1 == i ? "Total:" : "&nbsp;") + "</td>");
                }
                k = 0;
                for (Item pick : allPicValues.values()) {
                    out.println("<td style='text-align:center;'>" + intArray[k++] + "</td>");
                }
                out.println("</tr>");
                out.println("</table>");

            } catch (APIException e) {

                // Report the command level Exception
                out.println("The command failed");
                out.println(logException(e));
            }

            // Execute disconnect
            try {
                intSession.release();
            } catch (APIException ex) {
                logException(ex);
            }
        %>

    </body>
</html>