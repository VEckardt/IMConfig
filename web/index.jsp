<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
         pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <link rel="stylesheet" type="text/css" href="images/acls.css"
              media="screen">
        <link rel="stylesheet" type="text/css" href="images/aclsprint.css"
              media="print">
        <title>Integrity Config Reports and Tools</title>
        <style>
            body {
                background-image: url(./images/IntegrityWithSymbol.png);            
                background-origin: content-box;
                background-repeat: no-repeat;
                background-position: left 10px top 20px;
            }
        </style>
    </head>
    <body >

        <%@ page import="utils.Html" isThreadSafe="false"%>
        <%@ page import="utils.ReportList" isThreadSafe="false"%>
        <%@ page import="utils.Report" isThreadSafe="false"%>
        <%@ page import="api.IntegritySession" isThreadSafe="false"%>

        <div align=right><%=new java.util.Date()%></div>
        <h1>Configuration Reports and Tools</h1>

        <%
          // ReportList repList = new ReportList();
            // <img src='images/IntegrityWithSymbol.png' alt=''>

            out.print(Html.getIndexSection("Configuration Reports", "report", true));
            out.print(Html.getIndexSection("Administrative Reports &amp; Tools", "tool", false));
            out.print(Html.getIndexSection("Configuration Management (Demo only)", "Source Report", false));

            IntegritySession intSession = new IntegritySession();
            out.println(intSession.getAbout("Configuration Reports and Tools - V1.5"));
            intSession.release();
        %>

    </body>
</html>