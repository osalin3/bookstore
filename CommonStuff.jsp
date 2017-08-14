<%@ page import="java.sql.PreparedStatement"%>
<%@ page import="java.sql.Connection"%>
<%! //this is a declaration tag
static final String DBDriver  ="com.mysql.jdbc.Driver";
static final String strConn   ="jdbc:mysql://localhost/bookstoreRigel";
static final String DBusername="root";
static final String DBpassword="sqlBASE";


public static String loadDriver () {
    String sErr = "";
    try {
      java.sql.DriverManager.registerDriver((java.sql.Driver)(Class.forName(DBDriver).newInstance()));
    }
    catch (Exception e) {
      sErr = e.toString();
    }
    return (sErr);
  }

java.sql.Connection connectToDB() throws java.sql.SQLException {
    return java.sql.DriverManager.getConnection(strConn , DBusername, DBpassword);
}
public static boolean isAlphaNumeric(String abc) //checks the password is valid
{
	int alpha = 0;
	int num = 0;
	char c;
	boolean returnVal = false;
	
	for(int i = 0; i < abc.length(); i++)
	{
		c = abc.charAt(i);
		if(Character.isAlphabetic(c))
		{
			alpha = 1;
			System.out.println("Digit @ " + i + " is alphabetic\n");
		}
		if(Character.isDigit(c))
		{
			num = 1;
			System.out.println("Digit @ " + i + " is a digit\n");
		}
	}
	if(alpha == 1 && num == 1)
	{
		returnVal = true;
		if(abc.length() < 8)
		{
			returnVal = false;
		}
	}
	return returnVal;
}
public String MD5(String md5) //Borrowed from: http://stackoverflow.com/questions/415953/how-can-i-generate-an-md5-hash
{
	   try {
	        java.security.MessageDigest md = java.security.MessageDigest.getInstance("MD5");
	        byte[] array = md.digest(md5.getBytes());
	        StringBuffer sb = new StringBuffer();
	        for (int i = 0; i < array.length; ++i) {
	          sb.append(Integer.toHexString((array[i] & 0xFF) | 0x100).substring(1,3));
	       }
	        return sb.toString();
	    } catch (java.security.NoSuchAlgorithmException e) {
	    }
	    return null;
}
%>