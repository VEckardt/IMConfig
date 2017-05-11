<%-- 
    Document   : searchUser
    Created on : Apr 1, 2017, 3:35:58 PM
    Author     : veckardt
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>

    </head>
    <body>
        <br><br><br><br>
        <form name="searchForm" method="post" action="excelData.jsp">
            <table align="center" bgcolor="LIGHTBLUE">
                <tr>
                    <td colspan=3 align="center"><b>
                            <span style="font-size:20px;">Create a Excel file with Search Table</span></b></td>
                </tr>
                <tr>
                    <td colspan=3>&nbsp;</td>
                </tr>
                <tr>
                    <td><b>Search</b></td>
                    <td><input type="text" name="searchtxt" value=""></td>
                    <td><input type="submit" name="Submit" value="Search"></td>
                </tr>
                <tr>
                    <td colspan=3>&nbsp;</td>
                </tr>
            </table>
        </form>
    </body>
</html>
