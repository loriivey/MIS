<%@ Language = JScript %>
<!--#include file="misconn.inc" -->
<%
tab=0;
expand=-1;
newUser='N';
if (Request.QueryString("tab").Count==1){
	tab=Request.QueryString("tab")-0;
}
if (Request.QueryString("expand").Count==1){
	expand=Request.QueryString("expand")-0;
}
if (Request.QueryString("newUser").Count==1){
	newUser=Request.QueryString("newUser")+"";
}
function coopList() {
	MisCmd.CommandText = 
		 "SELECT c.Coop_Name "
		+"    FROM MIS.COOP c key join MIS.Coop_Member m "
		+"    where c.coop_active='Y'and m.Dist_code='" + Session("distCode") + "' "
		+"UNION "  
		+"SELECT c.Coop_Name "
		+"    FROM MIS.COOP c key join MIS.Coop_Campus_Member m "
		+"    where c.coop_active='Y'and m.Dist_code='" + Session("distCode") + "' and m.Camp_Code='" + Session("campCode") + "' "
		+"UNION "
		+"SELECT c.Coop_Name "
		+"    FROM MIS.COOP c key join MIS.Coop_Ptcpnt_Member m "
		+"    where c.coop_active='Y' and m.Ptcpnt_SSN='" + Session("SSN") + "' "
		+"order by Coop_Name ";
	MisRecSet.Open();
	var result = "<ul>";
	while (!MisRecSet.EOF)
	{	result += '<li>'
		  + MisRecSet("Coop_Name")
		  + '</li>';
		MisRecSet.MoveNext();
	}
	MisRecSet.Close();
	result += "</ul>";
	return result;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>My Account</title>
<link href='https://fonts.googleapis.com/css?family=Raleway' rel='stylesheet' type='text/css'>
<link href='https://fonts.googleapis.com/css?family=Merriweather' rel='stylesheet' type='text/css'>
<link rel='stylesheet' href='font-awesome.css' />
<link href="css/bootstrap.min.css" rel="stylesheet">
<link href="css/custom.css" rel="stylesheet">
<link rel='stylesheet' href='footer.css' />
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/1.11.3/jquery.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/jquery-ui.min.js"></script>
<link href='css/LoriMyAccount.css' rel='stylesheet' type="text/css" />

<script src='https://cdnjs.cloudflare.com/ajax/libs/chosen/1.4.2/chosen.jquery.min.js'></script>
<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/chosen/1.4.2/chosen.min.css' />
<script src='jquery.multiselect.min.js'></script>
<link rel='stylesheet' href='jquery.multiselect.css' />
<script src='https://cdnjs.cloudflare.com/ajax/libs/handlebars.js/4.0.5/handlebars.min.js'></script>

<script>
  //db_url_base='//localhost:8082/';
  db_url_base='//misdb.esc7.net:8082/';
	tab=<%=tab%>;
	expand=<%=expand%>;

  function afterSessionLoad() {
	$('#iframe').contents().find('a').css( "color", "blue" );
	$('#iframe').contents().find('a:contains(" as Somebody Else")').remove(); //Don't need thess anymore so remove these links
  }

 	//handler for links to view session details
	function viewSession(url) {
		iframe.attr('src',url);
		$sessionDialog.dialog("open");
	};

  $(document).ready(function() {
    // initial stuff to do after the document is complete 
	$("#tabsCtrl").tabs({
		hide : true,
		show : true
	});
	$( "#accordion" ).accordion({
		autoHeight: false,
		heightStyle: "content",
		clearStyle: true,
		collapsible: true,
		active: false
	});

	// Handlebars compiles the template into a callable function
	rendererCurrent = Handlebars.compile($("#currentTemplate").html());
	rendererPast = Handlebars.compile($("#pastTemplate").html());
	rendererSuggest = Handlebars.compile($("#suggestTemplate").html());
	Handlebars.registerHelper('evalCertLinks', function(EvalOK, CertOK, sessNum){
    var returnValue="&nbsp;";
    if (EvalOK == "Y") 
       returnValue = '<a target="_blank" href="Eval0.asp?sessNum='
       +sessNum + '">Evaluation</a>';
    if (CertOK=='Y') {
        if (returnValue!="&nbsp;") returnValue += "<br />";
        returnValue += '<a href="javascript:cert(\''
            + sessNum 
            + "','" + <%=Session("SSN")%>
            + '\')">Certificate</a>';
    }
    return new Handlebars.SafeString(returnValue);
	});
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

	//get coop sessions 
	$.getJSON(db_url_base+'MySessDataCoop', {"id":"<%=Session('SSN')%>"}, function(theData) {
		var theContent = rendererSuggest(theData);
		$("#coopDetail").html(theContent);
	});

	if (tab>=0) {$("#tabsCtrl").tabs("option","active",tab);}
	if (expand>=0) {$( "#accordion" ).accordion("option","active",expand);}

  //Create modal dialogs
	var wWidth = $(window).width();
	var dWidth = wWidth * 0.7;
	iframe = $('<iframe name="iframe" id="iframe" frameborder="0" marginwidth="0" marginheight="0" style="width:100%;height:750px"></iframe>');
	iframe.bind('load',afterSessionLoad);
	$sessionDialog = $('<div id="sessionDialog" />')
		.append(iframe)
        .appendTo('body')
        .dialog({
            resizable: true,
            autoOpen: false,
            height: "auto",
            width: dWidth,
            show: 'scale',
            hide: 'scale',
            modal: true,
						title: "Session Details",
						close: function () {
							iframe.attr("src", "")
						}
      });

  }); //end of document ready function

	function doDrop(dropSess,dropResult){
		if (dropResult=='N/A') {
			alert('Unable to drop at this time');
			return;
		}
		var forSure = confirm("Result will be: " + dropResult 
				+ ".  Are you certain you want to drop from session #"
				+dropSess +"?");
		if (forSure == true) {
		$.post("Dropout1.asp?Sess_Num="+dropSess)
				.done(function(data) {
					if (console) console.log(data);
					var $response = $(data);
					var message = String($("font b",$response).text()); //first adjacent sibling selector
					if (message.search('Participant has been ')>-1) {
						$('#row'+dropSess).remove();} //drop worked so remove the table row for the dropped session
					else alert(message);
				})
				.fail(function(xhr,textStatus,errorThrown) {
					alert('Error on droput processing: ' + textStatus + ' '  + xhr.status+': '+ errorThrown);
			});
		}
		else
			{alert("You remain registered for session number "+dropSess+".")}
	}

	function cert(sessNum,SSN) {
		document.certForm.sessNum.value=sessNum;
		document.certForm.submit();
	}

</script> 

<style>
#accordion table, #coop table {
    border-collapse: collapse;
}

