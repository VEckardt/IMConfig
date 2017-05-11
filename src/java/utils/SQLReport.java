/*
 * Copyright:      Copyright 2017 (c) Parametric Technology GmbH
 * Product:        PTC Integrity Lifecycle Manager
 * Author:         Volker Eckardt, Principal Consultant ALM
 * Purpose:        Custom Developed Code
 * **************  File Version Details  **************
 * Revision:       $Revision$
 * Last changed:   $Date$
 */
package utils;

import api.IntegritySession;
import com.mks.api.Command;
import com.mks.api.Option;
import com.mks.api.response.APIException;
import com.mks.api.response.Response;

/**
 *
 * @author veckardt
 */
public class SQLReport {

    public static String generateReport(IntegritySession session, String title, String sqlCmd, String imageName, Boolean showDescription) {
        // set the command to execute
        String output = title.isEmpty() ? "" : "<h4>" + title + "</h4>";

        Command cmd = new Command(Command.IM, "diag");
        cmd.addOption(new Option("diag", "runsql"));
        cmd.addOption(new Option("param", sqlCmd));

        // Date currentDate = new Date();
        try {
            // execute the command
            Response respo = session.execute(cmd);
            // ResponseUtil.printResponse(respo,1,System.out);

            if (respo.getExitCode() == 0) {

                String message = respo.getResult().getMessage();
                String[] rows = message.split("\n");
                int count = 0;
                output += ("<table border=1>");
                // analyse the output
                for (int i = 0; i < rows.length; i++) {
                    // out.println(rows[i]);
                    if (i < 2) {
                        String[] rowTitle = rows[i].split("\\t");
                        if (rowTitle.length > 2) {
                            output += ("<tr><th></th>");
                            for (String rowTitle1 : rowTitle) {
                                output += ("<th>" + rowTitle1.replaceAll("\\s+$", "").replaceAll("(\\p{Ll})(\\p{Lu})", "$1 $2") + "</th>");
                            }
                            if (showDescription) {
                                output += ("<th style=\"width: 50%;\">Description</th>");
                            }
                            output += ("</tr>");
                        }
                    } else {
                        String[] values = rows[i].split("\\t");
                        if (!(values[0].indexOf("-----") > -1)) {
                            count++;
                            output += ("<tr>");
                            for (int j = 0; j < values.length; j++) {
                                String value = values[j].replaceAll("\\s+$", "");
                                if (j == 0) {
                                    output += ("<td><img src='images/" + imageName + ".png' alt='" + "'></td><td>" + value.trim() + "</td>");
                                } else {
                                    output += ("<td>" + value.trim() + "</td>");
                                }
                            }
                            if (showDescription) {
                                output += ("<td>" + session.getTypeDescription(values[1].trim()) + "</td>");
                            }
                            output += ("</tr>");
                        }
                    }
                }

                // add table footer
                output += ("<tr><td colspan=2>&nbsp;&nbsp;" + count + " row" + (count == 1 ? "" : "s") + "</td></tr>");
                // close the table
                output += ("</table>");
            }

        } catch (APIException e) {

            // Report the command level Exception
            output += ("The command " + cmd.getCommandName() + " failed");
            output += (Html.logException(e));
        }
        return output;
    }
}
