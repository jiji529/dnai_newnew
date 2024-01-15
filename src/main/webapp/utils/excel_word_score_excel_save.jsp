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
request.setCharacterEncoding("utf-8");

String tab = request.getParameter("tab");
String pair_type = request.getParameter("pair_type");
String user_seq = request.getParameter("user_seq");
String period = request.getParameter("period");

String filename = request.getParameter("filename");
String word_score_data = request.getParameter("word_score_data");
String start_date = request.getParameter("start_date");
String end_date = request.getParameter("end_date");
String today_string = request.getParameter("today_string");
String type = request.getParameter("type");

JSONParser parser = new JSONParser();
JSONObject word_score = (JSONObject) parser.parse(word_score_data);
String file_path = folder_path+filename+".xls";
//날짜
String date_text = filename.split("_")[1];
System.out.println(date_text);
//1차로 workbook을 생성
HSSFWorkbook workbook=new HSSFWorkbook();
//2차는 sheet생성
HSSFSheet sheet=workbook.createSheet("wordscore_today_"+date_text);
//엑셀의 행 
HSSFRow row=null;
//엑셀의 셀 
HSSFCell cell=null;
sheet.addMergedRegion(new CellRangeAddress(0,0,0,5));
row = sheet.createRow(0);
cell = row.createCell(0);
String day_text = today_string;

//기간 표시 (오늘~오늘)
String period_text = start_date+"~"+end_date;
// 단어쌍 여부 표시
String pair_type_text = "";
if(pair_type.equals("0"))
	pair_type_text = "단일 단어";
else
	pair_type_text = "단어 쌍";

//
String head = "("+day_text+") "+tab+" - "+period_text+" - "+pair_type_text;
cell.setCellValue(head);

row = sheet.createRow(2);
cell = row.createCell(0);
if(pair_type.equals("1"))
	cell.setCellValue("단어 쌍");
else
	cell.setCellValue("단일 단어");



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
if(pair_type.equals("1"))
	word_score_array = (JSONArray) word_score.get("word_pair");
else
	word_score_array = (JSONArray) word_score.get("word");

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