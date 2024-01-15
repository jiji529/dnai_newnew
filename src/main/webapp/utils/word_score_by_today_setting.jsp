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
String pair_type = request.getParameter("pair_type");
String remove_check = request.getParameter("removeCheck");
long start = System.currentTimeMillis();
//article load
JSONArray article_data = db.article_content_data_return(user_seq, start_date, end_date);
//걸린시간 측정
long end = System.currentTimeMillis();
double timeTaken = (end - start) / 1000.0;
//현재 시간 디스플레이
SimpleDateFormat sdf = new SimpleDateFormat("");
java.util.Date time = new java.util.Date();
String time_string = sdf.format(time);
System.out.println(time_string+"오늘자 기사 불러오는데 걸린시간 : "+ timeTaken); 
//refine
JSONArray refine_data = r.refine_text_today(article_data);//refine_text(article_data);
//tfidf calculate 
JSONObject word_score = cal.calculate_today_article(refine_data);
//TOP 10
JSONArray TOP_keyword_list= db.member_word_score(user_seq, pair_type);
Set<String> words = new HashSet<String>();
int top10 = 0;
for(Object word : TOP_keyword_list) {
	JSONArray temp = (JSONArray) word;
	words.add(temp.get(1).toString());
	top10+=1;
	if(top10 == 10)
		break;
}
if(pair_type == "1"){ // 단어쌍
	for(Object obj : (JSONArray)word_score.get("word_pair")){
		JSONObject json = (JSONObject) obj;
		String word = json.get("word").toString();
		if(words.contains(word))
			json.put("accumulate", true);
		else
			json.put("accumulate", false);
	}
}else{
	for(Object obj : (JSONArray)word_score.get("word")){
		JSONObject json = (JSONObject) obj;
		String word = json.get("word").toString();
		if(words.contains(word))
			json.put("accumulate", true);
		else
			json.put("accumulate", false);
	}
}
//user_seq, pair_type
response.setContentType("application/json");
out.print(word_score);
%>  