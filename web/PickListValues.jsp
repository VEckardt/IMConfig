<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
         pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <link rel="stylesheet" type="text/css" href="images/acls.css"
              media="screen">
        <link rel="stylesheet" type="text/css" href="images/aclsprint.css"
              media="print">
        <title>Integrity Pick List Values</title>
    </head>

    <body>
        <%@ page import="utils.Excel.*" isThreadSafe="false"%>
        <%@ page import="java.sql.*" isThreadSafe="false"%>
        <%@ page import="java.util.*" isThreadSafe="false"%>

        <%@ page import="com.mks.api.*" isThreadSafe="false"%>
        <%@ page import="com.mks.api.response.*" isThreadSafe="false"%>
        <%@ page import="com.mks.api.util.ResponseUtil" isThreadSafe="false"%>
        <%@ page import="utils.*" isThreadSafe="false"%>
        <%@ page import="api.*" isThreadSafe="false"%>

        <%
            Report report = Html.initReport("Pick List Values");

            out.println(Html.getTitle());
            String excelFileName = report.getExcelFileName();
            // String title = "Pick List Values - V1.0";

            String field = request.getParameter("field");
            if (field == null) {
                field = "All";
            }

            // GenerateExcelFile.GenerateExcelFile();
            String format = request.getParameter("format");
            if ((format != null) && (format.equals("excel"))) {
                response.setContentType("application/vnd.ms-excel");
            }

            // out.println(request.getParameter("pickField")+"<br>");
            // out.println(request.getParameter("sortby")+"<br>");
            String[] headerFields = {"name", "displayName", "description", "default", "relevanceRule"};
            String[] rowFieldsSC = {"label", "value", "active", "phase"};
            String[] rowFieldsStd = {"label", "value", "active"};
            String[] rowFields = {"label", "value", "active"};

            IntegritySession intSession = new IntegritySession();
            intSession.readAllFields("pick");
            out.println(Html.itemSelectField("field", intSession.allFields, true, field, excelFileName));
            //out.println("<a href=\"../output/" + filename + "\">" + filename + "</a><br>");

            Excel.openExcel(excelFileName);

            Response respo;
            try {

                Boolean showAll = (field.contentEquals(new StringBuffer("All")));

                Command cmd = new Command(Command.IM, "viewfield");
                for (String fieldName : intSession.allFields.keySet()) {
                    cmd.addSelection(fieldName);
                }
                Response fieldsRespo = intSession.execute(cmd);
                WorkItemIterator wiip = fieldsRespo.getWorkItems();

                for (String fieldName : intSession.allFields.keySet()) {
                    WorkItem wi;
                    if (showAll) {
                        wi = intSession.allFields.get(fieldName);
                    } else {
                        wi = intSession.allFields.get(field);
                    }

                    String[] groupSC = {"nonmeaningful", "meaningful", "segment"};
                    String[] group = {"xx"};
                    if (wi.getField("name").getValueAsString().contentEquals(new StringBuffer("Shared Category"))) {
                        rowFields = rowFieldsSC;
                        group = groupSC;
                    } else {
                        rowFields = rowFieldsStd;
                    }

                    out.println("<hr>");

                    // Open Excel File
                    Excel.newRow();
                    Excel.newRow(Excel.newCell(report.getTitle()));
                    Excel.newRow();

                    // pick field definition in Column 1 and 2
                    out.println("<table border=1>");
                    for (int i = 0; i < headerFields.length; i++) {
                        // newRow();
                        out.println(Excel.newRow(Excel.newHeaderCellLeft(Html.capitalize(headerFields[i]) + ":")
                                + Excel.newCell(wi.getField(headerFields[i]).getValueAsString())));
                    }
                    out.println("</table>");
                    out.println("<br>");
                    // pick field values
                    out.println("<table border=1>");

                    Excel.newRow();
                    String data = "";
                    for (int i = 0; i < rowFields.length; i++) {
                        data = data + Excel.newHeaderCell(Html.capitalize(rowFields[i]));
                    }
                    out.println(Excel.newRow(data));

                    // get pick field values
                    WorkItem wip = fieldsRespo.getWorkItem(wi.getId());

                    for (int g = 0; g < group.length; g++) {

                        Field fld = wip.getField("picks");
                        @SuppressWarnings(  "rawtypes")
                        ListIterator li = fld.getList().listIterator();
                        while (li.hasNext()) {
                            Item item = (Item) li.next();
                            String phase = "";
                            try {
                                Field phaseField = item.getField("phase");

                                phase = (phaseField == null ? "" : item.getField("phase").getValueAsString() + "");
                            } catch (NoSuchElementException ex) {
                                phase = "";
                            }

                            // for (int i = 0; i< item.getFieldListSize(); i++) {
                            // 	item.
                            // }
                            // there is no image ... unfortunately
                            // Iterator it = item.getFields();
                            // while (it.hasNext()) {
                            // 	Field afld = (Field)it.next();
                            // 	out.println(afld.getName());
                            // }
                            if ((group.length == 1) || ((group.length > 1) && (group[g].contentEquals(new StringBuffer(phase))))) {
                                // data = out.println("<tr>");
                                data = "";
                                // newRow();
                                for (int i = 0; i < rowFields.length; i++) {
                                    try {
                                        data = data + Excel.newCell(item.getField(rowFields[i]).getValueAsString());
                                    } catch (NoSuchElementException e) {
                                        data = data + Excel.newCell("&nbsp;");
                                    }
                                }
                                out.println(Excel.newRow(data));
                            }
                        }
                        // }

                    }
                    out.println("</table>");
                    if (!showAll) {
                        break;
                    }
                }

                // if (issue.getAPIException() != null) {
                //     out.println("Issue " + id + " does not exist.");
                //
            } catch (APIException e) {

                // Report the command level Exception
                out.println("The command failed");
                out.println(Html.logException(e));
            }

            Excel.closeExcel();

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