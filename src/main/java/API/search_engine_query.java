package API;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;
//검색엔진을 이용해 기사를 조회하는 클래스
public class search_engine_query {
	// 검색엔진을 이용해 기사 긍부정을 조회하는 함수
	public JSONObject query_article_serial(String article_serial) {
		JSONObject result = new JSONObject();
		result.put("news_title", "");
		result.put("news_contents", "");
		result.put("sentiment", "");
		result.put("article_serial", article_serial);
		
		String targetUrl = "";
		// 지면 매체의 경우 시리얼이 18자리 라서 paperView에다가 질의 해야함
		if(article_serial.length() < 19) {
			targetUrl = "http://search.solr.api.dahami.com/nsearch/paperView?articleSerial="+article_serial+"&incContent=true&smID=hoonzinope";
		}else { // 온라인 매체 (128자리), 가공기사 (미지수) 는 onlineView에 질의 
			targetUrl = "http://search.solr.api.dahami.com/nsearch/onlineView?articleSerial="+article_serial+"&incContent=true&smID=hoonzinope";
		}
		// 가져온 값을 파싱
		DocumentBuilderFactory dbFactoty = DocumentBuilderFactory.newInstance();
		DocumentBuilder dBuilder;
		Document doc = null;
		try {
			dBuilder = dbFactoty.newDocumentBuilder();
			doc = dBuilder.parse(targetUrl);
		} catch (ParserConfigurationException e) {
			// TODO Auto-generated catch block
			//e.printStackTrace();
			return result;
		} catch (SAXException e) {
			// TODO Auto-generated catch block
			//e.printStackTrace();
			return result;
		} catch (IOException e) {
			// TODO Auto-generated catch block
			//e.printStackTrace();
			return result;
		}
		
		doc.getDocumentElement().normalize();
		
		NodeList nList = doc.getElementsByTagName("doc");
		// 제목, 본문, 긍부정 값 가져오기
		for(int temp = 0; temp < nList.getLength(); temp++){		
			Node nNode = nList.item(temp);
			if(nNode.getNodeType() == Node.ELEMENT_NODE){
				
				Element eElement = (Element) nNode;
				String title = "";
				String content = "";
				String sentiment = "";
				try {
					content = getTagValue("text", eElement);
					title = getTagValue("title", eElement);
					sentiment = getTagValue("sentiment", eElement);
				} catch (Exception e) {
					// TODO Auto-generated catch block
					//System.out.println(targetUrl);
					//e.printStackTrace();
				}
				result.put("news_title", title);
				result.put("news_contents", content);
				result.put("sentiment", sentiment);
				result.put("article_serial", article_serial);
			}	
		}
		
		return result;
	}
	
	private static String getTagValue(String tag, Element eElement) throws Exception {
		try {
		    NodeList nlList = eElement.getElementsByTagName(tag).item(0).getChildNodes();
		    Node nValue = (Node) nlList.item(0);
		    if(nValue == null) 
		        return null;
		    return nValue.getNodeValue().toString().replaceAll("(\r\n|\r|\n|\n\r)", " ");
		}catch(Exception e) {
			//e.printStackTrace();
			throw new Exception();
		}
	}
}
