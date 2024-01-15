<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="connect.DB"%>   
    
<%
DB db = new DB();
String sm3ID = request.getParameter("sm3ID");
JSONArray user_seq = db.user_seq_return(sm3ID);
String user_start_date = "1998-01-01";
if(user_seq.size() != 0){
	user_start_date = db.start_date(user_seq.get(0).toString());
}
String editValid = request.getParameter("editValid");
boolean edit_valid = false;
if(editValid != null && !editValid.equals("")) {
	edit_valid = Boolean.parseBoolean(editValid);
}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>DNA wordcloud</title>
<link rel="stylesheet" href="./css/style_copy.css">
<link id="load-css-0" rel="stylesheet" type="text/css" href="./css/tooltip.css">
<link id="load-css-1" rel="stylesheet" type="text/css" href="./css/util.css">
<link id="load-css-2" rel="stylesheet" type="text/css" href="./css/table.css">
<link id="load-css-3" rel="stylesheet" type="text/css" href="./css/format.css">
<link rel="stylesheet" type="text/css" href="./css/jquery-ui.css">
<link rel="stylesheet" type="text/css" href="./css/jquery-ui.min.css">


<script type="text/javascript" src="./js/webfont.js"></script>
<script type="text/javascript" src="./js/jquery.min.js"></script>
<script type="text/javascript" src="./js/jquery-ui.js"></script>
<!-- <script type="text/javascript" src="./js/datepicker-ko.js"></script>  -->
<script type="text/javascript" src="./js/jquery-1.12.4.js"></script>
<script type="text/javascript" src="./js/jquery-ui.min.js"></script>

<script type="text/javascript" src="./js/html2canvas.js"></script>
<script type="text/javascript" src="./js/download.js"></script>

<script type="text/javascript" src="./js/loader.js"></script>
<script src="./js/d3.v3.min.js" type="text/JavaScript"></script>
<script src="./js/d3.layout.cloud.js" type="text/JavaScript"></script>
<script type="text/javascript" src="./js/moment.js"></script>
<script type="text/javascript" src="./js/Chart.bundle.min.js"></script>
<script type="text/javascript" src="./js/Chart.min.js"></script>

