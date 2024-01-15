<%@page import="API.img_download"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@page import="java.io.File"%>
<%@page import="java.io.FileWriter"%>
<%@page import="java.io.FileReader"%>
<%@page import="java.io.IOException"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%

request.setCharacterEncoding("UTF-8");
System.out.println("call API");

img_download id = new img_download();
JSONObject result = new JSONObject();
result = id.result_return();
response.setContentType("application/json");
out.print(result.toJSONString().trim()); //
%>