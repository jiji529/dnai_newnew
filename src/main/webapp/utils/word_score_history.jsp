<%@page import="java.text.DecimalFormat"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="connect.DB"%>

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>


<%
//단어 추이선을 위한 단어 점수 기록 리턴
DB db = new DB();
String word_seq = request.getParameter("word_seq");
String user_seq = request.getParameter("user_seq");
//word_seq
JSONArray word_score = db.word_score_history(word_seq, user_seq);
response.setContentType("application/json");
out.print(word_score);
%>  