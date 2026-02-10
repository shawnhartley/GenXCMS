 <!---
      COMPONENT: dsp_head.cfm
      AUTHOR: Pat Whitlock
      DATE: 10/23/08
      PURPOSE:
      CHANGE HISTORY:
            * 10/23/2008: page completed
			* 11/09/2008: added page region code
--->

<!--- No cache --->
<cfheader name="Expires" value="Mon, 26 Jul 1997 05:00:00 GMT">
<cfheader name="Last-Modified" value="#DateFormat(Now()-1, 'ddd, dd mmm yyyy')# #TimeFormat(Now()-1,'HH:mm:ss')# GMT">
<cfheader name="Cache-Control" value="no-store, no-cache, must-revalidate">
<cfheader name="Cache-Control" value="post-check=0, pre-check=0">
<cfheader name="Pragma" value="no-cache">

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>

<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
<cfoutput>
<title>Management Center | #settings.var('siteTitle')#</title>
</cfoutput>
<!-- Meta data start -->
<meta name="author" content="Corporate 3 Design" />
<meta name="description" content="Management Center" />
<meta name="keywords" content="manage" />
<!-- Meta data end -->
<cfoutput>
<!-- Load CSS -->
<link href="#application.slashroot#managementcenter/css/mainstyle.css" rel="stylesheet" type="text/css" />


<!-- Load Javascript -->

<script type="text/javascript" src="#application.slashroot#managementcenter/js/jquery.tools.min.js"></script>
<script type="text/javascript" src="#application.slashroot#managementcenter/js/date.js"></script>
<script type="text/javascript" src="#application.slashroot#managementcenter/js/jquery.datepicker.js"></script>
<script type="text/javascript" src="#application.slashroot#managementcenter/js/jquery.idleTimeout.js"></script>
<script type="text/javascript" src="#application.slashroot#js/jquery.placeholder.js"></script>
<script type="text/javascript" src="#application.slashroot#js/modernizr-2.0.min.js"></script>
<script type="text/javascript" src="#application.slashroot#managementcenter/ckeditor/ckeditor.js"></script>
<script type="text/javascript" src="#application.slashroot#managementcenter/ckeditor/adapters/jquery.js"></script>
<script type="text/javascript" src="#application.slashroot#managementcenter/js/mc.js"></script>
</cfoutput>


</head>

<body>

