<%@ Language = JScript %>
<!--#include file="misconn.inc" -->
<%
//Server side functions used to build html from db 
function subjectOptions() {
	var result;
	MisCmd.CommandText = "Select List(Subject,'</option><option>' order by subject) as subjectList "
		+ "from MIS.Subject where Subject_Active='Y' ";
	MisRecSet.Open();
	result = (MisRecSet("subjectList")+"");
	MisRecSet.Close();
	return result;
}

function audienceOptions() {
	var result;
	MisCmd.CommandText = "Select List(Audience_Keyword,'</option><option>' order by Audience_Keyword) as audienceList "
		+ "from MIS.audience where audience_Active='Y' ";
	MisRecSet.Open();
	result = (MisRecSet("audienceList")+"");
	MisRecSet.Close();
	return result;
}

function districtOptions() {
	var result;
	MisCmd.CommandText = "Select List(String('<option value=\"', Dist_Code, '\">', Dist_Name, '</option>'), ' ' " 
		+ "order by Dist_Name) as distList "
		+ "from MIS.district where District_Active='Y' ";
	MisRecSet.Open();
	result = (MisRecSet("distList")+"");
	MisRecSet.Close();
	return result;
}

function assignmentOptions() {
	var result;
	MisCmd.CommandText = "Select List(String('<option value=\"', Asgn_Num, '\">', Asgn_Name, '</option>'), ' ' " 
		+ "order by Asgn_Name) as asgnList "
		+ "from MIS.Assignment where Asgn_Active='Y' ";
	MisRecSet.Open();
	result = (MisRecSet("asgnList")+"");
	MisRecSet.Close();
	return result;
}

function ttessOptions() {
	var result = "";
	var currDomain = "";
	MisCmd.CommandText = "Select * from MIS.TTESS order by Domain_Num, Dimension_Num "; 
	MisRecSet.Open();
	
	while (!MisRecSet.EOF){
	  if (MisRecSet("domain") != currDomain){
		if (currDomain != "") {
		   result+="</optgroup>\n";
		} //end if
		result+='<optgroup label="' + MisRecSet("Domain_Num") + ' ' + MisRecSet("Domain") + '">\n';
		currDomain = MisRecSet("domain").value;
	  } //end if   
	  result+='<option value="' + MisRecSet("Dimension_Num") + '" title="' 
		+ MisRecSet("Dimension_Description") + '"/>\n   '
		+ MisRecSet("Dimension_Num") + ' ' + MisRecSet("Dimension") + "\n"
		+ '</option>\n'; 
	  MisRecSet.MoveNext();
	} //end while

	result += "</optgroup>\n";
	MisRecSet.Close();
	return result;
}

function tpessOptions() {
	var result = "";
	var currstandard = "";
	MisCmd.CommandText = "Select * from MIS.tpess order by standard_Num, indicator_Num "; 
	MisRecSet.Open();
	
	while (!MisRecSet.EOF){
	  if (MisRecSet("standard") != currstandard){
		if (currstandard != "") {
		   result+="</optgroup>\n";
		} //end if
		result+='<optgroup label="' + MisRecSet("standard_Num") + ' ' + MisRecSet("standard") + '">\n';
		currstandard = MisRecSet("standard").value;
	  } //end if   
	  result+='<option value="' + MisRecSet("indicator_Num") + '" title="' 
		+ MisRecSet("performance_Description") + '"/>\n   '
		+ MisRecSet("indicator_Num") + ' ' + MisRecSet("indicator") + "\n"
		+ '</option>\n'; 
	  MisRecSet.MoveNext();
	} //end while

	result += "</optgroup>\n";
	MisRecSet.Close();
	return result;
}

