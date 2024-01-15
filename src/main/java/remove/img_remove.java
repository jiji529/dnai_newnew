package remove;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Locale;
// 사용자들이 워드클라우드 이미지를 다운로드 받을때 생성되는 파일을 주기적으로 지우기 위한 클래스
public class img_remove {
	// /home/dnai/apache-tomcat-8.0.53/webapps/dnai/wordcloud_image/
	// 이미지가 생성되는 폴더 위치 지정
	String folder_path = "/home/dnai/apache-tomcat-8.5.59/webapps/dnai/wordcloud_image/"; //구분자 붙힐 것
//	String folder_path = "C:\\Users\\tealight\\eclipse-workspace\\dev\\WebContent\\wordcloud_image\\";
	int day_before = -1;
	String log_file_path = "/home/dnai/dnai_img_remove_log/"; //구분자 붙힐것
//	String log_file_path = "C:\\Users\\tealight\\eclipse-workspace\\dev\\dnai_img_remove_log\\";
	/**
	 * @param	day_before	날짜 변경값, 현재 날짜에서 +/- 가능
	 * @return	yesterday	날짜 String 값
	 * 
	 * */
	public String day_before_return(int day_before) {
		Date dDate = new Date();
		dDate = new Date(dDate.getTime()+(1000*60*60*24*day_before));
		SimpleDateFormat dSdf = new SimpleDateFormat("yyyyMMdd", Locale.KOREA);
		String yesterday = dSdf.format(dDate);
		return yesterday;
	}
	
	/**
	 * 파일명에 붙은 날짜값이 오늘날짜가 아니면 전부 지우는 함수
	 * 로그파일에 지운 기록 생성 뒤, 파일 지우기
	 * */
	public void file_read_and_remove() throws Exception {
		String folder_path = this.folder_path;
		String yesterday = this.day_before_return(this.day_before);
		String today = this.day_before_return(0);
		List<String> file_name_list = new ArrayList<String>();
		
		File dir = new File(folder_path);
		File[] fileList = dir.listFiles();
		for(int i = 0 ; i < fileList.length ; i++){
			File file = fileList[i]; 
			if(file.isFile()){
				String temp_file_name = file.getName();
				if(temp_file_name.contains("_")) {
					String temp_date = temp_file_name.split("_")[1];
					//날짜가 어제와 같다면 -> 날짜가 오늘이 아니라면
					if(!temp_date.equals(today)) {
						file_name_list.add(temp_file_name);
					}
				}
			}else {
				continue;
			}
		}
		
		
		this.log_file_write(file_name_list, today);
		this.file_remove(file_name_list, folder_path);

	}
	/**
	 * 파일을 지우기 전 로그 기록을 작성하는 함수
	 * 
	 * */
	public void log_file_write(List<String> file_name_list, String today) throws Exception {
		File file = new File(this.log_file_path+today+".txt");
		
		FileWriter fw = new FileWriter(file, true);
		for(String file_name : file_name_list) {
			fw.write(file_name+"\n");
		}
		fw.close();
	}
	/**
	 * 파일을 지우는 함수
	 * 
	 * */
	public void file_remove(List<String> file_name_list, String folder_path) throws Exception {
		for(String file_name : file_name_list) {
			File file = new File(folder_path+file_name);
			
			if( file.exists() ){ 
				if(file.delete()){ 
					System.out.println("파일삭제 성공"); 
					}
				else{
					System.out.println("파일 삭제 실패");
					throw new Exception();
					} 
			}else{ 
				System.out.println("파일이 존재하지 않습니다."); 
			}
		}
	}
	
	public static void main(String[] args){
		img_remove remove = new img_remove();
		String today = remove.day_before_return(0);
		remove_fail_monitoring monitor = new remove_fail_monitoring();
		try {
			remove.file_read_and_remove();
		} catch (Exception e) {
			
			StringWriter error = new StringWriter();
			e.printStackTrace(new PrintWriter(error));
			
			monitor.send_mail(error.toString());
		}
	}
	
}
