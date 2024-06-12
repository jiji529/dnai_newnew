/*
 * date : 2020.06.16
 * 작성자 : 박지훈
 * 파일 이름 : DB.java
 * description : dnai 워드 클라우드 홈페이지를 띄우기 위한 디비 연결 클래스
 */

package connect;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.math.*;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import API.search_engine_query;
import API.sentiment_check;
import text_processing.refine;

public class DB {
	
	//dnai 워드 클라우드 홈페이지를 띄우기 위한 디비 연결 클래스
	//디비 연결할 주소, 아이디, 비번
	private String dictionary_url = "jdbc:mysql://222.231.4.92/scrap_analysis?useUnicode=true&characterEncoding=utf8&verifyServerCertificate=false&useSSL=false";
	private String dictionary_id = "hoonzinope";
	private String dictionary_password = "ekgkal4174@";
	// 시작 날짜가 없을 경우 시작기준날짜('2008-01-01') 부터 오늘날짜 까지 날짜 리스트를 반환
	private List<String> date_list() throws ParseException{
		final String DATE_PATTERN = "yyyy-MM-dd";
        String inputStartDate = "2008-01-01";
        Date now = new Date();
//        String inputEndDate = end_date;
        SimpleDateFormat sdf = new SimpleDateFormat(DATE_PATTERN);
        Date startDate = sdf.parse(inputStartDate);
        Date endDate = now;
        ArrayList<String> dates = new ArrayList<String>();
        Date currentDate = startDate;
        while (currentDate.compareTo(endDate) <= 0) {
            dates.add(sdf.format(currentDate));
            Calendar c = Calendar.getInstance();
            c.setTime(currentDate);
            c.add(Calendar.DAY_OF_MONTH, 1);
            currentDate = c.getTime();
        }
        
        return dates;
	}
	
	//특정 프리미엄 아이디의 날짜 구간을 받아오기 위함 -> 날짜별 단어 등장 점수의 가장 이전날짜와 현재까지로 
	private List<String> date_list(String user_seq) throws ParseException{
		final String DATE_PATTERN = "yyyy-MM-dd";
		//단어 최조 등장 날짜
        String inputStartDate = this.start_date(user_seq);
        Date now = new Date();
        SimpleDateFormat sdf = new SimpleDateFormat(DATE_PATTERN);
        Date startDate = sdf.parse(inputStartDate);
        Date endDate = now;
        ArrayList<String> dates = new ArrayList<String>();
        Date currentDate = startDate;
        while (currentDate.compareTo(endDate) <= 0) {
            dates.add(sdf.format(currentDate));
            Calendar c = Calendar.getInstance();
            c.setTime(currentDate);
            c.add(Calendar.DAY_OF_MONTH, 1);
            currentDate = c.getTime();
        }
        
        return dates;
	}
	
