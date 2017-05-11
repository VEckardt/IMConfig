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

import java.util.LinkedHashMap;
import java.util.Map;

public class ReportList {

    static Map<String, Report> repList = new LinkedHashMap<>();

    /**
     *
     */
    // private static final long serialVersionUID = 1L;
    public ReportList() {

        repList.put("Type Fields", new Report(
                "Workflow & Documents - Type Fields",
                "This report displays all settings related to an Integrity type, including states, properties, related triggers",
                "TypeFields.jsp", "report", "V2.1", null));

        repList.put("Pick List Values", new Report("Workflow & Documents - Pick List Values",
                "This report displays all pick list values for the selected fields",
                "PickListValues.jsp", "report", "V2.0", "PickListValues.xls"));

        repList.put("User (Dynamic) Group Assignment", new Report("Workflow & Documents - User (Dynamic) Group Assignment",
                "This report lists the user and his/her (Dynamic) Group assignment",
                "UserGroupAssignment.jsp", "report", "V1.0", null));

        repList.put("Static Group Details", new Report("Workflow & Documents - Static Group Details",
                "This report lists all details for Groups in W&D. It is assumed that a corresponding group exists in MKS Domain to retrieve the assignment from.",
                "StaticGroups.jsp", "report", "V1.0", "StaticGroupDetails.xls"));

        repList.put("Static Group and Object Refs", new Report("Workflow & Documents - Static Group and Object Refs",
                "This report lists all references for Static Groups (may take a minute to complete)",
                "StaticGroupAndObjectRefs.jsp", "report", "V1.0", null));

        repList.put("Dynamic Group Details", new Report("Workflow & Documents - Dynamic Group Details",
                "This report lists all details for Dynamic Groups",
                "DynamicGroups.jsp", "report", "V1.0", null));

        repList.put("Dynamic Group and Object Refs", new Report("Workflow & Documents - Dynamic Group and Object Refs",
                "This report lists all references for Dynamic Groups (may take a minute to complete)",
                "DynamicGroupAndObjectRefs.jsp", "report", "V1.0", null));

        repList.put("Currently Unused Fields", new Report(
                "Workflow & Documents - Currently Unused Fields",
                "This reports lists all unused fields that you may reuse later. Remember that such fields are possibly part of the Type history.",
                "UnusedFields.jsp", "tool", "V1.0", null));

        repList.put("Recently Changed Objects", new Report("Workflow & Documents - Recently Changed Objects",
                "This report lists all recently changed objects in the Integrity Administrator.",
                "RecentChanges.jsp", "tool", "V1.0", null));

        repList.put("Stage Configuration", new Report(
                "Workflow & Documents - Stage Configuration",
                "This report lists the most important table details for the Integrity Stage Configuration",
                "StageConfiguration.jsp", "tool", "V1.0", null));

        repList.put("Type Property Checker", new Report("Workflow & Documents - Type Property Checker",
                "The Property Checker validates if the type properties are set correctly.",
                "PropertyChecker.jsp", "tool", "V1.0", null));

        repList.put("Type Usage", new Report(
                "Workflow & Documents - Type Usage",
                "This report summarizes the items created by type and informs you about the last modified Item date. <br>You can use the result to determine which types you may hide to the users. This report might run a moment!",
                "TypeUsage.jsp", "tool", "V1.0", null));

        // Configuration Management
        repList.put("Project Checkpoints", new Report(
                "Configuration Management - Project Checkpoints",
                "List of all checkpoints for the selected project. This report is here just for DEMO purposes.",
                "ProjectCheckpoints.jsp", "Source Report", "V1.0", null));
    }

    Map<String, Report> getRepList() {
        return repList;
    }

    Report getReport(String name) {
        return repList.get(name);
    }

}
