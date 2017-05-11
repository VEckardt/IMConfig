<%@page import="utils.SQLReport"%>
<%@page import="api.IntegritySession.IMCommands"%>
<%@page import="com.mks.api.*" isThreadSafe="false"%>
<%@page import="com.mks.api.response.*" isThreadSafe="false"%>
<%@page import="com.mks.api.util.ResponseUtil" isThreadSafe="false"%>
<%@page import="api.IntegritySession" isThreadSafe="false"%>
<%@page import="utils.Html" isThreadSafe="false"%>

<%@page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <link rel="stylesheet" type="text/css" href="images/acls.css" media="screen">
        <link rel="stylesheet" type="text/css" href="images/aclsprint.css" media="print">
        <title>Integrity Type Usage</title>
    </head>

    <body>

        <%
            Html.initReport("Type Usage");
            out.println(Html.getTitle());
            out.println("<hr>");

            IntegritySession intSession = new IntegritySession();
            intSession.readAllObjects(IMCommands.types, intSession.allTypes);

            String days = request.getParameter(new String("days"));
            if ((days == null) || (days.contentEquals(new StringBuffer("")))) {
                days = "1";
            }

            String sql = "SELECT ";
            sql = sql + "TypeID \"TypeId\",";
            sql = sql + "t.Name \"TypeName\",";
            sql = sql + "max(i.ModifiedDate) \"ItemLastModifiedDate\",";
            sql = sql + "COUNT(i.ID) \"ItemCounter\" ";
            sql = sql + "FROM Issues i,";
            sql = sql + "Types t ";
            sql = sql + "where i.TypeID=t.ID  ";
            sql = sql + "group by TypeID, t.Name ";
            sql = sql + "order by max(i.ModifiedDate) desc ";

            out.println(SQLReport.generateReport(intSession, "", sql, "Type", true));

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