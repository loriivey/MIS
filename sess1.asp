<%@ Language = JScript 1.2%>
<% ThisDoc = "sess1.asp";
   Title = "MIS Registration for Session " + Request("sessNum")%>
<!--#include file="dump.inc" -->
<!--#include file="misconn.inc" -->
<link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/custom.css" rel="stylesheet">
<%
var prototype = Request("prototype");
MisCmd.Commandtext="Select UseSSN, DisableIcal from MIS.Parameters where parm_key=0";
MisRecSet.Open();
var useSSN=(MisRecSet("UseSSN").value+"")=='Y';
var DisableIcal = MisRecSet("DisableIcal")+"";
MisRecSet.Close();

var coopFee = "";
if (Session("loggedIn")+"" == "Y") {
    MisCmd.Commandtext=
        "Select '$'||CoopFee(p.Ptcpnt_SSN,s.Sess_Num) as coopFee " +
        "From Mis.Session s, Mis.Participant p " + 
        "Where s.Sess_Num='" + Request("sessNum") +
            "' and p.Username='" + Session("userName") + "' ";
    MisRecSet.Open();
    coopFee = MisRecSet("coopFee")+"";
    MisRecSet.Close();
}

function formatUSDollars (bucks){
//This function takes an integer and formats it to $9999.99 format
 
if (bucks == 0){
  x = "none";
  } 
else {
  a = bucks.value;
  a = a.toString();
  x = "$";
  cents = 0;
  isPeriod = new Boolean(false);
  for (var i=0; i < a.length; i++) {
    x = x + a.charAt(i);
    if (a.charAt(i) == '.'){
      isPeriod = true; 
      }
    else {
      if (isPeriod == true) {
        cents = cents + 1; 
        }
      } 
    } 
  if (isPeriod == false){
    x = x + ".00";
    }
  else {
    if (cents == 1) {
      x = x + "0";
      }
    }
  }
return x;
}

function formatUSPhone (phone){
//This function takes a ten digit string and formats is to (999)999-9999 format
x = " ";
if (phone.value != null){
  a = phone.value;
  x = "(" + a.substring(0,3) + ")" + a.substring(3,6) + "-" + a.substring(6,10);
  }
return x;
}

function formatUSPhoneFax (phone){
//This function takes a ten digit string and formats is to (999)999-9999 format
x = " ";
if (phone.value != null){
  a = phone.value;
  x = "(" + a.substring(0,3) + ")" + a.substring(3,6) + "-" + a.substring(6,10) + " (fax)";
  }
return x;
}

function writeAudience(){
MisCmd2 = Server.CreateObject("ADODB.Command");
MisRecSet2 = Server.CreateObject("ADODB.Recordset");
MisCmd2.ActiveConnection = MisCon;                               
MisRecSet2.Source = MisCmd2;        
MisCmd2.CommandText = "Select Audience_Keyword from MIS.Wksp_Audience "
  + "Where Wksp_Num='" + Session("Wksp_Num") + "' ";
MisRecSet2.Open();
aud = "";
while (!MisRecSet2.EOF){
  aud = aud + MisRecSet2("Audience_Keyword").value;
  MisRecSet2.MoveNext();
  if (!MisRecSet2.EOF) {
    aud = aud + ", ";
    }
  }
Response.Write(aud);
MisRecSet2.Close();
}

MisCon = Server.CreateObject("ADODB.CONNECTION");
MisCon.Open("DSN=MisData","MisWeb","MisWeb");
MisCmd = Server.CreateObject("ADODB.Command");
MisCmd.ActiveConnection = MisCon;                             
MisRecSet = Server.CreateObject("ADODB.Recordset");          
MisRecSet.Source = MisCmd;

