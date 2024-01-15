package API;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
// 긍부정 판별 하는 클래스
public class sentiment_check {
	// 긍부정 API 주소
	private String url_string = "http://222.231.4.35/sentiment/";
	/*
	 * 	- 요청 방식 : POST
  		- 요청 URL : http://222.231.4.42/sentiment/ (마지막 "/" 필수, 테스트 단독 서버)
  		- 요청 변수
	    * type (필수) : 매체유형 (other)
	    * md_oid : 매체코드
	    * article_serial : 기사 키값
	    * txt (필수) : 요청내용
	 * 
	 * */
	//리스트를 원하는 갯수별로 쪼개주는 함수 -> 메인에서 아이디별로 스레드를 나눌때 쓰는 함수
	//나눌 리스트, 몇개로 나누고 싶은지 숫자 변수
	public static <T> JSONArray split(JSONArray resList, int count) {
        if (resList == null || count <1)
            return null;
        JSONArray ret = new JSONArray();
        int size = resList.size();
        if (size <= count) {
            // 데이터 부족 count 지정 크기
            ret.add(resList);
        } else {
            int pre = size / count;
            int last = size % count;
            // 앞 pre 개 집합, 모든 크기 다 count 가지 요소
            for (int i = 0; i <pre; i++) {
            	JSONArray itemList = new JSONArray();
                for (int j = 0; j <count; j++) {
                    itemList.add(resList.get(i * count + j));
                }
                ret.add(itemList);
            }
            // last 진행이 처리
            if (last > 0) {
            	JSONArray itemList = new JSONArray();
                for (int i = 0; i <last; i++) {
                    itemList.add(resList.get(pre * count + i));
                }
                ret.add(itemList);
            }
        }
        return ret;
    }
	
	
	/**
	 * @param title String 기사 제목
	 * @param content String 기사 본문
	 * @return setiment String 긍부정 API 결과값 
	 * 
	 * */
	public String sentiment_return(String title, String content) throws IOException, ParseException {
		JSONParser parser = new JSONParser();
		
		String sentiment = "";
		String type = "other";
		String query_text = "@@"+title+"\n"+content;
		
		URL url = new URL(url_string);
		HttpURLConnection conn = (HttpURLConnection) url.openConnection();
		conn.setDoOutput(true);
		conn.setRequestMethod("POST"); // 보내는 타입
		conn.setRequestProperty("Content-Type", "application/json;utf-8");
		conn.setRequestProperty("Accept", "application/json");
		//conn.setRequestProperty("Accept-Language", "ko-kr,ko;q=0.8,en-us;q=0.5,en;q=0.3");
		JSONObject json = new JSONObject();
		json.put("type", type); // 
		json.put("txt", query_text);
		
		String param = json.toJSONString();
//		System.out.println(param);
		// 전송
		OutputStreamWriter osw = new OutputStreamWriter(conn.getOutputStream());
		try {
			osw.write(param);
			osw.flush();
			BufferedReader br = null;
			br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
			String line = null;
			while ((line = br.readLine()) != null) {
				//System.out.println(line);
				JSONObject result_json = (JSONObject) parser.parse(line);
				result_json = (JSONObject) result_json.get("result");
				double polarity = Double.valueOf(result_json.get("polarity").toString());
				if(polarity < 0)
					sentiment = "-1";
				else if(polarity > 0)
					sentiment = "1";
				else
					sentiment = "0";
			}
			
			osw.close();
			br.close();
		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (ProtocolException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		return sentiment;
	}
	/**
	 * @param article_data 기사 데이터 
	 * @return result 긍부정 판별이 완료된 기사 데이터 반환
	 * 
	 * */
	public JSONArray check(JSONArray article_data) throws InterruptedException {
		JSONArray result = new JSONArray();
		
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy년 MM월dd일 HH시mm분ss초");
		Date time = new Date();
		String time_string = sdf.format(time);
		System.out.println("check 함수 실행");
		System.out.println(time_string+" article_data_size : "+article_data.size());
		
		//등분할 숫자, 현재 4
		int part_num = 4;
		int article_size = article_data.size();
		int share = article_size / 10000;
		//기사 개수에 따른 등분 수 변화 
		if(share == 0) {
			part_num = 4;
		}else if(share == 1) {
			part_num = 5;
		}else if(share == 2) {
			part_num = 6;
		}else if(share == 3) {
			part_num = 7;
		}else {
			part_num = 8;
		}
		
		//4등분
		int split_size = article_data.size() / part_num;
		if(split_size < 1)
			split_size = 1;
		JSONArray split_article_data = this.split(article_data, split_size);
		System.out.println("등분수 : "+part_num);
		//예시
		/*
		 * [{"1":1},{"2":2},{"3":3},{"4":4}]
		 * [[{"1":1}],[{"2":2}],[{"3":3}],[{"4":4}]] 
		 */
		List<JSONArray> result_burket_list = new ArrayList<JSONArray>();
		for(int i = 0; i < split_article_data.size(); i++) {
			result_burket_list.add(new JSONArray());
		}
		List<Thread> thread_list = new ArrayList<Thread>();
		//각 thread별로 일 배분
		for(int i = 0; i < split_article_data.size(); i++) {
			JSONArray jarr = (JSONArray) split_article_data.get(i);
			JSONArray result_burket = result_burket_list.get(i);
			thread_list.add(new query_thread(jarr, result_burket));
		}
		
		for(Thread t : thread_list) {
			t.start();
		}
		
		for(Thread t : thread_list) {
			t.join();
		}
//		System.out.println(result_burket_list);
		//결과 통합
		for(JSONArray jarr : result_burket_list) {
			result.addAll(jarr);
		}
		
		sdf = new SimpleDateFormat("yyyy년 MM월dd일 HH시mm분ss초");
		time = new Date();
		time_string = sdf.format(time);
		System.out.println(time_string+" result aritlce_size : "+result.size());
		return result;
	}
	
	public static void main(String[] args) {
		/*
		sentiment_check sc = new sentiment_check();
		String title = "선림원 터에서 나온 신라 금동불상, 보존 처리 후 정식 공개";
		String content = "지난 2015년 10월 강원도 양양군의 고찰 선림원 터에서 출토된 9~10세기께 통일신라 금동보살입상이 최근 보존처리를 마치고 정식 공개됐다. 출토 직후 국립문화재연구소로 옮겨져 5년간 보존처리 작업 끝에 지난해 7월 아름다운 황금빛 자태를 되찾은 모습이 <한겨레>(2020년 7월31일치 18면)에 단독 공개돼 학계의 관심을 모은 바 있다. \r\n" + 
				"\r\n" + 
				"선림원 터 금동보살입상은 높이 38.7cm, 무게 4kg으로, 높이 14cm, 무게 3.7kg의 대좌가 아래를 받치고 있다. 출토 장소를 정확히 알 수 있는 역대 불상 가운데 가장 크다. 출토될 당시 섬세하게 새긴 대좌와 광배가 거의 원형을 잃지 않은 채 나왔다. 이후 5년간 연구소 쪽이 작업해 입상의 금빛과 본래 형태를 복원하면서 제작 기법과 제작 연대를 밝혀냈다. \r\n" + 
				"\r\n" + 
				"출토 당시 표면에 흙과 녹이 뒤엉켰고, 오른쪽 발목은 부러져 대좌에서 떨어져 나온데다 광배도 여러 조각으로 부서져 긴급 보존처리가 필요한 상태였다. 센터 쪽은 발굴조사 기관인 한빛문화재연구원에서 상을 인수해 2016년 1월~2020년 12월 과학적 조사와 보존처리 작업을 벌였다. 입상 보존상태 파악을 위해 엑스(X)선 투과, 내시경 조사, 재질 분석 등 과학적 조사를 했고, 이를 바탕으로 녹 제거, 강화처리, 접합복원 등 보존 처리를 했다. ";
		String sentiment = "";
		long start = System.currentTimeMillis();
		try {
			sentiment = sc.sentiment_return(title, content);
			System.out.println(sentiment);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		long end = System.currentTimeMillis();
		double timeTaken = (end - start) / 1000.0;
		System.out.println("timeTaken : "+timeTaken);
		*/
		
		JSONArray jarr = new JSONArray();
		JSONObject j = new JSONObject();
		j.put("1", 1);
		jarr.add(j);
		JSONObject j2 = new JSONObject();
		j2.put("2", 2);
		jarr.add(j2);
		JSONObject j3 = new JSONObject();
		j3.put("3", 3);
		jarr.add(j3);
		JSONObject j4 = new JSONObject();
		j4.put("4", 4);
		jarr.add(j4);
		System.out.println(jarr);
		sentiment_check sc = new sentiment_check();
		
		int split_size = jarr.size()/4;
		if(split_size < 1)
			split_size = 1;
		System.out.println(sc.split(jarr, split_size));
		
		
	}
	
}
