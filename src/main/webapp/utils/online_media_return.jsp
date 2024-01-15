<%@page import="org.json.simple.JSONObject"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="connect.*"%>

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>


<%
//주요 키워드 워드 스코어 리턴
media_return mr = new media_return();
//user_seq, pair_type
JSONObject online_media_list = mr.online_media_list_return();
response.setContentType("application/json");
out.print(online_media_list);
%>  