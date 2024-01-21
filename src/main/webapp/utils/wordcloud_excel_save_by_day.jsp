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
<%!
public void excel_save(String file_path, JSONArray word_score, String tab, String pair_type, String front){
	System.out.println("excel_save function");
	
}
%>

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

String tab = request.getParameter("tab");
String filename = request.getParameter("filename");
String removeCheck = request.getParameter("removeChecked");
String cal_date = request.getParameter("cal_date");
//오늘의 주요 키워드
if(tab.contains("오늘")){
	String pair_type = request.getParameter("pair_type");
	String front = request.getParameter("front");
	JSONArray word_score = db.total_word_score_by_day(pair_type, front, cal_date);
	String file_path = folder_path+filename+".xls";
	
	String front_text = "";
	if(front.equals("1"))
		front_text = "오늘의 주요 키워드";
	else
		front_text = "오늘의 신문 1면 주요키워드";
	
	String pair_type_text = "";
	if(pair_type.equals("0"))
		pair_type_text = "단일 단어";
	else
		pair_type_text = "단어 쌍";
	
	String date_text = filename.split("_")[1];
	/*BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(folder_path+filename), "euc-kr"));
	String csvString = "word,score\n";
	for(Object j : word_score){
		JSONArray word = (JSONArray) j;
		csvString += word.get(0)+","+word.get(1)+"\n";
	}
	writer.write(csvString);
	writer.flush();
	writer.close();*/
	//"C:\\Users\\tealight\\eclipse-workspace\\dev\\WebContent\\wordcloud_excel\\roqkffhwk.xls"
	
	//1차로 workbook을 생성
	HSSFWorkbook workbook=new HSSFWorkbook();
	//2차는 sheet생성
	HSSFSheet sheet=workbook.createSheet("wordcloud_"+date_text);
	//엑셀의 행 
	HSSFRow row=null;
	//엑셀의 셀 
	HSSFCell cell=null;
	sheet.addMergedRegion(new CellRangeAddress(0,0,0,5));
	row = sheet.createRow(0);
	cell = row.createCell(0);
	String day_text = date_text.substring(0,4)+"-"+date_text.substring(4,6)+"-"+date_text.substring(6,8);
	cell.setCellValue("("+day_text+") "+tab+" - "+front_text+" - "+pair_type_text);
	
	row = sheet.createRow(2);
	cell = row.createCell(0);
	cell.setCellValue("순위");

	cell = row.createCell(1);
	cell.setCellValue("단어");

	cell = row.createCell(2);
	cell.setCellValue("TF-IDF점수");
	
	
	
	for(int i = 0; i < word_score.size(); i++){
		JSONArray word = (JSONArray) word_score.get(i);
		row = sheet.createRow(i+3);
		cell = row.createCell(0);
		cell.setCellValue(i+1);
		for(int k = 0; k < word.size()-1; k++){
			cell = row.createCell(k+1);
			cell.setCellValue(word.get(k).toString());
		}
	}
	
	//셀 너비 지정
	sheet.setColumnWidth(1, 256*23);
	sheet.setColumnWidth(2, 256*10);
	
	File file = new File(file_path);
	FileOutputStream fileoutputstream=new FileOutputStream(file);
	//파일을 쓴다
	workbook.write(fileoutputstream);
	//필수로 닫아주어야함
	fileoutputstream.close();
	System.out.println("엑셀파일생성성공");
}
//프리미엄 키워드
else{
	String pair_type = request.getParameter("pair_type");
	String user_seq = request.getParameter("user_seq");
	String period = request.getParameter("period");
	String start_date = "";
	String end_date = "";
	JSONArray word_score;
	String period_text = "";
	if(period.equals("")){
		start_date = request.getParameter("start_date");
		end_date = request.getParameter("end_date");
		//누적 키워드
		if(start_date.equals("") && end_date.equals("")){
			word_score = db.member_word_score(user_seq, pair_type);
			period_text = "누적";
		}
		//기간 설정
		else{
			word_score = db.member_word_score_period_date_setting(user_seq, pair_type, start_date, end_date, removeCheck);
			period_text = start_date+"~"+end_date;
		}
	}else{
		//기간 (주간, 월간, 분기)
		word_score = db.member_word_score_period(user_seq, pair_type, period, removeCheck);
		
		if(period.equals("7"))
			period_text = "주간";
		else if(period.equals("30"))
			period_text = "월간";
		else
			period_text = "분기";
	}
	
	String file_path = folder_path+filename+".xls";
	//날짜
	String date_text = filename.split("_")[1];
	//단어쌍 여부
	String pair_type_text = "";
	if(pair_type.equals("0"))
		pair_type_text = "단일 단어";
	else
		pair_type_text = "단어 쌍";
	//1차로 workbook을 생성
	HSSFWorkbook workbook=new HSSFWorkbook();
	//2차는 sheet생성
	HSSFSheet sheet=workbook.createSheet("wordcloud_"+date_text);
	//엑셀의 행 
	HSSFRow row=null;
	//엑셀의 셀 
	HSSFCell cell=null;
	sheet.addMergedRegion(new CellRangeAddress(0,0,0,5));
	row = sheet.createRow(0);
	cell = row.createCell(0);
	String day_text = date_text.substring(0,4)+"-"+date_text.substring(4,6)+"-"+date_text.substring(6,8);
	cell.setCellValue("("+day_text+") "+tab+" - "+period_text+" - "+pair_type_text);
	
	row = sheet.createRow(2);
	cell = row.createCell(0);
	cell.setCellValue("순위");

	cell = row.createCell(1);
	cell.setCellValue("단어");

	cell = row.createCell(2);
	cell.setCellValue("TF-IDF점수");
	int len = 100;
	if(word_score.size() < 100)
		len = word_score.size();
	
	int word_max_length = 0;
	for(int i = 0; i < len; i++){
		JSONArray word = (JSONArray) word_score.get(i);
		row = sheet.createRow(i+3);
		cell = row.createCell(0);
		cell.setCellValue(i+1);
		if(period_text.equals("누적")){
			for(int k = 1; k < word.size()-1; k++){
				cell = row.createCell(k);
				cell.setCellValue(word.get(k).toString());
				if(k == 1){
					if(word_max_length < word.get(k+1).toString().length())
						word_max_length = word.get(k+1).toString().length();
				}
			}
		}else{
			for(int k = 0; k < word.size()-4; k++){
				cell = row.createCell(k+1);
				cell.setCellValue(word.get(k+1).toString());
				if(k == 0){
					if(word_max_length < word.get(k+1).toString().length())
						word_max_length = word.get(k+1).toString().length();
				}
			}	
		}
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
	
}

//response.setContentType("application/json");
out.print("done");
%>