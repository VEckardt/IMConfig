<%@page import="api.IntegritySession.IMCommands"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
         pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <link rel="stylesheet" type="text/css" href="images/acls.css"
              media="screen">
        <link rel="stylesheet" type="text/css" href="images/aclsprint.css"
              media="print">
        <title>Integrity Type Property Checker</title>
    </head>
    <body>

        <%@ page import="java.sql.*" isThreadSafe="false"%>
        <%@ page import="java.util.*" isThreadSafe="false"%>
        <%@ page import="java.lang.*" isThreadSafe="false"%>
        <%@ page import="java.util.Date" isThreadSafe="false"%>
        <%@ page import="java.io.StringReader" isThreadSafe="false"%>
        <%@ page import="com.mks.api.*" isThreadSafe="false"%>
        <%@ page import="com.mks.api.response.*" isThreadSafe="false"%>
        <%@ page import="com.mks.api.util.ResponseUtil" isThreadSafe="false"%>
        <%@ page import="api.IntegritySession" isThreadSafe="false"%>
        <%@ page import="utils.Html" isThreadSafe="false"%>


        <%!// Maps
            // WorkItem Maps
            static Map<String, WorkItem> allFields = new HashMap<String, WorkItem>();
            static Map<String, WorkItem> allStates = new HashMap<String, WorkItem>();
            static Map<String, WorkItem> allReports = new HashMap<String, WorkItem>();
            static Map<String, WorkItem> allQueries = new HashMap<String, WorkItem>();
            // static Map<String, WorkItem> allTypes = new LinkedHashMap<String, WorkItem>();
            // Field Maps
            static Map<String, Field> allSharedCategories = new HashMap<String, Field>();
            static Map<String, Field> allTaskPhases = new HashMap<String, Field>();
            // Counters
            static int invalidCount = 0;
            static int rowId = 0;
            static int validCount = 0;
            static String displayMode = "All Rows";
            static Boolean displayValidRows = false;

            // basic conversion to html style
            public static String toHtml(String text) {
                String esc = text.replaceAll(",", ", ").replaceAll(";", "; ").replaceAll("<", "&lt;")
                        .replaceAll(">", "&gt;");
                return esc; // .replaceAll("<", "-").replaceAll(">", "-");
            }

            // prints out the property row as success
            public static String validProperty(String key, String[] value, String text) {
                validCount++;
                rowId++;
                String descr = (value.length == 1 ? "" : value[1]);
                if (displayMode.contentEquals(new StringBuffer("All Rows"))) {
                    return ("<tr>" + Html.td(rowId + "") + Html.td(toHtml(key)) + Html.td(toHtml(value[0]))
                            + Html.td("<img src=\"images/ok.png\" alt=\"ok\">") + Html.td(toHtml(text))
                            + Html.td(toHtml(descr)) + "</tr>");
                } else {
                    return "";
                }
            }

            // prints out the property row as an error
            public static String invalidProperty(String key, String[] value, String entry, String typeName) {
                invalidCount++;
                rowId++;
                String descr = (value.length == 1 ? "" : value[1]);
                return ("<tr>" + Html.td(rowId + "") + Html.td(toHtml(key)) + Html.td(toHtml(value[0]))
                        + Html.td("<img src=\"images/error.png\" alt=\"error\">")
                        + Html.td("'" + toHtml(entry) + "' is not a valid " + toHtml(typeName) + "!")
                        + Html.td(toHtml(descr)) + "</tr>");
            }

            // checking if entry is part of a certain Map as key
            @SuppressWarnings(  "rawtypes")
            public static String checkProperty(String key, String[] propValue, Map map, String objectName) {
                String result = "";

                // String[] propValue = (String[]) properties.get(key);
                String[] objList = propValue[0].split(",");
                int errCount = 0;
                for (int i = 0; i < objList.length; i++) {
                    // if (objectName.contentEquals("query"))
                    // 	result = result + "<hr>"+key+ "<hr>"+ propValue[0]+ "<hr>"+ propValue[1]+ "<hr>"+ objList[i]+ "<hr>"+ objectName+ "<hr>";
                    if (!map.containsKey(objList[i])) {
                        errCount++;
                        result = result + invalidProperty(key, propValue, objList[i], objectName);
                    }
                }
                if (errCount == 0) {
                    result = result
                            + validProperty(key, propValue, objList.length + " " + objectName + "(s) checked");
                }
                return result;
            }

            // checking if brackets of type { } contains a valid field name
            public static String checkDisplayString(Object key, String[] propValue, String displayString,
                    String objectName) {

//                Pattern pattern = Pattern.compile(new String("\\{([^\\}]+)"));
//                // CharSequence cs = displayString;
//                Matcher matcher = pattern.matcher(new StringBuilder(displayString));
//                String result = "";
//        // List<String> tags = new ArrayList<String>();
//
//        // System.out.println("displayString: " + displayString);
//                int pos = -1;
//                while (matcher.find(pos + 1)) {
//                    pos = matcher.start();
//          // System.out.println("pos: " + pos);
//                    // System.out.println(matcher.group(1) + "<br>");
//                    String[] dispFormat = new String[]{matcher.group(1), propValue[1]};
//                    // System.out.println("dispFormat: " + dispFormat);
//                    result = result + (checkProperty(key.toString(), dispFormat, allFields, objectName));
//                    // System.out.println("result: " + result);
//                }
                String checkString = displayString.replaceAll("\\{\\{", "{").replaceAll("\\}\\}", "}");
                String result = "";
                while (checkString.length() > 0) {
                    int start = checkString.indexOf("{");
                    int end = checkString.indexOf("}");
                    if (start > 0) {
                        String field = checkString.substring(start + 1, end);
                        // out.println("> '" + field + "'");
                        String[] dispFormat = new String[]{field, propValue[1]};
                        result = result + (checkProperty(key.toString(), dispFormat, allFields, objectName));
                        checkString = checkString.substring(end + 1);
                    } else {
                        checkString = "";
                    }
                }

                if (result.length() < 10) {
                    result = result + validProperty(key.toString(), propValue, objectName + " valid");
                }
                return result;
            }

            // general matching check
            public static String checkIfEntryMatches(Object key, String[] propValue, String[] match,
                    String objectName) {
                String result = "";
                Boolean valMatches = false;
                for (int m = 0; m < match.length; m++) {
                    if (propValue[0].matches(match[m])) {
                        valMatches = true;
                    }
                }
                if (valMatches) {
                    result = result + (validProperty(key.toString(), propValue, objectName + " valid"));
                } else {
                    result = result + (invalidProperty(key.toString(), propValue, propValue[0], objectName));
                }
                return result;
            }%>

        <%
            Html.initReport("Type Property Checker");

            out.println(Html.getTitle());
            // String title = "Type Property Checker - V1.0";

            Response respo;

            // get the type if provided as paramater
            String typeName = request.getParameter("type");
            if (typeName == null || typeName.contentEquals(new StringBuffer(""))) {
                typeName = ""; // at the beginning show nothing
            }
            displayMode = request.getParameter("displayMode");
            if (displayMode == null || displayMode.contentEquals(new StringBuffer(""))) {
                displayMode = "All Rows";
            }

            IntegritySession intSession = new IntegritySession();

            // all type information
            intSession.readAllObjects(IMCommands.types, intSession.allTypes);

            // BEGIN: Build the selection list for types
            String[] displayModeDefiniton = new String[] { "Display", "displayMode", displayMode, "All Rows", "Issues Only" };
            out.println(Html.itemSelectField("type", intSession.allTypes, true, typeName, displayModeDefiniton));

            // END: Build the selection list for types
            // if a type is provided or selected
            if (typeName != null && !typeName.contentEquals(new StringBuffer(""))) {

                // read all field details from Integrity
                intSession.readAllObjects(IMCommands.fields, allFields);
                intSession.readAllObjects(IMCommands.states, allStates);
                intSession.readAllObjects(IMCommands.reports, allReports);
                intSession.readAllObjects(IMCommands.queries, allQueries);
                intSession.readField("Shared Category", allSharedCategories, "picks", "phase");

                Boolean showAll = (typeName.contentEquals(new StringBuffer("All")));

                for (Object type : intSession.allTypes.keySet()) {
                    rowId = 0;
                    invalidCount = 0;
                    validCount = 0;

                    if (showAll) {
                        typeName = type.toString();
                    }

                    // for each type
                    try {

                        // execute the command
                        Command cmd = new Command(Command.IM, "viewtype");
                        cmd.addOption(new Option("showProperties"));
                        cmd.addSelection(typeName);

                        respo = intSession.execute(cmd);
                        // ResponseUtil.printResponse(respo, 1, System.out);

                        if (respo.getExitCode() == 0) {
                            WorkItem wi = respo.getWorkItem(typeName);

                            out.println("<hr><table border=1>");
                            out.println(Html.getHeaderField(wi, "name"));
                            out.println(Html.getHeaderField(wi, "description"));
                            out.println(Html.getHeaderField(wi, "documentClass"));
                            out.println(Html.getHeaderField(wi, "phaseField"));
                            // out.println(getHeaderField(wi, "associatedType"));
                            // out.println(getHeaderField(wi, "viewPresentation", "(displayed below)"));
                            out.println(Html.getHeaderField(wi, "modifiedBy"));
                            out.println(Html.getHeaderField(wi, "lastModified"));
                            out.println("</table>");

                            // properties
                            Map<String, String[]> properties = new LinkedHashMap<String, String[]>();
                            Field fld = wi.getField("properties");
                            if (fld != null && fld.getList() != null) {
                                @SuppressWarnings(  "rawtypes")
                                ListIterator li = fld.getList().listIterator();
                                while (li.hasNext()) {
                                    Item it = (Item) li.next();
                                    String pName = "" + it.getField("name").getValueAsString();
                                    String pDescription = "" + it.getField("description").getValueAsString();
                                    String pValue = "" + it.getField("value").getValueAsString();
                                    properties.put(pName, new String[]{pValue, pDescription});
                                }
                            }

                            // now, I have a list of fields and types, and the properties
                            // begin the validation
                            String notValidated = "";
                            int countNotValidated = 0;
                            // Properties
                            out.println("<br><u>Validated Properties:</u>");
                            out.println("<table border=1>");
                            out.println("<tr><th>Id</th><th>Property</th><th>Value</th></th>&nbsp;<th><th>Status</th><th>Description</th></tr>");
                            for (Object key : properties.keySet()) {
                                // out.println(key.toString());
                                String[] propValue = (String[]) properties.get(key);

                                // CharSequence editField = "EditabilityField";
                                // MKS.RQ.postbranch.edit.field
                                // MKS.RQ.Finder.Relationship
                                // MKS.RQ.LastVerdictType
                                if ((key.toString().startsWith("MKS.RQ.Editability."))
                                        || key.toString().endsWith("FieldName")
                                        || key.toString().indexOf("EditabilityField") > -1
                                        || key.toString().contentEquals(new StringBuffer("MKS.RQ.postbranch.edit.field"))
                                        || key.toString().contentEquals(new StringBuffer("MKS.RQ.model.mathworks.LinkTagName.Models"))
                                        || key.toString().contentEquals(new StringBuffer(
                                                        "MKS.RQ.model.mathworks.LinkTagName.Validated_By"))
                                        || key.toString().contentEquals(new StringBuffer("MKS.RQ.Finder.Relationship"))
                                        || key.toString().contentEquals(new StringBuffer("MKS.RQ.WBSDownRelationships"))
                                        || key.toString().contentEquals(new StringBuffer("MKS.RQ.WBSUpRelationship"))
                                        || key.toString().contentEquals(new StringBuffer("MKS.RQ.SessionsRelationshipField"))
                                        || key.toString().contentEquals(new StringBuffer("MKS.RQ.LastVerdictType"))) {
                                    out.println(checkProperty(key.toString(), propValue, allFields, "field"));
                                } else if ((key.toString().endsWith("Report"))) {
                                    out.println(checkProperty(key.toString(), propValue, allReports, "report"));
                                } else if ((key.toString().matches("MKS\\.RQ\\.Task.*PhaseName"))) {
                                    // MKS.RQ.ChangeOrderPhaseFieldName
                                    String[] copfn = (String[]) properties.get("MKS.RQ.ChangeOrderPhaseFieldName");
                                    intSession.readField(copfn[0], allTaskPhases, "phases", "label");
                                    out.println(checkProperty(key.toString(), propValue, allTaskPhases, "task phase"));
                                } // MKS.RQ.DocumentTitleFormat
                                else if ((key.toString().contentEquals(new StringBuffer("MKS.RQ.DocumentTitleFormat")))) {
                                    // out.println(checkProperty (key.toString(), propValue, allReports, "report"));
                                    out.println(checkDisplayString(key, propValue, propValue[0],
                                            "DocumentTitleFormat"));
                                } // MKS.RQ.StatesToSetTestsAsOfDateField
                                else if ((key.toString().endsWith("StateName"))
                                        || (key.toString().endsWith("PhaseStates"))
                                        || (key.toString().endsWith("MKS.RQ.StatesToSetTestsAsOfDateField"))) {
                                    out.println(checkProperty(key.toString(), propValue, allStates, "state"));
                                } // MKS.RQ.SegmentConstrainedPhaseName
                                else if ((key.toString().matches("MKS\\.RQ\\.Segment.*PhaseName"))) {
                                    // out.println("<tr><td>Checking Phase Name</tr></td>");
                                    Map<String, Field> allDocumentPhases = new HashMap<String, Field>();
                                    // we do this a bit hardcoded, but this shall work for many installations
                                    if (allFields.containsKey("ALM_Document Phase")) {
                                        intSession
                                                .readField("ALM_Document Phase", allDocumentPhases, "phases", "label");
                                    } else {
                                        intSession.readField("Document Phase", allDocumentPhases, "phases", "label");
                                    }
                                    out.println(checkProperty(key.toString(), propValue, allDocumentPhases,
                                            "document phase"));
                                } // MKS.RQ.BaselineLabelStates
                                else if ((key.toString().matches("MKS\\.RQ\\.BaselineLabelStates"))) {
                                    // ALM_In Review:In Review, ALM_Published:Published, ALM_Delivered:Delivered, ALM_Retired:Retired
                                    String[] elem1 = propValue[0].split(",");
                                    for (int e = 1; e < elem1.length; e++) {
                                        String[] elem2 = elem1[e].split(":");
                                        out.println(checkProperty(key.toString(), elem2, allStates, "state"));
                                    }
                                } // MKS.RQ.trace.
                                else if ((key.toString().matches("MKS\\.RQ\\.trace.*"))) {
                                    // Checking Value: MKS.RQ.trace.<Requirement, System Requirement>
                                    String[] elem1 = propValue[0].split(";");
                                    for (int e = 1; e < elem1.length; e++) {
                                        String[] elem2 = elem1[e].split(":");
                                        out.println(checkProperty(key.toString(), elem2, allFields, "field"));
                                        String[] elem3 = elem2[1].split(",");
                                        // out.println(elem3.length+", elem3[0] => "+toHtml(elem3[0])+"elem3[1] => "+toHtml(elem3[0])+"<br>");
                                        elem3[0] = elem3[0].replaceAll("<", "").replaceAll(">", "");
                                        out.println(checkProperty(key.toString(), elem3, intSession.allTypes, "type"));
                                        if (elem3.length > 1) {
                                            elem3[0] = elem3[1].replaceAll("<", "").replaceAll(">", "");
                                            elem3[1] = "Checking Property Value";
                                            out.println(checkProperty(key.toString(), elem3, allSharedCategories,
                                                    "category"));
                                        }
                                    }

                                    // Checking Key: MKS.RQ.trace.<Requirement, System Requirement>
                                    String[] elem4 = key.toString().split("\\<");
                                    elem4 = elem4[1].split(",");
                                    elem4[0] = elem4[0].replaceAll(">", "");
                                    out.println(checkProperty(key.toString(), elem4, intSession.allTypes, "type"));
                                    if (elem4.length > 1) {
                                        elem4[0] = elem4[1].replaceAll("<", "").replaceAll(">", "");
                                        elem4[1] = "Checking Property Key";
                                        out.println(checkProperty(key.toString(), elem4, allSharedCategories,
                                                "category"));
                                    }
                                    // out.println(invalidProperty (key.toString(), propValue, propValue[0], "Trace"));

                                } // MKS.RQ.trace.
                                else if ((key.toString().matches("MKS\\.RQ\\.selftrace"))) {
                                    // out.println("<tr><td>Checking Trace</tr></td>");
                                    // Checking Value: MKS.RQ.trace.<Requirement, System Requirement>
                                    String[] elem1 = propValue[0].split(";");
                                    for (int e = 1; e < elem1.length; e++) {
                                        String[] elem2 = elem1[e].split(":");
                                        elem2[0] = elem2[0].replaceAll("<", "").replaceAll(">", "");
                                        out.println(checkProperty(key.toString(), elem2, intSession.allTypes, "type"));
                                        String[] elem3 = elem2[1].split(",");
                                        // out.println(elem3.length+", elem3[0] => "+toHtml(elem3[0])+"elem3[1] => "+toHtml(elem3[0])+"<br>");
                                        elem3[0] = elem3[0].replaceAll("<", "").replaceAll(">", "");
                                        out.println(checkProperty(key.toString(), elem3, allFields, "field"));
                                        if (elem3.length > 1) {
                                            elem3[0] = elem3[1].replaceAll("<", "").replaceAll(">", "");
                                            elem3[1] = "Checking Property Value";
                                            out.println(checkProperty(key.toString(), elem3, allSharedCategories,
                                                    "category"));
                                        }
                                    }
                                } // SelectionType
                                else if ((key.toString().matches(".*SelectionType"))) {
                                    out.println(checkIfEntryMatches(key, propValue, new String[]{"None",
                                        "SelectedItem"}, "SelectionType"));
                                } // CommandToken
                                else if ((key.toString().matches(".*CommandToken"))) {
                                    out.println(checkIfEntryMatches(key, propValue, new String[]{
                                        "ci.Relationships", "ci.Issues"}, "CommandToken"));
                                } // MKS.RQ.rm.document.views.item2.type
                                // MKS.RQ.rm.content.trace.item3.type
                                // MKS.RQ.tm.test.views.item2.type
                                else if ((key.toString().matches("MKS\\.RQ\\.rm\\.document\\.views\\.item.*type"))
                                        || (key.toString().matches("MKS\\.RQ\\.rm\\.content\\.trace\\.item.*type"))
                                        || (key.toString().matches("MKS\\.RQ\\.tm\\.test\\.views\\.item.*type"))) {
                                    out.println(checkIfEntryMatches(key, propValue, new String[]{"item",
                                        "separator"}, "type"));
                                } // MKS.RQ.rm.view7.ViewLoaderMessage
                                // MKS.RQ.rm.view11.ViewLoaderMessage
                                // MKS.RQ.rm.view1.Name
                                // MKS.RQ.rm.document.views.item0.name
                                // MKS.RQ.tm.test.views.item2.name
                                // MKS.RQ.rm.content.trace.item3.name
                                // MKS.RQ.BaselinePrefix
                                // MKS.SolutionDefinition
                                // MKS.isRQ
                                else if ((key.toString().matches("MKS\\.RQ\\.rm\\.view.*\\.ViewLoaderMessage"))
                                        || (key.toString().matches("MKS\\.RQ\\.rm\\.content\\.trace\\.item.*\\.type"))
                                        || (key.toString().matches("MKS\\.RQ\\.rm\\.view.*\\.Name"))
                                        || (key.toString()
                                        .matches("MKS\\.RQ\\.rm\\.document\\.views\\.item.*\\.name"))
                                        || (key.toString().matches("MKS\\.RQ\\.tm\\.test\\.views\\.item.*\\.name"))
                                        || (key.toString().matches("MKS\\.RQ\\.rm\\.content\\.trace\\.item.*\\.name"))
                                        || (key.toString().matches("MKS\\.RQ\\.BaselinePrefix"))
                                        || (key.toString().matches("MKS\\.SolutionDefinition\\..*"))
                                        || (key.toString().matches("MKS\\.isRQ"))) {
                                    if (propValue[0].length() >= 3) {
                                        out.println(validProperty(key.toString(), propValue, "String valid"));
                                    } else {
                                        out.println(invalidProperty(key.toString(), propValue, propValue[0], "String"));
                                    }
                                } // MKS.RQ.rm.view8.TabIcon
                                else if ((key.toString().matches("MKS\\.RQ\\.rm\\.view.*\\.TabIcon"))) {
                                    out.println(checkIfEntryMatches(key, propValue, new String[]{".*\\.gif"},
                                            "TabIcon"));
                                } // MKS.RQ.tm.test.views.item2.ViewRef
                                // MKS.RQ.rm.content.trace.item2.ViewRef
                                // MKS.RQ.rm.document.views.item8.ViewRef
                                else if ((key.toString().matches("MKS\\.RQ\\.tm\\.test\\.views\\.item.*\\.ViewRef"))
                                        || (key.toString()
                                        .matches("MKS\\.RQ\\.rm\\.content\\.trace\\.item.*\\.ViewRef"))
                                        || (key.toString()
                                        .matches("MKS\\.RQ\\.rm\\.document\\.views\\.item.*\\.ViewRef"))) {
                                    out.println(checkIfEntryMatches(key, propValue, new String[]{"rm\\.view.*"},
                                            "ViewRef"));
                                } // MKS.RQ.tm.test.views.item2.handlerClass
                                // MKS.RQ.rm.document.views.item7.handlerClass
                                // MKS.RQ.rm.content.trace.item3.handlerClass
                                else if ((key.toString()
                                        .matches("MKS\\.RQ\\.tm\\.test\\.views\\.item.*\\.handlerClass"))
                                        || (key.toString()
                                        .matches("MKS\\.RQ\\.rm\\.document\\.views\\.item.*\\.handlerClass"))
                                        || (key.toString()
                                        .matches("MKS\\.RQ\\.rm\\.content\\.trace\\.item.*\\.handlerClass"))) {
                                    out.println(checkIfEntryMatches(
                                            key,
                                            propValue,
                                            new String[]{"mks\\.ic\\.ci\\.ui\\.swing\\.requirements\\.SegmentInteractor"},
                                            "handlerClass"));
                                } // MKS.RQ.rm.view12.DynamicViewClass
                                else if ((key.toString().matches("MKS\\.RQ\\.rm\\.view.*\\.DynamicViewClass"))) {
                                    out.println(checkIfEntryMatches(key, propValue,
                                            new String[]{"mks\\.ic\\.ci\\.ui\\.swing\\.RelationshipsWindow"},
                                            "DynamicViewClass"));
                                } // MKS.RQ.tm.test.views.item0.SimpleRequirementsChecker.Cardinality
                                // MKS.RQ.rm.document.views.item7.SimpleRequirementsChecker.Cardinality
                                // MKS.RQ.rm.content.trace.item7.SimpleRequirementsChecker.Cardinality
                                else if ((key.toString()
                                        .matches("MKS\\.RQ\\.tm\\.test\\.views\\.item.*\\.SimpleRequirementsChecker\\.Cardinality"))
                                        || (key.toString()
                                        .matches("MKS\\.RQ\\.rm\\.document\\.views\\.item.*\\.SimpleRequirementsChecker\\.Cardinality"))
                                        || (key.toString()
                                        .matches("MKS\\.RQ\\.rm\\.content\\.trace\\.item.*\\.SimpleRequirementsChecker\\.Cardinality"))) {
                                    out.println(checkIfEntryMatches(key, propValue, new String[]{"1\\+", "0\\+"},
                                            "Cardinality"));
                                } // MKS.RQ.Domain
                                else if ((key.toString().matches("MKS\\.RQ\\.Domain"))) {
                                    out.println(checkIfEntryMatches(key, propValue, new String[]{"Test", "Input",
                                        "Requirement", "Specification", "Modelling"}, "Domain"));
                                } // MKS.RQ.Domain
                                else if ((key.toString().matches("MKS\\.RQ\\.Class"))) {
                                    out.println(checkIfEntryMatches(key, propValue, new String[]{"Change Request",
                                        "Change Order"}, "Class"));
                                } // MKS.RQ.PortfolioClassifications
                                else if ((key.toString().matches("MKS\\.RQ\\.PortfolioClassification"))) {
                                    out.println(checkIfEntryMatches(key, propValue, new String[]{"Project", "Product"},
                                            "PortfolioClassifications"));
                                } // MKS.RQ.rm.document.viewdocument.viewSettings
                                // MKS.RQ.rm.document.open.viewSettings
                                else if ((key.toString()
                                        .matches("MKS\\.RQ\\.rm\\.document\\.viewdocument\\.viewSettings"))
                                        || (key.toString().matches("MKS\\.RQ\\.rm\\.document\\.open\\.viewSettings"))) {

                                    // MKS.RQ.rm.document.open.viewSettings
                                    String[] paramList = propValue[0].split("\",");
                                    for (int p = 0; p < paramList.length; p++) {
                                        String pair = paramList[p].replaceAll("\"", "");
                                        String[] param = pair.split("=");
                                        // "structureFieldIconDisplayField=Category", "outlineColumns=Structure", "availableContexts=Authoring, Sharing, Tracing, MyOwn"
                                        // structureFieldIconDisplayField
                                        if (param[0].contentEquals(new StringBuffer("structureFieldIconDisplayField"))) {
                                            String[] propVal = new String[]{param[1], propValue[1]};
                                            out.println(checkProperty(key.toString(), propVal, allFields,
                                                    "structureFieldIconDisplayField"));
                                        } else // outlineColumns
                                        if (param[0].contentEquals(new StringBuffer("outlineColumns"))) {
                                            String[] propVal = new String[]{param[1], propValue[1]};
                                            out.println(checkProperty(key.toString(), propVal, allFields,
                                                    "traverseFields"));
                                        } else // availableContexts
                                        if (param[0].contentEquals(new StringBuffer("availableContexts"))) {
                                            String[] contexts = param[1].split(",");
                                            for (int c = 0; c < contexts.length; c++) {
                                                if (contexts[c].contentEquals(new StringBuffer("Authoring"))
                                                        || contexts[c].contentEquals(new StringBuffer("Sharing"))
                                                        || contexts[c].contentEquals(new StringBuffer("Tracing"))) {
                                                    out.println(validProperty(key.toString(), propValue, "context '"
                                                            + contexts[c] + "' valid"));
                                                } else {
                                                    out.println(invalidProperty(key.toString(), propValue, contexts[c],
                                                            "context"));
                                                }
                                            }
                                        }
                                    }
                                } // MKS.RQ.tm.test.views.item0.viewSettings
                                // MKS.RQ.rm.document.views.item8.viewSettings
                                // MKS.RQ.rm.content.trace.item1.viewSettings
                                // "title=Test Status", "tabTitle=Test Status", "traverseFields=ALM_Test Plans, ALM_Test Objectives, ALM_Completed Test Sessions", "structureFieldDisplayFormat={Summary}{Text} - {Type}", "displayForwardFields=False", "displayBackwardFields=False", "showFieldNodes=false", "saveSettings=false"
                                else if ((key.toString()
                                        .matches("MKS\\.RQ\\.tm\\.test\\.views\\.item.*\\.viewSettings"))
                                        || (key.toString()
                                        .matches("MKS\\.RQ\\.rm\\.document\\.views\\.item.*\\.viewSettings"))
                                        || (key.toString()
                                        .matches("MKS\\.RQ\\.rm\\.content\\.trace\\.item.*\\.viewSettings"))) {

                                    // MKS.RQ.rm.document.open.viewSettings
                                    String[] paramList = propValue[0].split("\",");
                                    for (int p = 0; p < paramList.length; p++) {
                                        String pair = paramList[p].replaceAll("\"", "");
                                        String[] param = pair.split("=");
                                        if (param[0].contentEquals(new StringBuffer("title")) || param[0].contentEquals(new StringBuffer("tabTitle"))) {
                                            if (param[1].length() > 0) {
                                                out.println(validProperty(key.toString(), propValue, param[0] + " valid"));
                                            } else {
                                                out.println(invalidProperty(key.toString(), propValue, param[1], param[0]));
                                            }
                                        } else if (param[0].contentEquals(new StringBuffer("expandLevel"))) {
                                            if (param[1].contentEquals(new StringBuffer("1")) || param[1].contentEquals(new StringBuffer("2"))
                                                    || param[1].contentEquals(new StringBuffer("3"))) {
                                                out.println(validProperty(key.toString(), propValue, "expandLevel valid"));
                                            } else {
                                                out.println(invalidProperty(key.toString(), propValue, param[1], param[0]));
                                            }
                                        } else if (param[0].contentEquals(new StringBuffer("displayForwardFields"))
                                                || param[0].contentEquals(new StringBuffer("displayBackwardFields"))
                                                || param[0].contentEquals(new StringBuffer("showFieldNodes"))
                                                || param[0].contentEquals(new StringBuffer("appendQueryToTitle")) // rm
                                                || param[0].contentEquals(new StringBuffer("saveSettings"))) {
                                            if (param[1].contentEquals(new StringBuffer("True")) || param[1].contentEquals(new StringBuffer("true"))
                                                    || param[1].contentEquals(new StringBuffer("False")) || param[1].contentEquals(new StringBuffer("false"))) {
                                                out.println(validProperty(key.toString(), propValue, param[0] + " valid"));
                                            } else {
                                                out.println(invalidProperty(key.toString(), propValue, param[1], param[0]));
                                            }
                                        } else // traverseFields
                                        if (param[0].contentEquals(new StringBuffer("traverseFields"))) {
                                            String[] propVal = new String[]{param[1], propValue[1]};
                                            out.println(checkProperty(key.toString(), propVal, allFields, param[0]));
                                        } else // query
                                        if (param[0].contentEquals(new StringBuffer("query"))) {
                                            String[] propVal = new String[]{param[1], propValue[1]};
                                            out.println(checkProperty(key.toString(), propVal, allQueries, param[0]));
                                        } else if (param[0].contentEquals(new StringBuffer("structureFieldDisplayFormat"))) {
                                            out.println(checkDisplayString(key, propValue, param[1], param[0]));
                                        } else if (param[0].contentEquals(new StringBuffer("structureFieldIconDisplayField"))) {
                                            out.println(checkDisplayString(key, propValue, param[1], param[0]));
                                        } else {
                                            out.println(invalidProperty(key.toString(), propValue, param[1], param[0]));
                                        }
                                    }
                                } // MKS.RQ.item.editissue.title
                                else if ((key.toString().matches("MKS\\.RQ\\.item\\.editissue\\.title"))) {
                                    out.println(checkDisplayString(key, propValue, propValue[0], "title field"));
                                } // MKS.RQ.rm.document.includedocument.finderSettings
                                // MKS.RQ.rm.document.createfromtemplate.finderSettings
                                // MKS.RQ.rm.content.insertdocument.finderSettings
                                else if ((key.toString().matches("MKS\\.RQ\\.rm\\.document\\..*\\.finderSettings"))
                                        || (key.toString().matches("MKS\\.RQ\\.rm\\.document\\..*\\.finderSettings"))
                                        || (key.toString().matches("MKS\\.RQ\\.rm\\.content\\..*\\.finderSettings"))) {
                                    String[] paramList = propValue[0].split("\",");
                                    for (int p = 0; p < paramList.length; p++) {
                                        String pair = paramList[p].replaceAll("\"", "");
                                        String[] param = pair.split("=");
                                        if (param[0].contentEquals(new StringBuffer("title"))) {
                                            if (param[1].length() > 0) {
                                                out.println(validProperty(key.toString(), propValue, param[0] + " valid"));
                                            } else {
                                                out.println(invalidProperty(key.toString(), propValue, param[1], param[0]));
                                            }
                                        } else if (param[0].contentEquals(new StringBuffer("fields"))) {
                                            if (param[1].length() > 0) {
                                                out.println(validProperty(key.toString(), propValue, param[0] + " valid"));
                                            } else {
                                                out.println(invalidProperty(key.toString(), propValue, param[1], param[0]));
                                            }
                                        } else if (param[0].contentEquals(new StringBuffer("showFieldNodes"))) {
                                            if (param[1].contentEquals(new StringBuffer("True")) || param[1].contentEquals(new StringBuffer("true"))
                                                    || param[1].contentEquals(new StringBuffer("False")) || param[1].contentEquals(new StringBuffer("false"))) {
                                                out.println(validProperty(key.toString(), propValue, param[0] + " valid"));
                                            } else {
                                                out.println(invalidProperty(key.toString(), propValue, param[1], param[0]));
                                            }
                                        } else // query
                                        if (param[0].contentEquals(new StringBuffer("query"))) {
                                            String[] propVal = new String[]{param[1], propValue[1]};
                                            out.println(checkProperty(key.toString(), propVal, allQueries, param[0]));
                                        } else if (param[0].contentEquals(new StringBuffer("nodeDisplayFields"))) {
                                            out.println(checkDisplayString(key, propValue, param[1], "nodeDisplayFields"));
                                        } else {
                                            out.println(invalidProperty(key.toString(), propValue, param[1], param[0]));
                                        }
                                    }
                                } else {
                                    countNotValidated++;
                                    notValidated = notValidated + "<tr>" + Html.td(toHtml(key.toString()))
                                            + Html.td(toHtml(propValue[0]))
                                            + Html.td("<img src=\"images/unreadFlag.png\" alt=\"-\">")
                                            + Html.td("not validated") + Html.td(toHtml(propValue[1])) + "</tr>";
                                }
                            }
                            out.println("</table><br>");

                            out.println("<u>Result:</u>");
                            out.println("<table border=1>");
                            out.println("<tr><th>Properties defined</th><th>Validations performed</th><th>With Success</th><th>With Issues</th><th>Properties not validated yet</th></tr>");
                            out.println("<tr>" + Html.td(properties.size() + "") + Html.td(rowId + "")
                                    + Html.td(validCount + "") + Html.td(invalidCount + "")
                                    + Html.td(countNotValidated + "") + "</tr>");
                            out.println("</table><br>");

                            if (countNotValidated > 0) {
                                out.println("<u>Properties not validated yet:</u>");
                                out.println("<table border=1>");
                                out.println("<tr><th>Property</th><th>Value</th></th>&nbsp;<th><th>Status</th><th>Description</th></tr>");
                                out.println(notValidated);
                                out.println("</table><br>");
                            }

                        }

                    } catch (APIException ex) {
                        out.println("The command failed - APIException:");
                        out.println(Html.logException(ex));
                    }
                    if (!showAll) {
                        break;
                    }
                }
                out.println(intSession.getAbout(Html.getTitleAndVersion()));
                // Execute disconnect
                intSession.release();
            }
        %>

    </body>
</html>