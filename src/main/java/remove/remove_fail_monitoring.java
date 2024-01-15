package remove;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.Properties;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
// 이미지 삭제가 제대로 안될 경우 메일로 모니터링 하는 클래스
public class remove_fail_monitoring {
	
	private Properties prop = new Properties();
	// 이미지 삭제 로그를 기록하는 폴더
	String log_file_path = "C:\\Users\\tealight\\eclipse-workspace\\dev\\dnai_img_remove_log\\"; //구분자 붙힐것
	///home/dnai/dnai_img_remove_log/today.txt
	// 생성자
	// 이메일을 보내는 주체를 설정
	public remove_fail_monitoring() {
		final String user = "hoonzinope@dahami.com";
		final String password = "hj75604310";
		final String host = "mail.dahami.com";
		
		prop.put("mail.smtp.host", host); 
		prop.put("mail.smtp.port", 25); 
		prop.put("mail.smtp.auth", "true"); 
		prop.put("mail.smtp.ssl.enable", "false");
		prop.put("mail.transport.protocol", "smtp");
		prop.put("mail.pop3.host", host);
	}
	// 로그를 읽어 이상이 있을경우, 메일을 발송
	public void log_Read() {
		img_remove remove = new img_remove();
		String today = remove.day_before_return(0);
		
		File file = new File(this.log_file_path+today+".txt");
		try {
			FileReader fr = new FileReader(file);
			BufferedReader bufReader = new BufferedReader(fr);
            String line = "";
            String test_line = "";
            while(true){
            	line = bufReader.readLine();
            	if(line != null){
            		test_line = new String(line);
            	}
            	else {
            		break;
            	}
         
            }
            //System.out.println(test_line);
            if(test_line.contains("failed"))
            	this.send_mail("error");
		} catch (FileNotFoundException e) {
		} catch (IOException e) {
		}
	}
	
	/*public void send_mail() {
		final String user = "hoonzinope@dahami.com";
		final String password = "hj75604310";
		final String host = "mail.dahami.com";
		
		// SMTP 서버 정보를 설정한다. 
//		Properties prop = new Properties(); 
//		prop.put("mail.smtp.host", host); 
//		prop.put("mail.smtp.port", 25); 
//		prop.put("mail.smtp.auth", "true"); 
//		prop.put("mail.smtp.ssl.enable", "false");
//		prop.put("mail.transport.protocol", "smtp");
//		prop.put("mail.smtp.ssl.trust", "mail.dahami.com");
//		prop.put("mail.smtp.socketFactory.fallback", "true");

		Session session = Session.getDefaultInstance(this.prop, new javax.mail.Authenticator() { 
			protected PasswordAuthentication getPasswordAuthentication() { 
				return new PasswordAuthentication(user, password); } 
			});
		try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(user));

            //수신자메일주소
            message.addRecipient(Message.RecipientType.TO, new InternetAddress("hoonzinope@dahami.com")); 

            // Subject
            message.setSubject("image_remove_fail"); //메일 제목을 입력

            // Text
            message.setText("dnai_image_remove_fail");    //메일 내용을 입력

            // send the message
            Transport.send(message); ////전송
            System.out.println("message sent successfully...");
            
            
        } catch (AddressException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (MessagingException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

	}*/
	// 메일 발송하는 함수
	public void send_mail(String error) {
		final String user = "hoonzinope@dahami.com";
		final String password = "hj75604310";
		final String host = "mail.dahami.com";
		
		// SMTP 서버 정보를 설정한다. 
//		Properties prop = new Properties(); 
//		prop.put("mail.smtp.host", host); 
//		prop.put("mail.smtp.port", 25); 
//		prop.put("mail.smtp.auth", "true"); 
//		prop.put("mail.smtp.ssl.enable", "false");
//		prop.put("mail.transport.protocol", "smtp");
//		prop.put("mail.smtp.ssl.trust", "mail.dahami.com");
//		prop.put("mail.smtp.socketFactory.fallback", "true");

		Session session = Session.getDefaultInstance(this.prop, new javax.mail.Authenticator() { 
			protected PasswordAuthentication getPasswordAuthentication() { 
				return new PasswordAuthentication(user, password); } 
			});
		try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(user));

            //수신자메일주소
            message.addRecipient(Message.RecipientType.TO, new InternetAddress("hoonzinope@dahami.com")); 

            // Subject
            message.setSubject("image_remove_fail"); //메일 제목을 입력

            // Text
            message.setText(error);    //메일 내용을 입력

            // send the message
            Transport.send(message); ////전송
            System.out.println("message sent successfully...");
            
            
        } catch (AddressException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (MessagingException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

	}
	
	public static void main(String[] args) {
		remove_fail_monitoring mail = new remove_fail_monitoring();
		mail.log_Read();
	}
	
}
