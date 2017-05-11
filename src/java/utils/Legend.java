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

@SuppressWarnings("serial")
public class Legend extends LinkedHashMap<String, String> {

  public void Add(String s1, String s2) {
	super.put(s1, s2);
  }

  public String getLegend() {

	String data = "<u>Legend:</u><table border=1>";

	for (Object key : this.keySet()) {
	  data = data + "<tr><td>" + key + ":</td><td>" + this.get(key) + "</td></tr>";
	}
	return data + ("<table><br>");

  }
}
