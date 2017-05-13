/*
 * Copyright:      Copyright 2017 (c) Parametric Technology GmbH
 * Product:        PTC Integrity Lifecycle Manager
 * Author:         Volker Eckardt, Principal Consultant ALM
 * Purpose:        Custom Developed Code
 * **************  File Version Details  **************
 * Revision:       $Revision: 1.1 $
 * Last changed:   $Date: 2017/05/02 12:18:40CEST $
 */
package utils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.IndexedColors;

/**
 *
 * @author veckardt
 */
public class Excel {

    static Boolean asExcel = true;

    static HSSFSheet sheet;
    static HSSFRow row;
    static int rowId = 0;
    static int cellId = 0;
    static HSSFWorkbook workbook;
    java.util.Date date = new java.util.Date();
    static String filepath = "../data/tmp/web/";
    // String filename = "ExcelData_f" + date.getTime() + ".xls";
    static String filename = "PickListValues.xls";

    public static void setFileName(String thefilename) {
        filename = thefilename;
    }

    public static String getFileName() {
        return filename;
    }

    public static void openExcel(String fileName) {
        setFileName(fileName);
        rowId = 0;
        cellId = 0;
        workbook = new HSSFWorkbook();
        sheet = workbook.createSheet("new sheet");
        System.out.println("Excel Workbook opened ...");
    }

    public static void closeExcel() throws IOException {
        File f = new File(filepath);
        f.mkdirs();
        try (FileOutputStream fileOut = new FileOutputStream(filepath + filename)) {
            workbook.write(fileOut);
        }
        System.out.println("Excel Workbook created.");
    }

    public static void newRow() {
        if (asExcel) {
            row = sheet.createRow(++rowId);
            cellId = 0;
        }
    }

    public static String newRow(String data) {
        if (asExcel) {
            row = sheet.createRow(++rowId);
            cellId = 0;
        }
        return ("<tr>" + data + "</tr>");
    }

    public static String newTitleCell(String data) {
        if (asExcel) {
            HSSFCellStyle style = workbook.createCellStyle();
            HSSFFont font = workbook.createFont();
            font.setFontName(HSSFFont.FONT_ARIAL);
            font.setFontHeightInPoints((short) 14);
            font.setBoldweight(Font.BOLDWEIGHT_BOLD);
            style.setFont(font);
            cellId++;
            HSSFCell cell = row.createCell(cellId);
            cell.setCellValue(data);
            cell.setCellStyle(style);
        }
        return ("<td>" + data + "</td>");
    }

    

    public static String newCell(String data) {
        if (asExcel) {
            cellId++;
            row.createCell(cellId).setCellValue(data);
        }
        return ("<td>" + data + "</td>");
    }

    public static String newHeaderCell(String data) {
        if (asExcel) {
            cellId++;
            HSSFCell cell = row.createCell(cellId);
            cell.setCellValue(data);
            CellStyle style = workbook.createCellStyle();
            style.setFillForegroundColor(IndexedColors.AQUA.getIndex());
            style.setFillPattern(CellStyle.SOLID_FOREGROUND);
            cell.setCellStyle(style);
        }
        return ("<th>" + data + "</th>");
    }

    public static String newHeaderCellLeft(String data) {
        if (asExcel) {
            cellId++;
            HSSFCell cell = row.createCell(cellId);
            cell.setCellValue(data);
            CellStyle style = workbook.createCellStyle();
            style.setFillForegroundColor(IndexedColors.AQUA.getIndex());
            style.setFillPattern(CellStyle.SOLID_FOREGROUND);
            cell.setCellStyle(style);
        }
        return ("<th style='text-align:left'>" + data + "</th>");
    }
}