%>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8" />
	<title>Mis Home</title> 
	<link href='https://fonts.googleapis.com/css?family=Raleway' rel='stylesheet' type='text/css'>
	<link href='https://fonts.googleapis.com/css?family=Merriweather' rel='stylesheet' type='text/css'>
	<link rel='stylesheet' href='font-awesome.css' />
	<!--<link rel='stylesheet' href='header.css' />-->
	<link rel='stylesheet' href='footer.css' />
	<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/jquery-ui.min.css' />
	<link rel='stylesheet' href='https://ajax.googleapis.com/ajax/libs/jqueryui/1.11.4/themes/flick/jquery-ui.css' />
	<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/fullcalendar/2.5.0/fullcalendar.min.css' />
	<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/chosen/1.4.2/chosen.min.css' />
	<link rel='stylesheet' href='jquery.multiselect.css' />
	<link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/custom.css" rel="stylesheet">
	<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/1.11.3/jquery.js"></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/jquery-ui.min.js"></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.10.6/moment.min.js" type="text/javascript"></script>
	<script src='https://cdnjs.cloudflare.com/ajax/libs/fullcalendar/2.5.0/fullcalendar.min.js'></script>
	<script src='https://cdnjs.cloudflare.com/ajax/libs/handlebars.js/4.0.5/handlebars.min.js'></script>
	<script src='https://cdnjs.cloudflare.com/ajax/libs/chosen/1.4.2/chosen.jquery.min.js'></script>
	<script src='https://cdnjs.cloudflare.com/ajax/libs/jquery-validate/1.14.0/jquery.validate.min.js'></script>
	<script src='https://cdnjs.cloudflare.com/ajax/libs/jquery-validate/1.14.0/additional-methods.min.js'></script>
	<script src='jquery.multiselect.min.js'></script>
