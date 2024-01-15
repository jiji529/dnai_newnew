package API;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.concurrent.TimeUnit;

import javax.imageio.ImageIO;

import org.apache.commons.codec.binary.Base64;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
// 이미지 API 요청시 동작하는 클래스
public class img_download {
	
	//local
//	String driverFilePath = "C:\\Users\\tealight\\Desktop\\hoonzi\\20.단어연관도\\chromedriver_win32\\chromedriver.exe";
//	String query_url = "http://localhost:8080/dnai/wordcloud_image_rendering.jsp";
//	String download_path = "C:\\Users\\tealight\\eclipse-workspace\\.metadata\\.plugins\\org.eclipse.wst.server.core\\tmp2\\wtpwebapps\\dnai\\wordcloud_image\\";
    //server
	// 서버내 브라우저 렌더링을 위한 크롬드라이버 주소
	String driverFilePath = "/home/dnai/word2vec/chromedriver";
	// 서버내 이미지 렌더링을 할 jsp 주소
	String query_url = "http://dnai.scrapmaster.co.kr/dnai/wordcloud_image_rendering.jsp";
	// 다운로드할 워드 클라우드 이미지가 저장되는 주소
	String download_path = "/home/dnai/apache-tomcat-8.5.59/webapps/dnai/wordcloud_image/";
	public JSONObject result_return() {
		JSONObject result = new JSONObject();
		
		img_download id = new img_download();
		
		//이미지 존재 여부 파악
		SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd_HHmm");
		Date time = new Date();
		Calendar cal = Calendar.getInstance();
		cal.setTime(time);
		int min = cal.get(Calendar.MINUTE);
		min %= 10;
		cal.add(Calendar.MINUTE, -min);
		
		String time_String = format.format(cal.getTime());
//		System.out.println(time_String);
		String fileName = time_String+".png";
		File file = new File(id.download_path+fileName);
		if(file.exists()) { // 파일 존재
			// 기존 이미지 주소 반환
			String file_path = id.download_path+fileName;
//			System.out.println(file_path);
			file_path = "http://dnai.scrapmaster.co.kr/dnai/wordcloud_image/"+fileName;
			result.put("url", file_path);
		}
		else { // 파일존재 x
			String file_path = "";
			// 이미지 주소 반환
			System.setProperty("webdriver.chrome.driver",id.driverFilePath);
			ChromeOptions options = new ChromeOptions();
			options.addArguments("--headless","--disable-gpu", "--window-size=1920,1200","--ignore-certificate-errors", "--silent"); // "--headless", 
			
			WebDriver driver = new ChromeDriver(options);
		    driver.get(id.query_url);
		    driver.manage().timeouts().implicitlyWait(1000, TimeUnit.SECONDS);
		    
		    try {
				Thread.sleep(3000);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		    WebElement element = driver.findElement(By.id("download_link"));// download_link
		    
		    file_path = element.getAttribute("href");
//		    System.out.println(file_path);
		    
		    driver.quit();//
		    result.put("url", file_path);
		}
		
		return result;
	}
	
	public static void main(String[] args) {
		
	}
	
}