MisCmd.CommandText = 
  "SELECT                                     " +
  ' MIS."Session".Sess_Num,                   ' +
  'DATEFORMAT(("Session".Start_DateTime),     ' +
  "'mm/dd/yyyy hh:nnaa') as Start_Date,       " +
  'DATEFORMAT(("Session".End_DateTime),       ' +
  "'mm/dd/yyyy hh:nnaa') as End_Date,         " +
  'DATEFORMAT("Session".Registration_End_Datetime,' +
  "'mm/dd/yyyy hh:nnaa') as Registration_Deadline," +
  ' MIS."Session".Venue,                      ' +
  " Availability(sess_Num) as availability,    " +
  " AvailabilityDL(sess_Num) as availabilityDL," +
  ' MIS."Session".Daily_Times,                ' +
  ' MIS."Session".City,                       ' +
  ' MIS."Session".Loc,                        ' +
  ' MIS."Session".Dur,                        ' +
  ' MIS."Session".Fee||\'\' as Fee,           ' +
  ' MIS."Session".Mesg,                       ' +
  ' htmllinebreak(MIS."Session".Presenter) as Presenter,' +
  ' MIS."Session".Cap,                        ' +
  ' MIS."Session".CapDL,                      ' +
  ' MIS."Session".Stat,                       ' +
  ' MIS."Session".WaitList_OK,                ' +
  ' MIS."Session".Coop_Only,                  ' +
  ' MIS."Session".Allow_Registration,         ' +
  ' MIS."Session".Disallowed_Registration_Notice, ' +
  " MIS.Workshop.Wksp_Num,                    " +
  " MIS.Workshop.Short_Title,                 " +
  " MIS.Workshop.Long_Title,                  " +
  " MIS.Credit_Type.Credit_Type_Descr,        " +
  " MIS.Workshop.Description,                 " +
  " MIS.Workshop.HTML_File,                   " +
  " MIS.Workshop.Grade_List,                  " +
  " (Select List(PDAS_Obj)                    " +
  "  from MIS.Wksp_PDAS                                       " +
  '  where "Session".Wksp_Num=Wksp_PDAS.Wksp_Num) as PDAS_List, ' +
  " (Select List(PSS_Standard_Code||PSS_Skill_Code)           " +
  "  from MIS.Wksp_PSS                                        " +
  '  where "Session".Wksp_Num=Wksp_PSS.Wksp_Num) as PSS_List, ' +
  " (Select List(Dimension_Num) " +
  "  from MIS.Wksp_TTESS " +
  "  where WorkShop.Wksp_Num=Wksp_TTESS.Wksp_Num) as TTESS_List, " +
  " (Select List(Indicator_Num) " +
  "  from MIS.Wksp_TPESS " +
  "  where WorkShop.Wksp_Num=Wksp_TPESS.Wksp_Num) as TPESS_List, " +
  " (Select List('$'||Coop_Fee||' for members of '||Coop_Name,'<br />')           " +
  "  from MIS.Session_Coop sc key join Mis.Coop c             " +
  '  where sc.Sess_Num="Session".Sess_Num and Coop_Active=\'Y\') as Coop_List, ' +
  "FK_Session_Consultant_InfoContact.Title as Info_Title, "      +
  "FK_Session_Consultant_InfoContact.First_Name as Info_FName, " +
  "FK_Session_Consultant_InfoContact.Last_Name as Info_LName, "  +
  "FK_Session_Consultant_InfoContact.Affiliation as Info_Aff, "  +
  "FK_Session_Consultant_InfoContact.Email as Info_Email, "      +
  "FK_Session_Consultant_InfoContact.Work_Phone as Info_Phone, " +
  "FK_Session_Consultant_InfoContact.Fax as Info_Fax, " +
  "FK_Session_Consultant_RegisterContact.Title as Reg_Title, "   +
  "FK_Session_Consultant_RegisterContact.First_Name as Reg_FName, " +
  "FK_Session_Consultant_RegisterContact.Last_Name as Reg_LName, "  +
  "FK_Session_Consultant_RegisterContact.Affiliation as Reg_Aff, "  +
  "FK_Session_Consultant_RegisterContact.Email as Reg_Email,"   +
  "FK_Session_Consultant_RegisterContact.Work_Phone as Reg_Phone, " +
  "FK_Session_Consultant_RegisterContact.Fax as Reg_Fax, " +
  "(Select Count(Ptcpnt_SSN) from MIS.Register " +
  "  Where Register.Sess_Num = '" +
     Request("sessNum") + "' AND" +
  "  Register.Stat in ('F',' ') AND distanceLearning='N') as Enrollment, " +
  "(Select Count(Ptcpnt_SSN) from MIS.Register " +
  "  Where Register.Sess_Num = '" +
     Request("sessNum") + "' AND" +
  "  Register.Stat in ('F',' ') AND distanceLearning='Y') as EnrollmentDL, " +
  "String('<a target=\"_blank\" href=\"http://www.google.com/calendar/event?action=TEMPLATE&text=',HTTP_Encode(Long_Title),'&dates=',DateFormat(Start_DateTime,'YYYYMMDDTHHNNSS/'), " +
  " DateFormat(End_DateTime,'YYYYMMDDTHHNNSS'),'&details=',HTTP_Encode(Description),'&location=',HTTP_Encode(Session.City),',  ',HTTP_Encode(Loc), " +
  " '\">Add to Google Calendar</a>') as gCalLink " +
  "FROM " +
  'MIS."Session" key join MIS.Workshop key join MIS.Credit_Type ' +
  "  key left outer join MIS.Consultant FK_Session_Consultant_InfoContact "     +
  "  key left outer join MIS.Consultant FK_Session_Consultant_RegisterContact " +
  'Where "Session".Sess_Num ' +
  "= '" + Request("sessNum") + "' "
