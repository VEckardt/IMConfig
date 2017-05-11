<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" type="text/css" href="images/acls.css"
	media="screen">
<link rel="stylesheet" type="text/css" href="images/aclsprint.css"
	media="print">
<title>Insert title here</title>
<script type='text/javascript' src='https://www.google.com/jsapi'></script>
<script type='text/javascript'>
	google.load('visualization', '1', {
		packages : [ 'table' ]
	});
	google.setOnLoadCallback(drawTable);
	function drawTable() {
		var data = new google.visualization.DataTable();
		data.addColumn('string', 'Name');
		data.addColumn('number', 'Salary');
		data.addColumn('boolean', 'Full Time Employee');
		data.addRows([ [ 'Mike', {
			v : 10000,
			f : '$10,000'
		}, true ], [ 'Jim', {
			v : 8000,
			f : '$8,000'
		}, false ], [ 'Alice', {
			v : 12500,
			f : '$12,500'
		}, true ], [ 'Bob', {
			v : 7000,
			f : '$7,000'
		}, true ] ]);

		var table = new google.visualization.Table(document
				.getElementById('table_div'));
		table.draw(data, {
			showRowNumber : true
		});
	}
</script>

<script type="text/javascript">
	// Load the Visualization API and the piechart package.
	google.load('visualization', '1.0', {
		'packages' : [ 'corechart' ]
	});

	// Set a callback to run when the Google Visualization API is loaded.
	google.setOnLoadCallback(drawChart);

	// Callback that creates and populates a data table,
	// instantiates the pie chart, passes in the data and
<%// draws it.
			out.println("function drawChart() {");
			// Create the data table.
			out.println("		var data = new google.visualization.DataTable();");
			out.println("		data.addColumn('string', 'Topping');");
			out.println("	data.addColumn('number', 'Slices');");
			out.println("		data.addRows([ [ 'Mushrooms', 3 ], [ 'Onions', 1 ], [ 'Olives', 1 ],[ 'Zucchini', 1 ], [ 'Pepperoni', 2 ] ]);");

			// Set chart options
			out.println("		var options = {'title' : 'Test Case Overview','width' : 800,'height' : 500};");

			// Instantiate and draw our chart, passing in some options.
			out.println("		var chart = new google.visualization.PieChart(document.getElementById('chart_div'));");
			out.println("		chart.draw(data, options);");
			out.println("}");%>
	
</script>

</head>
<body>

	<%@ page import="java.sql.*" isThreadSafe="false"%>
	<%@ page import="java.util.*" isThreadSafe="false"%>
	<%@ page import="com.mks.api.*" isThreadSafe="false"%>
	<%@ page import="com.mks.api.response.*" isThreadSafe="false"%>
	<%@ page import="com.mks.api.util.ResponseUtil" isThreadSafe="false"%>
	<%@ page import="utils.*" isThreadSafe="false"%>
	<%@ page import="api.*" isThreadSafe="false"%>

	<%
	  out.println(Html.getTitle("Test State"));
	  String title = "Test State - V0.5";

	  String project = request.getParameter("project");
	  if (project == null)
			project = "/Projects/Release2";
	  String objective = request.getParameter("objective");
	  if (objective == null)
			objective = "All";

	  IntegritySession intSession = new IntegritySession();
	  intSession.getIMProjects();
	  // for (Object key : intSession.getIMProjects().keySet()) {  
	  // 
	  // }

	  // out.println(Html.itemSelectField("project", intSession.allIMProjects, true, project, null));

	  intSession.getTestObjectives(project);

	  out.println("<table border=1><form name=form1><tr>");
	  out.println("<tr>"
				+ Html.getOptionBox("project", intSession.allIMProjects, true, project, null) + "</tr>");
	  out.println("<tr>"
				+ Html.getOptionBox("objective", intSession.allTestObjectives, true, objective, null)
				+ "</tr>");
	  out.println("<tr><td></td>" + Html.td("<input type=\"submit\" value=\"Refresh\">") + "</tr>");
	  out.println("</form>");
	%>


	<div id='table_div'></div>
	<div id="chart_div"></div>
</body>
</html>