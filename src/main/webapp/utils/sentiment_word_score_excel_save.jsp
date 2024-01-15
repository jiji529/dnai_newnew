<%@page import="org.json.simple.parser.JSONParser"%>
<%@page import="org.apache.poi.ss.util.CellRangeAddress"%>
<%@page import="org.apache.poi.ss.usermodel.Workbook"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="connect.DB"%>
<%@page import="org.apache.commons.codec.binary.Base64" %>
<%@page import="java.io.*"%>
<%@page import="java.awt.image.*"%>
<%@page import="javax.imageio.*"%>
<%@page import="connect.DB"%>
<%@page import="org.apache.poi.hssf.usermodel.HSSFWorkbook"%>
<%@page import="org.apache.poi.hssf.usermodel.HSSFSheet"%>
<%@page import="org.apache.poi.hssf.usermodel.HSSFRow"%>
<%@page import="org.apache.poi.hssf.usermodel.HSSFCell"%>
<%@page import="org.apache.commons.lang3.math.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
DB db = new DB();
//String folder_path = "/home/dnai/apache-tomcat-8.0.53/webapps/dnai/wordcloud_excel/";
String path = request.getSession().getServletContext().getRealPath("");
String folder_path = path+"wordcloud_excel/";
//String folder_path = "C:\\Users\\tealight\\eclipse-workspace\\dev\\WebContent\\wordcloud_excel\\";
if(!new File(folder_path).exists()){
	new File(folder_path).mkdir();
}
request.setCharacterEncoding("utf-8");

String filename = request.getParameter("filename");
String word_score_data = request.getParameter("word_score_data");
String start_date = request.getParameter("start_date");
String end_date = request.getParameter("end_date");
String type = request.getParameter("type");

JSONParser parser = new JSONParser();
JSONObject word_score = (JSONObject) parser.parse(word_score_data);
String period_text = "";


String file_path = folder_path+filename+".xls";
//날짜
String date_text = filename.split("_")[1];

//1차로 workbook을 생성
HSSFWorkbook workbook=new HSSFWorkbook();
//2차는 sheet생성
HSSFSheet sheet=workbook.createSheet("wordscore_sentiment_"+date_text);
//엑셀의 행 
HSSFRow row=null;
//엑셀의 셀 
HSSFCell cell=null;
sheet.addMergedRegion(new CellRangeAddress(0,0,0,5));
row = sheet.createRow(0);
cell = row.createCell(0);
String day_text = date_text.substring(0,4)+"-"+date_text.substring(4,6)+"-"+date_text.substring(6,8);
cell.setCellValue("긍/부정 단어 점수 엑셀표");

row = sheet.createRow(2);
cell = row.createCell(0);
if(type.equals("1"))
	cell.setCellValue("긍정");
else
	cell.setCellValue("부정");

row = sheet.createRow(3);
cell = row.createCell(0);
cell.setCellValue("순위");

cell = row.createCell(1);
cell.setCellValue("단어");

cell = row.createCell(2);
cell.setCellValue("TF-IDF점수");

int word_max_length = 0;

int row_num = 4;
JSONArray word_score_array = new JSONArray();
if(type.equals("1"))
	word_score_array = (JSONArray) word_score.get("positive");
else
	word_score_array = (JSONArray) word_score.get("negative");

for(int i = 0; i < word_score_array.size(); i++){
	JSONObject json = (JSONObject) word_score_array.get(i);
	String word = json.get("word").toString();
	double score = (double) json.get("score");
	score = Math.round(score*100)/100.0;
	
	if(word.length() > word_max_length){
		word_max_length = word.length();
	}
	
	row = sheet.createRow(row_num);
	cell = row.createCell(0);
	cell.setCellValue(i+1);
	
	cell = row.createCell(1);
	cell.setCellValue(word);
	
	cell = row.createCell(2);
	cell.setCellValue(score);
	row_num++;
}


//셀 너비 지정
sheet.setColumnWidth(1, 256*word_max_length*2);
sheet.setColumnWidth(2, 256*10);

File file = new File(file_path);
FileOutputStream fileoutputstream=new FileOutputStream(file);
//파일을 쓴다
workbook.write(fileoutputstream);
//필수로 닫아주어야함
fileoutputstream.close();
System.out.println("엑셀파일생성성공");

//response.setContentType("application/json");
out.print("done");
%>