<script>
	inListView = false;
	L='<%=Session("loggedIn")%>';
	afterLogin = function() {};
	function gradeBitMask() {
	  var gradeArray = $("#grade").multiselect("getChecked").map(function(){
		return eval(this.value)});
	  var gradeSum = 0;
	  for (var i = 0;i < gradeArray.length;i++) gradeSum += gradeArray[i];
	  return gradeSum;
	}; // end gradeBitMask

	function ttessList() {
	  var ttessPseudoArray = $("#ttess").multiselect("getChecked").map(function(){
		return this.value});
	  var ttessArray = $.makeArray(ttessPseudoArray);
	  if (ttessArray.length > 0)
		return ttessArray.join()
	  else return "any";
	}; // end ttessList

	function tpessList() {
	  var tpessPseudoArray = $("#tpess").multiselect("getChecked").map(function(){
		return this.value});
	  var tpessArray = $.makeArray(tpessPseudoArray);
	  if (tpessArray.length > 0)
		return tpessArray.join()
	  else return "any";
	}; // end tpessList

	function padNum(argvalue) {
	  argvalue = argvalue.toString();
	  if (argvalue.length == 6){
		 return argvalue;
		 }
	  else {
		 padLength = 6 - argvalue.length;
		 temp = "";
		 for (var n = 0; n < padLength; n++) {
			 temp = temp + "0";
			 }
		 temp = temp + argvalue;
		 return temp.toString();
	  }
	}

  function afterSessionLoad() {
	$('#iframe').contents().find('a').css( "color", "blue" );
	$('#iframe').contents().find('a:contains(" as Somebody Else")').remove(); //Don't need thess anymore so remove these links
	$('#iframe').contents().find('a:contains("Register for this Session"),a:contains("Join the Wait List for this Session")')
		//.attr('target','_blank')
		.click(function(event) {
			if (parent.L != 'Y') {
				event.preventDefault();
				afterLogin = function() {
					//Get sessNum, build url to sess1.asp, reload #sessionDialog html
					var sessNumParm=String($('#sessionDialog').html()).match(/sessNum=\d{6}/);
					var url='sess1.asp?type=DATE&'+sessNumParm;
					iframe.attr('src',url);
				};
				$loginDialog.dialog("open");
			}
		});
  }


  $(document).ready(function() {
    // initial stuff to do after the document is complete 
	$('#listView').hide();
	var template = $("#itemTemplate").html();
	// Handlebars compiles the template into a callable function
	renderer = Handlebars.compile(template);

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

	$loginDialog = $('#loginDialogForm')
        .dialog({
            resizable: false,
            autoOpen: false,
            height: "auto",
            width: "350",
            show: 'scale',
            hide: 'scale',
            modal: true,
			title: "Sign In",
			buttons: [
				{
					text: "Cancel",
					click: function () {
						$(this).dialog("close");
					}
				},
				{
					text: "Continue",
					click: function () {
						//now use ajax or $.post() to try authenticate and deal with result
						$.post('doLogin.asp', //https://api.jquery.com/jQuery.post/
							$('#loginForm').serialize(),
							function(data) {
								loginData = data; //save in a page global object for later
								$('#loginResult').html(loginData.loginResult);
								if (loginData.PassWordOK=='Y') {
									L="Y";
									$loginDialog.dialog("close");
									//Fill in values for matching profile verification dialog input type=text elements
									for (var fieldName in loginData) {
										$('#'+fieldName).val(loginData[fieldName]);
									}
									//Refresh chosen widgets to show the selected option
									$("#Dist_Code").trigger("chosen:updated");
									$("#Asgn_Num").trigger("chosen:updated");
									$profileDialog.dialog("open");
								};
							});
					}
				}
			]
        });

	$profileDialog = $('#verifyProfileForm')
        .dialog({
            resizable: false,
            autoOpen: false,
            height: "650",
            width: "500",
            show: 'scale',
            hide: 'scale',
            modal: true,
			title: "Profile Verification",
			buttons: [
				{
					text: "Cancel",
					click: function () {
						$(this).dialog("close");
					}
				},
				{
					text: "Confirm",
					click: function () {
					  //Do validation of the form data and complain if it is wrong
					  if ($('#verifyForm').valid())
					  {	//if validation succeeded post to try update data and deal with result
						if ($("#verifyForm").data("changed")) { //Detect if nothing changed and skip the post else close the dialog
							//Compress everything but digits out of the validated phone numbers
							$('#Home_Phone').val(String(($('#Home_Phone').val())).replace(/[^0-9]/g, ''));
							$('#Work_Phone').val(String(($('#Work_Phone').val())).replace(/[^0-9]/g, ''));
							$.post('doProfileVerify.asp',
								$('#verifyForm').serialize())
								.done(function(data) {
									$profileDialog.dialog("close");
									afterLogin(); 
								})
								.fail(function(xhr,textStatus,errorThrown) {
									//NOTE: Service must return HTTP Error Status if problem else this method would be a silent failure!
									$('#profileResult').text(textStatus + ' '  + xhr.status+': '+ errorThrown);
								});
						}
						else {
							$(this).dialog("close");
							afterLogin(); 
						}
					  }
					}
				}
			]
        });

	//handler for click event on myAccount button and menu item
	$('a[href="my-dashboard.asp"]').on('click', function(event) {
		if (L=='Y') {}
		else {
			event.preventDefault();
			afterLogin = function() {window.location.href = "my-dashboard.asp"};
			$loginDialog.dialog("open");
		}
	});

	//remember if profile verification form has been changed
	$("#verifyForm input, #verifyForm select").change(function() {
		$("#verifyForm").data("changed",true);
	});

	//handler for click event on listview table rows
	$('#listView tbody, #onlineList tbody').on('click', 'tr', function() {
		iframe.attr('src',$(this).data('urlSess'));
		$sessionDialog.dialog("open");
	});

	//Turn select list filters into combo boxes with chosen jquery plugin
	$("#sessType").chosen();
	$("#subject").chosen();
	$("#audience").chosen();
	$("#Dist_Code").chosen({ width:"99%" });
	$("#Asgn_Num").chosen({ width:"99%" });

	//Turn multiselect list filters into checklist boxes with jquery.multiselect plugin from Eric Hynd
	$("#grade").multiselect({
		selectedList: 18,
		height: "auto",
		noneSelectedText: "any"
	});
	$("#grade").multiselect("uncheckAll");

	$("#ttess").multiselect({
		selectedList: 1,
		height: 300,
		noneSelectedText: "any"
	});
	$("#ttess").multiselect("uncheckAll");

	$("#tpess").multiselect({
		selectedList: 1,
		height: 300,
		noneSelectedText: "any"
	});
	$("#tpess").multiselect("uncheckAll");

	//Make multiselect widgetsmaller & stop turning blue on mouseover
	$('.ui-multiselect').css('width','250px');
	$('.ui-multiselect').off('mouseenter');

	//Make buttons themeable
	//$('#applyFilters,#clearFilters').button();

	//Put hover effect on filter buttons
	$('.applyFiltersDiv button').hover(function(){
		$(this).toggleClass('fc-state-hover');
	});

	//handler for click on apply filters button
	$('#applyFilters').on('click', function() {
		$('#calendar').fullCalendar('refetchEvents');
		var sessVal = $('#sessNum').val();
		sessVal = sessVal.toString();
		if (sessVal.length > 0 ) {
			var sessNum = padNum(sessVal);
			$('#sessNum').val("");
			iframe.attr('src','sess1.asp?type=DATE&sessNum='+sessNum);
			$sessionDialog.dialog("open");
		}
	});

	//handler for click on clear filters button
	$('#clearFilters').on('click', function() {
		$('#date option').removeAttr("selected");
		$('#sessType option').removeAttr("selected");
		$('#subject option').removeAttr("selected");
		$("#subject").trigger("chosen:updated");
		$('#audience option').removeAttr("selected");
		$("#audience").trigger("chosen:updated");
		$('#ttess').multiselect('uncheckAll');
		$('#tpess').multiselect('uncheckAll');
		$('#grade').multiselect('uncheckAll');
		$('#sessNum').val("");
		$('#calendar').fullCalendar('refetchEvents');
	});

	//capture enter key in session number field
	$('#sessNum').keydown(function(event) {
	if (event.which == 13) $('#applyFilters').click();
	});

	//Form Validation Setup 
	$.validator.addMethod("notEqualTo", function (value, element, param)
	{
		var target = $(param);
		if (value) return value != target.val();
		else return this.optional(element);
	}, "Emails must be different");

	$('#verifyForm').validate({
	  rules: {
		Home_Phone: {
		  required: true,
		  phoneUS: true
		},
		Home_Phone: {
		  required: true,
		  phoneUS: true
		},
		Home_Email : {
			notEqualTo: "#email"	
		}
	  }
	});

	$('#calendar').fullCalendar({
        // put your options and callbacks here
		events: {
			//url: '//localhost:8082/calendarData',
			url: '//misdb.esc7.net:8082/calendarData',
			data: function() { 
					return {
					subject: $("#subject").val()+"",
					audience: $("#audience").val()+"",
					grade: gradeBitMask(),
					ttess: ttessList(),
					tpess: tpessList(),
					sessType: $("#sessType").val()+""
					}
			}
		},	
		theme: false,
		eventColor: '#DEDEE0', //background and border color of event
		eventTextColor:'#444444',
		aspectRatio: 2,
        height: "auto",
		contentHeight: "auto",
		fixedWeekCount: false,
		eventRender: function(event, element) {
//			var calDate=$('#calendar').fullCalendar('getDate');
//			if (moment(event.start).isBefore(calDate.startOf('month'))
//				&& moment(event.end).isAfter(calDate.endOf('month'))) {
//				return false};
			if (event.Loc.substring(0,6) == "Online" || event.Loc.substring(0,7) == "Webinar") {
				return false};
			element.attr('title', event.Description);
		},
		eventAfterAllRender: function(view) {
			var listContent = renderer($('#calendar').fullCalendar('clientEvents'));
			$("#listViewDetail").html(listContent);

			//copy array elements that are Online Courses
			var calDate=$('#calendar').fullCalendar('getDate');
			var onlineListEvents = [];
			$.each( $('#calendar').fullCalendar('clientEvents'), function( index, event ){
//			if (moment(event.start).isBefore(calDate.startOf('month'))
//				&& moment(event.end).isAfter(calDate.endOf('month'))) {
			if (event.Loc.substring(0,6) == "Online" || event.Loc.substring(0,7) == "Webinar") {
				onlineListEvents.push(event)};
			});
			
			//Render the table of all month long events
			var onlineListContent = renderer(onlineListEvents);
			$("#onlineListDetail").html(onlineListContent);
			if (!inListView && (onlineListEvents.length > 0)) $("#onlineList").show()
			else $("#onlineList").hide(); 
		},
		customButtons: {
			PrintButton: {
				text: 'Print',
				click: function() {
					window.print();
				}
			},
			ListButton: {
				text: 'List View',
				click: function() {
					$('#onlineList').hide('fold');
					$('.leaderTrailer').hide('fold');
					$('div.fc-view-container').hide('scale', function() {$('#listView').show('scale');});
					inListView = true;
				}
			},
			CalendarButton: {
				text: 'Calendar View',
				click: function() {
					$('#listView').hide('scale');
					$('div.fc-view-container').show('scale', 
						function() {
							$('.leaderTrailer').show('fold');
							$('#onlineList').show('fold');
						});
					inListView = false;
				}
			}
		},
		header: {
			left:   'prev title next today',
			center: '',
			right: 'ListButton CalendarButton PrintButton'
		},
		eventClick: function(calEvent, jsEvent, view) {
			//had to rename url to urlSess in the calendar feed on prod server to intercept click without navigating away
			iframe.attr('src',calEvent.urlSess);
			$sessionDialog.dialog("open");
		}

    }); //end of fullCalendar


  }); //end of document ready function

