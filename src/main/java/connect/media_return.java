package connect;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.charset.Charset;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;

public class media_return {
	String online_media_path = "http://txtnews2.scrapmaster.co.kr/api/online_news_media_list.php";
	
	private static String readAll(Reader rd) throws IOException {
	    StringBuilder sb = new StringBuilder();
	    int cp;
	    while ((cp = rd.read()) != -1) {
	      sb.append((char) cp);
	    }
	    return sb.toString();
	  }
	// 온라인 매체 정보를 가져오는 함수
	// 위 url로 접속시 JSON 값을 볼수 있음
	public JSONObject online_media_list_return() throws MalformedURLException, IOException {
		String online_media = "";
		int online_media_count = 0;
		InputStream is = new URL(this.online_media_path).openStream();
		Set<String> mediaKindCode = new HashSet<String>(Arrays.asList("101_001","104_001","103_001","08_001"));//"13_001","15_001","15_002"));
		
		try {
		    BufferedReader rd = new BufferedReader(new InputStreamReader(is, Charset.forName("UTF-8")));
		    String jsonText = readAll(rd);
		    JSONParser parser = new JSONParser();
		    JSONArray json = (JSONArray) parser.parse(jsonText);
		    
		    for(int i = 0; i < json.size(); i++) {
		    	JSONObject ctg = (JSONObject) json.get(i);
		    	String ctg_code = ctg.get("ctg_code").toString();
		    	if(!mediaKindCode.contains(ctg_code))
		    		continue;
		    	JSONArray org_JSON = (JSONArray) ctg.get("media");
		    	
		    	for(Object md : org_JSON) {
		    		JSONObject temp_md = (JSONObject) md;
		    		String md_oid = temp_md.get("md_oid").toString();
		    		online_media+=md_oid+"_";
		    		online_media_count ++;
		    	}
		    }
		}catch(Exception e) {
			
		}
		JSONObject result = new JSONObject();
		result.put("online_media_list", online_media);
		result.put("online_media_count", online_media_count);
		return result;
	}
	// 지면 매체 정보를 가져오는 함수
	// 디비에 접근해 매체 리스트를 가져옴
	public JSONObject paper_media_list_return() {
		JSONObject result = new JSONObject();
		
		//디비 연결 준비
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		
		String sql = "";
		int count = 0;
		//디비에 연결할때, 주소, 아이디, 비번
		String url = "jdbc:mysql://222.231.4.2/sm3_service?useUnicode=true&characterEncoding=utf8&verifyServerCertificate=false&useSSL=false";
		String id = "scrap_analysis";
		String password = "tmzmfoqqnstjr@4174";
		
		try {
			Class.forName("com.mysql.jdbc.Driver");
			
			con = DriverManager.getConnection(url, id, password);
			//지정한 매체들만 가져오기 위한 쿼리
			sql = "SELECT count(*) as count FROM paper WHERE kind_serial in ('00_000','01_000','50_000','02_000','04_000','80_001','03_001','03_002',\r\n" + 
					"'03_003','03_005','03_004','03_006','03_007','03_008','80_003') and active = 'Y'";
			pstmt = con.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if(rs.next()) {
				count = rs.getInt("count");
			}
		}catch(Exception e) {
			e.printStackTrace();
		}
		result.put("paper_media_count", count);
		return result;
	}
	
	public static void main(String[] args) throws MalformedURLException, IOException {
		media_return mr = new media_return();
		System.out.println(mr.online_media_list_return());
	}
	
}
