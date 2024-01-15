package text_processing;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.lucene.analysis.ko.morph.MorphException;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import connect.DB;
import kr.co.shineware.nlp.komoran.core.analyzer.Komoran;
import kr.co.shineware.util.common.model.Pair;
import text_processing.ArirangAnalyzerHandler;

public class refine {
	
	//local
	private String komoran_model_path = "C:\\Users\\tealight\\Desktop\\hoonzi\\model_path\\";
	private String komoran_user_dictionary = komoran_model_path+"dic.user";
	//server
	// 형태소 분석기 서버 위치 (로컬 테스트 시 위 로컬 부분의 경로를 바꿔줘야함)
//	public static String komoran_model_path = "/home/dnai/model_path";
//	public static String komoran_user_dictionary = "/home/dnai/word2vec/dic.user";
	
	// "/", "&", "·" 을 제거하기 위한 함수
	//앞이나 뒤에 붙어있을 경우 해당 한 글자만을 제거하는 함수
	private String sign_reject(String str) {
		String result = "";
		
		//앞에 "/", "&"이 붙어 있을 경우 제거
		if(str.startsWith("/") || str.startsWith("&"))
			str = str.substring(1, str.length());
		
		//뒤에 "/","&"이 붙어 있을 경우 제거
		if(str.endsWith("/") || str.endsWith("&"))
			str = str.substring(0, str.length()-1);
		
		//결과 리턴
		result = new String(str);
		return result;
	}
	
	// 전처리시 기호 제거 함수
	public String clean_title(String title) {
		String clean_title = "";
		clean_title = title.replace("…", " ");
		clean_title = clean_title.replace("'", "");
		clean_title = clean_title.replaceAll("[^a-zA-Z0-9가-힣&/%·]", " ").replaceAll(" +", " ").toLowerCase();
		return clean_title;
	}
	
	// 스트링 숫자값을 숫자형 변수로 변환
	public boolean isNumeric(String s) {
		try {
		      Double.parseDouble(s);
		      return true;
		  } catch(NumberFormatException e) {
		      return false;
		  }
	}
	