</script>
<style type="text/css">
	#icons td {
		text-align: center;
	}
	#icons img {
		width: 40%;
		height: auto;
	}
	.filterBox    {
        background-color: white; 
        padding:0.5em; 
        margin-left:auto; 
        margin-right:auto;
    }
	.fc-event {
		cursor: pointer;
	}
	.fc-content {
		font-weight: normal;
	}
	#listView table, #onlineList table {
		font-size: 80%;
		border: 1px solid gray;
		border-collapse: collapse;
		margin-left: auto;
		margin-right: auto;
	}
	#listView th, #listView td , #onlineList th, #onlineList td{
		border: 1px solid gray;
		border-collapse: collapse;
		padding-left: 4px;
		padding-right: 4px;
	}
	#listView th , #onlineList th, #onlineList caption{
        background-color: #2D5EA8; 
		color:white;
		font-size: 120%;
	}
	#listView tbody tr:hover, #onlineList tbody tr:hover {
		background-color: #ffe78d;
		cursor: pointer;
	}
	#filters td {
		text-align: right;
		margin-left: auto;
		margin-right: auto;
	}
	#filters table {
		width: 100%;
	}
	.applyFiltersDiv {
	text-align: center;
	padding-top: 1em;
	}
	li.active-result {
		text-align: left;
	}
	input[type="button"], button:not(.ui-multiselect), button.ui-button {
		border-radius: 10px 0px !important;
	}
	.leaderTrailer {
		border-bottom: 1px solid #A6A6A6;
		text-align:center;
		color:#A6A6A6;
	}
	#onlineTable {
		max-height: 400px;
		overflow-y: auto;
	}
	.fc-unthemed .fc-today {
    background: #e5ffe5;
	}
	.error {
		color: red;
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
	<script type="text/x-handlebars-template" id="itemTemplate">
		{{#each this}}
			<tr data-url-sess="{{urlSess}}">
				<td>{{Dates}}</td>
				<td>{{Daily_Times}}</td>
				<td>{{id}}</td>
				<td>{{Long_Title}}</td>
				<td>{{Loc}}</td>
				<td>{{Rooms}}</td>
				<td>{{Presenter}}</td>
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
    <hr class="divider-color">
    
<div class="container">
    <table id="icons" width="100%">
		<tr>
			<td><a id="MyAccount" href="my-dashboard.asp"><img src="MyAccount.png" width="300" height="300" alt="My Account" /></a></td>
			<td><a id="CreateAccount" href="my-account.asp?newUser=Y"><img src="CreateAccount.png" width="300" height="300" alt="Create Account" /></a></td>
			<td><a id="WorkshopCatalog" href="https://misweb.esc7.net/Documents/Fall%20Catalog%20Sept%202015-Jan%202016.pdf">
				<img src="WorkshopCatalog.png" width="300" height="300" alt="Workshop Catalog" /></a></td>
			<td><a id="Featured" href="https://misweb.esc7.net/featured/"><img src="Upcoming-Events-Icon-HP.png" width="300" height="300" alt="Upcoming Events" /></a></td>
			<td><a id="Conferences" href="#"><img src="Upcoming-Conferences-Icon.png" width="300" height="300" alt="Upcoming Events" /></a></td>
		</tr>
	</table>
	<hr class="divider-color">
    </hr>
	<div id="filters" class="filterBox">
		<table width="100%">
			<tr>
				<td><label for="sessNum">Session #</label>
					<input id="sessNum" name="sessNum" type="text" maxlength="6">
					</td>
				<td>
					<label for="subject">Subject</label>
					<select id="subject" name="subject">
						<option value="any" selected="selected">any</option>
						<option><%=subjectOptions()%></option>
					</select>
				</td>
				<td>
					<label for="ttess">T-TESS</label>
					<select id="ttess" name="ttess">
						<%=ttessOptions()%>
					</select>
				</td>
				<td>
					<label for="grade">Grade</label>
					<select id="grade" name="grade">
						<option value="1"     />EC</option> 
						<option value="2"     />Pre-K</option> 
						<option value="4"     />K</option> 
						<option value="8"     />1</option> 
						<option value="16"    />2</option> 
						<option value="32"    />3</option> 
						<option value="64"    />4</option> 
						<option value="128"   />5</option> 
						<option value="256"   />6</option> 
						<option value="512"   />7</option> 
						<option value="1024"  />8</option> 
						<option value="2048"  />9</option> 
						<option value="4096"  />10</option> 
						<option value="8192"  />11</option> 
						<option value="16384" />12</option> 
					</select>
				</td>
			</tr>
			<tr>
				<td>
					<label for="sessType">Session Type</label>
					<select id="sessType" name="sessType">
						<option value="any" selected="selected">any</option>
						<option value="In Person Or Distance Learning">In Person Or Distance Learning</option>
						<option value="In Person Only">In Person Only</option>
						<option value="Distance Learning Only">Distance Learning Only</option>
					</select>
				</td>
				<td>
					<label for="audience">Audience</label>
					<select id="audience" name="audience" >
						<option value="any" selected="selected">any</option>
						<option><%=audienceOptions()%></option>
					</select>
				</td>
				<td>
					<label for="tpess">T-PESS</label>
					<select id="tpess" name="tpess">
						<%=tpessOptions()%>
					</select>
				</td>
				<td>
					
				</td>
			</tr>
		</table>
		<div class="applyFiltersDiv fc">
		<button id="applyFilters" class="fc-ListButton-button fc-button fc-state-default fc-corner-left fc-corner-right" type="button">Apply My Filters</button>
		<button id="clearFilters" class="fc-ListButton-button fc-button fc-state-default fc-corner-left fc-corner-right" type="button">Clear All Filters</button>
		</div>
	</div> 

	<h1 class="leaderTrailer">In-Person Events</h1>

	<hr class="divider-color">

	<div id="calendar"></div> 

	<div id="onlineList">
		<h1 class="leaderTrailer" >Online Events</h1>
		<div id="onlineTable">
			<table>
			  <thead>
				<tr>
					<th>Date(s)</th>
					<th>Time</th>
					<th>Session#</th>
					<th>Session name</th>
					<th>Location</th>
					<th>Room(s)</th>
					<th>Presenter</th>
				</tr>
			  </thead>
			  <tbody id="onlineListDetail">
			  </tbody>
			</table>
		</div>
	</div> 

	<div id="listView">
		<table>
		  <thead>
			<tr>
				<th>Date(s)</th>
				<th>Time</th>
				<th>Session#</th>
				<th>Session name</th>
				<th>Location</th>
				<th>Room(s)</th>
				<th>Presenter</th>
			</tr>
		  </thead>
		  <tbody id="listViewDetail">
		  </tbody>
		</table>
	</div> 
</div>
<!--#include file="footer.html" -->

<!-- Modals -->
<div id="loginDialogForm">
	<form method="post" id="loginForm" name="loginForm" autocomplete="on">
		<table align="center">
			<p><i>If you know your user name and password, login below.</i></p>
			<tr>
				<th><strong>User Name</strong>:</th>
				<td><input type="text" size="20" maxlength="40" name="userName" /></td>
			</tr>
			<tr>
				<th><strong>Password</strong>:</th>
				<td><input type="password" size="20" maxlength="20" name="password" /></td>
			</tr>
		</table>
		<div style="text-align:center">
			<p><strong>Reset password? Click <a target="_blank" href="forgotten0.asp">here</a>.</strong></p>
			<p><strong>Forgot your user name? Click
			<a target="_blank" href="forgottenUserName0.asp">here</a>.</strong></p>
			<span id="loginResult" />
		</div>
	</form>
</div>

	<div id="verifyProfileForm">
		<form method="post" id="verifyForm" name="verifyForm" autocomplete="on">
			<h2>Verify Your Profile Information</h2>
			<table>
				<tr>
					<td><label for="First_Name" >First Name </label></td>
					<td><input type="text"  name="First_Name"  id="First_Name"  placeholder="First Name "  size="16" maxlength="16" required>&nbsp;</td>
				</tr>
				<tr>
					<td><label for="Middle_Name">Middle Name</label></td>
					<td><input type="text"  name="Middle_Name" id="Middle_Name" placeholder="Middle Name" size="16" maxlength="16"></td>
				</tr>
				<tr>
					<td><label for="Last_Name"  >Last Name  </label></td>
					<td><input type="text"  name="Last_Name"   id="Last_Name"   placeholder="Last Name  "  size="16" maxlength="16" required></td>
				</tr>
				<tr>
					<td><label for="Dist_Code" >District</label></td>
					<td>
						<select id="Dist_Code" name="Dist_Code" placeholder="District"><%=districtOptions()%></select>
					</td>
				</tr>
				<tr>
					<td><label for="Asgn_Num" >Assignment</label></td>
					<td>
						<select id="Asgn_Num" name="Asgn_Num" placeholder="Assignment"><%=assignmentOptions()%></select>
					</td>
				</tr>
				<tr>
					<td><label for="email"      >Work Email </label></td>
					<td><input type="email" name="email"       id="email"       placeholder="Work Email "  size="30" maxlength="40" required></td>
				</tr>
				<tr>
					<td><label for="homeEmail"  >Home Email </label></td>
					<td><input type="email" name="Home_Email"   id="Home_Email"   placeholder="Home Email "  size="30" maxlength="40"></td>
				</tr>
				<tr>
					<td><label for="Home_Phone" >Home Phone </label></td>
					<td><input type="tel"   name="Home_Phone"  id="Home_Phone"  placeholder="Home Phone "  size="16" maxlength="13"></td>
				</tr>
				<tr>
					<td><label for="Work_Phone" >Work Phone </label></td>
					<td><input type="tel"   name="Work_Phone"  id="Work_Phone"  placeholder="Work Phone "  size="16" maxlength="13"></td>
				</tr>
			</table>
			<div style="text-align:center; font-weight:bold; color:red;">
				<span id="profileResult" />
			</div>
		</form>
	</div>
	
	<!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="js/bootstrap.min.js"></script>
</body>
</html>
