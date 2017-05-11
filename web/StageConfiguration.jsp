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
        <title>Integrity Stage Configuration</title>
    </head>

    <body>

        <%
            Html.initReport("Stage Configuration");
            out.println(Html.getTitle());
            out.println("<hr>");

            IntegritySession intSession = new IntegritySession();
            intSession.readAllObjects(IMCommands.types, intSession.allTypes);

            String sql = "select UserId, LockTime, BindingServerIndex from AdminLock";
            out.println(SQLReport.generateReport(intSession, "Table 'AdminLock':", sql, "lock", false));

            sql = "select id, name, port from Servers";
            out.println(SQLReport.generateReport(intSession, "Table 'Servers':", sql, "lock", false));

            sql = "select BaseProdServerID, ServerID, TargetServerID from AdminStagingIDInfo";
            out.println(SQLReport.generateReport(intSession, "Table 'AdminStagingIDInfo':", sql, "lock", false));

            sql = "select Name, Version, MinorVersion, StagingDatabase from VersionIdentity";
            out.println(SQLReport.generateReport(intSession, "Table 'VersionIdentity':", sql, "lock", false));

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