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

public class Report {

    private String title;
    private String description;
    private String group;
    private String jspFile;
    private String version;
    private String excelFileName;

    public Report(
            String title,
            String description,
            String jspFile,
            String group,
            String version,
            String excelFileName) {
        this.title = title;
        this.description = description;
        this.group = group;
        this.jspFile = jspFile;
        this.version = version;
        this.excelFileName = excelFileName;
    }

    public String getDescription() {
        return description;
    }

    public String getTitle() {
        return title;
    }

    public String getVersion() {
        return version;
    }

    public String getGroup() {
        return group;
    }

    public String getJspFile() {
        return jspFile;
    }

    // excelFileName
    public String getExcelFileName() {
        return excelFileName;
    }
}