	//특정 프리미엄 아이디의 단어 최초 등장 날짜를 가져오기 위한 함수
	public String start_date(String user_seq) {
		
		String start_date = "";
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = "";
		
		try {
			Class.forName("com.mysql.jdbc.Driver");
			con = DriverManager.getConnection(this.dictionary_url, this.dictionary_id, this.dictionary_password);
			//단어 점수의 최초 등장 날짜를 보기 위한 쿼리
			sql = "SELECT date FROM daily_score JOIN word_dictionary ON daily_score.word_dictionary_seq = word_dictionary.seq WHERE word_dictionary.user_list_seq = ? ORDER BY date LIMIT 1"; //test - INTERVAL 1 DAY
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, user_seq);
			rs = pstmt.executeQuery();
			if(rs.next()) {
				start_date = rs.getString("date");
			}
			
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SQLException sqlexception) {
			try {
				con.close();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} catch(Exception e){
			try {
				con.close();
			} catch (Exception e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}finally {
			try {
				con.close();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		return start_date;
	}
	
	//범용 사전의 단어 점수중 현재 시점 기준 top100을 리턴하는 함수
	//파라미터로 단어/단어쌍 여부, 전체/1면 여부를 받아 리턴
	public JSONArray total_word_score(String pair_type, String front_type) {
		JSONArray result = new JSONArray();
		
		List<String> today_date_list = this.getTodayPeriod();
		String start_date = today_date_list.get(0);
		String end_date = today_date_list.get(1);
		
		//디비 연결 준비
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = "";
		
		try {

			Class.forName("com.mysql.jdbc.Driver");
			con = DriverManager.getConnection(this.dictionary_url, this.dictionary_id, this.dictionary_password);
			//total_word_dictionary에서 점수가 가장 높은 단어 100개를 리턴 //DATE_FORMAT(date, '%Y-%m-%d') = CURDATE()
			sql = "SELECT word, score, pair_type FROM common_daily_score WHERE pair_type = ? AND type = ? AND date BETWEEN ? AND ? ORDER BY score DESC LIMIT 150;"; //test - INTERVAL 1 DAY
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, pair_type);
			pstmt.setString(2, front_type);
			pstmt.setString(3, start_date);
			pstmt.setString(4, end_date);
			rs = pstmt.executeQuery();
			int limit_word_num = 1;
			
			while(rs.next()) {
				String word = rs.getString("word");
				if(this.isNumeric(word))
					continue;
				if(pair_type.equals("1")) {
					String token1 = word.split(" ")[0];
					String token2 = word.split(" ")[1];
					if(this.isNumeric(token1) && this.isNumeric(token2))
						continue;
				}
				JSONArray temp = new JSONArray();
				temp.add(word);
				temp.add(rs.getDouble("score"));
				temp.add(rs.getString("pair_type"));
				result.add(temp);
				if(limit_word_num == 100)
					break;
				limit_word_num+=1;
				
			}
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SQLException sqlexception) {
			try {
				con.close();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} catch(Exception e){
			try {
				con.close();
			} catch (Exception e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}finally {
			try {
				con.close();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		return result;
	}
	
	//범용 사전의 단어 점수중 현재 시점 기준 top100을 리턴하는 함수 -> 2022-04-28 추가
	//파라미터로 단어/단어쌍 여부, 전체/1면 여부를 전부? 리턴
	public JSONObject total_word_score() {
//		String pair_type = "0"; //"1"=pair
//		String front_type = "1"; //"1"=!1면 / "2"=1면
		
		JSONObject result = new JSONObject();
		result.put("today_word_score", this.total_word_score("0", "1"));
		result.put("today_word_score_pair", this.total_word_score("1", "1"));
		
		result.put("today_1_word_score", this.total_word_score("0", "2"));
		result.put("today_1_word_score_pair", this.total_word_score("1", "2"));
		
		return result;
	}
	
	//범용 사전의 단어 점수중 현재 시점 기준 top100을 리턴하는 함수
	//파라미터로 단어/단어쌍 여부, 전체/1면 여부를 받아 리턴
	public JSONArray total_word_score_by_day(String pair_type, String front_type, String sel_date) {
		JSONArray result = new JSONArray();
		
		String start_date = sel_date;
		String end_date = sel_date;
		
		//디비 연결 준비
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = "";
		
		try {

			Class.forName("com.mysql.jdbc.Driver");
			con = DriverManager.getConnection(this.dictionary_url, this.dictionary_id, this.dictionary_password);
			//total_word_dictionary에서 점수가 가장 높은 단어 100개를 리턴 //DATE_FORMAT(date, '%Y-%m-%d') = CURDATE()
			sql = "SELECT word, score, pair_type FROM common_daily_score WHERE pair_type = ? AND type = ? AND date BETWEEN ? AND ? ORDER BY score DESC LIMIT 150;"; //test - INTERVAL 1 DAY
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, pair_type);
			pstmt.setString(2, front_type);
			pstmt.setString(3, start_date);
			pstmt.setString(4, end_date);
			rs = pstmt.executeQuery();
			int limit_word_num = 1;
			
			while(rs.next()) {
				String word = rs.getString("word");
				if(this.isNumeric(word))
					continue;
				if(pair_type.equals("1")) {
					String token1 = word.split(" ")[0];
					String token2 = word.split(" ")[1];
					if(this.isNumeric(token1) && this.isNumeric(token2))
						continue;
				}
				JSONArray temp = new JSONArray();
				temp.add(word);
				temp.add(rs.getDouble("score"));
				temp.add(rs.getString("pair_type"));
				result.add(temp);
				if(limit_word_num == 100)
					break;
				limit_word_num+=1;
				
			}
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SQLException sqlexception) {
			try {
				con.close();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} catch(Exception e){
			try {
				con.close();
			} catch (Exception e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}finally {
			try {
				con.close();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		return result;
	}
	
	//범용 사전의 단어 점수중 현재 시점 기준 top100을 리턴하는 함수 -> 2022-04-28 추가
	//파라미터로 단어/단어쌍 여부, 전체/1면 여부를 전부? 리턴
	public JSONObject total_word_score_by_day(String sel_date) {
//		String pair_type = "0"; //"1"=pair
//		String front_type = "1"; //"1"=!1면 / "2"=1면
		
		JSONObject result = new JSONObject();
		result.put("today_word_score", this.total_word_score_by_day("0", "1",sel_date));
		result.put("today_word_score_pair", this.total_word_score_by_day("1", "1",sel_date));
		
		result.put("today_1_word_score", this.total_word_score_by_day("0", "2",sel_date));
		result.put("today_1_word_score_pair", this.total_word_score_by_day("1", "2",sel_date));
		
		return result;
	}	
	
	//업체별 단어 점수가 제일 높은 단어 100개를 리턴하는 함수
	//업체 키값과 단어/단어쌍 여부를 파라미터로 입력 받아 리턴
	public JSONArray member_word_score(String user_seq, String pair_type) {
		JSONArray result = new JSONArray();
		
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = "";

		JSONArray keyword_list = new JSONArray();
		
		try {
			Class.forName("com.mysql.jdbc.Driver");
			con = DriverManager.getConnection(this.dictionary_url, this.dictionary_id, this.dictionary_password);
			
			//업체별 단어 점수가 상위 100개를 리턴하는 함수
			sql = "SELECT seq, word, score, pair_type, active FROM word_dictionary WHERE user_list_seq = ? AND pair_type = ? AND active = 'Y' ORDER BY score DESC LIMIT 150";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, user_seq);
			pstmt.setString(2, pair_type);
			rs = pstmt.executeQuery();
			
			int limit_word_num = 1;
			while(rs.next()) {
				String word = rs.getString("word");
				if(this.isNumeric(word))
					continue;
				if(pair_type.equals("1")) {
					String token1 = word.split(" ")[0];
					String token2 = word.split(" ")[1];
					if(this.isNumeric(token1) && this.isNumeric(token2))
						continue;
				}
				JSONArray jsonArray = new JSONArray();
				jsonArray.add(rs.getString("seq"));
				jsonArray.add(rs.getString("word"));
				jsonArray.add(rs.getString("score"));
				jsonArray.add(rs.getString("pair_type"));
				
				result.add(jsonArray);
				
				if(limit_word_num == 100)
					break;
				limit_word_num+=1;
			}			
			
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SQLException sqlexception) {
			try {
				con.close();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} finally {
			try {
				con.close();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		
		
		return result;
	}
	
	//업체별 단어 점수가 제일 높은 단어 100개를 리턴하는 함수 -> 2022-04-28 추가
	//업체 키값을 입력받아서 단어/단어쌍 전부 리턴
	public JSONObject member_word_score(String user_seq) {
		JSONObject result = new JSONObject();
		result.put("total_member_word_score", this.member_word_score(user_seq, "0"));
		result.put("total_member_word_score_pair", this.member_word_score(user_seq, "1"));
		return result;
	}
	
	//업체별 기간동안 화제 였던 단어를 리턴하는 함수
	//업체 키값, 단어/단어쌍 여부, 기간을 파라미터로 받아 리턴
	//화제 단어를 검출하기 위해 해당 기간동안 높았던 단어중 누적 단어를 제외
	public JSONArray member_word_score_period(String user_seq, String pair_type, String period, String removeChecked) {
		// DATE_ADD(NOW(),INTERVAL - ? DAY ) 혹은 NOW()를 쓸 경우, '2024-01-01 00:00:00으로 기간이 다르기 때문에 값이 다르게 나옴'
		// 따라서 날짜조건을 워드클라우드와 동일하게 맞춰주기 위한 작업을 추가함
		LocalDate end_date = LocalDate.now();
		String end_date_string = end_date.toString();
		LocalDate start_date = end_date.minusDays(Integer.valueOf(period));
		String start_date_string = start_date.toString();		
		
		JSONArray result = new JSONArray();
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		String sql = "";
		
		JSONArray keyword_list = new JSONArray();
		JSONArray TOP_keyword_list= this.member_word_score(user_seq, pair_type);
		
		Set<String> words = new HashSet<String>();
		
//		if(removeChecked.equals("true")) {
		int top10 = 0;
		for(Object word : TOP_keyword_list) {
			JSONArray temp = (JSONArray) word;
			words.add(temp.get(1).toString());
			top10+=1;
			if(top10 == 10)
				break;
		}
//		}
		try {
			Class.forName("com.mysql.jdbc.Driver");
			con = DriverManager.getConnection(this.dictionary_url, this.dictionary_id, this.dictionary_password);
			
			//해당 기간중 점수가 높았던 단어를 뽑아내기 위한 쿼리
			sql = "SELECT word_dictionary_seq, SUM(daily_score.score) as total_score, word_dictionary.word " + 
					"FROM daily_score " + 
					"LEFT JOIN word_dictionary " + 
					"ON daily_score.word_dictionary_seq = word_dictionary.seq " + 
//					"WHERE date BETWEEN DATE_ADD(NOW(),INTERVAL - ? DAY ) AND NOW() " + 
					"WHERE date BETWEEN ? AND ? " + 
					"AND word_dictionary.user_list_seq = ? " + 
					"AND word_dictionary.active = 'Y' AND word_dictionary.pair_type = ? " + 
					"GROUP BY word_dictionary_seq ORDER BY total_score DESC LIMIT 300";
			
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, start_date_string);
			pstmt.setString(2, end_date_string);
//			pstmt.setString(1, period);
			pstmt.setString(3, user_seq);
			pstmt.setString(4, pair_type);
			rs = pstmt.executeQuery();
			
			//넉넉하게 300개 들고와서 누적 단어를 제외하고, 100개를 리턴
			if(removeChecked.equals("false")) {
				int cnt=0;
				while(rs.next()) {
					JSONArray jsonArray = new JSONArray();
					String temp_word = rs.getString("word");
					if(this.isNumeric(temp_word))
						continue;
					if(pair_type.equals("1")) {
						String token1 = temp_word.split(" ")[0];
						String token2 = temp_word.split(" ")[1];
						if(this.isNumeric(token1) && this.isNumeric(token2))
							continue;
					}
					
					if(!words.contains(temp_word)) {
						jsonArray.add(rs.getString("word_dictionary_seq"));
						jsonArray.add(temp_word);
						jsonArray.add(rs.getString("total_score"));
						jsonArray.add(pair_type);
						jsonArray.add("Y");
						jsonArray.add("누적단어아님");
						result.add(jsonArray);
						cnt += 1;
					}
					if(cnt == 100)
						break;
				}
			}
			else {
				int cnt=0;
				while(rs.next()) {
					JSONArray jsonArray = new JSONArray();
					String temp_word = rs.getString("word");
					if(this.isNumeric(temp_word))
						continue;
					if(pair_type.equals("1")) {
						String token1 = temp_word.split(" ")[0];
						String token2 = temp_word.split(" ")[1];
						if(this.isNumeric(token1) && this.isNumeric(token2))
							continue;
					}
					
					if(!words.contains(temp_word)) {
						jsonArray.add(rs.getString("word_dictionary_seq"));
						jsonArray.add(temp_word);
						jsonArray.add(rs.getString("total_score"));
						jsonArray.add(pair_type);
						jsonArray.add("Y");
						jsonArray.add("누적단어아님");
						result.add(jsonArray);
						cnt += 1;
					}else {
						jsonArray.add(rs.getString("word_dictionary_seq"));
						jsonArray.add(temp_word);
						jsonArray.add(rs.getString("total_score"));
						jsonArray.add(pair_type);
						jsonArray.add("Y");
						jsonArray.add("누적단어");
						result.add(jsonArray);
						cnt += 1;
					}
					
					if(cnt == 100)
						break;
				}
			}	
			
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SQLException sqlexception) {
			sqlexception.printStackTrace();
			System.out.println("error");
			try {
				con.close();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} finally {
			try {
				con.close();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		
		return result;
	}
	
	//업체별 기간 동안 화제 단어 리턴하는 함수 -> 2022-04-28 추가
	//업체 키값, 기간 파라미터
	public JSONObject member_word_score_period(String user_seq, String period, String removeChecked) {
		JSONObject result = new JSONObject();
		
		LocalDate end_date = LocalDate.now();
		String end_date_string = end_date.toString();
		LocalDate start_date = end_date.minusDays(Integer.valueOf(period));
		String start_date_string = start_date.toString();
		
		result.put("period_member_word_score", member_word_score_period_date_setting(user_seq, "0",start_date_string, end_date_string, removeChecked));
		result.put("period_member_word_score_pair", member_word_score_period_date_setting(user_seq, "1",start_date_string, end_date_string, removeChecked));
		return result;
	}
	
	
	//업체별 설정된 기간동안 화제였던 단어를 리턴하는 함수
	//업체 키값, 단어/단어쌍 여부, 기간을 파라미터로 받아 리턴
	//화제 단어를 검출하기 위해 해당 기간동안 높았던 단어중 누적 단어를 제외
	public JSONArray member_word_score_period_date_setting(String user_seq, String pair_type, String start_date, String end_date, String removeChecked) {
		JSONArray result = new JSONArray();
		
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		String sql = "";
		
		JSONArray keyword_list = new JSONArray();
		JSONArray TOP_keyword_list= this.member_word_score(user_seq, pair_type);
		
		Set<String> words = new HashSet<String>();
//		if(removeChecked.equals("true")) {
		int top10 = 0;
		for(Object word : TOP_keyword_list) {
			JSONArray temp = (JSONArray) word;
			words.add(temp.get(1).toString());
			top10+=1;
			if(top10 == 10)
				break;
		}
//		}
		
		try {
			Class.forName("com.mysql.jdbc.Driver");
			con = DriverManager.getConnection(this.dictionary_url, this.dictionary_id, this.dictionary_password);
			
			//해당 기간중 점수가 높았던 단어를 뽑아내기 위한 쿼리
			
			if(start_date.equals(end_date)) {
				sql = "SELECT word_dictionary_seq, SUM(daily_score.score) as total_score, word_dictionary.word " + 
						"FROM daily_score " + 
						"LEFT JOIN word_dictionary " + 
						"ON daily_score.word_dictionary_seq = word_dictionary.seq " + 
						"WHERE DATE(date) = ? " + 
						"AND word_dictionary.user_list_seq = ? " + 
						"AND word_dictionary.active = 'Y' AND word_dictionary.pair_type = ? " + 
						"GROUP BY word_dictionary_seq ORDER BY total_score DESC LIMIT 300";
				pstmt = con.prepareStatement(sql);
				pstmt.setString(1, start_date);
				pstmt.setString(2, user_seq);
				pstmt.setString(3, pair_type);
				
			}else {
				sql = "SELECT word_dictionary_seq, SUM(daily_score.score) as total_score, word_dictionary.word " + 
						"FROM daily_score " + 
						"LEFT JOIN word_dictionary " + 
						"ON daily_score.word_dictionary_seq = word_dictionary.seq " + 
						"WHERE date BETWEEN ? AND ? " + 
						"AND word_dictionary.user_list_seq = ? " + 
						"AND word_dictionary.active = 'Y' AND word_dictionary.pair_type = ? " + 
						"GROUP BY word_dictionary_seq ORDER BY total_score DESC LIMIT 300";
				pstmt = con.prepareStatement(sql);
				pstmt.setString(1, start_date);
				pstmt.setString(2, end_date);
				pstmt.setString(3, user_seq);
				pstmt.setString(4, pair_type);
			}
			
			
			
			
			rs = pstmt.executeQuery();
			//넉넉하게 300개 들고와서 누적 단어를 제외하고, 100개를 리턴
			if(removeChecked.equals("false")) {
				int cnt=0;
				while(rs.next()) {
					JSONArray jsonArray = new JSONArray();
					String temp_word = rs.getString("word");
					if(this.isNumeric(temp_word))
						continue;
					if(pair_type.equals("1")) {
						String token1 = temp_word.split(" ")[0];
						String token2 = temp_word.split(" ")[1];
						if(this.isNumeric(token1) && this.isNumeric(token2))
							continue;
					}
					
					if(!words.contains(temp_word)) {
						jsonArray.add(rs.getString("word_dictionary_seq"));
						jsonArray.add(temp_word);
						jsonArray.add(rs.getString("total_score"));
						jsonArray.add(pair_type);
						jsonArray.add("Y");
						jsonArray.add("누적단어아님");
						result.add(jsonArray);
						cnt += 1;
					}
					if(cnt == 100)
						break;
				}
			}
			else {
				int cnt=0;
				while(rs.next()) {
					JSONArray jsonArray = new JSONArray();
					String temp_word = rs.getString("word");
					if(this.isNumeric(temp_word))
						continue;
					if(pair_type.equals("1")) {
						String token1 = temp_word.split(" ")[0];
						String token2 = temp_word.split(" ")[1];
						if(this.isNumeric(token1) && this.isNumeric(token2))
							continue;
					}
					
					if(!words.contains(temp_word)) {
						jsonArray.add(rs.getString("word_dictionary_seq"));
						jsonArray.add(temp_word);
						jsonArray.add(rs.getString("total_score"));
						jsonArray.add(pair_type);
						jsonArray.add("Y");
						jsonArray.add("누적단어아님");
						result.add(jsonArray);
						cnt += 1;
					}else {
						jsonArray.add(rs.getString("word_dictionary_seq"));
						jsonArray.add(temp_word);
						jsonArray.add(rs.getString("total_score"));
						jsonArray.add(pair_type);
						jsonArray.add("Y");
						jsonArray.add("누적단어");
						result.add(jsonArray);
						cnt += 1;
					}
					if(cnt == 110)
						break;
				}
			}
			
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SQLException sqlexception) {
			sqlexception.printStackTrace();
			System.out.println("error");
			try {
				con.close();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} finally {
			try {
				con.close();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		
		
		return result;
	}
	
	public JSONObject member_word_score_period_date_setting(String user_seq, String start_date, String end_date, String removeChecked) {
		JSONObject result = new JSONObject();
		
		result.put("period_member_word_score", member_word_score_period_date_setting(user_seq, "0",start_date, end_date, removeChecked));
		result.put("period_member_word_score_pair", member_word_score_period_date_setting(user_seq, "1",start_date, end_date, removeChecked));
		
		return result;
	}
	
	
	//단어 키값을 통해 daily_score 테이블에서 날짜별 단어 점수를 반환
	public JSONArray word_score_history(String word_seq, String user_seq) {
		JSONArray result = new JSONArray();
		
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		String sql = "";
		
		JSONArray keyword_score_list = new JSONArray();
		
		try {
			Class.forName("com.mysql.jdbc.Driver");
			con = DriverManager.getConnection(this.dictionary_url, this.dictionary_id, this.dictionary_password);
			//해당 단어의 날짜별 점수 전체를 가지고 온다
			sql = "SELECT date, score FROM daily_score WHERE word_dictionary_seq = ?;";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, word_seq);
			rs = pstmt.executeQuery();
			Map<String, Double> score_map = new HashMap<String, Double>();
			while(rs.next()) {
				score_map.put(rs.getString("date"), rs.getDouble("score"));
			}
			
			//단어 추이선을 위한 날짜 기간을 설정
			List<String> date_list = this.date_list(user_seq);
			//단어가 등장하지 않은 날짜는 단어 점수 0으로 처리
			for(String day : date_list) {
				JSONArray rowArray = new JSONArray();
				if(!score_map.containsKey(day)) {
					rowArray.add(day);
					rowArray.add(0);
					result.add(rowArray);
				}else {
					rowArray.add(day);
					rowArray.add(score_map.get(day));
					result.add(rowArray);
				}
			}
			
			
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SQLException sqlexception) {
			try {
				con.close();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} catch(Exception e){
			try {
				con.close();
			} catch (Exception e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}finally {
			try {
				con.close();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		return result;
	}
	
	
	//sm3ID를 통해 premiumID를 가져온뒤 해당 아이디를 user_list table에서 검색해 키값을 들고오는 함수
	public JSONArray user_seq_return(String sm3ID) {
		JSONArray result = new JSONArray();
		//sm3ID를 프리미엄 아이디로 변환
		String premium_id = this.premium_id_return(sm3ID);
		
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		String sql = "";
		
		try {
			Class.forName("com.mysql.jdbc.Driver");
			con = DriverManager.getConnection(this.dictionary_url, this.dictionary_id, this.dictionary_password);
			//변환한 프리미엄 아이디를 user_list table에서 검색
			sql = "SELECT seq FROM user_list WHERE user_id = ?;";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, premium_id);
			rs = pstmt.executeQuery();
			
			if(rs.next()) {
				result.add(rs.getString("seq"));
			}
			
			
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SQLException sqlexception) {
			try {
				con.close();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} catch(Exception e){
			try {
				con.close();
			} catch (Exception e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}finally {
			try {
				con.close();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		return result;
	}
	
	//sm3ID를 통해 premiumID를 들고오기 위한 함수
	private String premium_id_return(String sm3ID) {
		String result = "";
		
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		String sql = "";
		
		//디비 주소, 아이디, 비번
		String url = "jdbc:mysql://222.231.4.2/sm3_service?useUnicode=true&characterEncoding=utf8&verifyServerCertificate=false&useSSL=false";;
		String id = "scrap_analysis";
		String pw = "tmzmfoqqnstjr@4174";
		
		try {
			Class.forName("com.mysql.jdbc.Driver");
			con = DriverManager.getConnection(url, id, pw);
			
			//멤버 테이블에서 프리미엄 아이디를 검색
			sql = "SELECT premiumID FROM premiumInfo WHERE sm3ID = ?;";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, sm3ID);
			rs = pstmt.executeQuery();
			
			if(rs.next()) {
				result= rs.getString("premiumID");
			}
			
			
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SQLException sqlexception) {
			try {
				con.close();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} catch(Exception e){
			try {
				con.close();
			} catch (Exception e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}finally {
			try {
				con.close();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		return result;
	}
	
	public boolean isNumeric(String s) {
		try {
		      Double.parseDouble(s);
		      return true;
		  } catch(NumberFormatException e) {
		      return false;
		  }
	}
	
	// 긍부정 키워드를 알기위해 해당 사용자의 프리미엄 기사 데이터를 가져오는 함수
	public JSONArray article_content_data_return(String user_seq, String start_date, String end_date) {
//		String sm3ID = this.getSM3ID(user_seq);
//		System.out.println("sm3ID : "+sm3ID);
//		String premiumID = this.premium_id_return(sm3ID);
		String premiumID = this.getSM3ID(user_seq);
		
		System.out.println("premiumID : "+premiumID);
		JSONArray result = new JSONArray();
		try {
			List<String> scrapBookNo = this.scrapBookNo_return(premiumID, start_date, end_date);
			System.out.println("scrapBookNo : "+scrapBookNo);
			result = this.news_return(premiumID, scrapBookNo);
			//System.out.println("news_contents : "+news_contents);
			//result = this.hnp_news_sp_contents_switch(news_contents);
			return result;
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return result;
	}
	
	// 프리미엄 아이디로  paper_management_+premiumID 접근
	// 특정 날짜의 scrapBookNo 가져오기
	public List<String> scrapBookNo_return(String premiumID, String start_date, String end_date) throws Exception {
		
		//스크랩북 넘버를 저장하기 위한 리스트 생서
		List<String> scrapNo = new ArrayList<String>();
		//프리미엄 아이디가 없는 문자거나, 길이가 0이거나, ""일때 없다고 리턴
		if(premiumID.equals("") || premiumID.length() == 0 || premiumID == null)
			return scrapNo;
		
		//디비 연결을 위한 사전 준비
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = "";
		
		// 아이디 군포의 경우 page_management가 없기때문에 에러 발생 -> 예외 처리
		if(premiumID.equals("gunpo"))
			return scrapNo;
		
		//연결할 주소, 계정, 비번 초기화
		String log_url = "jdbc:mysql://211.233.16.3/paper_management_"+premiumID+"?useUnicode=true&characterEncoding=utf8&verifyServerCertificate=false&useSSL=false";
		String log_id = "scrap_analysis";
		String log_password = "tmzmfoqqnstjr@4174";
		
		
		try {
			Class.forName("com.mysql.jdbc.Driver");

			con = DriverManager.getConnection(log_url, log_id, log_password);
			//해당 날짜의 스크랩북 넘버를 가져오기 위한 쿼리
			if(!start_date.equals(end_date)) {
				sql = "SELECT no FROM scrapBook WHERE newsMe NOT IN (2) AND scrapDate between ? and ?"; //AND newsMe = ?";
				pstmt = con.prepareStatement(sql);
				pstmt.setString(1, start_date);
				pstmt.setString(2, end_date);
				rs = pstmt.executeQuery();
			}
			else { // 만약 시작, 종료날짜가 동일하다면
				sql = "SELECT no FROM scrapBook WHERE newsMe NOT IN (2) AND scrapDate = ?";
				pstmt = con.prepareStatement(sql);
				pstmt.setString(1, start_date);
				rs = pstmt.executeQuery();
			}
			
			
			while(rs.next()) {
				scrapNo.add(rs.getString("no"));
			}

		} catch (Exception e) {
			
//					에러 발생시 해당 부분에서 문제가 생겼다는것을 알리기 위해
			e.printStackTrace();
			if(con != null) {
				try {
					con.close();
				} catch (Exception e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
					//닫다가 문제가 생길 경우~
					throw e1;
				}
			}
			//문제 발생시 해당 함수를 호출한 상위 함수에게로 익셉션을 던지기 위함
			throw e;
		}finally {
			if(con!= null) {
				try {
					con.close();
				} catch (Exception e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
					throw e;
				}
			}
		}
//				System.out.println(scrapNo);
		//스크랩북 리턴
		return scrapNo;
		
	}
	
	// scrapBookNo로 스크랩한 기사 가져오기
	// articleSerial, news_contents
	public JSONArray news_return(String premiumID, List<String> scrapBookNo) throws Exception {
		JSONArray result = new JSONArray();
		search_engine_query query = new search_engine_query();
		sentiment_check sc = new sentiment_check();
		if(scrapBookNo.size() == 0)
			return result;
		else {
			//디비 연결하기 위한 변수
			Connection con = null;
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			String sql = "";
			
			//디비 연결 주소, 계정, 비번 -> 프리미엄 사용자 데이터 베이스 접근
			String log_url = "jdbc:mysql://211.233.16.3:3306/paper_management_"+premiumID+"?useUnicode=true&characterEncoding=utf8&verifyServerCertificate=false&useSSL=false&validationQuery=\"select 1\"";
			String log_id = "scrap_analysis";
			String log_password = "tmzmfoqqnstjr@4174";
			
			try {
				Class.forName("com.mysql.jdbc.Driver");
				
				con = DriverManager.getConnection(log_url, log_id, log_password);
				// 위에서 가져온 스크랩북 숫자를 통해 제목을 반환하는 쿼리
				sql = "SELECT news_title, news_contents, article_serial FROM hnp_news WHERE scrapBookNo in ("+StringUtils.join(scrapBookNo,',')+") GROUP BY news_title"; //news_title, news_contents
				pstmt = con.prepareStatement(sql);
				rs = pstmt.executeQuery();
				
				while(rs.next()) {
					//article_total_count++;
					String article_serial = rs.getString("article_serial");
					String news_title = rs.getString("news_title").trim();
					String news_contents = rs.getString("news_contents").trim();
					String sentiment = "";
					JSONObject news = new JSONObject();
					
					news_contents = news_contents.replace("$r$n", "");
					JSONObject json = new JSONObject();
					json.put("article_serial", article_serial);
					json.put("news_contents", news_contents);
					json.put("news_title", news_title);
					//json.put("sentiment", sentiment);
					result.add(json);
				}
				if(!con.isClosed())
					con.close();
			} catch (Exception e) {

				e.printStackTrace();
				if(con != null) {
					try {
						con.close();
					} catch (Exception e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
						throw e1;
					}
				}
				throw e;
			}finally {
				if(con != null) {
					try {
						con.close();
					} catch (Exception e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
						throw e;
					}
				}
				
			}
		}
		
		return result;
	}
	
	// sp_contents 여부 검사 로직 필요
	// sp_contents 없을 경우, hnp_news.news_contents 그대로 이용
	public JSONArray hnp_news_sp_contents_switch(JSONArray hnp_news) throws Exception {
		JSONArray result = new JSONArray();
		
		//디비 연결하기 위한 준비
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = "";
		
		//디비연결에 필요한 주소, 계정, 비번
		String log_url = "jdbc:mysql://222.231.4.32/sm3_article?useUnicode=true&characterEncoding=utf8&verifyServerCertificate=false&useSSL=false";
		String log_id = "article_reader";
		String log_password = "rltkdlfrrl@4174";
		
		for(Object obj : hnp_news) {
			JSONObject json = (JSONObject) obj;
			JSONObject result_json = new JSONObject();
			
			String article_serial = json.get("article_serial").toString();
			String news_contents = json.get("news_contents").toString();
			String news_title = json.get("news_title").toString();
			if(article_serial.length() < 19) {
				try {
					Class.forName("com.mysql.jdbc.Driver");
	
					con = DriverManager.getConnection(log_url, log_id, log_password);
					//위에서 반환된 시리얼 번호를 통해 해당 기사를 전부 가져오는 쿼리
					sql = "SELECT sp_content FROM xml_article_sp_content WHERE article_serial = ?";
					pstmt = con.prepareStatement(sql);
					pstmt.setString(1, article_serial);
					rs = pstmt.executeQuery();
					
					while(rs.next()) {
						news_contents = rs.getString("sp_content");
					}
	
				} catch (Exception e) {
					e.printStackTrace();
					if(con != null) {
						try {
							con.close();
						} catch (Exception e1) {
							// TODO Auto-generated catch block
							e1.printStackTrace();
							throw e1;
						}
					}
					throw e;
	
				}finally {
	
					try {
						con.close();
					} catch (Exception e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				}
			}
			
			news_contents = news_contents.replace("$r$n$r$n", "");
			result_json.put("article_serial", article_serial);
			result_json.put("news_contents", news_contents);
			result_json.put("news_title", news_title);
			result.add(result_json);
		}
		
		return result;
	}
	
	// 정제시 필요한 reject_word를 가져오기
	public List<String> reject_words_return(){
		List<String> reject_words = new ArrayList<String>();
		
		//디비에 연결할 준비
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		String sql = "";
		
		//디비에 연결할 주소, 아이디, 비번
		String company_url = "jdbc:mysql://222.231.4.92/scrap_analysis?useUnicode=true&characterEncoding=utf8&verifyServerCertificate=false&useSSL=false";
		String company_id = "hoonzinope";
		String company_password = "ekgkal4174@";
		
		try {
			Class.forName("com.mysql.jdbc.Driver");
			con = DriverManager.getConnection(company_url, company_id, company_password);
			sql = "SELECT word FROM reject_dictionary WHERE type =  0";
			pstmt = con.prepareStatement(sql);
			rs = pstmt.executeQuery();
			while(rs.next()) {
				reject_words.add(rs.getString("word"));
			}
			con.close();
		} catch (SQLException | ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			try {
				if(!con.isClosed())
					con.close();
			} catch (SQLException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
		
		return reject_words;
	}
	
	//user_id 반환을 위함
	public String getSM3ID(String user_seq) {
		String user_id = "";
		
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		String sql = "";
		
		//디비 주소, 아이디, 비번
		String url = "jdbc:mysql://222.231.4.92/scrap_analysis?useUnicode=true&characterEncoding=utf8&verifyServerCertificate=false&useSSL=false";;
		String id = "hoonzinope";
		String pw = "ekgkal4174@";
		
		try {
			Class.forName("com.mysql.jdbc.Driver");
			con = DriverManager.getConnection(url, id, pw);
			
			//멤버 테이블에서 프리미엄 아이디를 검색
			sql = "SELECT user_id FROM user_list WHERE seq = ?;";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, user_seq);
			rs = pstmt.executeQuery();
			
			if(rs.next()) {
				user_id= rs.getString("user_id");
			}
			
			if(!con.isClosed())
				con.close();
			return user_id;
			
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SQLException sqlexception) {
			try {
				con.close();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} catch(Exception e){
			try {
				con.close();
			} catch (Exception e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}finally {
			try {
				con.close();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		return user_id;
	}
	
	// 오늘날짜 - 어제날짜 반환 (ex. 2022-04-28 / 2022-04-29) 
	public List<String> getTodayPeriod(){
		LocalDate currentDate = LocalDate.now();
		String start_date = currentDate.toString();
		currentDate = currentDate.plusDays(1);
		String end_date = currentDate.toString();
		
		List<String> result = new ArrayList<String>(Arrays.asList(start_date, end_date));
		return result;
	}
	
	public static void main(String[] args) {
		DB db = new DB();
		refine r = new refine();
//		System.out.println(db.user_seq_return("geochang"));
//		System.out.println(db.isNumeric("26 27"));
		//System.out.println(db.member_word_score("123", "0"));
//		System.out.println(db.getTodayPeriod());
		String user_seq = "9";
		String start_date = "2023-02-23";
		String end_date = "2023-02-23";
		JSONArray article_data = db.article_content_data_return(user_seq, start_date, end_date);
		JSONArray refine_data = r.refine_text_today(article_data);
		System.out.println(refine_data);
	}
}
