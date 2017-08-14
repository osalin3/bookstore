<%@ include file="CommonStuff.jsp" %>


<%! String sSignUpErr = ""; 
	String sFilename = "ManageUsers.jsp";
%>

<%
//check for permissions
String userlevel = (String)session.getAttribute("level");
if(userlevel.equals("1")) {//send 401.
	response.sendError(401, "You are not authorized to see this page");
}
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<body>
<%@ include file="Header.jsp" %>
<center>

<%
String sForm = request.getParameter("FormName");
if(sForm==null) //it will be null if we get to ManageUsers.jsp from some other page
	sForm=""; //it will be search if we get to ManageUsers from the Search form.
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
if(sForm.equals("searchUsers"))
	sErr=doSearch(request,  response, session, out, sForm, conn, stat);
else if(sForm.equals(""))
	showQueryTable(out);
else if(sForm.equals("modifyUser"))
	sErr=doModify(request,  response, session, out, sForm, conn, stat);
%>

<%! 
//this implementation has the drawback that it is rewriting values to the database that
//may have not been changed. However, it is simple. 
String doModify(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
	String sErr="";
	try {
		String user_id=request.getParameter("user_id");
		String delete_user=request.getParameter("delete_user");
		if(delete_user!=null) {
			/*String sqlQuery="delete from users where user_id='"+user_id+"'";
			int count = stat.executeUpdate(sqlQuery);*/
			String sqlQuery="delete from users where user_id=?";
			PreparedStatement deleteUser = conn.prepareStatement(sqlQuery);
			deleteUser.setString(1, user_id);
			deleteUser.executeUpdate();
			session.setAttribute("user_deleted", user_id);
			response.sendRedirect("UpdateSuccessful.jsp");
			sErr="delete";
		}
		String password= request.getParameter("password");
 		if(isAlphaNumeric(password) == false)
 		{
 			//System.out.println("found existing user");
     		response.sendRedirect("BadModify.jsp");
 		}
 		else
 		{
 			String sqlQuery = "update users set ";
 			String whereClause = "where user_id='" + user_id+ "'";
 			String ccno = request.getParameter("ccno");
 			if(ccno!=null) {
 				//sqlQuery+=" credit_card='"+ccno+"', ";
 				sqlQuery+=" credit_card=?, ";
 			}
 			String address= request.getParameter("address");
 			if(address!=null) {
 				//sqlQuery+=" address='"+address+"', ";
 				sqlQuery+=" address=?, ";
 			}
 			if(password!=null) {
 				//sqlQuery+=" password='"+password+"', ";
 				sqlQuery+=" password=?, ";
 			}
 			String userlevel=request.getParameter("userlevel");
 			String level="1";
 			if(userlevel.equals("yes"))
 				level="2";
 			sqlQuery+=" level='"+level+"' "+ whereClause;
 			System.out.println(sqlQuery);
 			PreparedStatement updateUser = conn.prepareStatement(sqlQuery);
 			updateUser.setString(1, ccno);
 			updateUser.setString(2, address);
 			password = MD5(password);
 			updateUser.setString(3, password);
 			System.out.println(updateUser);
 			updateUser.executeUpdate();
 			session.setAttribute("user_updated", user_id);
 			response.sendRedirect("UpdateSuccessful.jsp");	
 		}
	}
	catch(Exception e) {
		out.println(e.toString());
	}
	return sErr;
}

