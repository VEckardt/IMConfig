/*
 * Copyright:      Copyright 2017 (c) Parametric Technology GmbH
 * Product:        PTC Integrity Lifecycle Manager
 * Author:         Volker Eckardt, Principal Consultant ALM
 * Purpose:        Custom Developed Code
 * **************  File Version Details  **************
 * Revision:       $Revision: 1.1 $
 * Last changed:   $Date: 2017/05/02 12:18:39CEST $
 */
package api;

import com.mks.api.response.APIException;
import java.io.IOException;
import static java.lang.System.out;

/**
 *
 * @author veckardt
 */
public class GroupDefTest {

    public static void main(String[] args) throws APIException, IOException {

        IntegritySession intSession = new IntegritySession();

        String userName = "veckardt";
        String[] elementClasses = new String[]{"Type", "Field"};

        // runs viewtype and collects the field overwrites via viewfield
        Type defect = intSession.readType("Defect");
        // Type defect = intSession.getType("Defect");
        
        // intSession.readTypeField("Defect", "Domain (Item)", intSession.allFields);
        out.println(defect.getUsedString("Hardware Entwickler"));
        
        // exit(0);
        
        intSession.readStaticGroups("", "Yes");
        String staticGroups = intSession.getStaticGroupsForUser(userName);
        out.println("Groups where the user " + userName + " is directly assigned: " + staticGroups);

        intSession.readDynamicGroups("", "No");

        out.println("Part 1 ***************** static ************  ");

        // String[] elementClasses = new String[]{"Type", "Field"};
        for (String name : intSession.allStaticGroups.keySet()) {
            StaticGroup baseGroup = intSession.allStaticGroups.get(name);
            // out.println("Checking " + baseGroup.getName() + " ...");
            // for (String group : groups.split("."))
            if (baseGroup.isMemberOfGroup(userName, staticGroups)) {
                staticGroups = staticGroups + "," + baseGroup.getName();
                out.println("SG '" + name + "': " + baseGroup.getMembership() + baseGroup.getReferences("Type", elementClasses) + baseGroup.getReferences("Field", elementClasses));
            }
        }

        out.println("Part 2 ***************** dynamic ************  ");
        out.println("Groups where the user " + userName + " is (in-)directly assigned: " + staticGroups);

        for (String name : intSession.allDynamicGroups.keySet()) {
            DynamicGroup group = intSession.allDynamicGroups.get(name);
            // out.println("MAIN: Checking group '" + group.getName() + "' ...");
            if (group.isMemberOfGroup(userName, staticGroups)) {
                out.println("DG '" + name + "': " + group.getMembership(userName, staticGroups) + group.getReferences("Type", elementClasses) + group.getReferences("Field", elementClasses));
            }
        }
    }
}
