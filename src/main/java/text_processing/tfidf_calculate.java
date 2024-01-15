package text_processing;

import java.util.*;
import java.util.Map.Entry;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
// 앞서 만들어진 명사 리스트를 통해 단어 점수를 계산 및 반환
public class tfidf_calculate {
	// 단어 점수 계산 함수 (감성분석 API용)
	public JSONObject calculate(JSONArray refine_article_data) {
		JSONObject result = new JSONObject();
		JSONArray positive = new JSONArray();
		JSONArray negative = new JSONArray();
		
		
		tf_idf calculate = new tf_idf();
		// idf값을 담기 위해 문서별 단어 등장 횟수 카운트
		Map<String, Integer> idf_map_positive = new HashMap<String, Integer>();
		Map<String, Integer> idf_map_negative = new HashMap<String, Integer>();
		// tf값을 담기 위해 문서의 단어 등장 횟수 리스트 생성
		List<Map<String, Integer>> tf_map_list_positive = new ArrayList<Map<String, Integer>>();
		List<Map<String, Integer>> tf_map_list_negative = new ArrayList<Map<String, Integer>>();
				
		int positive_count = 0;
		int negative_count = 0;
		for(Object obj : refine_article_data) {
			JSONObject json = (JSONObject) obj;
			List<String> refine_news_title = (List<String>) json.get("refine_news_title");
			String sentiment = json.get("sentiment").toString();
			
			// positive count
			if(sentiment.equals("1")) {
				positive_count++;
				Set<String> for_idf = new HashSet<String>(refine_news_title);
				for(String word : for_idf) {
					if(idf_map_positive.containsKey(word)) {
						idf_map_positive.put(word, idf_map_positive.get(word)+1);
					}else {
						idf_map_positive.put(word, 1);
					}
				}
				
				Map<String, Integer> tf_positive = new HashMap<String, Integer>();
				for(String word : refine_news_title) {
					if(tf_positive.containsKey(word)) {
						tf_positive.put(word, tf_positive.get(word)+1);
					}else {
						tf_positive.put(word, 1);
					}
				}
				tf_map_list_positive.add(tf_positive);
			}
			
			// negative count
			if(sentiment.equals("-1")) {
				negative_count++;
				Set<String> for_idf = new HashSet<String>(refine_news_title);
				for(String word : for_idf) {
					if(idf_map_negative.containsKey(word)) {
						idf_map_negative.put(word, idf_map_negative.get(word)+1);
					}else {
						idf_map_negative.put(word, 1);
					}
				}
				
				Map<String, Integer> tf_negative = new HashMap<String, Integer>();
				for(String word : refine_news_title) {
					if(tf_negative.containsKey(word)) {
						tf_negative.put(word, tf_negative.get(word)+1);
					}else {
						tf_negative.put(word, 1);
					}
				}
				tf_map_list_negative.add(tf_negative);
			}
		}
		//단어별 점수 합산 - positive
		Map<String, Double> word_score_positive = new HashMap<String, Double>();
		for(Map<String, Integer> tf_map : tf_map_list_positive) {
			for(String word : tf_map.keySet()) {
				double score = calculate.tfIdf_2(tf_map, idf_map_positive, positive_count, word);
				score = (double)tf_map.get(word) * score;
				if(word_score_positive.containsKey(word)) {
					word_score_positive.put(word, word_score_positive.get(word)+score);
				}else {
					word_score_positive.put(word, score);
				}
			}
		}
		
		
		
		//단어별 점수 합산 - negative
		Map<String, Double> word_score_negative = new HashMap<String, Double>();
		for(Map<String, Integer> tf_map : tf_map_list_negative) {
			for(String word : tf_map.keySet()) {
				double score = calculate.tfIdf_2(tf_map, idf_map_negative, negative_count, word);
				score = (double)tf_map.get(word) * score;
				if(word_score_negative.containsKey(word)) {
					word_score_negative.put(word, word_score_negative.get(word)+score);
				}else {
					word_score_negative.put(word, score);
				}
			}
		}
		
		//내림차순 정렬
		//word_score 정렬
		// Map.Entry 리스트 작성
		List<Entry<String, Double>> list_entries = new ArrayList<Entry<String, Double>>(word_score_positive.entrySet());

		// 비교함수 Comparator를 사용하여 내림 차순으로 정렬
		Collections.sort(list_entries, new Comparator<Entry<String, Double>>() {
			// compare로 값을 비교
			public int compare(Entry<String, Double> obj1, Entry<String, Double> obj2)
			{
				// 내림 차순으로 정렬
				return obj2.getValue().compareTo(obj1.getValue());
			}
		});
		
		if(list_entries.size() > 100) {
			for(Entry<String, Double> e : list_entries.subList(0, 100)) {
				JSONObject json = new JSONObject();
				json.put("word", e.getKey());
				json.put("score", e.getValue());
				positive.add(json);
			}
		}
		else {
			for(Entry<String, Double> e : list_entries) {
				JSONObject json = new JSONObject();
				json.put("word", e.getKey());
				json.put("score", e.getValue());
				positive.add(json);
			}
		}
		
		
		//내림차순 정렬
		//word_score 정렬
		// Map.Entry 리스트 작성
		list_entries = new ArrayList<Entry<String, Double>>(word_score_negative.entrySet());

		// 비교함수 Comparator를 사용하여 내림 차순으로 정렬
		Collections.sort(list_entries, new Comparator<Entry<String, Double>>() {
			// compare로 값을 비교
			public int compare(Entry<String, Double> obj1, Entry<String, Double> obj2)
			{
				// 내림 차순으로 정렬
				return obj2.getValue().compareTo(obj1.getValue());
			}
		});
		
		if(list_entries.size() > 100) {
			for(Entry<String, Double> e : list_entries.subList(0, 100)) {
				JSONObject json = new JSONObject();
				json.put("word", e.getKey());
				json.put("score", e.getValue());
				negative.add(json);
			}
		}
		else {
			for(Entry<String, Double> e : list_entries) {
				JSONObject json = new JSONObject();
				json.put("word", e.getKey());
				json.put("score", e.getValue());
				negative.add(json);
			}
		}
		
		result.put("positive", positive);
		result.put("negative", negative);
		
		return result;
	}
	
