<%@ include file="CommonStuff.jsp" %>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<%@ include file="Header.jsp"%>

<%
//create connection
//Assuming the user is already logged in. (Redirection to login page if user is not logged in in the next assignment.)
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
//check if we are logged in HERE?
String logInCheck = (String)session.getAttribute("user_id");
String referer = request.getHeader("referer"); //->http://localhost:8080/bookstore3/ShowBooks.jsp
//System.out.println(referer);
referer = referer.replace("http://localhost:8080/bookstore3/", "Login.jsp?returnPage=");
if(logInCheck == null) //redirect users that are not logged in
{
		session.setAttribute("workflow", "t");
		response.sendRedirect(referer);
}
stat = conn.createStatement();
String wTest = (String)session.getAttribute("workflow");
if(wTest.equals("t"))
{
	String ref = request.getHeader("referer");
	printSuccessfulMessage(conn, out, session, ref, response);
}
ProcessOrder(stat, conn, out, session, request, response);
%>


<%! //get parameters and send the insert query to the database.
void ProcessOrder(java.sql.Statement stat, java.sql.Connection conn, javax.servlet.jsp.JspWriter out, javax.servlet.http.HttpSession session,javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response) throws java.io.IOException {
	try {
		String ref = request.getHeader("referer");
		//the parameters are those from the input fields in the forms in ShowBooks:
		//quantity,
		//ISBN
		//the user_id is in the session object
		String quantity=request.getParameter("quantity");
		String ISBN = request.getParameter("ISBN");
		
		String user_id = (String)session.getAttribute("user_id");
		//String sqlQuery = "insert into orders(ISBN, user_id, quantity) values("+ISBN+", '"+user_id+"', "+quantity+");";
		String sqlQuery = "insert into orders(ISBN, user_id, quantity) values(?, ?, ?);";
		//out.println(sqlQuery);
		PreparedStatement stmt = conn.prepareStatement(sqlQuery);
		stmt.setString(1, ISBN);
		stmt.setString(2, user_id);
		stmt.setString(3, quantity);
		stmt.executeUpdate();
		//int count = stat.executeUpdate(sqlQuery);;
	    printSuccessfulMessage(conn, out, session, ref, response);
	}
	catch(Exception e) {
		out.println(e.toString());
	}
 }

void printSuccessfulMessage(java.sql.Connection conn, javax.servlet.jsp.JspWriter out, javax.servlet.http.HttpSession session, String ref, javax.servlet.http.HttpServletResponse response) throws java.io.IOException {
	//out.print("This is the referer: " + ref);
	//response.sendRedirect("Login.jsp?pageToSendTheUserToAfterLogin="+ref);
	String username=(String)session.getAttribute("username");//this was set at Login
	out.println("<p align = \"center\">" +username+"</p>");
	String user_id = (String)session.getAttribute("user_id");
	//give the user an overview of their shopping cart. Another way to do this without having to query the database is by recording the necessary information in a session.
	try {
		java.sql.Statement stat = conn.createStatement();
		String sqlQuery="Select image, quantity, price from books, orders where user_id=? AND orders.ISBN=books.ISBN;";
		PreparedStatement stmt = conn.prepareStatement(sqlQuery);
		stmt.setString(1, user_id);
		java.sql.ResultSet rs = stmt.executeQuery();

		//start writing table out:
		out.print("<table align=\"center\">\n"+
			"<thead>\n"+
			"	<tr>\n"+
			"		<td>Book Title</td>\n"+
			"		<td>Quantity</td>\n"+
			"		<td>Price</td>\n"+
			"	</tr>\n"+
			"	</thead>\n");
		float order_price=0;
		float total_price=0;
		while(rs.next()) { //print the orders table row by row for this user.
			String image_path = rs.getString("image");
			int quantity = rs.getInt("quantity");
			float price  = rs.getFloat("price");
			order_price = quantity*price; //the price of a single order
			total_price+=order_price;
			out.println("<tr>\n"+
					"<td><img src=\""+image_path+"\" style=\"height: 70px; width: 43px; \"></td>\n"+
					"<td>"+quantity+"</td>\n"+
					"<td>"+order_price+"</td>\n"+
				"</tr>\n");
		}
		out.println("<td colspan=\"2\"> Total Price</td><td>"+total_price+"</td>");
		out.print("<td><form action=\"Checkout.jsp\" method=\"post\">\n"+
				   "<input type=\"submit\" value=\"Checkout\"></form>\n"+
				"</td>");
		out.println("</table>");

		out.print("<p align=\"center\"><a href=\"ShowBooks.jsp\"> Click Here to Order More Books</a></p>");
	}
	catch(Exception e) {out.println(e.toString());}
}
 %>
			
</body>
</html>