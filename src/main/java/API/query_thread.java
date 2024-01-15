package API;

import java.io.IOException;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.ParseException;
/**
 * 	긍부정 API를 통해 긍부정 워드클라우드를 보여주기 위한 조회 클래스. 
 * 
 * */
public class query_thread extends Thread{
	
	JSONArray article_data_with_sentiment = new JSONArray();
	JSONArray result_burket = new JSONArray();
	// 생성자 부분 
	/**
	 * @param article_data json array 형식, [ {title, content, sentiment},... ] 구성
	 * @param result_burket 긍부정 판별 결과를 담을 변수
	 * */
	public query_thread(JSONArray article_data, JSONArray result_burket) {
		this.article_data_with_sentiment = article_data;
		this.result_burket = result_burket;
	}
	
	public void run() {
		search_engine_query search_query = new search_engine_query();
		sentiment_check check = new sentiment_check();
		for(Object obj : article_data_with_sentiment) {
			JSONObject json = (JSONObject) obj;
			String title = json.get("news_title").toString();
			String contents = json.get("news_contents").toString();
			String article_serial = json.get("article_serial").toString();
			
			JSONObject result_json = new JSONObject();
			// 지면, 온라인 / 가공기사로 나누어 긍부정 판별
			// 
			if(article_serial.length() == 18 || article_serial.length() == 128) { //지면, 온라인
				JSONObject search_article = search_query.query_article_serial(article_serial);
				String sentiment = search_article.get("sentiment").toString();
				title = search_article.get("news_title").toString();
				contents = search_article.get("news_contents").toString();
				if(sentiment.equals("")) { // 검색엔진에 sentiment 값이 없을 경우
					try {
						sentiment = check.sentiment_return(title, contents);
					} catch (IOException | ParseException e) {
						e.printStackTrace();
					}
				}
				result_json.put("news_title", title);
				result_json.put("news_contents", contents);
				result_json.put("article_serial", article_serial);
				result_json.put("sentiment", sentiment);
			}else { //가공기사
				String sentiment = "0";
				try {
					sentiment = check.sentiment_return(title, contents);
				} catch (IOException | ParseException e) {
					e.printStackTrace();
				}
				result_json.put("news_title", title);
				result_json.put("news_contents", contents);
				result_json.put("article_serial", article_serial);
				result_json.put("sentiment", sentiment);
			}
			
			result_burket.add(result_json);
		}
		
	}
	
}
