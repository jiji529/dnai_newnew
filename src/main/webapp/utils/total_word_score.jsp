<%@page import="java.text.DecimalFormat"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="connect.DB"%>

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>


<%
DB db = new DB();
String pair_type = request.getParameter("pair_type");
String front = request.getParameter("front");
//System.out.println(text);
//instance.text_read_from_jsp(text);
JSONArray word_score = db.total_word_score(pair_type, front);
response.setContentType("application/json");
out.print(word_score);
%>  