</head>
<body>
	<div class="container">
		
		
		
		<div class="tabs">
            <ul class="inner">
                <li id = "tab_one" class="tab-link current" data-tab="tab-1" style="cursor: pointer">오늘의 뉴스 분석</li>
                <li id = "tab_two" class="tab-link" data-tab="tab-2"  style="cursor: pointer">프리미엄 기사 분석</li>
            </ul>
        </div>
		<div id="tab-1" class="tab-content current wrap">
			
                <div class="tab_tit">
                	<div class="inner">
						<ul class="sub_tabs">
							<li class="sub_tab-link current" data-tab="today_total" style="cursor: pointer"><h1>오늘의 주요 키워드</h1></li>
							<li class="sub_tab-link" data-tab="today_total" style="cursor: pointer"><h1>오늘의 신문 1면 주요키워드</h1></li>
						</ul>
					</div>
				</div>
			
			
		 	<div class = "score_display" id = "total_score_display">
		 		<div class="inner">

					<!-- 2024-01-15 HA.J.S 국방부용 달력 추가 -->
					<!-- DatePicker 활용할 예정 -->
					<!-- JSTL로 조건문 분기시켜야함(그게 아니라면 자바스크립트로라도 조건 줘야함) -->
                    <div class="cal">
                        <div class="cal_wrap">
                            <div class="cal_area">
                                <button type="button" class="cal_btn" id="cal_prev">
                                	<span class="blind">이전날</span>
                                </button>
                                <input type="button" class="cal_date" id="cal_date" value="">
                                <button type="button" class="cal_btn cal_next disabled" id="cal_next">
                                	<span class="blind">다음날</span>
                                </button>
                            </div>
                        </div>
                    </div>
                                        		 		
		 				<div class="sub_tab-content current menu1" id = "today_total">
							<!--  <h4 class = "total_info">ⓘ 신문 315종과 인터넷 뉴스 227종을 분석했습니다.</h4> -->
							
							<!-- <input id="blobButton" class="blobButton" type="button" onclick="img_download()" value="이미지 저장">
							<input id="blobButton2" class="blobButton2" type="button" onclick="excel_download()" value="엑셀로 저장">  -->
							<ul id = "pair_type" class="pair_type lt">
							     <li class="active" >단일 단어</li>
							     <li class="li_bar" id="before_bar"></li>
							     <li >단어 쌍</li> <!--  style="cursor: pointer" -->
						 	</ul>
						 	<ul class="btn_area rt">
						 		
	                            <li><input class="blobButton" type="button" id="totalImgDownload" value="이미지 저장"></li>
	                            <li><input class="blobButton" type="button" id="totalExcelDownload" value="엑셀 저장"></li>
	                            <!-- <li><input id="blobButton" class="blobButton" type="button" onclick="total_table_img_download()" value="키워드 순위 이미지 저장"></li> -->
	                        </ul>
	                        
	                        
	                    
					 	</div>
		 				
				 		<div id = "wordcloud" class= "cloud box">
				 			<h3 class="box_tit" style="cursor: pointer">워드 클라우드</h3>
				 			<div id = "total_wordcloud_shape" class="view_btn"><button id = "total_wordcloud_rect" class="view_w on">기본형</button><button id = "total_wordcloud_square" class="view_h">정방형</button></div>
				 			<div id = "loadingBar_wordcloud_total" style="display:none; width:750px; height: 300px">
		               			<img id = "loading-image" src = "./css/ajax-loader.gif"  style = "position: relative; top: 50%; left: 50%; z-index:100;"/>
		               		</div>	
				 		</div>
					 	
					 	<div id = "word-table" class = "word_table box">
					 		<h3 class ="box_tit" >키워드 순위</h3> 
					 		<div class="btn_area">
	                            <button class="btn3 btn_gr" id="editing_action" onoff="off"><i class="ri-edit-line"></i>편집</button>
	                         	<button class="btn3 btn_gr" id="save_action" style="display:none"></i>적용</button>
	                         	<button class="btn3 btn_gr" id="cancel_action" style="display:none"></i>취소</button>
	                        </div>
					 		<div id = "loadingBar_wordtable_total" style="display:none; width:250px; height: 250px">
		               			<img id = "loading-image" src = "./css/ajax-loader.gif"  style = "position: relative; top: 50%; left: 50%; z-index:100;"/>
		               		</div>
					 		<ul class = "rank_li srch" id="total_word_table_ul">
					 		</ul>
					 		<!-- <button id = "search_keyword_total_button" onclick="search_keyword_total()" style = "width:50px; height:20px"> &nbsp;</button>  -->
					 	</div>
					 	<ul class="total_info">
	                        <li class="media_count_info">신문 "&{paper_media_count};"종과 인터넷 뉴스 "&{online_media_count};"종을 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다.<a href="#">TF-IDF란?</a></li>
	                        <li>10분마다 갱신됩니다.</li>
	                    </ul>
				</div>
			</div>
		</div>
				 
		
		
		<!-- 프리미엄 기사 분석 탭 -->
		<div id="tab-2" class="tab-content wrap">
		
			<div class="tab_tit">
                <div class="inner">
                    <h1>프리미엄 등록 기사 주요 키워드 -</h1>
                    <ul class="sub_tabs_member">
                        <li class="sub_tab_member-link current" data-tab="member_total" line-tab="member_total_line" style="cursor: pointer">누적</li>
                        <li class="bar"></li>
                        <li class="sub_tab_member-link" data-tab="member_total_period" line-tab="member_total_period_line" style="cursor: pointer">주간</li>
                        <li class="bar"></li>
                        <li class="sub_tab_member-link" data-tab="member_total_period" line-tab="member_total_period_line" style="cursor: pointer">월간</li>
                        <li class="bar"></li>
                        <li class="sub_tab_member-link" data-tab="member_total_period" line-tab="member_total_period_line" style="cursor: pointer">분기</li>
                        <li class="bar"></li>
                        <li class="sub_tab_member-link" data-tab="member_total_period" line-tab="member_total_period_line" style="cursor: pointer">기간설정</li>
                    </ul>
                </div>         
            </div>
            
            
			<div class = "score_display" id = "member_score_display">
			
				<div class="inner">
				
					<!--기간-->
                    <div id="period_setting" class="pair_type period_setting" style="display: block;">
                   		<input type="text" id="start_datepicker" placeholder="시작일" class="Datepicker">
                   		<input type="text" id="end_datepicker" placeholder="종료일" class="Datepicker">
                   		<input type="button" name="date_submit" id="date_submit" value="적용하기">
                	</div>
	                <!--기간-->
					<div class="sub_tab_member-content current menu1" id="member_total">
	                    
	                    <ul id="pair_type_member" class="pair_type lt">
                            <li class="active" id = "type">단일 단어</li>
                            <li class="li_bar" id="before_bar"></li>
                            <li id = "type">단어 쌍</li>
                            <li class="check"><input type="checkbox" id="removeCheck"><label for="removeCheck"><span class="label"></span><span class=""><i class="tag1">누적</i></span> 포함</label></li>
                        </ul>
                        <ul class="btn_area rt">
					 		
                            <li><input id="memberCloudImgDownload" class="blobButton" type="button" value="이미지 저장"></li>
                            <li><input id="memberCloudExcelDownload" class="blobButton" type="button" value="엑셀 저장"></li>
                            <!-- <li><input id="blobButton" class="blobButton" type="button" onclick="member_table_img_download()" value="키워드 순위 이미지 저장"></li> -->
                        </ul>
	                    
	                </div>
	                
					<div id="member_wordcloud" class="cloud box" style="font-family: GmarketSansBold;">
	                    <h3 class="box_tit">워드 클라우드</h3>
	                    <!-- 1105 div.view_btn 추가 -->
                        <div id = "member_wordcloud_shape" class="view_btn"><button id = "member_wordcloud_rect" class="view_w on">기본형</button><button id = "member_wordcloud_square" class="view_h">정방형</button></div>
	                    <div id = "loadingBar_wordcloud" style="display:none; width:750px; height: 300px">
	               			<img id = "loading-image" src = "./css/ajax-loader.gif"  style = "position: relative; top: 50%; left: 50%; z-index:100;"/>
	               		</div>
	                </div>
	                
	                <div id="member_word-table" class="word_table box">
	                    <h3 class="box_tit">키워드 순위</h3>
	                    <div class="btn_area">
	                    	<button class="btn3 btn_gr" id="editing_action_member" onoff="off"><i class="ri-edit-line"></i>편집</button>
                        	<button class="btn3 btn_gr" id="save_action_member" style="display:none"></i>적용</button>
                        	<button class="btn3 btn_gr" id="cancel_action_member" style="display:none"></i>취소</button>
                        </div>
	                    <div id = "loadingBar_wordtable" style="display:none; width:250px; height: 250px">
	               			<img id = "loading-image" src = "./css/ajax-loader.gif"  style = "position: relative; top: 50%; left: 50%; z-index:100;"/>
	               		</div>
	                    <ul class="rank_li srch" id="member_word-table_ul">
	                    </ul>
	                    <!--<button id = "search_keyword_member_button" onclick="search_keyword_member()" style = "width:50px; height:20px">&nbsp;</button>  -->
	                </div>
	                <ul class="member_total_info">
                        <li class="media_count_info">프리미엄 서비스 출시 이후 고객님의 계정에 어제까지 뷰어에 등록된 기사(가판 제외)를 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다.<a>TF-IDF란?</a></li>
                        <li>워드클라우드에서 단어를 클릭하면 해당 단어가 기사 내 언급된 날짜별 추이로 아래 그래프에 반영됩니다. 그래프의 특정 위치를 클릭하면 해당 일자와 점수를 확인할 수 있습니다.</li>
                    </ul>
			 	</div>
			</div>
			
			<div class="box history">
				<div class = "inner">
					<!--     		
                    <h3 class="history_info_text_total box_tit" style="visibility: visible;">프리미엄 등록 기사 주요 키워드 추이 : 
                    <span id="text_total"></span> <span onclick="show_history_infoText()" class="line_info_button" style="visibility: visible;cursor: pointer;">ⓘ</span>
                    </h3>
               		 
               		<p>&nbsp;</p>
               		-->
               		<h3 class="history_info_text_total box_tit" style="visibility: visible;">프리미엄 등록 기사 주요 키워드 추이 : <span id="text_total"></span>
               		<span onclick="show_history_infoText()" class="line_info_button" style="visibility: visible;cursor: pointer;">ⓘ </span>
                    
                    <!-- 위치변경 span 추가 -->
                    <span class="check">
                     <label id="periodLabel"><span class="label"></span>
                     <input type="checkbox" id="periodCheck" value="off">전체기간보기</label>
                    </span>
                    <span class="member_history_info" style="float: right; color: #999; font-size: 13px; font-weight: 300;"><span onclick="show_tfidf_infotext()" class="line_info_button" style="visibility: visible;cursor: pointer;">ⓘ</span> 점수는 TF-IDF 알고리즘으로 분석한 결과입니다.</span></h3>
               		<p>&nbsp;</p>
               		
               		
               		<div id = "loadingBar" style="display:none; width:1200px; height: 300px">
               			<img id = "loading-image" src = "./css/ajax-loader.gif"  style = "position: relative; top: 50%; left: 50%; z-index:100;"/>
               		</div>
                	
                	<canvas id = "lineChart_total" width = "1200" height = "300" class ="linechart"></canvas>
              	</div>  
            </div>
            
            <div class = "score_display" id = "sentiment_score_display">
				<div class="inner">
					<div class="sub_tab_member-content current menu1" id="member_total">
	                    <ul id="pair_type_member_sentiment" class="pair_type lt">
                            <li id="type" class="active">긍정 단어</li>
                            <li class="li_bar" id="before_bar"></li>
                            <li id="type">부정 단어</li>
                        </ul>
                        <ul class="btn_area rt">
					 		
                            <li><input id="memberSentimentCloudImgDownload" class="blobButton" type="button" value="이미지 저장"></li>
                            <li><input id="memberSentimentCloudExcelDownload" class="blobButton" type="button" value="엑셀 저장"></li>
                            <!-- <li><input id="blobButton" class="blobButton" type="button" onclick="table_img_download_sentiment()" value="키워드 순위 이미지 저장"></li> -->
                        </ul>
	                    
	                </div>
	                
					<div id="member_wordcloud_sentiment" class="cloud box" style="font-family: GmarketSansBold;">
	                    <h3 class="box_tit">워드 클라우드</h3>
	                    <!-- 1105 div.view_btn 추가 -->
                        <div id = "sentiment_member_wordcloud_shape" class="view_btn"><button id = "sentiment_member_wordcloud_rect" class="view_w on">기본형</button><button id = "sentiment_member_wordcloud_square" class="view_h">정방형</button></div>
	                    <div id = "sentiment_loadingBar_wordcloud" style="display:none; width:750px; height: 300px">
	               			<img id = "loading-image" src = "./css/ajax-loader.gif"  style = "position: relative; top: 50%; left: 50%; z-index:100;"/>
	               		</div>
	                </div>
	                
	                <div id="sentiment_member_word-table" class="word_table box">
	                    <h3 class="box_tit">키워드 순위</h3>
	                    <div class="btn_area">
	                    	<button class="btn3 btn_gr" id="editing_action_sentiment" onoff="off"><i class="ri-edit-line"></i>편집</button>
                        	<button class="btn3 btn_gr" id="save_action_sentiment" style="display:none"></i>적용</button>
                        	<button class="btn3 btn_gr" id="cancel_action_sentiment" style="display:none"></i>취소</button>
	                    </div>
	                    <div id = "sentiment_loadingBar_wordtable" style="display:none; width:250px; height: 250px">
	               			<img id = "loading-image" src = "./css/ajax-loader.gif"  style = "position: relative; top: 50%; left: 50%; z-index:100;"/>
	               		</div>
	                    <ul class="rank_li srch" id="sentiment_member_word-table_ul">
	                    </ul>
	                    <!--<button id = "search_keyword_member_button" onclick="search_keyword_member()" style = "width:50px; height:20px">&nbsp;</button>  -->
	                </div>
	                <!-- 
	                <ul class="member_total_info">
                        <li>프리미엄 서비스 출시 이후 고객님의 계정에 어제까지 뷰어에 등록된 기사(가판 제외)를 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다.<a href="#">TF-IDF란?</a></li>
                        <li>워드클라우드에서 단어를 클릭하면 해당 단어가 기사 내 언급된 날짜별 추이로 아래 그래프에 반영됩니다. 그래프의 특정 위치를 클릭하면 해당 일자와 점수를 확인할 수 있습니다.</li>
                    </ul>
                     -->
			 	</div>
			</div>
            
		</div>
		<a id = "download_link" download ></a>
	</div>
	
<script type="text/javascript">
var user_name = "<%=sm3ID%>";
var user_seq = <%=user_seq%>;
var user_start_date = "<%=user_start_date%>";
var edit_valid = <%=edit_valid%>;
</script>
<script type="text/javascript" src="./js/dnai_js/main_ver2.js"></script> 
</body>
</html>