String doSearch(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
	try {
		String name = request.getParameter("name");
		String username= request.getParameter("username");
		String ccno = request.getParameter("ccno");
		/*
		String sqlQuery = "select user_id, name, password, address, credit_card, level "+
						  "from users where name='"+name+"' OR username ='"+username+
						  "' OR credit_card = '"+ccno+"'";
		java.sql.ResultSet rs = stat.executeQuery(sqlQuery);
		*/
	      String sqlQuery12 = "select user_id, name, password, address, credit_card, level "+
				  "from users where name=? OR username =? OR credit_card =?"; 
	      //java.sql.ResultSet rs = stat.executeQuery(sqlQuery1);
	      //checkName = strConn.prepareStatement(sqlQuery1);
	      PreparedStatement checkUser = conn.prepareStatement(sqlQuery12);
	      checkUser.setString(1, name);
	      checkUser.setString(2, username);
	      checkUser.setString(3, ccno);
	      java.sql.ResultSet rs = checkUser.executeQuery();
		
		//this can return more than one users, if they have the same name.
		out.println("    <table style=\"\" border=1>\n");
	    while(rs.next()) {
			out.println("<tr>\n  <td>\n");
			//for every user, print a table and a form.
			out.println("  <table>");
			String name1=rs.getString("name");
			String user_id1=rs.getString("user_id");
			String password1=rs.getString("password");
			System.out.println("password: " + password1);
			password1 = MD5(password1);
			System.out.println("password: " + password1);
			String address1=rs.getString("address");
			String ccno1=rs.getString("credit_card");
			String level1=rs.getString("level");
			String radioInputCheckedlevel1="";
			String radioInputCheckedlevel2="";
			if(level1.equals("1"))
				radioInputCheckedlevel1="checked";
			else if(level1.equals("2"))
				radioInputCheckedlevel2="checked";
			out.println("The current values for the user are shown in the text fields<br>");
			out.println("Change them to new values and click on submit");
			out.println("<form action=\"ManageUsers.jsp\" method=\"post\">\n"+
						"<input type=\"hidden\" name=\"FormName\" value=\"modifyUser\">\n"+
						"<input type=\"hidden\" name=\"user_id\" value=\""+user_id1+"\">\n"+
					"<tr>\n"+
					"   <td> Change the user's password </td>"+ 
						"<td><input type=\"text\" name=\"password\" value=\""+password1+"\">\n"+
					"</tr>\n"+
					"<tr>\n"+
					"   <td> Change the user's address </td>"+ 
						"<td><input type=\"text\" name=\"address\" value=\""+address1+"\">\n"+
					"</tr>\n"+
					"<tr>\n"+
					"   <td> Change the user's CC No </td>"+ 
						"<td><input type=\"text\" name=\"ccno\" value=\""+ccno1+"\">\n"+
					"</tr>\n"+
					"<tr>\n"+
					"   <td> Set as Admin? </td>"+ 
					"<td><input type=\"radio\" name=\"userlevel\" value=\"yes\""+radioInputCheckedlevel2+">Yes\n"+
					"<td><input type=\"radio\" name=\"userlevel\" value=\"no\""+radioInputCheckedlevel1+">No\n"+
					"</tr>\n"+
					"   <td> Check Box to Delete User </td>"+ 
					"<td><input type=\"checkbox\" name=\"delete_user\" value=\"Delete\">\n"+
					"</tr>\n"+
					"<tr>\n"+
					"<td>Click to submit changes</td>"+
					"<td><input type=\"submit\" value=\"Submit\"></td>"+
					"</tr>"+
					
					"</form>\n");
			out.println("  </table>");
			out.println("  </td>\n</tr>\n");
			
		}
		out.println("</table>");
	}
	catch(Exception e) {
		out.print(e.toString());
	}
	String sErr="";
	out.println("Search Done");
	return sErr;
}

void showQueryTable(javax.servlet.jsp.JspWriter out) throws java.io.IOException { //search by user name. Search by name. Search by credit card.
	try {
		out.println("Search for a user by name, username, or credit card number");
		out.println("    <table style=\"\" border=1>");
	    out.println("     <tr>\n      <td style=\"background-color: #336699; text-align: Center; border-style: outset; border-width: 1\" colspan=\"2\"><font style=\"font-size: 12pt; color: #FFFFFF; font-weight: bold\">Enter login and password</font></td>\n     </tr>");

		  out.println("     <form action=\""+sFilename+"\" method=\"POST\">");
		  out.println("     <input type=\"hidden\" name=\"FormName\" value=\"searchUsers\">");
		  out.println(" <tr>\n"+      
		                    "<td>Name </td>"+
		                    "<td><input type=\"text\" name=\"name\" maxlength=\"50\"></td>\n"+         "</tr>");
		    out.println(" <tr>\n"+      
		            "<td>Username</td>"+
		            "<td><input type=\"text\" name=\"username\" maxlength=\"50\"></td>\n"+         "</tr>");
		    out.println(" <tr>\n"+      
		            "<td>Credit Card</td>"+
		            "<td><input type=\"text\" name=\"ccno\" maxlength=\"16\"></td>\n"+         "</tr>");
		    out.print("   <tr>\n"+
                    "<td><input type=\"submit\" value=\"Search\"></td>"+
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