;
                           
if (prototype!="yes") MisCmd.CommandText += 'AND "Session".PublishOnWeb = ' + "'Y' ";

MisRecSet.Open();

if (!MisRecSet.EOF){

Session("Sess_Num") = Request("sessNum") + "";
Session("Wksp_Num") = MisRecSet("Wksp_Num").value;
Session("Long_Title") = MisRecSet("Long_Title").value;
var venue = MisRecSet("Venue") + "";
var availability = MisRecSet("Availability") + "";
var availabilityDL = MisRecSet("AvailabilityDL") + "";

// Format database fields for display
coopList=MisRecSet("Coop_List").value;
coopList=coopList.replace(/\$0\.00/g,"Fee Waived");
coopOnly=MisRecSet("Coop_Only").value;
feeList = (coopOnly=='Y') ? 'For Coop Members Only' : '$' + MisRecSet("Fee").value + " Standard Fee";

if (coopList != '') feeList += '<br />' + coopList;

if (Session("loggedIn")+"" == "Y") {
    feeList += '<br /><strong>With all applicable coop discounts your personal fee is '
        + coopFee + '.</strong>'; 
}
else {
    feeList += '<br /><a href="partreg0.asp?flow=coop">Look up my Coop memberships</a> '; 
}

if (MisRecSet("Info_FName").value == null){
   firstname = "";
   }
else {
   firstname = MisRecSet("Info_FName").value;
   }
if (MisRecSet("Info_LName").value == null){
   lastname = "No Contact Available";
   }
else {
   lastname = MisRecSet("Info_LName").value;
   }

if (MisRecSet("Info_Title").value != null)
   Info_Name = MisRecSet("Info_Title") + " "
             + firstname + " " 
             + lastname
else
   Info_Name = firstname + " " 
             + lastname;

if (MisRecSet("Reg_FName").value == null){
   firstname = "";
   }
else {
   firstname = MisRecSet("Reg_FName").value;
   }
if (MisRecSet("Reg_LName").value == null){
   lastname = "No Contact Available";
   }
else {
   lastname = MisRecSet("Reg_LName").value;
   }

if (MisRecSet("Reg_Title").value != null)
   Reg_Name = MisRecSet("Reg_Title") + " "
            + firstname + " " 
            + lastname
else
   Reg_Name = firstname + " " 
            + lastname;

var formAction = "partreg1.asp";

if (useSSN) {
    var idLink = formAction+"?Sess_Num="
        +MisRecSet("Sess_Num") + "&ssn1="
        +Request("ssn1") + "&ssn2="
        +Request("ssn2") + "&ssn3="
        +Request("ssn3");
}       
else {
    var idLink = formAction+"?Sess_Num="
        +MisRecSet("Sess_Num") + "&userName="
        +Request("userName") + "&passWord="
        +Request("passWord");
}
%>
	<div class="container"
        <div class="row">
          <div class="col-md-12">
				<br>
				<br>
              <h3>Session Information</h3>
              <br>
			  <br>
			  
			  <p>
				<strong>Session Description</strong><br>
				<%=MisRecSet("Description")%>
				</p>
				<TABLE class = "table">
				 <tr>
					<td><b>Short Title</b></td>
					<td><%=MisRecSet("Short_Title")%></td>
					<td><b>Long Title</b></td>
					<td><%=MisRecSet("Long_Title")%></td>
				</tr>
				
				<tr>
					<td><b>PDAS Objectives</b></td>
					<td><%=MisRecSet("PDAS_List")%></td>
					<td><b>TTESS Codes</b></td>
					<td><%=MisRecSet("TTESS_List")%></td>
				</tr>	
				<tr>
					<td><b>TPESS Codes</b></td>
					<td><%=MisRecSet("TPESS_List")%></td>
					<td><b>Credit Type</b></td>
					<td><%=MisRecSet("Credit_Type_Descr")%></td>
				</tr>
				<tr>
					<td><b>Audience Type</strong><br>
					<td><%writeAudience();%></td>
					<td><b>Grade Levels</strong><br>
					<td><%=MisRecSet("Grade_List")%></td>
				</tr>
				 </TABLE>
				 
				
		<table class= "table">
				<tr>
				<td><b>Session  </b></td>
				<td><b>Start    </b></td>
				<td><b>End      </b></td>
				<td><b>Schedule </b></td>
				</tr>
			<tr>
				<td><b><%=MisRecSet("Sess_Num")%></font></b></td>
				 <td><%=MisRecSet("Start_Date")%></td>
				 <td><%=MisRecSet("End_Date")%></td>
				 <td><%=MisRecSet("Daily_Times")%></td>
			</tr>			<tr>
				<td><b>Venue    </b></td>
				<td><b>City     </b></td>
				<td><b>Location </b></td>
				<td><b>Duration </b></td>
			</tr>
			<tr>
				<td><%=venue%></td>
				<td><%=MisRecSet("City")%></td>
				<td><%=MisRecSet("Loc")%></td>
				<td><%=MisRecSet("Dur")%></td>
			 </tr>
		</table>	
		<table class= "table">
			<tr>
				 <td><b>Workshop Fees </b></td>
				 <td><%=feeList%></td>
			   </tr>   
			   <tr>
				 <td><b>Presenter </b></td>
				 <td><%=MisRecSet("Presenter")%></td>
			   </tr>   
			   <tr>
				 <td><b>Registration Deadline </b></td>
				 <td><%=MisRecSet("Registration_Deadline")%></td>
			   </tr>   
			   <tr>
				 <td><b>Message   </b></td>
				 <td><%=MisRecSet("Mesg")%></td>
			   </tr>
			</table>
			 </div>
		
<%
if (MisRecSet("HTML_File") > ' ') {
%>
  
<%
} //endif html_file
%>
  
<%
if (DisableIcal == "N") {
	Response.Write('<a href="iCal.asp?sessNum='
    +Request("sessNum")
    +'"><img src="Calendar.gif"  width="24" height="24" border="0" align="left" alt="Import to Calendar" />'
    +'Import to my calendar</a><br />\n');
	Response.Write(MisRecSet("gCalLink").value)
}

if (MisRecSet("Enrollment").value >= MisRecSet("Cap").value) 
   {full=true}
else {full=false};

if (full) 
   {wait=MisRecSet("WaitList_OK").value}
else {wait="N"};

Session("wait")=wait;
//r7 mod 25OCT2010 removed wait session variable: must be set in partreg0.asp, partreg1.asp, and sessreg0.asp
Session.Contents.Remove("wait");

if (Request("type") == "DATE") {
    var formAction = "partreg0.asp";
    idLink = formAction+'?Sess_Num=' + Request("sessNum"); //r7Mod 25OCT2010 removed wait parameter
}

if ((venue=='In Person Or Distance Learning') || (venue=='In Person Only'))
{
    Response.Write('<table align="center">');

    if ((MisRecSet("Allow_Registration") == "N") && (prototype!="yes")) 
        Response.Write("<tr><td><b>" + MisRecSet("Disallowed_Registration_Notice") + "</b></td></tr>\n")
    else if ((availability=="Available for Registration") || (prototype=="yes")) 
            if (Session("loggedIn")+"" != "Y")
                Response.Write('<tr><td><a href ="javascript:doNavigation(\'login\',\'N\',\'N\')"><b>Register for this Session</b></a></td></tr>\n')
            else {
                Response.Write('<tr><td><a href ="javascript:doNavigation(\'noLogin\',\'N\',\'N\')"><b>Register for this Session as '
                    + Session("userName") + '</b></a></td></tr>\n')
                Response.Write('<tr><td><a href ="javascript:doNavigation(\'login\',\'N\',\'N\')"><b>Register for this Session as Somebody Else</b></a></td></tr>\n')
            }
         else if (availability=="Available for waitlist only: session is full") 
                if (Session("loggedIn")+"" != "Y")
                    Response.Write('<tr><td><a href ="javascript:doNavigation(\'login\',\'N\',\'Y\')"><b>Join the Wait List for this Session</b></a></td></tr>\n')
                else {
                    Response.Write('<tr><td><a href ="javascript:doNavigation(\'noLogin\',\'N\',\'Y\')"><b>Join the Wait List for this Session as '
                        + Session("userName") + '</b></a></td></tr>\n')
                    Response.Write('<tr><td><a href ="javascript:doNavigation(\'login\',\'N\',\'Y\')"><b>Join the Wait List for this Session as Somebody Else</b></a></td></tr>\n')
                }
              else Response.Write('<tr><td><b>' + availability + '</b></td></tr>\n');
    Response.Write('</table>\n');
}

if ((venue=='In Person Or Distance Learning') || (venue=='Distance Learning Only'))
{
    Response.Write('<table align="center">');
    if (MisRecSet("Allow_Registration") == "N") 
        Response.Write("<tr><td><b>" + MisRecSet("Disallowed_Registration_Notice") + "</b></td></tr>\n")
    else if (availabilityDL=="Available for Registration") 
            if (Session("loggedIn")+"" != "Y")
                Response.Write('<tr><td><a href ="javascript:doNavigation(\'login\',\'Y\',\'N\')"><b>Register for this Session via Distance Learning</b></a></td></tr>\n')
            else {
                Response.Write('<tr><td><a href ="javascript:doNavigation(\'noLogin\',\'Y\',\'N\')"><b>Register for this Session via Distance Learning as '
                    + Session("userName") + '</b></a></td></tr>\n')
                Response.Write('<tr><td><a href ="javascript:doNavigation(\'login\',\'Y\',\'N\')"><b>Register for this Session via Distance Learning as Somebody Else</b></a></td></tr>\n')
            }
         else Response.Write('<tr><td><b>' + availabilityDL + '</b></td></tr>\n');
    Response.Write('</table>\n');
}



%>
<table align="center">
   <tr>
     <td width = 50%><b>For Workshop Information Contact:</b></td>
     <td width = 50%><b>For Registration Information Contact:</b></td>
   </tr>
   <tr>
     <td width = 50%><%=Info_Name%></td>
     <td width = 50%><%=Reg_Name%></td>
   <tr>   
     <td width = 50%><%=MisRecSet("Info_Aff")%>
     <td width = 50%><%=MisRecSet("Reg_Aff")%></td>
   </tr>
   <tr>
     <td width = 50%><a href=mailto:<%=MisRecSet("Info_EMail")%>>
                     <%=MisRecSet("Info_EMail")%></a></td>
     <td width = 50%><a href=mailto:<%=MisRecSet("Reg_EMail")%>>
                     <%=MisRecSet("Reg_EMail")%></a></td>
   </tr>
   <tr>   
     <td width = 50%><%=formatUSPhone(MisRecSet("Info_Phone"))%></td>
     <td width = 50%><%=formatUSPhone(MisRecSet("Reg_Phone"))%></td>
   </tr>
   <tr>   
     <td width = 50%><%=formatUSPhoneFax(MisRecSet("Info_Fax"))%></td>
     <td width = 50%><%=formatUSPhoneFax(MisRecSet("Reg_Fax"))%></td>
   </tr>
</table></p>
<form name="theForm" method="post" action="partreg1.asp">
<input name="Sess_Num" type="hidden" value="<%=Request("sessNum")%>">
<input name="userName" type="hidden" value="<%=Request("userName")%>">
<input name="passWord" type="hidden" value="<%=Request("passWord")%>">
<input name="ssn1" type="hidden" value="<%=Request("ssn1")%>">
<input name="ssn2" type="hidden" value="<%=Request("ssn2")%>">
<input name="ssn3" type="hidden" value="<%=Request("ssn3")%>">
<input name="wait" type="hidden" value="<%=wait%>">
<input name="DL" type="hidden" value="N">
</form>

<%  } // End if record found

else {
%>
<p><font face="Arial, helvetica"><b>The session number <%=Request("sessNum")%>
that you have selected is either invalid or not published.  Please browse the catalog
to see if we have another session available that you might be interested in.  Thanks!
</b></font></p>
<%
//Response.Write(MisCmd.CommandText);
}
%>
<script type="text/javascript">
function doNavigation(login,DL,wait) {
    window.document.theForm.DL.value=DL;
    window.document.theForm.wait.value=wait;
    if (login=="noLogin") {
        window.document.theForm.action="sessreg0.asp";
    if ("<%=prototype%>"!="yes") window.document.theForm.submit();
    }
    else {
        if (("<%=formAction%>"=="partreg0.asp") && ("<%=prototype%>"!="yes")) window.document.location="<%=idLink%>&DL="+DL+"&wait="+wait
        else {
        window.document.theForm.action="<%=formAction%>";
        if ("<%=prototype%>"!="yes") window.document.theForm.submit();
        }
    }
}
</script>
</div>
<!--#include file="DocTail.inc" -->
