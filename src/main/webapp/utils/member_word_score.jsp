<%@page import="java.text.DecimalFormat"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="connect.DB"%>

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>


<%
//주요 키워드 워드 스코어 리턴
DB db = new DB();
String user_seq = request.getParameter("user_seq");
String pair_type = request.getParameter("pair_type");
//user_seq, pair_type
JSONArray word_score = db.member_word_score(user_seq, pair_type);
response.setContentType("application/json");
out.print(word_score);
%>  