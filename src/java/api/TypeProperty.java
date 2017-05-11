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

public class TypeProperty {

  public String propKey;
  public String propField;
  public String propFields;

  public TypeProperty (
		  String propKey,
		  String propField,
		  String propFields) {
	  this.propKey = propKey;
	  this.propField = propField;
	  this.propFields = propFields;	
  }
  
}
