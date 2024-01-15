<%@page import="java.text.SimpleDateFormat"%>
<%@page import="API.sentiment_check"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="text_processing.tfidf_calculate"%>
<%@page import="text_processing.refine"%>
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
refine r = new refine();
tfidf_calculate cal = new tfidf_calculate();
sentiment_check sc = new sentiment_check();

String user_seq = request.getParameter("user_seq");
System.out.println(user_seq);
String start_date = request.getParameter("start_date");
String end_date = request.getParameter("end_date");
long start = System.currentTimeMillis();
//article load
JSONArray article_data = db.article_content_data_return(user_seq, start_date, end_date);

JSONArray article_data_subList = new JSONArray();
if(article_data.size() > 50000){
	for(int i = 0; i < 50000; i++){
		article_data_subList.add((JSONObject) article_data.get(i));
	}
}else{
	article_data_subList = article_data; 
}

JSONArray articke_data_with_sentiment = sc.check(article_data_subList);

//걸린시간 측정
long end = System.currentTimeMillis();
double timeTaken = (end - start) / 1000.0;

// 현재 시간 디스플레이
SimpleDateFormat sdf = new SimpleDateFormat("");
java.util.Date time = new java.util.Date();
String time_string = sdf.format(time);
System.out.println(time_string+" 불러오는데 걸린시간 : "+ timeTaken); 

//refine
JSONArray refine_data = r.refine_text(articke_data_with_sentiment);
//tfidf calculate
JSONObject word_score = cal.calculate(refine_data);
//user_seq, pair_type
response.setContentType("application/json");
out.print(word_score);
%>  