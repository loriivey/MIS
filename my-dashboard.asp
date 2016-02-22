<%@ Language = JScript %>
<!--#include file="misconn.inc" -->
<%
%>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title>My Dashboard</title>

    <!-- Bootstrap core CSS -->
	<!--<link rel='stylesheet' href='header.css' />-->
	
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/custom.css" rel="stylesheet">
<link rel='stylesheet' href='footer.css' />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/1.11.3/jquery.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/jquery-ui.min.js"></script>
<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/jquery-ui.min.css' />
<script src='https://cdnjs.cloudflare.com/ajax/libs/chosen/1.4.2/chosen.jquery.min.js'></script>
<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/chosen/1.4.2/chosen.min.css' />
<script src='bootstrap/jquery.multiselect.min.js'></script>
<link rel='stylesheet' href='bootstrap/jquery.multiselect.css' />
	<script src='https://cdnjs.cloudflare.com/ajax/libs/handlebars.js/4.0.5/handlebars.min.js'></script>
    <script>
	//db_url_base='//localhost:8082/';
	db_url_base='//misdb.esc7.net:8082/';

  $(document).ready(function() {
    // initial stuff to do after the document is complete 

	// Handlebars compiles the template into a callable function
	rendererCurrent = Handlebars.compile($("#currentTemplate").html());
	rendererPast = Handlebars.compile($("#pastTemplate").html());
	rendererSuggest = Handlebars.compile($("#suggestTemplate").html());
	//get current sessions 
	$.getJSON(db_url_base+'MySessDataCurrent', {"id":"<%=Session('SSN')%>"}, function(theData) {
		var theContent = rendererCurrent(theData);
		$("#currentDetail").html(theContent);
	});

	//get past sessions 
	$.getJSON(db_url_base+'MySessDataPast', {"id":"<%=Session('SSN')%>"}, function(theData) {
		var theContent = rendererPast(theData);
		$("#pastDetail").html(theContent);
	});

	//get suggested sessions 
	$.getJSON(db_url_base+'MySessDataSuggest', {"id":"<%=Session('SSN')%>"}, function(theData) {
		var theContent = rendererSuggest(theData);
		$("#suggestDetail").html(theContent);
	});

  }); //end of document ready function
</script> 


  </head>

  <body>
  <script type="text/x-handlebars-template" id="currentTemplate">
		{{#each this}}
			<tr id="row{{sessNum}}">
				<td>{{date}}</td>
				<td>{{title}}</td>
			</tr>
		{{/each}}
	</script>
	<script type="text/x-handlebars-template" id="suggestTemplate">
		{{#each this}}
			<tr id="row{{sessNum}}">
				<td>{{date}}</td>
				<td>{{title}}</td>
			</tr>
		{{/each}}
	</script>
	<script type="text/x-handlebars-template" id="pastTemplate">
		{{#each this}}
			<tr id="row{{sessNum}}">
				<td>{{date}}</td>
				<td>{{title}}</td>
			</tr>
		{{/each}}
	</script>
    <!--#include file="header.html" -->
	<br>
	<br>
	<br>
    <br>
	<br>
	<br>
	<br>
    <div class="container">
    <hr class="divider-color">

    <!-- Main jumbotron for a primary marketing message or call to action -->
    
      <h1 id="greetings">HI ! WELCOME TO YOUR REGION 7 WORKSHOP DASHBOARD.</h1>
    

    
      <!-- My Profile & Notifications -->
      <div class="row">
        <div class="col-md-6">
          <a href="my-account.asp" class="category-header btn">
            <span class="glyphicon glyphicon-user pull-left" aria-hidden="true"></span>
            <span class="pull-left">MY PROFILE</span>
            <span class="pull-right">EDIT</span> 
</a> 

          <hr class="divider">
          <table width="100%">
            <tr>
              <td>
                <strong>Username</strong><br>
                <em><%=Session("userName")%></em>
              </td>
              <td>
                <strong>Last Updated</strong><br>
                <em><%=Session("lastUpdated")%></em>
              </td>
            </tr>
            <tr>
              <td>
                <strong>District / Charter</strong><br>
                <em><%=Session("district")%></em>
              </td>
              <td>
                <strong>Primary Email</strong><br>
                <em><%=Session("email")%></em>
              </td>
            </tr>
            <tr>
              <td>
                <strong>Campus</strong><br>
                <em><%=Session("campus")%></em>
              </td>
              <td>
                <strong>Primary Phone</strong><br>
                <em><%=Session("workPhone")%></em>
              </td>
            </tr>
          </table>
          
        </div>
        <div class="col-md-6">
          <a href="javascript:window.history.back();" class="category-header btn">
            <span class="glyphicon glyphicon-envelope pull-left" aria-hidden="true"></span>
            <span class="pull-left">MY REGION 7<br>NOTIFICATIONS</span>
             <span class="pull-right">Log Out</span>
            
          </a>
          <hr class="divider">
            <p>
            	<strong>Welcome to your Dashboard!</strong>  
                <br>Here you can find everything you need for current, past and future sessions.  Also be sure to check out your Membership Benefits to see sessions available to you at little to no cost.
              </p>
            
          </div>
        </div>
        <br>

      <!-- Events & Updates -->
      
        <div class="row">
          <div class="col-md-12">
            <a href="my-account.asp" class="category-header btn">
              <span class="glyphicon glyphicon-envelope pull-left" aria-hidden="true"></span>
              <span class="pull-left">EVENTS &amp;<br>UPDATES</span>
              <span class="pull-right">SEE ALL  </span>
            </a>
            
          </div>
        </div>
		<br>
       
      <div class="row">
          <div class="col-md-3" style="height: 250px; overflow: hidden;">
            <a href="my-account.asp?tab=1&expand=0" class="category-header btn">
            
              <span>MY CURRENT SESSIONS</span>
             </a>
            
               	<div class="Table">
              		<table class="table">
					<tbody id="currentDetail" />
				</table>
              </div>
           
          </div>

        <div class="col-md-3" style="height: 250px; overflow: hidden;">
             <a href="my-account.asp?tab=1&expand=2" class="category-header btn">
              <span>MY PAST EVENTS</span>
            </a>
                <table class="table">
					<tbody id="pastDetail" />
				</table>
            </div>
         
            <div class="col-md-3" style="height: 250px; overflow: hidden;">
            <a href="my-account.asp?tab=1&expand=1" class="category-header btn">
              <span>SUGGESTED SESSIONS</span>
             </a>
             	
               	<table class="table">
					<tbody id="suggestDetail" />
				</table>
            </div>
            		<div class="col-md-3" style="height: 250px; overflow: hidden;">
            <a href="https://misweb.esc7.net/mis/my-account.asp?tab=4#coop" class="category-header btn">
              <span>My Co-Op Benefits</span>
              </a>
              <p>Click here to see your District's Co-Ops and membership benefits.  View sessions available to you at little to no cost.</p
              ></p>
          </div>
      </div>  			<!-- / end row -->
      		
          </div>        
          
          
       
    
     
<!-- /container -->
<!--#include file="footer.html" -->  
    
</body>

    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <script src="bootstrap/js/bootstrap.min.js"></script>
  
  
</html>