	// 긍부정 워드 클라우드를 만들기 위한 형태소 분석 총괄 함수
	public JSONArray refine_text(JSONArray article_data) {
		JSONArray result = new JSONArray();
		
		JSONArray refine_article_title;
		try {
			refine_article_title = this.arirang_refine(article_data);
			result = this.komoran_refine(refine_article_title);
		} catch (MorphException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return result;
	}
	
	//당일치 계산을 위한 형태소 분석 총괄 함수
	public JSONArray refine_text_today(JSONArray article_data) {
		JSONArray result = new JSONArray();
		
		JSONArray refine_article_title;
		
		try {
			refine_article_title = this.arirang_refine(article_data);
			result = this.komoran_refine_prev(refine_article_title);
		} catch (MorphException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return result;
	}
	
	// 아리랑 형태소 분석기를 이용해 제목만 형태소 분석 실시
	// 긍부정 워드클라우드로 보여주기 위한 긍부정 값도 같이 결과로 저장
	public JSONArray arirang_refine(JSONArray article_data) throws MorphException {
		JSONArray result = new JSONArray();
		ArirangAnalyzerHandler arirang = new ArirangAnalyzerHandler();
		DB db = new DB();
		List<String> reject_words = db.reject_words_return();
		for(Object obj : article_data) {
			JSONObject json =  (JSONObject) obj;
			JSONObject result_json = new JSONObject();
			
			String news_title = json.get("news_title").toString();
			
			news_title = this.clean_title(news_title);
//			if(reject_words.contains(news_title))
//				continue;
			
			for(String reject_word : reject_words) {
				if(news_title.contains(reject_word))
					news_title = news_title.replace(reject_word, "");
			}
			
			for(String eojeol : news_title.split(" ")) {
				for(String reject_word : reject_words) {
					if(eojeol.contains(reject_word)) {
						news_title = news_title.replace(eojeol, "");
					}
				}
			}
			
			if(news_title.equals(""))
				continue;
			if(news_title.split(" ").length < 2)
				continue;
			
			List<String> news_title_arirang = arirang.extractNoun(news_title);
			result_json.put("refine_news_title", news_title_arirang);
			
			if(json.containsKey("sentiment")) {
				String sentiment = json.get("sentiment").toString();
				result_json.put("sentiment", sentiment);
			}
			result.add(result_json);
		}
		
		
		return result;
	}
	// 코모란 형태소 분석기를 이용해 제목만 형태소 분석 실시
	// 긍부정 워드클라우드로 보여주기 위한 긍부정 값도 같이 결과로 저장
	public JSONArray komoran_refine(JSONArray article_data) {
		JSONArray result = new JSONArray();
		
		DB db = new DB();
		//코모란 품사 테이블 참조 -> https://docs.komoran.kr/firststep/postypes.html 
		Set<String> tag = new HashSet<String>(Arrays.asList("VV","MM","MAJ","IC",//,"NNB",
				"JKS","JKC","JKG","JKO","JKB","JKV","JKQ","JX","JC","VCP","EC","ETN","VX",
				"NP","MAG","EP","EF","ETM","XPN","XSN","XSV","XSA","XR","VCP","SS","SF","SE","SO"));
		//VCP, ETM => 준비 중인 / 준비 중 이(VCP) ㄴ(ETM) 으로 분해
		//EC => 대여 => 대 이(VCP) 어(EC) 로 분해
		//ETN => 의료기기 => 의료기 이 기(ETN) 로 분해
		//VV => 이게 => 이(VV) 게 로 분해
		//XSN  => 전임이들이 => 전임 이 들(XSN) 이
		//NNB -> 의존명사 라서 제외 -> 것 
		Set<String> tag_giho = new HashSet<String>(Arrays.asList("SF","SP","SS","SE","SO"));//,"SW"));
		//komoran
		Komoran komoran = new Komoran(this.komoran_model_path);
		komoran.setUserDic(this.komoran_user_dictionary);
		List<String> reject_words = db.reject_words_return();
		
		
		for(Object obj : article_data) {
			JSONObject json = (JSONObject) obj;
			JSONObject result_json = new JSONObject();
			
//			String sentiment = json.get("sentiment").toString();
			List<String> refine_news_title = (List<String>) json.get("refine_news_title");
			
			List<String> news_title_komoran = new ArrayList<String>();
			
			for(String word : refine_news_title) {
				if(reject_words.contains(word)){
					continue;
				}
				
				//단어중 명사가 아닌부분을 덜어내기
				List<String> temp_word_list = new ArrayList<String>();
				List<List<Pair<String,String>>> komoran_result = komoran.analyze(word);//title.get(0).toString());//word
//						String modi_line = new String(word);
				for (List<Pair<String, String>> eojeolResult : komoran_result) {
					List<Pair<String, String>> eojeolResult_copy = new ArrayList<Pair<String, String>>(eojeolResult);
					for (Pair<String, String> wordMorph : eojeolResult) {
						if(tag.contains(wordMorph.getSecond())) {// && wordMorph.getFirst().length() >= 2)
							//word = word.replace(wordMorph.getFirst(), "");
							int index = eojeolResult_copy.indexOf(wordMorph);
							
							String prev_morph = "";
							String next_morph = "";
							if(index - 1 <= 0)
								prev_morph = eojeolResult_copy.get(0).getSecond();
							else
								prev_morph = eojeolResult_copy.get(index-1).getSecond();
							
							if(index+1 >= eojeolResult_copy.size()-1)
								next_morph = eojeolResult_copy.get(eojeolResult_copy.size()-1).getSecond();
							else
								next_morph = eojeolResult_copy.get(index+1).getSecond();
							
							if(!tag.contains(prev_morph) && !tag.contains(next_morph))
								continue;
							else
								eojeolResult_copy.remove(index);
						}
					}
					
					String token = "";
					for (Pair<String, String> wordMorph : eojeolResult_copy) {
						
						if(reject_words.contains(wordMorph.getFirst()) && eojeolResult_copy.size() == 1) {
							continue;
						}
						
						if(reject_words.contains(wordMorph.getFirst())){
							continue;
						}
						
						//한글자이고, 기호일 경우 포함 시키지 않는다.
						if(wordMorph.getFirst().length() == 1 && tag_giho.contains(wordMorph.getSecond())) {
							continue;
						}
						//숫자 다음의 한글이 오면 떨어트리지 않고 붙힌다. => 공백을 없앤다.
						else if(this.isNumeric(wordMorph.getFirst())) {
							int index = eojeolResult_copy.indexOf(wordMorph);
							if(index <= eojeolResult_copy.size()-2) {
								if(!this.isNumeric(eojeolResult_copy.get(index+1).getFirst()))
									token+= wordMorph.getFirst();//+"("+wordMorph.getSecond()+")";
							}
							else
								token+=wordMorph.getFirst()+" ";//+"("+wordMorph.getSecond()+")"+" ";
						}
						//수사라면 앞에 숫자인지 판단 혹은 뒤가 의존명사인지 판단
						else if(wordMorph.getSecond().equals("NR")) {
							int index = eojeolResult_copy.indexOf(wordMorph);
							if(index <= eojeolResult_copy.size()-2 && index > 0) {
								if(eojeolResult_copy.get(index+1).getSecond().equals("NNB")) {
									token+= wordMorph.getFirst();//+"("+wordMorph.getSecond()+")";
								}else if(eojeolResult_copy.get(index-1).getSecond().equals("SN")) {
									token+= wordMorph.getFirst();//+"("+wordMorph.getSecond()+")";
								}
								else {
									continue;
								}
							}
							else
								token+= wordMorph.getFirst()+" ";//+"("+wordMorph.getSecond()+")"+" ";
						}
						//NNB 인경우, 앞에 숫자나 수사가 아니라면 제거
						else if(wordMorph.getSecond().equals("NNB")) {
							int index = eojeolResult_copy.indexOf(wordMorph);
							if(index <= 0)
								token+= " ";
							else {
								if(eojeolResult_copy.get(index-1).getSecond().equals("SN") || eojeolResult_copy.get(index-1).getSecond().equals("NR")) {
									token+=wordMorph.getFirst()+" ";//+"("+wordMorph.getSecond()+")"+" ";
								}else {
									token+=" ";
								}
							}
						}
						else {
							if(wordMorph.getFirst().length() < 2)
								continue;
//							if(isNumeric(wordMorph.getFirst()))
//								continue;
							token+=wordMorph.getFirst()+" ";//+"("+wordMorph.getSecond()+")"+" ";
						}
					}
					List<String> tokens = new ArrayList<String>(Arrays.asList(token.split(" ")));
					List<String> modi_tokens = new ArrayList<String>(tokens);
					for(String t: tokens) {
						if(t.length() < 2 || this.isNumeric(t))
							modi_tokens.remove(t);
						if(reject_words.contains(t))
							modi_tokens.remove(t);
						
						if(t.contains(")")) {
							if(t.substring(t.length()-2, t.length()-1).equals(")") && t.substring(t.length()-1, t.length()).length() == 1) {
								String temp_t = t.substring(0, t.length()-1);
								int t_index = modi_tokens.indexOf(t);
								modi_tokens.remove(t);
								modi_tokens.add(t_index, temp_t);
							}
						}
					}
					news_title_komoran.addAll(modi_tokens);
				}
			}
//			result_json.put("sentiment", sentiment);
			result_json.put("refine_news_title", news_title_komoran);
			
			if(json.containsKey("sentiment")) {
				String sentiment = json.get("sentiment").toString();
				result_json.put("sentiment", sentiment);
			}
			result.add(result_json);
		}
		
		return result;
	}
	// 코모란 형태소 분석기를 이용해 제목만 형태소 분석 실시
	// 당일치 계산을 위해 함수를 하나 더 생성 -> 사용자별 명사 추출과 기존 긍부정 명사 추출 로직이 달라서
	public JSONArray komoran_refine_prev(JSONArray article_data) {
		JSONArray result = new JSONArray();
		DB db = new DB();
		//코모란 품사 테이블 참조 -> https://docs.komoran.kr/firststep/postypes.html 
//		Set<String> tag = new HashSet<String>(Arrays.asList("VV","MM","MAJ","IC",//,"NNB",
//				"JKS","JKC","JKG","JKO","JKB","JKV","JKQ","JX","JC","VCP","EC","ETN","VX",
//				"NP","MAG","EP","EF","ETM","XPN","XSN","XSV","XSA","XR","VCP","SS","SF","SE","SO"));
//		//VCP, ETM => 준비 중인 / 준비 중 이(VCP) ㄴ(ETM) 으로 분해
//		//EC => 대여 => 대 이(VCP) 어(EC) 로 분해
//		//ETN => 의료기기 => 의료기 이 기(ETN) 로 분해
//		//VV => 이게 => 이(VV) 게 로 분해
//		//XSN  => 전임이들이 => 전임 이 들(XSN) 이
//		//NNB -> 의존명사 라서 제외 -> 것 
		
		//코모란 태그 표 -> https://docs.komoran.kr/firststep/postypes.html
		// 어미,접두사, 접미사 등 아리랑이 걸러내지 못한 부분을 걸러내기 위함
		Set<String> tag = new HashSet<String>(Arrays.asList("MM","MAJ","IC",
				"JKS","JKC","JKG","JKO","JKB","JKV","JKQ","JX","JC",
				"NP","MAG","EP","EF","ETM","XPN","XSV","XSA","XR","SS","SF","SE","SO"));
		
		Set<String> tag_giho = new HashSet<String>(Arrays.asList("SF","SP","SS","SE","SO"));//,"SW"));
		//komoran
		Komoran komoran = new Komoran(this.komoran_model_path);
		komoran.setUserDic(this.komoran_user_dictionary);
		List<String> reject_words = db.reject_words_return();
		
		for(Object obj : article_data) {
			JSONObject json = (JSONObject) obj;
			JSONObject result_json = new JSONObject();
			
			List<String> refine_news_title = (List<String>) json.get("refine_news_title");
 			List<String> news_title_komoran = new ArrayList<String>();
			
 			for(String word : refine_news_title) {
 				if(reject_words.contains(word)) {
 					continue;
 				}
 				List<String> temp_word_list = new ArrayList<String>();
 				List<List<Pair<String,String>>> komoran_result = komoran.analyze(word);
 				for (List<Pair<String, String>> eojeolResult : komoran_result) {
					for (Pair<String, String> wordMorph : eojeolResult) {
						if(tag.contains(wordMorph.getSecond())) {// && wordMorph.getFirst().length() >= 2)
//							System.out.println(wordMorph);//.getFirst());
							word = word.replace(wordMorph.getFirst(), "");
							//result_mix.add(wordMorph.getFirst());
						}
					}
				}
 				//위 과정을 거친뒤 해당 단어가 공백이 아니라면 단어 리스트 추가
				if(!word.equals(""))
					news_title_komoran.add(word);
 			}
 			//명사 리스트 -> "/"가 앞이나 뒤에 존재 할경우 제거 하는 로직이 필요 -startWith. endWith
			List<String> doc = new ArrayList<String>();
			for (String str : news_title_komoran) {
				str = sign_reject(str);
				
				if(str.length() > 1)
					doc.add(str);
			}
			
			result_json.put("refine_news_title", doc);
			
			if(json.containsKey("sentiment")) {
				String sentiment = json.get("sentiment").toString();
				result_json.put("sentiment", sentiment);
			}
			result.add(result_json);
		}
		
		return result;
	}

	public static void main(String[] args) {
		// test 를 위한 main 함수 선언
		
		// dnai 당일치 계산시 사용되는 로직
		DB db = new DB();
		refine r = new refine();
		tfidf_calculate cal = new tfidf_calculate();
		
		String user_seq = "144";
		String start_date = "2021-04-28";
		String end_date = "2021-04-28";
		JSONArray article_data = db.article_content_data_return(user_seq, start_date, end_date);
		
		//refine
		JSONArray refine_data = r.refine_text_today(article_data);//refine_text(article_data);
		
		//tfidf calculate 
		JSONObject word_score = cal.calculate_today_article(refine_data);//calculate_today_article
		
		System.out.println(word_score);
		
	}
}
