<%@ include file="CommonStuff.jsp" %>

<%! //this is a declaration tag
static final String sFileName = "Login.jsp";
String sLoginErr = "";
%>

<%
session.setAttribute("workflow", "f");
boolean bDebug = false;

//we can get to Login.jsp in two ways. Either by typing in the URL in the browser's address bar or by 
//submitting the form to log in. In the first case, there are no HTTP parameters being sent. In the second case there are. FormName is used to distinguish between these two cases.
String sForm = request.getParameter("FormName"); 
if(sForm==null) //it will be null if we get to Login.jsp by typing the url in the address bar.
  sForm="";


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
if(sForm.equals("Login")) {
  sLoginErr = Login(request, response, session, out, sForm, conn, stat);
  if ( "sendRedirect".equals(sLoginErr)) return;
}

%>            
<html>
<head>
<title>Book Store</title>
</head>
<body>


<center>
 <table>
  <tr>
   
   <td valign="top">
<% ShowLoginTable(request, response, session, out, sLoginErr, sForm, conn, stat); %>
   </td>
  </tr>
 </table>


<%
if ( stat != null ) stat.close();
if ( conn != null ) conn.close();
%>
<%!

  String Login(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
    String sLoginErr = "";
    try {
      String sPassword = request.getParameter("Password");
      sPassword = MD5(sPassword);
      String sLogin = request.getParameter("Login");
      /*String sqlQuery = "select user_id, username, level from users where username ='" + sLogin + "' and password='" + sPassword+"'";
      java.sql.ResultSet rs = stat.executeQuery(sqlQuery);*/
      String sqlQuery1 = "select user_id, username, level from users where username =? and password=?";
      PreparedStatement Login = conn.prepareStatement(sqlQuery1);
      Login.setString(1, sLogin);
      Login.setString(2, sPassword);
      java.sql.ResultSet rs = Login.executeQuery();
      if ( rs.next() ) {
    	  String level="1";
            session.setAttribute("user_id", rs.getString(1));
            session.setAttribute("username", rs.getString(2));
            level = rs.getString(3);
            session.setAttribute("level",  level);
            try {
                 if ( stat != null ) stat.close();
                if ( conn != null ) conn.close();
            }
            catch ( java.sql.SQLException ignore ) {}
            if(level.equals("1"))
            	response.sendRedirect("ShowBooks.jsp");
            else if(level.equals("2"))
                	response.sendRedirect("Statistics.jsp");
            return "login_successful_I_did_a_sendRedirect";
      }
      else 
        sLoginErr = "Login or Password is incorrect.";
      rs.close();
    }
    catch (Exception e) { out.println(e.toString()); }
    return (sLoginErr);
  }

//this method shows the Login Form
  void ShowLoginTable(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
    try {  
    	//out.println("joko");
    	//out.println(session.getAttribute("user_id"));
    	
      String sSQL="";
      //String transitParams = "";
      //String sQueryString = request.getParameter("querystring");
      String sPage = request.getParameter("pageToSendTheUserToAfterLogin");
     out.println("sPage: "+ sPage);
      out.println("    <table style=\"\" border=1>");
      out.println("     <tr>\n      <td style=\"background-color: #336699; text-align: Center; border-style: outset; border-width: 1\" colspan=\"2\"><font style=\"font-size: 12pt; color: #FFFFFF; font-weight: bold\">Enter login and password</font></td>\n     </tr>");

      if ( sLoginErr.compareTo("") != 0 ) {
        out.println("     <tr>\n      <td colspan=\"2\" style=\"background-color: #FFFFFF; border-width: 1\"><font style=\"font-size: 10pt; color: #000000\">"+sLoginErr+"</font></td>\n     </tr>");
      }
      sLoginErr="";
      out.println("     <form action=\""+sFileName+"\" method=\"POST\">");
      out.println("     <input type=\"hidden\" name=\"FormName\" value=\"Login\">");
      if ( session.getAttribute("user_id") == null || ((String) session.getAttribute("user_id")).compareTo("") == 0 ) {
        // User did not login
        out.println(" <tr>\n"+      
                        "<td>Login</td>"+
                        "<td><input type=\"text\" name=\"Login\" maxlength=\"50\" value=\"\"></td>\n"+
                      "</tr>");
        out.println(" <tr>\n"+      
                        "<td>Password</td>"+
                        "<td><input type=\"text\" name=\"Password\" maxlength=\"50\"></td>\n"+         "</tr>");
        out.print("   <tr>\n"+
                        "<td><input type=\"submit\" value=\"Login\"></td>"+
                      "</form>"+ //the login form ends here. Now we do a signup form of just one button, in the next <td>
                      "<td><form action=\"Signup.jsp\" method=\"post\">"+
                      	  "<input type=\"submit\" value=\"Sign Up\">"+
                    	  "</form>"+ 
                      "</td>"+
                      "</tr>");
      }
      else {
        // User logged in
        //String getUserID(java.sql.Statement stat, String table, String fName, String where)
        //String sUserID = dLookUp( stat, "members", "member_login", "member_id =" + session.getAttribute("UserID"));
        //out.println("in ligin");
        java.sql.Connection conn1 = null;
        java.sql.Statement stat1 = null;
         String userID ="";
        try {
          conn1 = java.sql.DriverManager.getConnection(strConn , DBusername, DBpassword);
          stat1 = conn1.createStatement();
          String sqlQ = "SELECT user_id FROM users where user_id = '" + session.getAttribute("user_id")+"'";
          java.sql.ResultSet rsLookUp = stat.executeQuery(sqlQ);

         // openrs( stat1, "SELECT " + fName + " FROM " + table + " WHERE " + where);
          if (! rsLookUp.next()) {
            rsLookUp.close();
            stat1.close();
            conn1.close();
        }
          userID = rsLookUp.getString(1);
          rsLookUp.close();
          stat1.close();
          conn1.close();
          
        }
        catch (Exception e) { 
           out.println(e.toString());
        }
        out.println("    <table style=\"\" border=1>");
        out.println("     <tr>\n      <td style=\"background-color: #336699; text-align: Center; border-style: outset; border-width: 1\" colspan=\"2\"><font style=\"font-size: 12pt; color: #FFFFFF; font-weight: bold\">Enter login and password</font></td>\n     </tr>");
        sLoginErr="";
        out.println("     <form action=\"Logout.jsp\" method=\"POST\">");
        out.print(" <tr>"+
                      "<td>"+userID+"&nbsp;&nbsp;"+
                      "<input type=\"submit\" value=\"Logout\"/>");
        out.println("</td>\n     </form>\n     </tr>");
        out.println("    </table>");
      }

  

    }
    catch (Exception e) { out.println(e.toString()); }
  }
%>
</body>
</html>