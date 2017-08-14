<%@ include file="CommonStuff.jsp" %>


<%@ page import="org.apache.commons.lang3.RandomStringUtils"%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<body>
<%@ include file="Header.jsp"%>
<center>

<%! String sSignUpErr = ""; 
	String sFilename = "Signup.jsp";
%>

<%
String sForm = request.getParameter("FormName"); 
if(sForm==null) //it will be null if we get to SignUp.jsp by typing the url in the address bar.
  sForm="";		//it will be equal to SignUp, if this is a non-logged in user who is signing up
  				//it will be equal to modifyInfo, if this is a user who is modifying their info.


java.sql.Connection conn = null;
java.sql.Statement stat = null;
String sErr = loadDriver();
conn = connectToDB();
if ( ! sErr.equals("") ) {
 try {
   out.println(sErr);
 }
 catch (Exception e) {}
}
stat = conn.createStatement();
if(sForm.equals("SignUp")) {
  sSignUpErr = Signup(request, response, session, out, sForm, conn, stat);
  if ( "sendRedirect".equals(sSignUpErr)) return;
}
else if(sForm.equals("modifyInfo")) {
	sSignUpErr = ModifyInfo(request, response, session, out, sForm, conn, stat);
}
else 
	ShowSignupTable(request, response, session, out, sErr, sForm, conn, stat);
%>



<%
if ( stat != null ) stat.close();
if ( conn != null ) conn.close();
%>
<%!

String Signup(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
    String sErr = "";
    try {
      String name = request.getParameter("name");
      String password = request.getParameter("password");
      String username = request.getParameter("username");
      String address = request.getParameter("address");
      String ccno = request.getParameter("ccno");

      //jar file containing the code of this class in WEB-INF/lib
      //generate a random string of 6 characters. 
      //6 characters long is not secure. Todo project 3.
      String user_id=RandomStringUtils.randomAlphanumeric(6);
      out.print(user_id);
      
      //PreparedStatement checkName = null;
      //String sqlQuery1 = "select user_id FROM users where username= '"+username+"'";
      String sqlQuery1 = "select user_id FROM users where username=?"; 
      //java.sql.ResultSet rs = stat.executeQuery(sqlQuery1);
      //checkName = strConn.prepareStatement(sqlQuery1);
      PreparedStatement checkName = conn.prepareStatement(sqlQuery1);
      checkName.setString(1, username);
      java.sql.ResultSet rs = checkName.executeQuery();
      
     	if(rs.next())	
     	{
     		System.out.println("found existing user");
     		response.sendRedirect("SignupUnsuccessful.jsp");
     	}
     	else
     	{
     		if(isAlphaNumeric(password) == false)
     		{
     			//System.out.println("found existing user");
         		response.sendRedirect("badPassword.jsp");
     		}
     		else
     		{
             	// select member_id, member_level from members where member_login ='tom' and member_password='   bom' OR 1=1 #'
             /*
                PreparedStatement checkName = conn.prepareStatement(sqlQuery1);
      			checkName.setString(1, username);
      			java.sql.ResultSet rs = checkName.executeQuery();
             
       	      String sqlQuery = "insert into users values('" + user_id + "', '" +
       	     					username + "', '" + password + "', '" + name +
       	     					"', '" + address + "', '" + ccno + "', '1'" + ")";
       	      int count = stat.executeUpdate(sqlQuery);*/
       	   	  String sqlQuery = "insert into users values(?, ?, ?, ?, ?, ?, '1')";
       	   	PreparedStatement insertName = conn.prepareStatement(sqlQuery);
       	 	password = MD5(password);
       	 	insertName.setString(1, user_id);
       		insertName.setString(2, username);
       		insertName.setString(3, password);
       		insertName.setString(4, name);
       		insertName.setString(5, address);
       		insertName.setString(6, ccno);

       		insertName.executeUpdate();
       	      
       	      //assuming the insert has been successful. It may however fail. Todo project 3.
       	      //Do we log the user in after signing up or not? 
       	      //let us have the user logged in automatically after signup. <===============================THIS
       	      session.setAttribute("user_id", user_id);
       	      session.setAttribute("username", username);
       	      session.setAttribute("level", "1"); //normal users have level 1.		
     		}
     	}
      try {
          if ( stat != null ) stat.close();
          if ( conn != null ) conn.close();
      }
      catch ( java.sql.SQLException ignore ) {}
      response.sendRedirect("SignupSuccessful.jsp");
      return "signupSuccessful";
    }
    catch(Exception e) {
    	out.print(e.toString());
    }
    return sErr;
   }

