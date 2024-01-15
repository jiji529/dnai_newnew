<%@page import="java.text.DecimalFormat"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="connect.DB"%>
<%@page import="org.apache.commons.codec.binary.Base64" %>
<%@page import="java.io.*"%>
<%@page import="java.awt.image.*"%>
<%@page import="javax.imageio.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
request.setCharacterEncoding("utf-8");
String base64Str = request.getParameter("imgBase64");
String filename = request.getParameter("filename");
String replace_base64str = base64Str.replace("data:image/png;base64,","");

String path = request.getSession().getServletContext().getRealPath("");
String folder_path = path+"wordcloud_image/";

byte[] decodedBytes = Base64.decodeBase64(replace_base64str); //apache Base64
try {
		//System.out.println(replace_base64str);
		System.out.println(folder_path);
		if(new File(folder_path).exists()){
			System.out.println("folder exists");
		}else{
			new File(folder_path).mkdir();
		}
        BufferedImage bm = ImageIO.read(new ByteArrayInputStream(decodedBytes));
        //ImageIO.write(bm, "png", new File("/home/dnai/apache-tomcat-8.0.53/webapps/dnai/wordcloud_image/"+filename));
        ImageIO.write(bm, "png", new File(folder_path+filename));
    } catch (IOException e) {
        e.printStackTrace();
    }
%>