#accordion table a, #coop table a{
    color: blue;
}

#accordion table, #accordion th, #accordion td, 
#coop table, #coop th, #coop td{
    border: 1px solid gray;
    padding: 5px;
}

	.ui-dialog-titlebar > .ui-button {
		outline: none; /* fixes bug that outlines dialog close buttons in jQuery UI */
	}

.ui-widget-overlay{
z-index:1031;
}

.ui-dialog{
z-index:1032;
}

</style>

</head>
<body>
	<script type="text/x-handlebars-template" id="currentTemplate">
		{{#each this}}
			<tr id="row{{sessNum}}">
				<td>{{date}}</td>
				<td>{{title}}</td>
				<td>{{type}}</td>
				<td>{{loc}}</td>
				<td>{{sessNum}}</td>
				<td><a href="javascript:doDrop('{{sessNum}}','{{dropResult}}');" title="{{dropResult}}">Cancel My Session</a></td>
				<td><a href="javascript:viewSession('sess1.asp?type=DATE&sessNum={{sessNum}}')">View Details</a></td>
			</tr>
		{{/each}}
	</script>
	<script type="text/x-handlebars-template" id="suggestTemplate">
		{{#each this}}
			<tr id="row{{sessNum}}">
				<td>{{date}}</td>
				<td>{{title}}</td>
				<td>{{type}}</td>
				<td>{{loc}}</td>
				<td>${{cost}}</td>
				<td>{{availSeats}}</td>
				<td><a href="javascript:viewSession('sess1.asp?type=DATE&sessNum={{sessNum}}')">View Details</a></td>
			</tr>
		{{/each}}
	</script>
	<script type="text/x-handlebars-template" id="pastTemplate">
		{{#each this}}
			<tr id="row{{sessNum}}">
				<td>{{date}}</td>
				<td>{{title}}</td>
				<td>{{sessNum}}</td>
				<td>{{evalCertLinks EvalOK CertOK sessNum}}</td>
				<td>{{credit}}</td>
				<td>{{subjects}}</td>
				<td><a href="javascript:viewSession('sess1.asp?type=DATE&sessNum={{sessNum}}')">View Details</a></td>
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
	<br>
	<h1 id="greetings"><%=Session("firstName")%>'s REGION 7 PROFILE</h1>
    <br>
    <hr class="divider-color">
<div id="tabsCtrl">
	<ul>
		<li><a href="profileForm.asp?newUser=<%=newUser%>">Profile</a></li>
		<li><a href="#mySessions">My Region 7 Sessions</a></li>
		<li><a href="#coop">Membership Benefits</a></li>
	</ul>

<div id="mySessions">
	<h1>My Regon 7 Sessions</h1>
	<p>All of the sessions you are currently registered for and past sessions you were registered to attend will be available for your review at all 
		times in this section of your profile. Sessions you may be interested in registering for will also always be available here. Click a section title to expand or collapse it. </p>
	<div id="accordion">
		<h3>MY CURRENT SESSIONS</h3>
		<div>
			<p>Region 7 sessions you are currently registered for are listed below. Click "View Details" for additional information.</p>
			<table>
			  <thead>
					<tr>
						<th>DATE</th>
						<th>SESSION TITLE</th>
						<th>TYPE</th>
						<th>LOCATION</th>
						<th>SESSION #</th>
						<th>CANCEL</th>
						<th>VIEW</th>
					</tr>
			  </thead>
				<tbody id="currentDetail">
				</tbody>
			</table>
</div>

		<h3>MY SUGGESTED SESSIONS</h3>
		<div>
			<p>The Region 7 sessions listed below are those you may be interested in based on information obtained in your Region 7 workshop profile and registration account. Click "View			Details" for more information or to register.</p>
			<table>
			  <thead>
				<tr>
					<th>DATE</th>
					<th>SESSION TITLE</th>
					<th>TYPE</th>
					<th>LOCATION</th>
					<th>MY COST</th>
					<th>AVAILABLE SEATS</th>
					<th>VIEW</th>
				</tr>
			  </thead>
				<tbody id="suggestDetail">
				</tbody>
			</table>
		</div>

		<h3>MY PAST SESSIONS</h3>
		<div>
			<p>The Region 7 sessions listed below are past sessions you were registered to attend. Click the "Evaluation" link to complete your evaluation of the session, which may be required to receive your certificate of completion. Click the "Certificate" link to view or print your certificate of completion.</p>
			<table>
				<tr>
			  <thead>
					<th>DATE</th>
					<th>SESSION TITLE</th>
					<th>SESSION #</th>
					<th>EVALUATION / CERTIFICATE</th>
					<th>CREDITS</th>
					<th>SUBJECTS</th>
					<th>VIEW</th>
				</tr>
			  </thead>
				<tbody id="pastDetail">
				</tbody>
			</table>
		</div>
	</div>
</div>

<div id="coop">
	<h1>MY Membership Benefits</h1>
	<div>
		<p>The cooperatives and contracted services your district/charter/campus is a member of are listed below. 
			As an employee of a contracted member district/charter, select sessions and events are available to you at no cost and/or at a discounted rate. 
			All of the sessions and events available to you within any of your particular cooperatives are listed in the following table. 
			The cost your campus/district/charter pays for attending each session or event is be displayed in the "My Cost" column.
		</p>
		<%=coopList()%>
		<table>
		  <thead>
			<tr>
				<th>DATE</th>
				<th>SESSION TITLE</th>
				<th>TYPE</th>
				<th>LOCATION</th>
				<th>MY COST</th>
				<th>AVAILABLE SEATS</th>
				<th>REGISTRATION</th>
			</tr>
		  </thead>
		  <tbody id="coopDetail">
		  </tbody>
		</table>
	</div>
</div>
</div>
</div>

<form name="certForm" method="post" action="Cert.asp">
<input type="hidden" name="sessNum">    
<input type="hidden" name="SSN" value="<%=Session('SSN')%>">    
</form>

<!--#include file="footer.html" -->
</body>
</html>
