<%@page import="java.text.DecimalFormat"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="connect.DB"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
//주요 키워드 워드 스코어 리턴
DB db = new DB();
String user_seq = request.getParameter("user_seq");
String start_date = request.getParameter("start_date");
String end_date = request.getParameter("end_date");
String removeChecked = request.getParameter("removeChecked");
//user_seq, pair_type
JSONObject word_score = db.member_word_score_period_date_setting(user_seq, start_date, end_date, removeChecked);
response.setContentType("application/json");
out.print(word_score);
%>  