	// 단어 점수 계산 함수 (오늘 스크랩 기사 분석 용)
	public JSONObject calculate_today_article(JSONArray refine_article_data) {
		JSONObject result = new JSONObject();
		JSONArray word_arr = new JSONArray();
		JSONArray word_pair_arr = new JSONArray();
		
		tf_idf calculate = new tf_idf();
		
		List<List<String>> title_list = new ArrayList<List<String>>();
		List<List<String>> title_pair_list = new ArrayList<List<String>>();
		
		for(Object obj : refine_article_data) {
			JSONObject json = (JSONObject) obj;
			List<String> refine_title = (List<String>) json.get("refine_news_title");
			title_list.add(refine_title);
			
			List<String> pair = new ArrayList<String>();
			for(int i = 0; i < refine_title.size()-1; i++) {
				pair.add(String.format("%s %s", refine_title.get(i),refine_title.get(i+1)));
			}
			title_pair_list.add(pair);
		}
		
		// 
		Map<String, Double> word_score = new HashMap<String, Double>();
		for(List<String> news_title_list : title_list) {
			for(String word : news_title_list) {
				double score = calculate.tfIdf(news_title_list, title_list, word);
				word_score.put(word, word_score.getOrDefault(word, 0.0)+score);
			}
		}
		//내림차순 정렬
		//word_score 정렬
		// Map.Entry 리스트 작성
		List<Entry<String, Double>> list_entries = new ArrayList<Entry<String, Double>>(word_score.entrySet());

		// 비교함수 Comparator를 사용하여 내림 차순으로 정렬
		Collections.sort(list_entries, new Comparator<Entry<String, Double>>() {
			// compare로 값을 비교
			public int compare(Entry<String, Double> obj1, Entry<String, Double> obj2)
			{
				// 내림 차순으로 정렬
				return obj2.getValue().compareTo(obj1.getValue());
			}
		});
		
		if(list_entries.size() > 100) {
			for(Entry<String, Double> e : list_entries.subList(0, 100)) {
				JSONObject json = new JSONObject();
				json.put("word", e.getKey());
				json.put("score", e.getValue());
				word_arr.add(json);
			}
		}
		else {
			for(Entry<String, Double> e : list_entries) {
				JSONObject json = new JSONObject();
				json.put("word", e.getKey());
				json.put("score", e.getValue());
				word_arr.add(json);
			}
		}
		
		
		
		//
		Map<String, Double> word_pair_score = new HashMap<String, Double>();
		for(List<String> news_title_pair_list : title_pair_list) {
			for(String word : news_title_pair_list) {
				double score = calculate.tfIdf(news_title_pair_list, title_pair_list, word);
				word_pair_score.put(word, word_pair_score.getOrDefault(word, 0.0)+score);
			}
		}
		
		//내림차순 정렬
		//word_score 정렬
		// Map.Entry 리스트 작성
		list_entries = new ArrayList<Entry<String, Double>>(word_pair_score.entrySet());

		// 비교함수 Comparator를 사용하여 내림 차순으로 정렬
		Collections.sort(list_entries, new Comparator<Entry<String, Double>>() {
			// compare로 값을 비교
			public int compare(Entry<String, Double> obj1, Entry<String, Double> obj2)
			{
				// 내림 차순으로 정렬
				return obj2.getValue().compareTo(obj1.getValue());
			}
		});
		
		if(list_entries.size() > 100) {
			for(Entry<String, Double> e : list_entries.subList(0, 100)) {
				JSONObject json = new JSONObject();
				json.put("word", e.getKey());
				json.put("score", e.getValue());
				word_pair_arr.add(json);
			}
		}
		else {
			for(Entry<String, Double> e : list_entries) {
				JSONObject json = new JSONObject();
				json.put("word", e.getKey());
				json.put("score", e.getValue());
				word_pair_arr.add(json);
			}
		}
		
		result.put("word", word_arr);
		result.put("word_pair", word_pair_arr);
		
		return result;
	}
	
}
