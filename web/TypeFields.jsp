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
        <title>Integrity Type Fields</title>
    </head>
    <body>

        <%@ page import="java.sql.*" isThreadSafe="false"%>
        <%@ page import="java.util.*" isThreadSafe="false"%>
        <%@ page import="java.util.Date" isThreadSafe="false"%>
        <%@ page import="java.io.StringReader" isThreadSafe="false"%>
        <%@ page import="com.mks.api.*" isThreadSafe="false"%>
        <%@ page import="com.mks.api.response.*" isThreadSafe="false"%>
        <%@ page import="com.mks.api.util.ResponseUtil" isThreadSafe="false"%>
        <%@ page import="javax.xml.parsers.DocumentBuilder"
                 isThreadSafe="false"%>
        <%@ page import="javax.xml.parsers.DocumentBuilderFactory"
                 isThreadSafe="false"%>
        <%@ page import="org.w3c.dom.Document" isThreadSafe="false"%>
        <%@ page import="org.w3c.dom.Element" isThreadSafe="false"%>
        <%@ page import="org.w3c.dom.NamedNodeMap" isThreadSafe="false"%>
        <%@ page import="org.w3c.dom.Node" isThreadSafe="false"%>
        <%@ page import="org.w3c.dom.NodeList" isThreadSafe="false"%>
        <%@ page import="org.xml.sax.InputSource" isThreadSafe="false"%>
        <%@ page import="api.IntegritySession" isThreadSafe="false"%>
        <%@ page import="utils.Html" isThreadSafe="false"%>
        <%@ page import="utils.Legend" isThreadSafe="false"%>
        <%@ page import="api.TypeProperty" isThreadSafe="false"%>

        <%!// Maps
            // Simple String Maps
            static Map<String, String> typeFields = new HashMap<String, String>();
            static Map<String, String> sortedTypeFields = new LinkedHashMap<String, String>();

            static Map<String, String[]> typeEditProps = new LinkedHashMap<String, String[]>();
            // Legend
            static Legend legend = new Legend();

            private static void getFieldRow(IntegritySession intSession, List<String> fields, String ident,
                    Map<String, String> copyFields, Map<String, String> significantEditFields,
                    Map<String, String[]> typeProps, Map<String, String> stateTransitions,
                    Map<String, String> mandatoryFields) {
                // for all fields
                for (int i = 0; i < fields.size(); i++) {
                    WorkItem field = (WorkItem) intSession.allFields.get(fields.get(i));

                    // allow color setting later using #bgcolor#
                    String data = ("<tr><th style='text-align:left;'>" + fields.get(i) + "</th>");

                    try {
                        String maxLength = field.getField("maxLength").getValueAsString();
                        data = data
                                + ("<td style='#bgcolor#text-align:left;'>"
                                + field.getField("type").getValueAsString() + "&nbsp;(" + maxLength + ")</td>");
                    } catch (Exception e) {
                        data = data
                                + ("<td style='#bgcolor#text-align:left;'>"
                                + field.getField("type").getValueAsString() + "</td>");
                    }

                    data = data + ("<td style='#bgcolor#text-align:center;'>" + ident + "</td>");
                    if (copyFields.containsKey(fields.get(i))) {
                        data = data + ("<td style='#bgcolor#text-align:center;'>x</td>");
                    } else {
                        data = data + ("<td style='#bgcolor#text-align:center;'>-</td>");
                    }
                    if (significantEditFields.containsKey(fields.get(i))) {
                        data = data + ("<td style='#bgcolor#text-align:center;'>x</td>");
                    } else {
                        data = data + ("<td style='#bgcolor#text-align:center;'>-</td>");
                    }

                    for (Object key : typeProps.keySet()) {
                        String fieldsProp = typeProps.get(key)[0];
                        if (("," + fieldsProp + ",").indexOf("," + fields.get(i) + ",") > -1) {
                            data = data + ("<td style='#bgcolor#text-align:center;'>x</td>");
                        } else {
                            data = data + ("<td style='#bgcolor#text-align:center;'>-</td>");
                        }
                    }

                    for (Object key : stateTransitions.keySet()) {
                        if (mandatoryFields.containsKey(fields.get(i) + "+" + key.toString())) {
                            data = data + ("<td style='#bgcolor#text-align:center;'>" + "x" + "</td>");
                        } else {
                            data = data + ("<td style='#bgcolor#text-align:center;'>" + "-" + "</td>");
                        }
                    }
                    data = data
                            + ("<td style='#bgcolor#text-align:left;'>"
                            + field.getField("displayName").getValueAsString() + "</td>");
                    data = data
                            + ("<td style='#bgcolor#text-align:left;'>" + field.getField("description")
                            .getValueAsString());
                    if (field.getField("type").getValueAsString().contentEquals(new StringBuffer("fva"))) {
                        data = data + "<br>(Relationship: "
                                + field.getField("backedBy").getValueAsString().replaceAll("\\.", ", Field: ") + ")";
                    }
                    data = data + ("</td>");

                    data = data + ("</tr>");
                    typeFields.put(fields.get(i), data);
                    sortedTypeFields.put(fields.get(i), data);
                }
                // out.println(">>> typeFields.size() > "+typeFields.size()+"");
            }

            // get the xml document from a String 
            public static Document loadXMLFromString(String xml) throws Exception {
                DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
                DocumentBuilder builder = factory.newDocumentBuilder();
                InputSource is = new InputSource(new StringReader(xml));
                return builder.parse(is);
            }%>

        <%
            Html.initReport("Type Fields");
            out.println(Html.getTitle());
            // out.println(request.getParameter("fields")+"<br>");
            // out.println(request.getParameter("sortby")+"<br>");

            Response respo;
            Map<String, WorkItem> allTypes = new LinkedHashMap<String, WorkItem>();

            // Parameter
            // get the type if provided as paramater
            String typeName = request.getParameter("type");

            // Connect to Integrity
            IntegritySession intSession = new IntegritySession();
            intSession.readAllObjects(IMCommands.types, allTypes);

            // Build the selection list for types
            out.println(Html.itemSelectField("type", allTypes, false, typeName, ""));

            // if a type is provided or selected
            if (typeName != null && !typeName.equals("")) {

                // read all field details from Integrity
                intSession.readAllFields(null);
                intSession.readAllObjects(IMCommands.triggers, intSession.allTriggers);
                intSession.solutionProperties = intSession.getProperties(null, "MKS Solution");

                // loop through all types in the document hierarchy  (segment > node > shared node)
                while (!typeName.equals("")) {
                    try {
                        // execute the command
                        Command cmd = new Command(Command.IM, "viewtype");
                        cmd.addOption(new Option("showProperties"));
                        cmd.addSelection(typeName.replaceAll("\\+", " "));

                        respo = intSession.execute(cmd);
                        // ResponseUtil.printResponse(respo, 1, System.out);

                        if (respo.getExitCode() == 0) {
                            WorkItem wi = respo.getWorkItem(typeName.replaceAll("\\+", " "));

                            String docClass = wi.getField("documentClass").getValueAsString();

                            out.println("<hr><table border=1>");
                            out.println(Html.getHeaderField(wi, "name"));
                            out.println(Html.getHeaderField(wi, "description"));
                            out.println(Html.getHeaderField(wi, "documentClass"));
                            out.println(Html.getHeaderField(wi, "phaseField"));
                            out.println(Html.getHeaderField(wi, "associatedType"));
                            out.println(Html.getHeaderField(wi, "viewPresentation", "(displayed below)"));
                            out.println(Html.getHeaderField(wi, "modifiedBy"));
                            out.println(Html.getHeaderField(wi, "lastModified"));
                            out.println("</table>");

                            // get the next type name in the hierarchy, or set to "blank" when done
                            try {
                                if (wi.getField("associatedType").getValueAsString().contentEquals(new StringBuffer("none"))) {
                                    typeName = "";
                                } else {
                                    typeName = wi.getField("associatedType").getValueAsString();
                                }
                            } catch (Exception e) {
                                // in case of invalid response, stop herewith
                                typeName = "";
                            }

                            Map<String, String> phases = new HashMap<String, String>();

                            if (wi.getField("phaseField").getValueAsString() != null
                                    && !wi.getField("phaseField").getValueAsString().contentEquals(new StringBuffer("null"))) {
                                // build up the map for the phase field
                                cmd = new Command(Command.IM, "viewfield");
                                cmd.addSelection(wi.getField("phaseField").getValueAsString());
                                respo = intSession.execute(cmd);
                                WorkItem wph = respo.getWorkItem(wi.getField("phaseField").getValueAsString());
                                // ResponseUtil.printResponse(respo, 1, System.out);
                                Field fld = wph.getField("phases");
                                if (fld != null && fld.getList() != null) {
                                    @SuppressWarnings(  "rawtypes")
                                    ListIterator lip = fld.getList().listIterator();
                                    while (lip.hasNext()) {
                                        Item it = (Item) lip.next(); // im.PhaseList.Entry
                                        Field fld2 = it.getField("states");
                                        @SuppressWarnings(  "rawtypes")
                                        ListIterator li2 = fld2.getList().listIterator();
                                        while (li2.hasNext()) {
                                            String it2 = (String) li2.next(); // Field
                                            phases.put(it2, it.getId());
                                        }
                                    }
                                }
                            }

                            Map<String, String> stateTransHM = new HashMap<String, String>();
                            Map<String, String> stateGroupsLHM = new LinkedHashMap<String, String>();

                            // BEGIN: Workflow State Transitions and permitted Groups
                            String stateTrans = "<table border=1>";
                            stateTrans = stateTrans
                                    + "<tr><th>From State</th><th>To State</th><th>Permitted Groups</th></tr>";
                            Field fld = wi.getField("stateTransitions");
                            @SuppressWarnings(  "rawtypes")
                            ListIterator liSt = fld.getList().listIterator();
                            while (liSt.hasNext()) {
                                Item it = (Item) liSt.next();
                                String currFromState = "";
                                String fromState = it.getId();
                                fld = it.getField("targetStates");
                                @SuppressWarnings(  "rawtypes")
                                ListIterator li2 = fld.getList().listIterator();
                                while (li2.hasNext()) {
                                    Item it2 = (Item) li2.next();
                                    String toState = it2.getId();
                                    if (!fromState.contentEquals(new StringBuffer(toState))) {
                                        if (currFromState.contentEquals(new StringBuffer(fromState))) {
                                            stateTrans = stateTrans + "<tr><td>&nbsp;</td>";
                                        } else {
                                            stateTrans = stateTrans + "<tr><td>" + fromState + "</td>";
                                            currFromState = fromState;
                                        }
                                        stateTrans = stateTrans + "<td>" + toState + "</td><td>";
                                        fld = it2.getField("permittedGroups");
                                        @SuppressWarnings(  "rawtypes")
                                        ListIterator li3 = fld.getList().listIterator();
                                        while (li3.hasNext()) {
                                            Item it3 = (Item) li3.next();
                                            String permGroup = it3.getId();
                                            // out.println(fromState+" => "+toState+ ", permGroup: "+permGroup);
                                            stateTrans = stateTrans + permGroup + ", ";
                                            stateTransHM.put(fromState + "+" + toState + "+" + permGroup, "x");
                                            stateGroupsLHM.put(permGroup, "x");
                                        }
                                        stateTrans = stateTrans + "</td></tr>";
                                    }
                                }
                                // stateTrans = stateTrans + "</tr>";
                            }
                            stateTrans = stateTrans + "</table>";

                            String permGrps = "";
                            for (Object key : stateGroupsLHM.keySet()) {
                                permGrps = permGrps + "<th>" + key.toString() + "</th>";
                            }
                                  // not yet here:  stateTrans = stateTrans.replace("<th>Permitted Groups</th>", permGrps);

                            // END: Workflow State Transitions and permitted Groups
                            // Properties
                            Map<String, String[]> properties = intSession.getProperties(wi, null);

                            //
                            typeEditProps.clear();

                            // editable Fields based on other fields
                            if (docClass.contentEquals(new StringBuffer("segment")) || docClass.contentEquals(new StringBuffer("node"))) {
                                // MKS.RQ.Editability.1
                                // Fields that are editable only when the field referenced by property 
                                // MKS.RQ.EditabilityField.1 = "Valid Change Order" has value "true".

                                String[] editPropertyName = {"MKS.RQ.Editability.1", "MKS.RQ.Editability.Document.1", "MKS.RQ.Editability.Document.2", "MKS.RQ.Editability.Document.3"};
                                for (int i = 0; i < editPropertyName.length; i++) {
                                    intSession.setEditProperty(properties, typeEditProps, editPropertyName[i]);
                                }

                                // (Configurable) Fields that are editable only when the field referenced by property 
                                // MKS.RQ.EditabilityField.Document.1 has value "true".
                                // Allow Edits
                                // Allow Trace = "MKS.RQ.Editability.Document.2";
                                // Allow Link = "MKS.RQ.Editability.Document.3";
                            }

                            // visibleFields
                            List<String> visibleFields = intSession.getFieldList(wi, "visibleFields");
                            // systemManagedFields
                            List<String> systemManagedFields = intSession.getFieldList(wi, "systemManagedFields");
                            // copyFields
                            Map<String, String> copyFields = intSession.getFieldMap(wi, "copyFields");
                            // significantEditFields
                            Map<String, String> significantEditFields = intSession.getFieldMap(wi, "significantEdit");
                            // stateTransitions
                            Map<String, String> stateTransitions = intSession.getFieldMap(wi, "stateTransitions");

                            // mandatoryFields
                            Map<String, String> mandatoryFields = new HashMap<String, String>();
                            fld = wi.getField("mandatoryFields");
                            if (fld != null && fld.getList() != null) {
                                ListIterator li = fld.getList().listIterator();
                                while (li.hasNext()) {
                                    Item it = (Item) li.next(); // State
                                    Field fld2 = it.getField("fields");
                                    @SuppressWarnings(  "rawtypes")
                                    ListIterator li2 = fld2.getList().listIterator();
                                    while (li2.hasNext()) {
                                        Item it2 = (Item) li2.next(); // Field
                                        mandatoryFields.put(it2.getId() + "+" + it.getId(), "x");
                                    }
                                }
                            }

                            // Begin with the main table output
                            out.println("<br><h3>Fields and States:</h3><table border=1>");
                            out.println("<tr><th height=\"180\">Fields</th><th>Type</th><th>Visible</th><th>Copy</th><th>Sign Edit</th>");
                            for (Object key : typeEditProps.keySet()) {
                                out.println("<th>if " + key + "</th>");
                            }

                            // out.println("<th>if "+edit1Field+"</th><th>if "+editDoc1Field+"</th><th>if "+editDoc2Field+"</th><th>if "+editDoc3Field+"</th>");
                            for (Object key : stateTransitions.keySet()) {
                                String phase = (String) phases.get(key.toString());
                                if (phase != null && !phase.equals("")) {
                                    out.println("<th><div class=\"verticalText\">" + key.toString() + "&nbsp;("
                                            + phase + ")</div></th>");
                                } else {
                                    out.println("<th><div class=\"verticalText\">" + key.toString() + "</div></th>");
                                }
                            }

                            out.println("<th>DisplayName</th><th>Description</th></tr>");

                            // for visibleFields
                            // out.println(getFieldRow(visibleFields, "x", copyFields, significantEditFields, stateTransitions, mandatoryFields));
                            // for systemManagedFields
                            // out.println(getFieldRow(systemManagedFields, "S", copyFields, significantEditFields, stateTransitions, mandatoryFields));
                            // fill the arrays
                            typeFields.clear();
                            sortedTypeFields.clear();
                            getFieldRow(intSession, visibleFields, "x", copyFields, significantEditFields,
                                    typeEditProps, stateTransitions, mandatoryFields);
                            getFieldRow(intSession, systemManagedFields, "S", copyFields, significantEditFields,
                                    typeEditProps, stateTransitions, mandatoryFields);

                            // analyse the presentation xml
                            // havn't found a better way than SQL :)
                            if (true) {
                                String viewPresentation = wi.getField("viewPresentation").getValueAsString();
                                // out.println(">>> viewPresentation => "+viewPresentation);
                                String sql = "select Contents from DBFile where Name like '%/" + viewPresentation
                                        + ".xml'";
                                Command cmd2 = new Command(Command.IM, "diag");
                                cmd2.addOption(new Option("diag", "runsql"));
                                cmd2.addOption(new Option("param", sql));
                                Response respo2 = intSession.execute(cmd2);

                                /// out.println(respo2.toString());
                                // ResponseUtil.printResponse(respo2, 1, System.out);
                                if (respo2.getExitCode() == 0) {
                                    Result result = respo2.getResult();
                                    String message = result.getMessage();

                                    if (message.length() > 100) {
                                        int p = message.indexOf("xml");
                                        // out.println(message);
                                        // out.println("~" + p + "~" + message.length() + "~");
                                        Document doc = loadXMLFromString(message.substring(p - 2));

                                        NodeList nodes1 = doc.getElementsByTagName("Tab");
                                        // out.println(nodes1.getLength() + " Tabs found to analyse ...");
                                        for (int h = 0; h < nodes1.getLength(); h++) {
                                            Node node1 = nodes1.item(h);
                                            // out.println(node1.getNodeName());
                                            NamedNodeMap nnm = node1.getAttributes();
                                            Node nName = nnm.getNamedItem("name");
                                            Node nPosition = nnm.getNamedItem("position");
                                            // out.println(nName.getNodeValue() + " /" + nPosition.getNodeValue() + "/");
                                            // out.println(nPosition.getNodeValue());
                                            out.println("<tr><td>Tab:&nbsp" + nName.getNodeValue() + "</td></tr>");

                                            if (node1 instanceof Element) {
                                                Element e = (Element) node1;
                                                NodeList nl = e.getElementsByTagName("FieldValue");
                                                // out.println(nl.getLength()+" FieldValues found to analyse ...");
                                                for (int g = 0; g < nl.getLength(); g++) {
                                                    Node node2 = nl.item(g);
                                                    NamedNodeMap nnm2 = node2.getAttributes();
                                                    Node nName2 = nnm2.getNamedItem("fieldID");
                                                    // Node nPosition2 = nnm2.getNamedItem("textStyle");
                                                    // out.println(nName2.getNodeValue());  // die feld id

                                                    WorkItem fild = (WorkItem) intSession.allFieldsById.get(nName2
                                                            .getNodeValue());
                                                    // out.println(".. " + fild.getField("name").getValueAsString() + " /" + nName2.getNodeValue() + "/");
                                                    // out.println(nPosition2.getNodeValue());

                                                    String fName = fild.getField("name").getValueAsString();
                                                    String fData = (String) typeFields.get(fName);
                                                    if ((fData == null) || fData.equals("") || fData.equals("null")) {
                                                        out.println("<i>Note: field '"
                                                                + fName
                                                                + "' is part of the presentation template, but not a visible field</i><br>");
                                                    } else {
                                                        String color = ((g % 2 == 1) ? "background-color:#f6f6f6;"
                                                                : "background-color:#FDFDFD;");
                                                        out.println(fData.replaceAll("#bgcolor#", color));
                                                    }
                                                    sortedTypeFields.remove(fName);
                                                }
                                            }
                                        }

                                    }
                                }

                                out.println("<tr><td>Additional Fields</td></tr>");
                                int count = 0;
                                for (Object key : sortedTypeFields.keySet()) {
                                    count++;
                                    String color = ((count % 2 == 0) ? "background-color:#f6f6f6;"
                                            : "background-color:#FDFDFD;");
                                    String fData = (String) sortedTypeFields.get(key);
                                    out.println(fData.replaceAll("#bgcolor#", color));
                                }
                            }

                            // footer with field counters
                            out.println("<tr><td>&nbsp;<td>");
                            out.println("<td style='text-align:center;'>"
                                    + (visibleFields.size() + systemManagedFields.size()) + "</td>");
                            out.println("<td style='text-align:center;'>" + (copyFields.size()) + "</td>");
                            out.println("<td style='text-align:center;'>" + (significantEditFields.size())
                                    + "</td>");

                            // Allow Traces, Allow Links etc.
                            for (Object key : typeEditProps.keySet()) {
                                String propFields = typeEditProps.get(key)[0];
                                out.println("<td style='text-align:center;'>" + (propFields.split(",").length)
                                        + "</td>");
                                // out.println(typeEditProps.get(key)[1]);
                            }

                            out.println("</tr>");
                            out.println("</table><br>");

                            // Legend
                            legend.put("Visible", "Visible Fields<br>An S indicates a System Managed Field");
                            legend.put("Copy", "Copy Fields");
                            legend.put("Sign&nbsp;Edit", "Significant Edit Fields");
                            legend.put(
                                    "States",
                                    "Checked fields below the states are mandatory.<br>The state order does not necessarily show the order in the workflow.");
                            legend.put("Additional Fields",
                                    "These fields will usually show up at the bottom of the first tab, although system fields may not");

                            // Add legend for the additional conditional Edit fields
                            for (Object key : typeEditProps.keySet()) {
                                legend.put("if " + key.toString(), "Edit is only possible if the logical field '"
                                        + key + "' returns true");
                            }

                            out.println(legend.getLegend());

                            String data = ("<h3>Specific Document Fields:</h3>");
                            data = data + "<table border=1><tr><th>Field</th><th>Display Name</th><th>Computation</th></tr>";
                            for (Object key : typeEditProps.keySet()) {
                                String propFieldName = typeEditProps.get(key)[1];
                                WorkItem field = intSession.allFields.get(propFieldName);
                                String displayName = field.getField("displayName").getValueAsString();
                                // <th>Display Name</th>
                                String Computation = field.getField("Computation").getValueAsString();
                                data = data + ("<tr><td style='text-align:left;'>" + (propFieldName)
                                        + "</td><td>" + displayName + "</td><td>" + Computation.replaceAll("\nOR\n", "<br>OR ").replaceAll("\nor\n", "<br>OR ") + "</td></tr>");
                            }
                            data = data + "</table>";
                            if (data.length() > 120) {
                                out.println(data);
                            }

                            out.println("<br><h3>Referenced Triggers:</h3>");
                            String triggers = "<table border=1>";
                            triggers = triggers
                                    + "<tr><th>Trigger</th><th>Type</th><th>Rule</th><th>Description</th></tr>";
                            for (Object key : intSession.allTriggers.keySet()) {
                                WorkItem wit = intSession.allTriggers.get(key);
                                String tName = wit.getField("name").getValueAsString();
                                String tRule = wit.getField("rule").getValueAsString();
                                String tQuery = wit.getField("query").getValueAsString();
                                String tType = wit.getField("type").getValueAsString();
                                String tDescription = wit.getField("description").getValueAsString();
                                if (tRule != null
                                        && (tRule.indexOf("[\"Type\"] = \"" + wi.getField("name").getValueAsString()
                                                + "\"") > -1
                                        || tRule.indexOf("is " + docClass) > -1)) {
                                    triggers = triggers
                                            + ("<tr><td>" + tName + "</td><td>" + tType + "</td><td>" + tRule
                                            + "</td><td>" + tDescription + "</td></tr>");
                                }

                            }
                            triggers = triggers + ("<table><br>");
                            if (triggers.length() > 100) {
                                out.println(triggers);
                            } else {
                                out.println("No directly related triggers found.<br><br>");
                            }

                            // Properties
                            out.println(Html.h3("Type Properties:"));
                            if (properties.size() > 0) {

                                out.println("<table border=1>");
                                out.println("<tr><th>Property</th><th>Value</th><th>Description</th></tr>");
                                for (Object key : properties.keySet()) {
                                    // out.println(key.toString());
                                    String[] propValue = (String[]) properties.get(key);
                                    String pValue = propValue[0].replaceAll(",", ", ").replaceAll(";", "; ");
                                    String pDescr = propValue[1];
                                    out.println("<tr><td>" + key.toString() + "</td><td>" + pValue + "</td><td>"
                                            + pDescr + "</td></tr>");
                                }
                                out.println("<table><br>");
                            } else {
                                out.println("No type properties defined.<br><br>");
                            }

                            // related triggers
                            // State Transitions
                            out.println("<h3>Workflow State Transitions and permitted Groups:</h3>" + stateTrans
                                    + "<br>");
                        }

                    } catch (APIException e) {

                        // Report the command level Exception
                        out.println("The command failed");
                        out.println(Html.logException(e));
                        typeName = "";
                    }
                }
                out.println(intSession.getAbout(Html.getTitleAndVersion()));
                // Execute disconnect

            }
            try {
                intSession.release();
            } catch (APIException ex) {
                out.println(Html.logException(ex));
            }
        %>

    </body>
</html>