String ModifyInfo(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
	String sErr="";
	try {
		String password= request.getParameter("password");
 		if(isAlphaNumeric(password) == false)
 		{
 			//System.out.println("found existing user");
     		response.sendRedirect("Signup.jsp");
 		}
 		else
 		{
 			int attributeIndex = 0;
 			String user_id = (String)session.getAttribute("user_id");
 			//String whereClause = "where user_id='" + user_id+ "'";
 			String whereClause = "where user_id=?";
 			String sqlQuery = "update users set ";
 			PreparedStatement modInfo = null;
 			String ccno = request.getParameter("ccno");
 			if(ccno!=null) {
 				//sqlQuery+=" ccno='"+ccno+"' "+ whereClause;
 				sqlQuery+=" ccno=? "+ whereClause;
 				//int count = stat.executeUpdate(sqlQuery);
 				attributeIndex++;
 				sErr+="ccno";
 			}
 			String address= request.getParameter("address");
 			if(address!=null) {
 				//sqlQuery+=" address='"+address+"' "+ whereClause;
 				sqlQuery+=" address=? "+ whereClause;
 				//int count = stat.executeUpdate(sqlQuery);
 				attributeIndex++;
 				sErr+="address";
 			}
 			//String password= request.getParameter("password");
 			if(password!=null) {
 				//sqlQuery+=" password='"+password+"' "+ whereClause;
 				sqlQuery+=" password=? "+ whereClause;
 				//int count = stat.executeUpdate(sqlQuery);
 				attributeIndex++;
 				sErr+="password";
 			}
 			
 			if(ccno!=null) {
 				modInfo.setString(attributeIndex, ccno);
 			}
 			if(address!=null) {
 				modInfo.setString(attributeIndex, address);
 			}
 			if(password!=null) {
 				password = MD5(password);
 				modInfo.setString(attributeIndex, password);
 			}
 			modInfo = conn.prepareStatement(sqlQuery);
 			modInfo.executeUpdate();	
 		}
	}
	catch(Exception e) {
		out.print(e.toString());
		sErr="exception";
	}
	return sErr;
}

//this method shows the Login Form
  String ShowSignupTable(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
    try {  
      String sSQL="";
      //String transitParams = "";
      //String sQueryString = request.getParameter("querystring");
      String sPage = request.getParameter("ret_page");
  
      out.println("    <table style=\"\" border=1>");
      out.println("     <tr>\n      <td style=\"background-color: #336699; text-align: Center; border-style: outset; border-width: 1\" colspan=\"2\"><font style=\"font-size: 12pt; color: #FFFFFF; font-weight: bold\">Enter login and password</font></td>\n     </tr>");

      if ( sLoginErr.compareTo("") != 0 ) {
        out.println("     <tr>\n      <td colspan=\"2\" style=\"background-color: #FFFFFF; border-width: 1\"><font style=\"font-size: 10pt; color: #000000\">"+sLoginErr+"</font></td>\n     </tr>");
      }
      sLoginErr="";
      out.println("     <form action=\""+sFilename+"\" method=\"POST\">");
      
      if ( session.getAttribute("user_id") == null || ((String) session.getAttribute("user_id")).compareTo("") == 0 ) {
        // User has not logged in. Can we have logged in users sign up?
        out.println("     <input type=\"hidden\" name=\"FormName\" value=\"SignUp\">");
        out.println(" <tr>\n"+      
                "<td>Name</td>"+
                "<td><input type=\"text\" name=\"name\" maxlength=\"50\" value=\"\"></td>\n"+
              "</tr>");
        out.println(" <tr>\n"+      
                        "<td>Choose a username</td>"+
                        "<td><input type=\"text\" name=\"username\" maxlength=\"50\" value=\"\"></td>\n"+
                      "</tr>");
        out.println(" <tr>\n"+      
                        "<td>Choose a Password</td>"+
                        "<td><input type=\"text\" name=\"password\" maxlength=\"50\"></td>\n"+         "</tr>");
        out.println(" <tr>\n"+      
                "<td>Address</td>"+
                "<td><input type=\"text\" name=\"address\" maxlength=\"50\"></td>\n"+         "</tr>");
        out.println(" <tr>\n"+      
                "<td>Credit Card Number</td>"+
                "<td><input type=\"text\" name=\"ccno\" maxlength=\"16\"></td>\n"+         "</tr>");
        out.print("   <tr>\n"+
                        "<td><input type=\"submit\" value=\"Sign Up\"></td>"+
                      "</form>"+
                 "</tr></table>");
      }
      else {
        // User logged in, let us let them change their data here (CC, address, password).
        //Not part of the requirements for project2.
        //String getUserID(java.sql.Statement stat, String table, String fName, String where)
        //String sUserID = dLookUp( stat, "members", "member_login", "member_id =" + session.getAttribute("UserID"));
        java.sql.Connection conn1 = null;
        java.sql.Statement stat1 = null;
        String username = (String) session.getAttribute("username");
        showModifyUserInfoTable(username, out);
      }

    }
    catch (Exception e) { out.println(e.toString()); }
    return "OK";
  }

void showModifyUserInfoTable(String username, javax.servlet.jsp.JspWriter out) throws java.io.IOException {
	try {
  out.println("Hello "+username+". You can modify your information using the form below <p>");
  out.println("     <form action=\""+sFilename+"\" method=\"POST\">");
  out.println("     <input type=\"hidden\" name=\"FormName\" value=\"modifyInfo\">");
  out.println(" <tr>\n"+      
                    "<td>Enter New Password</td>"+
                    "<td><input type=\"text\" name=\"Password\" maxlength=\"50\"></td>\n"+         "</tr>");
    out.println(" <tr>\n"+      
            "<td>Enter New Address</td>"+
            "<td><input type=\"text\" name=\"address\" maxlength=\"50\"></td>\n"+         "</tr>");
    out.println(" <tr>\n"+      
            "<td>Enter New Credit Card Number</td>"+
            "<td><input type=\"text\" name=\"ccNo\" maxlength=\"16\"></td>\n"+         "</tr>");
    out.print("   <tr>\n"+
                    "<td><input type=\"submit\" value=\"Modify Info\"></td>"+
                  "</form>"+
              "</tr></table>");
	}
	catch(Exception e) {
		out.print(e.toString());
	}
}

%>

</body>
</html>