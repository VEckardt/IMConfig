<%-- 
    Document   : excelData
    Created on : Apr 1, 2017, 3:36:36 PM
    Author     : veckardt
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="org.apache.poi.hssf.usermodel.HSSFSheet"%>
<%@ page import="org.apache.poi.hssf.usermodel.HSSFWorkbook"%>
<%@ page import="org.apache.poi.hssf.usermodel.HSSFRow"%>
<%@ page import="org.apache.poi.hssf.usermodel.HSSFCell"%>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>

<br><br>
<%

    java.util.Date date = new java.util.Date();

    String filepath = "../data/public_html/output/";
    String filename = "ExcelData_f" + date.getTime() + ".xls";

    String searchText = "";
    if (request.getParameter("searchtxt") != null) {
        searchText = request.getParameter("searchtxt").toString();
    }

    try {

        HSSFWorkbook hwb = new HSSFWorkbook();
        HSSFSheet sheet = hwb.createSheet("new sheet");

        HSSFRow rowhead = sheet.createRow(2);
        rowhead.createCell(0).setCellValue("SNo");
        rowhead.createCell(1).setCellValue("First Name");
        rowhead.createCell(2).setCellValue("Last Name");
        rowhead.createCell(3).setCellValue("Username");
        rowhead.createCell(4).setCellValue("E-mail");
        rowhead.createCell(5).setCellValue("Country");

        int index = 3;
        int sno = 0;
        String name = "";

        sno++;

        HSSFRow row = sheet.createRow(index);
        row.createCell(0).setCellValue(sno);
        row.createCell(1).setCellValue("1");
        row.createCell(2).setCellValue("1");
        row.createCell(3).setCellValue("1");
        row.createCell(4).setCellValue("1");
        row.createCell(5).setCellValue("1");
        index++;

        FileOutputStream fileOut = new FileOutputStream(filepath + filename);
        hwb.write(fileOut);
        fileOut.close();

        out.println("<b>Your excel file has been generated</b><br>");

        File dir = new File(filepath);
        File[] filesList = dir.listFiles();
        for (File file : filesList) {
            if (file.isFile()) {
//                System.out.println(file.getName());
                out.println("<a href=\"../output/" + file.getName() + "\">" + file.getName() + "</a><br>");
            }
        }

        //       out.println("<a href=\"../output/" + filename + "\">Download</a><br>");
    } catch (Exception ex) {
        out.println(ex.getMessage());
    }
%>
