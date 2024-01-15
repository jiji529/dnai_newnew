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
<script type="text/javascript">
//tab click

WebFont.load({
  custom: {
    families: ['GmarketSansBold'],
  }
});

var online_media_list = "";
var online_media_count = 0;
var user_seq = eval(<%=user_seq%>)[0];
var user_start_date = new String("<%=user_start_date%>");
google.charts.load('current',{
    'packages' : ['corechart','table']});
google.charts.setOnLoadCallback(drawChart);
var sentiment_word_score = null;
var global_period_check = true;
var sentiment_xhr;

// 오늘 점수 저장을 위해
var today_word_score = null;

function search_keyword(obj){
	var paper_1 = $(".sub_tab-link.current").text();
	var online_media_list_parameter = online_media_list
	var flag = false;
	if(paper_1.includes("1면"))
		flag = true;
	var parent =$(obj).parent()//.parent().parent();
	var keyword = parent.children('span').text();
	online_media_list_parameter = online_media_list_parameter.slice(0,-1);
	
	
	window.open("sm5search:"+keyword+"|"+online_media_list_parameter+"|"+flag, "keword_search","width = 400, height=300, left=100, top=50");
}


function drawChart(){
	var type = "0";
	ajax_total_word_score(type, 1);
	ajax_member_word_total(user_seq,type,1,true);
	//ajax_member_word_period(user_seq,type, 7, 2,false);
}

function setting_today() {
	var today = new Date();
	var year = today.getFullYear();
	var month = today.getMonth() + 1;
	var date = today.getDate();
	
	if(month < 10)
		month = "0"+month;
	if(date < 10)
		date = "0"+date;
	
	var today_string = year+"-"+month+"-"+date;
	
	return today_string;
}

function setting_yesterday () {
	var today = new Date();   
	var year = today.getFullYear(); // 년도
	var month = today.getMonth() + 1;  // 월
	var date = today.getDate()-1;  // 날짜
	
	if(month < 10)
		month = "0"+month;
	if(date < 10)
		date = "0"+date;
	
	var yester_day = year+"-"+month+"-"+date;
	
	
	
	var today = new Date();   
	var year = today.getFullYear(); // 년도
	var month = today.getMonth() + 1;  // 월
	var date = today.getDate()-7;  // 날짜
	
	if(month < 10)
		month = "0"+month;
	if(date < 10)
		date = "0"+date;
	
	var yester_day_minus7 = year+"-"+month+"-"+date;
	//var dateControl = document.querySelector('start_datepicker');
	//for(var i =0 ; i < dateControl.length; i++){
	//	dateControl[i].value = yester_day;
	//	console.log(dateControl[i]);
	//}
	
	document.getElementById('start_datepicker').value = yester_day;
	document.getElementById('end_datepicker').value = yester_day;
}

//워드클라우드 날짜 표시 (오늘날짜 반환)
/*function yesterday(){
	var week = new Array('일', '월', '화', '수', '목', '금', '토')

	var date = new Date(); 
	var year = date.getFullYear(); 
	var month = new String(date.getMonth()+1); 
	var day = new String(date.getDate()); 
	var day_name = week[date.getDay()];
	// 한자리수일 경우 0을 채워준다. 
	if(month.length == 1){ 
	  month = "0" + month; 
	} 
	if(day.length == 1){ 
	  day = "0" + day; 
	} 
	
	return year+'-'+month+'-'+day+"("+day_name+")";
}*/

function yesterday(){
	var week = new Array('일', '월', '화', '수', '목', '금', '토')

	var date = new Date(); 
	date.setDate(date.getDate() -1);
	var year = date.getFullYear(); 
	var month = new String(date.getMonth()+1); 
	var day = new String(date.getDate()); 
	var day_name = week[date.getDay()];
	// 한자리수일 경우 0을 채워준다. 
	if(month.length == 1){ 
	  month = "0" + month; 
	} 
	if(day.length == 1){ 
	  day = "0" + day; 
	} 
	
	return year+'-'+month+'-'+day+"("+day_name+")";
}

//워드클라우드 날짜 표시(주간, 월간, 분기)
function today_minus(period){
	var week = new Array('일', '월', '화', '수', '목', '금', '토')

	var date = new Date(); 
	date.setDate(date.getDate() -1);
	date.setDate(date.getDate() - period);
	
	var year = date.getFullYear(); 
	var month = new String(date.getMonth()+1); 
	var day = new String(date.getDate()); 
	var day_name = week[date.getDay()];
	// 한자리수일 경우 0을 채워준다. 
	if(month.length == 1){ 
	  month = "0" + month; 
	} 
	if(day.length == 1){ 
	  day = "0" + day; 
	} 
	
	return year+'-'+month+'-'+day+"("+day_name+")";
}

//워드클라우드 날짜 표시 (오늘의 키워드)
function today_10ago(){
	var week = new Array('일', '월', '화', '수', '목', '금', '토')
	var date = new Date();
	date.setMinutes(date.getMinutes() - 20);
	var minus_minute = date.getMinutes() % 10;
	date.setMinutes(date.getMinutes() - minus_minute + 10);
	
	var year = date.getFullYear(); 
	var month = new String(date.getMonth()+1); 
	var day = new String(date.getDate());
	var day_name = week[date.getDay()];
	var Hour = new String(date.getHours());
	var minute = new String(date.getMinutes());
	// 한자리수일 경우 0을 채워준다. 
	if(month.length == 1){ 
	  month = "0" + month; 
	} 
	if(day.length == 1){ 
	  day = "0" + day; 
	}
	if(Hour.length == 1){
		Hour = "0" + Hour;
	}
	if(minute.length == 1){
		minute = "0" + minute;
	}
	
	//console.log(year+'-'+month+'-'+day+" "+Hour+":"+minute);
	return year+'-'+month+'-'+day+"("+day_name+")"+" "+Hour+":"+minute;
}

//워드클라우드 날짜표시 (누적, 기간설정의 경우 요일도 반환하기 위해)
function date_name_return(date){
	var week = new Array('일', '월', '화', '수', '목', '금', '토')
	var split_date = date.split("-")
	var date = new Date(date);//new Date(split_date[0], split_date[1], split_date[2]);
	
	var year = date.getFullYear();  
	var month = new String(date.getMonth()+1); 
	var day = new String(date.getDate());
	
	//date.setMonth(date.getMonth() - 1);
	var day_name = week[date.getDay()];
	// 한자리수일 경우 0을 채워준다. 
	if(month.length == 1){ 
	  month = "0" + month; 
	} 
	if(day.length == 1){ 
	  day = "0" + day; 
	}
	return year+'-'+month+'-'+day+"("+day_name+")"
}

function online_media_return(){
	var online_media_list = "";
	var online_media_count = 0;
	$.ajax({
        type : 'POST',
        url : './utils/online_media_return.jsp',
        dataType : 'json',
        async: false,
        success : function(data) {
            //data, total or member, front
            online_media_list = data['online_media_list'];
            online_media_count = data['online_media_count'];
        },
        error : function(e) {
            //alert(e.responseText)
        }
    });
	return [online_media_list, online_media_count];
}

function paper_media_return(){
	var paper_media_count = 0;
	$.ajax({
        type : 'POST',
        url : './utils/paper_media_return.jsp',
        dataType : 'json',
        async: false,
        success : function(data) {
            //data, total or member, front
            paper_media_count = data['paper_media_count'];
        },
        error : function(e) {
            //alert(e.responseText)
        }
    });
	return paper_media_count;
}

$(document).ready(function(){
	
	var online_media_info = online_media_return()
	online_media_list = online_media_info[0];
	online_media_count = online_media_info[1];
	paper_media_count = paper_media_return();
	setting_yesterday();
	$(document).bind("contextmenu", function(e){
        return false;
    });
	
	$('ul.inner li').click(function(){
		$("#period_setting").hide();
		$("li.check").hide();
		$("#sentiment_score_display").hide();
		var tab_id = $(this).attr('data-tab');
		
		$('ul.inner li').removeClass('current');
		$('.tab-content').removeClass('current');

		$(this).addClass('current');
		$("#"+tab_id).addClass('current');
		
		$("#periodLabel").hide();
		var sub_tab_text = $('.sub_tab_member-link.current').text();
		//if(sub_tab_text == "주간" || sub_tab_text == "월간"  || sub_tab_text == "분기" || sub_tab_text == "기간설정")
		//	$("#removeSpace").show();
		if(sub_tab_text === "기간설정"){
			$("#period_setting").show();
			$("#sentiment_score_display").show();
		}
		if(sub_tab_text !== "누적"){
			$("li.check").show();
			$("#periodLabel").show();
		}
	})
	
	$('ul.sub_tabs li').click(function(){
		
		var tab_id = $(this).attr('data-tab');
		$('ul.sub_tabs li').removeClass('current');
		$('.sub_tab-content').removeClass('current');
		$(this).addClass('current');
		$("#"+tab_id).addClass('current');
		
		var front = 1;
		var front_text = $(this).text()
		if(front_text.indexOf("1면") >= 0){
			front = 2;
		}
		var type = 0;
		var pair_type = $('#pair_type').children('.active').text();
		if(pair_type == '단어 쌍'){
			type = 1;
		}
			
		ajax_total_word_score(type,front);
	})
	
	$('ul.sub_tabs_member li').click(function(){
		var chk = $("#removeCheck").is(":checked");
		var tab_id = $(this).attr('data-tab');
		$("#period_setting").hide();
		$("#sentiment_score_display").hide();
		$('ul.sub_tabs_member li').removeClass('current');
		//$('.sub_tab_member-content').removeClass('current');		
		$(this).addClass('current');
		$("#"+tab_id).addClass('current');
		//console.log($(this).text())
		var type = 0;
		var pair_type = $('#pair_type_member').children('.active').text();
		if(pair_type == "단어 쌍")
			type=1;
		
		var period = $(this).text();
		$(".linechart").hide();
		$("li.check").hide();
		$("#periodLabel").hide();
		if(period == "주간"){
	    	period = 7;
	    	$("li.check").show();
	    	$("#periodLabel").show();
	    	$("#member_wordcloud_shape").attr("style", "position: absolute; top: 95px; right: 380px;");
	    	//seq, pair_type, 기간, front, start)
	    	ajax_member_word_period(user_seq,type, period, chk,true);
	    }
	    else if(period == "월간"){
	    	period = 30;
	    	$("li.check").show();
	    	$("#periodLabel").show();
	    	$("#member_wordcloud_shape").attr("style", "position: absolute; top: 95px; right: 380px;");
	    	//seq, pair_type, 기간, front, start)
	    	ajax_member_word_period(user_seq,type, period, chk,true);
	    	
	    }
	    else if(period == "분기"){
	    	period = 90;
	    	$("li.check").show();
	    	$("#periodLabel").show();
	    	$("#member_wordcloud_shape").attr("style", "position: absolute; top: 95px; right: 380px;");
	    	//seq, pair_type, 기간, front, start)
	    	ajax_member_word_period(user_seq,type, period, chk,true);
	    }
	    else if(period == "기간설정"){
	    	$("#period_setting").show();
	    	$("#sentiment_score_display").show();
	    	$("li.check").show();
	    	$("#periodLabel").show();
	    	//console.log($("#member_wordcloud_shape").attr("style"));
	    	$("#member_wordcloud_shape").attr("style", "position: absolute; top: 130px; right: 380px;");
	    	var start_date = $("#start_datepicker").val();
			var end_date = $("#end_datepicker").val();
			//seq, pair_type, front, start, 기간)
			var today_string = setting_today();
			if(start_date === today_string && end_date === today_string){
				ajax_member_word_today_setting(user_seq, type, chk, true, start_date, end_date);			
			}else{
				ajax_member_word_period_setting(user_seq, type, chk, true, start_date, end_date);
			}
	    	ajax_member_sentiment_word_period_setting(user_seq, type, chk, true, start_date, end_date);
	    }
	    else{
	    	$("#periodLabel").hide();
	    	$("#member_wordcloud_shape").attr("style", "position: absolute; top: 95px; right: 380px;");
	  		ajax_member_word_total(user_seq,type, 1,true);
	  		$("li.check").hide();
	    }
		
	})
	
	if(typeof user_seq == "undefined"){
		$("#tab_two").hide();
		$("#tab-2").hide();
	}
	
	$("#pair_type").on('click','li', function(event){
		if(typeof($(event.target).attr('id')) != "undefined" && $(event.target).attr("id").includes("before"))
			return;	
		
		$("#pair_type li").removeClass('active');
		$(event.target).addClass('active');
		var pair_type = $(event.target).text()
		var type = 0;
		if(pair_type == "단어 쌍")
			type = 1;
		
		var front = 1;
		var front_text = $('.sub_tab-link.current').text()
		if(front_text.indexOf("1면") >= 0){
			front = 2;
		}
		ajax_total_word_score(type,front);
		
		
	})
	
	$("#pair_type_member").on('click','#type', function(event){
		if(typeof($(event.target).attr('id')) != "undefined" && $(event.target).attr("id").includes("before"))
			return;
		
		var chk = $("#removeCheck").is(":checked");
		$("#period_setting").hide();
		
		var pair_type_member_tagName = $(event.target).prop('tagName');
		if(pair_type_member_tagName === "SPAN" || pair_type_member_tagName === "INPUT" 
				|| pair_type_member_tagName === "I" || pair_type_member_tagName === "LABEL"){
			var pair_type = $("#pair_type_member li.active").text();
			var type = 0;
			if(pair_type == "단어 쌍")
				type = 1;
		}else{
			$("#pair_type_member li").removeClass('active');
			$(event.target).addClass('active');
			var pair_type = $(event.target).text()
			var type = 0;
			if(pair_type == "단어 쌍")
				type = 1;
		}
		
		var period = $('.sub_tab_member-link.current').text();
		$(".linechart").hide();
		$("#removeSpace").hide();
		$("li.check").hide();
		$("#periodLabel").hide();
		if(period == "주간"){
	    	period = 7;
	    	$("li.check").show();
	    	//seq, pair_type, 기간, front, start)
	    	ajax_member_word_period(user_seq,type, period, chk,true);
	    }
	    else if(period == "월간"){
	    	period = 30;
	    	$("li.check").show();
	    	$("#periodLabel").show();
	    	//seq, pair_type, 기간, front, start)
	    	ajax_member_word_period(user_seq,type, period, chk,true);
	    }
	    else if(period == "분기"){
	    	period = 90;
	    	$("li.check").show();
	    	$("#periodLabel").show();
	    	//seq, pair_type, 기간, front, start)
	    	ajax_member_word_period(user_seq,type, period, chk,true);
	    }
	    else if(period == "기간설정"){
	    	$("#period_setting").show();
	    	$("li.check").show();
	    	$("#periodLabel").show();
	    	var start_date = $("#start_datepicker").val();
			var end_date = $("#end_datepicker").val();
			//seq, pair_type, front, start, 기간)
			var today_string = setting_today();
			if(start_date === today_string && end_date === today_string){
				ajax_member_word_today_setting(user_seq, type, chk, true, start_date, end_date);			
			}else{
				ajax_member_word_period_setting(user_seq, type, chk, true, start_date, end_date);
			}
	    }
	    else{
	    	$("li.check").hide();
	    	$("#periodLabel").show();
	  		ajax_member_word_total(user_seq,type, 1,true);
	    }
	})
	
	$("#pair_type_member_sentiment").on('click','li', function(event){
		if($("#sentiment_loadingBar_wordtable").is(':visible'))
			return;
		
		if($(event.target).attr("id").includes("before"))
			return;
		
		$("#pair_type_member_sentiment li").removeClass('active');
		$(event.target).addClass('active');
		var pair_type = $(event.target).text()
		var type = 1;
		if(pair_type == "부정단어")
			type = -1;
		
		var front = 1;
		var date_period_string = "";
		
		var type = 0;
		if($($("#pair_type_member_sentiment li")[0]).attr('class').includes("active"))
			type = 1;
		else
			type = -1;
		
		var score_data = null;
		if(type == 1)
			score_data = sentiment_word_score['positive'];
		else
			score_data = sentiment_word_score['negative'];
		
		var on_off_text = "OFF";
		if($("#sentiment_member_wordcloud_rect").attr("class").includes("on"))
			on_off_text = "OFF"; 
		else
			on_off_text = "ON";
		
		var front = 1;
		var date_period_string = "";
		
		build_wordcloud_sentiment(score_data,false,front,date_period_string, on_off_text);
		build_wordTable_sentiment(score_data,false,front, on_off_text);
		
		//build_wordcloud_sentiment(sentiment_word_score,false,front,date_period_string, on_off_text);
		//build_wordTable_sentiment(sentiment_word_score,false,front, on_off_text);
	})
	
	$("#removeCheck").on("click",function(event){
		var chk = $("#removeCheck").is(":checked");
		$("#period_setting").hide();
		
		var pair_type = $("#pair_type_member li.active").text()
		var test = $("#pair_type_member li").text();
		var type = 0;
		if(pair_type == "단어 쌍")
			type = 1;
		
		var period = $('.sub_tab_member-link.current').text();
		$(".linechart").hide();
		if(period == "주간"){
	    	period = 7;
	    	ajax_member_word_period(user_seq,type, period, chk,true);
	    }
	    else if(period == "월간"){
	    	period = 30;
	    	ajax_member_word_period(user_seq,type, period, chk,true);
	    }
	    else if(period == "분기"){
	    	period = 90;
	    	ajax_member_word_period(user_seq,type, period, chk,true);
	    }
	    else if(period == "기간설정"){
	    	$("#period_setting").show();
	    	var start_date = $("#start_datepicker").val();
			var end_date = $("#end_datepicker").val();
			
			var today_string = setting_today();
			if(start_date === today_string && end_date === today_string){
				ajax_member_word_today_setting(user_seq, type, chk, true, start_date, end_date);
			}else{
				ajax_member_word_period_setting(user_seq, type, chk, true, start_date, end_date);	
			}
	    }
	})
	
	$(document).on("click", "#periodCheck", function() {
		var chk = $("#periodCheck").is(":checked");
		global_period_check = chk;
		//history_change 함수 호출...
		var IDname = "member_wordcloud";
		history_change(global_item, IDname);
	})
	/*
	// 오늘의 뉴스 정사각형
	var check_square = $("#check_square_total");
	var on_off_text_total = "";
	check_square.click(function() {
		$(".p_square_check_total").toggle();
		var p_square_check = $(".p_square_check_total");
		for(var i = 0; i < p_square_check.length; i++){
			var p_tag = $(p_square_check[i]);
			if(p_tag.is(':visible')){
				on_off_text_total = p_tag.text();
			}
		}
		
		//신문 1면인지 아닌지
		var front = 1;
		var front_text = $('.sub_tab-link.current').text()
		if(front_text.indexOf("1면") >= 0){
			front = 2;
		}
		
		//단일단어 / 단어쌍 여부
		var type = 0;
		var pair_type = $('#pair_type').children('.active').text();
		if(pair_type == '단어 쌍'){
			type = 1;
		}
		
		// 해당 정보로 wordcloud 밑 table 그리게끔 만들면됌			
		ajax_total_word_score_on_off_toggle(type,front);//
	});
	*/
	
	//오늘의 뉴스 직사각형2
	$("#total_wordcloud_rect").click(function() {
		$("#total_wordcloud_square").removeClass("on");
		$("#total_wordcloud_rect").addClass("on");
		
		$("#wordcloud").removeClass("vt");
		$("#word-table").removeClass("vt");
		
		//신문 1면인지 아닌지
		var front = 1;
		var front_text = $('.sub_tab-link.current').text()
		if(front_text.indexOf("1면") >= 0){
			front = 2;
		}
		
		//단일단어 / 단어쌍 여부
		var type = 0;
		var pair_type = $('#pair_type').children('.active').text();
		if(pair_type == '단어 쌍'){
			type = 1;
		}
		ajax_total_word_score_on_off_toggle(type,front);
	})
	//오늘의 뉴스 정사각형2
	$("#total_wordcloud_square").click(function() {
		$("#total_wordcloud_rect").removeClass("on");
		$("#total_wordcloud_square").addClass("on");
		

		$("#wordcloud").addClass("vt");
		$("#word-table").addClass("vt");
		
		//신문 1면인지 아닌지
		var front = 1;
		var front_text = $('.sub_tab-link.current').text()
		if(front_text.indexOf("1면") >= 0){
			front = 2;
		}
		
		//단일단어 / 단어쌍 여부
		var type = 0;
		var pair_type = $('#pair_type').children('.active').text();
		if(pair_type == '단어 쌍'){
			type = 1;
		}
		
		ajax_total_word_score_on_off_toggle(type,front);
	})
	
	/*
	//프리미엄 뉴스 정사각형
	var check_square_member = $("#check_square_member");
	var on_off_text_member = "";
	check_square_member.click(function() {
		$(".p_square_check_member").toggle();
		var p_square_check = $(".p_square_check_member");
		for(var i = 0; i < p_square_check.length; i++){
			var p_tag = $(p_square_check[i]);
			if(p_tag.is(':visible')){
				on_off_text_member = p_tag.text();
			}
		}
		
		// 단어쌍 여부
		var type = 0;
		var pair_type = $('#pair_type_member').children('.active').text();
		if(pair_type == "단어 쌍")
			type=1;
		var chk = $("#removeCheck").is(":checked");
		
		
		var period = $('.sub_tab_member-link.current').text();
		//$(".linechart").hide();
		if(period == "주간"){
	    	period = 7;
	    	ajax_member_word_period_on_off_toggle(user_seq,type, period, chk,false);
	    }
	    else if(period == "월간"){
	    	period = 30;
	    	ajax_member_word_period_on_off_toggle(user_seq,type, period, chk,false);
	    }
	    else if(period == "분기"){
	    	period = 90;
	    	ajax_member_word_period_on_off_toggle(user_seq,type, period, chk,false);
	    }
	    else if(period == "기간설정"){
	    	$("#period_setting").show();
	    	var start_date = $("#start_datepicker").val();
			var end_date = $("#end_datepicker").val();
	    	ajax_member_word_period_setting_on_off_toggle(user_seq, type, chk, false, start_date, end_date);
	    }else{
	    	ajax_member_word_total_on_off_toggle(user_seq,type, 1,false);
	    }
	});
	*/
	
	//프리미엄 뉴스 직사각형2
	$("#member_wordcloud_rect").click(function() {
		$("#member_wordcloud_square").removeClass("on");
		$("#member_wordcloud_rect").addClass("on");
		
		$("#member_wordcloud").removeClass("vt");
		$("#member_word-table").removeClass("vt");
		
		// 단어쌍 여부
		var type = 0;
		var pair_type = $('#pair_type_member').children('.active').text();
		if(pair_type == "단어 쌍")
			type=1;
		var chk = $("#removeCheck").is(":checked");
		
		
		var period = $('.sub_tab_member-link.current').text();
		//$(".linechart").hide();
		if(period == "주간"){
	    	period = 7;
	    	ajax_member_word_period_on_off_toggle(user_seq,type, period, chk,false);
	    }
	    else if(period == "월간"){
	    	period = 30;
	    	ajax_member_word_period_on_off_toggle(user_seq,type, period, chk,false);
	    }
	    else if(period == "분기"){
	    	period = 90;
	    	ajax_member_word_period_on_off_toggle(user_seq,type, period, chk,false);
	    }
	    else if(period == "기간설정"){
	    	$("#period_setting").show();
	    	var start_date = $("#start_datepicker").val();
			var end_date = $("#end_datepicker").val();
			
			var today_string = setting_today();
			if(start_date === today_string && end_date === today_string){
				ajax_member_word_today_setting(user_seq, type, chk, true, start_date, end_date);			
			}else{
	    		ajax_member_word_period_setting_on_off_toggle(user_seq, type, chk, false, start_date, end_date);
			}
	    }else{
	    	ajax_member_word_total_on_off_toggle(user_seq,type, 1,false);
	    }
	})
	//프리미엄 뉴스 정사각형2
	$("#member_wordcloud_square").click(function() {
		$("#member_wordcloud_rect").removeClass("on");
		$("#member_wordcloud_square").addClass("on");
		
		$("#member_wordcloud").addClass("vt");
		$("#member_word-table").addClass("vt");
		
		// 단어쌍 여부
		var type = 0;
		var pair_type = $('#pair_type_member').children('.active').text();
		if(pair_type == "단어 쌍")
			type=1;
		var chk = $("#removeCheck").is(":checked");
		
		
		var period = $('.sub_tab_member-link.current').text();
		//$(".linechart").hide();
		if(period == "주간"){
	    	period = 7;
	    	ajax_member_word_period_on_off_toggle(user_seq,type, period, chk,false);
	    }
	    else if(period == "월간"){
	    	period = 30;
	    	ajax_member_word_period_on_off_toggle(user_seq,type, period, chk,false);
	    }
	    else if(period == "분기"){
	    	period = 90;
	    	ajax_member_word_period_on_off_toggle(user_seq,type, period, chk,false);
	    }
	    else if(period == "기간설정"){
	    	$("#period_setting").show();
	    	var start_date = $("#start_datepicker").val();
			var end_date = $("#end_datepicker").val();
			
			var today_string = setting_today();
			if(start_date === today_string && end_date === today_string){
				ajax_member_word_today_setting(user_seq, type, chk, true, start_date, end_date);			
			}else{
	    		ajax_member_word_period_setting_on_off_toggle(user_seq, type, chk, false, start_date, end_date);
			}
	    }else{
	    	ajax_member_word_total_on_off_toggle(user_seq,type, 1,false);
	    }
	})
	
	//기간 설정 긍부정 워드 클라우드 직사각형
	$("#sentiment_member_wordcloud_rect").click(function() {
		if($("#sentiment_loadingBar_wordtable").is(':visible'))
			return;
		
		$("#sentiment_member_wordcloud_square").removeClass("on");
		$("#sentiment_member_wordcloud_rect").addClass("on");
		
		$("#member_wordcloud_sentiment").removeClass("vt");
		$("#sentiment_member_word-table").removeClass("vt");
		/*
		// 단어쌍 여부
		var type = 0;
		var pair_type = $('#pair_type_member_sentiment').children('.active').text();
		if(pair_type == "단어 쌍")
			type=1;
		var chk = $("#removeCheck").is(":checked");
		*/
		var chk = $("#removeCheck").is(":checked");
		start_date = $("#start_datepicker").val();

	    end_date = $("#end_datepicker").val();
	    
		//ajax_member_sentiment_word_period_setting(user_seq, type, chk, true, start_date, end_date);
		
		
		
		var type = 0;
		if($($("#pair_type_member_sentiment li")[0]).attr('class').includes("active"))
			type = 1;
		else
			type = -1;
		
		var score_data = null;
		if(type == 1)
			score_data = sentiment_word_score['positive'];
		else
			score_data = sentiment_word_score['negative'];
		
		var front = 1;
		var date_period_string = "";
		var on_off_text = "OFF";
		build_wordcloud_sentiment(score_data,false,front,date_period_string, on_off_text);
		build_wordTable_sentiment(score_data,false,front, on_off_text);
		
	})
	//기간 설정 긍부정 워드 클라우드 정사각형
	$("#sentiment_member_wordcloud_square").click(function() {
		if($("#sentiment_loadingBar_wordtable").is(':visible'))
			return;
		
		$("#sentiment_member_wordcloud_rect").removeClass("on");
		$("#sentiment_member_wordcloud_square").addClass("on");
		
		$("#member_wordcloud_sentiment").addClass("vt");
		$("#sentiment_member_word-table").addClass("vt");

		var chk = $("#removeCheck").is(":checked");
		start_date = $("#start_datepicker").val();

	    end_date = $("#end_datepicker").val();
	    
		//ajax_member_sentiment_word_period_setting(user_seq, type, chk, true, start_date, end_date);
	    //
	    var type = 0;
		if($($("#pair_type_member_sentiment li")[0]).attr('class').includes("active"))
			type = 1;
		else
			type = -1;
		
		var score_data = null;
		if(type == 1)
			score_data = sentiment_word_score['positive'];
		else
			score_data = sentiment_word_score['negative'];
		
		var front = 1;
		var date_period_string = "";
		var on_off_text = "ON";
		build_wordcloud_sentiment(score_data,false,front,date_period_string, on_off_text);
		build_wordTable_sentiment(score_data,false,front, on_off_text);
	})
})

function showText() {
  var x = document.getElementById("info-text");
  if (x.style.display === "none") {
    x.style.display = "inline";
  } else {
    x.style.display = "none";
  }
}

function ajax_total_word_score(type, front){
	var on_off_text_total = "";
	/*
	var p_square_check = $(".p_square_check_total");
	for(var i = 0; i < p_square_check.length; i++){
		var p_tag = $(p_square_check[i]);
		if(p_tag.is(':visible')){
			on_off_text_total = p_tag.text();
		}
	}
	*/
	if($("#total_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
		on_off_text_total = "OFF";
	}
	else{
		on_off_text_total = "ON";
	}
	
	var minute10_ago = today_10ago();
	var date_period_string = minute10_ago;
	$.ajax({
        type : 'POST',
        url : './utils/total_word_score.jsp',
        data : {pair_type : type,
        		front : front},
        dataType : 'json',
        async: true,
        success : function(data) {
            //data, total or member, front
        	if(eval(data).length == 0){
        		if(front == 1){
        			total_info_();
        		}else{
            		sunday();
        		}
            }else{
            	$("#loadingBar_wordcloud_total").hide();
            	$("#wordcloud svg").show();
            	
            	$("#loadingBar_wordtable_total").hide();
            	$("#total_word_table_ul").show(); //
            	
            	//$("#total_score_display").css("display","block");
            	if(front == 2)
            		$(".total_info").html('<li>신문 '+paper_media_count+'종의 1면을 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다.<a href="#" onclick = "showTFIDFPopup()">TF-IDF란?</a></li');
            	else
            		$(".total_info").html('<li>신문 '+paper_media_count+'종과 인터넷 뉴스 '+online_media_count+'종을 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다.<a href="#" onclick = "showTFIDFPopup()">TF-IDF란?</a></li>'+
	                        '<li>10분마다 갱신됩니다.</li>');
            	$("#pair_type").css("display","block");
            	$("#wordcloud").css("display","block");
            	$("#word-table").css("display","block");
	        	build_wordcloud(data,false,front,date_period_string, on_off_text_total);
	            build_wordTable(data,false,front, on_off_text_total);
            }
        },
        beforeSend : function() {
        	$("#loadingBar_wordcloud_total").show();
        	$("#wordcloud svg").hide();
        	
        	$("#loadingBar_wordtable_total").show();
        	$("#total_word_table_ul").hide(); //
        },
        error : function(e) {
            //alert(e.responseText)
        }
    });
}

//오늘의 주요 키워드 on/off toggle
function ajax_total_word_score_on_off_toggle(type, front){
	var on_off_text_total = "";
	/*
	var p_square_check = $(".p_square_check_total");
	for(var i = 0; i < p_square_check.length; i++){
		var p_tag = $(p_square_check[i]);
		if(p_tag.is(':visible')){
			on_off_text_total = p_tag.text();
		}
	}
	*/
	
	if($("#total_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
		on_off_text_total = "OFF";
	}
	else{
		on_off_text_total = "ON";
	}
	
	
	var minute10_ago = today_10ago();
	var date_period_string = minute10_ago;
	$.ajax({
        type : 'POST',
        url : './utils/total_word_score.jsp',
        data : {pair_type : type,
        		front : front},
        dataType : 'json',
        async: true,
        success : function(data) {
        	$("#loadingBar_wordcloud_total").hide();
        	$("#wordcloud svg").show();
        	
        	$("#loadingBar_wordtable_total").hide();
        	$("#total_word_table_ul").show(); //
            //data, total or member, front
        	if(eval(data).length == 0){
        		if(front == 1){
        			total_info_();
        		}else{
            		sunday();
        		}
            }else{
            	
            	
            	//$("#total_score_display").css("display","block");
            	if(front == 2)
            		$(".total_info").html('<li>신문 '+paper_media_count+'종의 1면을 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다.<a href="#" onclick = "showTFIDFPopup()">TF-IDF란?</a></li');
            	else
            		$(".total_info").html('<li>신문 '+paper_media_count+'종과 인터넷 뉴스 '+online_media_count+'종을 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다.<a href="#" onclick = "showTFIDFPopup()">TF-IDF란?</a></li>'+
	                        '<li>10분마다 갱신됩니다.</li>');
            	$("#pair_type").css("display","block");
            	$("#wordcloud").css("display","block");
            	$("#word-table").css("display","block");
	        	build_wordcloud(data,false,front,date_period_string, on_off_text_total);
	            build_wordTable(data,false,front, on_off_text_total);
            }
        },
        beforeSend : function(){
        	$("#loadingBar_wordcloud_total").show();
        	$("#wordcloud svg").hide();
        	
        	$("#loadingBar_wordtable_total").show();
        	$("#total_word_table_ul").hide(); //
        },
        error : function(e) {
            //alert(e.responseText)
        }
    });
}

function ajax_word_score_history_return(word_seq,period_text, word, IDname, periodCheck){
	//단어 추이선
	$.ajax({
        type : 'POST',
        url : './utils/word_score_history.jsp',
        data : {word_seq : word_seq,
        		user_seq : user_seq,
        	}, //default = word_seq
        dataType : 'json',
        async: true,
        success : function(data) {
        	//$("#text").text(item[0]);
        	//$(".history_info_text_total").show();
            
        	score_history_line_chart(data,period_text, word, IDname, periodCheck);
        	
        },
        beforeSend:function(){

            //(이미지 보여주기 처리)
			
            $("#loadingBar").show();
            var tag = '프리미엄 등록 기사 '+""+' 주요 키워드 추이 : <span id="text_total"></span> <span class = "member_history_info" style = "float: right; color: #999; font-size: 13px; font-weight: 300;"> <span onclick="show_tfidf_infotext()" class="line_info_button" style="visibility: visible;cursor: pointer;">ⓘ</span> 점수는 TF-IDF 알고리즘으로 분석한 결과입니다.</span>'
    		$('.history_info_text_total').html(tag);
            //$(".history_info_text_total").hide();
            $(".linechart").hide();
            //$('.wrap-loading').removeClass('display-none');

        },
        complete:function(){

            //(이미지 감추기 처리)
			//$(".linechart").hide();
			//$("#loadingBar").hide();
            //$('.wrap-loading').addClass('display-none');

     

        },
        error : function(e) {
            //alert(e.responseText)
            
        }
    });
}

function ajax_member_word_period(user_seq,type, period, chk,start){
	var on_off_text_member = "";
	/*
	var p_square_check = $(".p_square_check_member");
	for(var i = 0; i < p_square_check.length; i++){
		var p_tag = $(p_square_check[i]);
		if(p_tag.is(':visible')){
			on_off_text_member = p_tag.text();
		}
	}
	*/
	if($("#member_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
		on_off_text_member = "OFF";
	}
	else{
		on_off_text_member = "ON";
	}
	
	var today = yesterday();
	var today_minus_period = today_minus(period);
	//console.log(today_minus_period+" ~ "+today)
	var date_period_string = today_minus_period+" ~ "+today
	var front = 1;
	
	$.ajax({
        type : 'POST',
        url : './utils/word_score_by_period.jsp',
        data : {user_seq : user_seq,
        		pair_type : type,
        		period : period,
        		removeCheck : chk}, //default = 7
        dataType : 'json',
        async: true,
        success : function(data) {
        	data.sort(function(a,b) {
        		if(a[2] - b[2] == 0){
        			return a[1] < b[1] ? -1 : a[1] > b[1] ? 1 : 0;
        		}
        		else{
        			return b[2] - a[2];
        		}
        	})
        	
        	//해당 주기에 데이터가 존재하지 않을 수 있다.
        	if(eval(data).length == 0){	
            	period_info_();
            	//$("#period_setting").show();
            }else{
            	if(start){
            		$(".history").css("display","block");
            		history_change(data[0],"member_wordcloud");
            	}
            	
            	//var start_time_2 = new Date().getTime();
            	$(".member_total_info").html('<li>프리미엄 서비스 출시 이후 고객님의 계정에 어제까지 뷰어에 등록된 모든 기사를 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다.<a href="#" onclick = "showTFIDFPopup()">TF-IDF란?</a></li>'+
            			'<li>스크랩마스터 프리미엄 뷰어에 등록된 기사 수가 적은 경우 워드클라우드의 결과가 다소 미흡해 보일 수 있으나, 이는 시스템 오류가 아닌 점 참고 부탁드립니다.</li>'
            			+'<li>워드클라우드에서 단어를 클릭하면 해당 단어가 기사 내 언급된 날짜별 추이로 아래 그래프에 반영됩니다. 그래프의 특정 위치를 클릭하면 해당 일자와 점수를 확인할 수 있습니다.</li>');
            	$(".sub_tab_member-content").css("display","block");
            	$("#pair_type_member").css("display","block");
            	//버튼 보이게
            	$("#blobButton_member").css("display","block");
        		$("#blobButton_member_excel").css("display","inline-block");
        		$("#removeSpace").css("display","inline-block");
            	
            	$("#member_score_display").css("display","block");
            	$("#member_wordcloud").css("display","block");
            	$("#member_word-table").css("display","block");
            	
	        	build_wordcloud(data,true,front, date_period_string, on_off_text_member);
	            build_wordTable(data,true,front, on_off_text_member);
            }
        	$("#member_wordcloud svg").show();
        	$("#member_word-table_ul").show();
        	$("#search_keyword_member_button").show();
        },
        beforeSend:function() {
        	$(".member_total_info").html("<li>해당 기간동안 스크랩된 기사 키워드를 불러오는 중입니다.</li>");
        	$("#period_setting").hide();
        	
        	$("#loadingBar_wordcloud").show();
        	$("#member_wordcloud svg").hide();
        	
        	$("#loadingBar_wordtable").show();
        	$("#member_word-table_ul").hide();
        	
        	$("#search_keyword_member_button").hide();
        	
        	$("#loadingBar").show();
        	var tag = '프리미엄 등록 기사 주요 키워드 추이 : <span id="text_total"></span> <span onclick="show_history_infoText()" class="line_info_button" style="visibility: visible;cursor: pointer;">ⓘ</span><span class = "member_history_info" style = "float: right; color: #999; font-size: 13px; font-weight: 300;"> 점수는 TF-IDF 알고리즘으로 분석한 결과입니다.</span>'
     		$('.history_info_text_total').html(tag);
        	
        },
        complete:function() {
        	$("#loadingBar_wordcloud").hide();
        	$("#loadingBar_wordtable").hide();
        	
        	//$("#loadingBar").hide();
        },
        error : function(e) {
            //alert(e.responseText)
            
        }
    });
}

//프리미엄 사용자 기간 설정 (주간,월간,분기) on/off toggle
function ajax_member_word_period_on_off_toggle(user_seq,type, period, chk,start) {
	var on_off_text_member = "";
	/*
	var p_square_check = $(".p_square_check_member");
	for(var i = 0; i < p_square_check.length; i++){
		var p_tag = $(p_square_check[i]);
		if(p_tag.is(':visible')){
			on_off_text_member = p_tag.text();
		}
	}
	*/
	
	if($("#member_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
		on_off_text_member = "OFF";
	}
	else{
		on_off_text_member = "ON";
	}
	
	
	var today = yesterday();
	var today_minus_period = today_minus(period);
	//console.log(today_minus_period+" ~ "+today)
	var date_period_string = today_minus_period+" ~ "+today
	var front = 1;
	
	$.ajax({
        type : 'POST',
        url : './utils/word_score_by_period.jsp',
        data : {user_seq : user_seq,
        		pair_type : type,
        		period : period,
        		removeCheck : chk}, //default = 7
        dataType : 'json',
        async: true,
        success : function(data) {
        	data.sort(function(a,b) {
        		if(a[2] - b[2] == 0){
        			return a[1] < b[1] ? -1 : a[1] > b[1] ? 1 : 0;
        		}
        		else{
        			return b[2] - a[2];
        		}
        	})
        	
        	//해당 주기에 데이터가 존재하지 않을 수 있다.
        	if(eval(data).length == 0){	
            	period_info_();
            	//$("#period_setting").show();
            }else{
            	if(start){
            		$(".history").css("display","block");
            		history_change(data[0],"member_wordcloud");
            	}
            	
            	//var start_time_2 = new Date().getTime();
            	$(".member_total_info").html('<li>프리미엄 서비스 출시 이후 고객님의 계정에 어제까지 뷰어에 등록된 모든 기사를 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다.<a href="#" onclick = "showTFIDFPopup()">TF-IDF란?</a></li>'+
            			'<li>스크랩마스터 프리미엄 뷰어에 등록된 기사 수가 적은 경우 워드클라우드의 결과가 다소 미흡해 보일 수 있으나, 이는 시스템 오류가 아닌 점 참고 부탁드립니다.</li>'
            			+'<li>워드클라우드에서 단어를 클릭하면 해당 단어가 기사 내 언급된 날짜별 추이로 아래 그래프에 반영됩니다. 그래프의 특정 위치를 클릭하면 해당 일자와 점수를 확인할 수 있습니다.</li>');
            	$(".sub_tab_member-content").css("display","block");
            	$("#pair_type_member").css("display","block");
            	//버튼 보이게
            	$("#blobButton_member").css("display","block");
        		$("#blobButton_member_excel").css("display","inline-block");
        		$("#removeSpace").css("display","inline-block");
            	
            	$("#member_score_display").css("display","block");
            	$("#member_wordcloud").css("display","block");
            	$("#member_word-table").css("display","block");
            	
	        	build_wordcloud(data,true,front, date_period_string, on_off_text_member);
	            build_wordTable(data,true,front, on_off_text_member);
            }
        	$("#member_wordcloud svg").show();
        	//$("#member_word-table_ul").show();
        	//$("#search_keyword_member_button").show();
        },
        beforeSend:function() {
        	$(".member_total_info").html("<li>해당 기간동안 스크랩된 기사 키워드를 불러오는 중입니다.</li>");
        	$("#period_setting").hide();
        	
        	$("#loadingBar_wordcloud").show();
        	$("#member_wordcloud svg").hide();
        	
        	$("#loadingBar_wordtable").show();
        	$("#member_word-table_ul").hide();
        	
        	//$("#search_keyword_member_button").hide();
        	
        	//$("#loadingBar").show();
        	//var tag = '프리미엄 등록 기사 주요 키워드 추이 : <span id="text_total"></span> <span onclick="show_history_infoText()" class="line_info_button" style="visibility: visible;cursor: pointer;">ⓘ</span><span class = "member_history_info" style = "float: right; color: #999; font-size: 13px; font-weight: 300;"> 점수는 TF-IDF 알고리즘으로 분석한 결과입니다.</span>'
     		//$('.history_info_text_total').html(tag);
        	
        },
        complete:function() {
        	$("#loadingBar_wordcloud").hide();
        	$("#loadingBar_wordtable").hide();
        	
        	//$("#loadingBar").hide();
        },
        error : function(e) {
            //alert(e.responseText)
            
        }
    });
}

function ajax_member_sentiment_word_period_setting(user_seq, type, chk, start, start_date, end_date){
	if(sentiment_xhr && sentiment_xhr.readystate != 4){
		sentiment_xhr.abort();
    }
	
	var st_date = date_name_return(start_date);
	var ed_date = date_name_return(end_date);
	var date_period_string = st_date;
	if(st_date != ed_date)
		var date_period_string = st_date+" ~ "+ed_date;
	var front = 1;
	
	var on_off_text = "";
	if($("#sentiment_member_wordcloud_rect").attr("class").includes("on"))
		on_off_text = "OFF";
	else
		on_off_text = "ON";
	
	var type = 0;
	if($($("#pair_type_member_sentiment li")[0]).attr('class').includes("active"))
		type = 1;
	else
		type = -1;
	
	sentiment_xhr = $.ajax({ 
        type : 'POST',
        url : './utils/member_sentiment_word_cloud.jsp',
        data : {user_seq : user_seq,
        		//pair_type : type,
        		start_date : start_date,
        		end_date : end_date,
        		//removeCheck : chk,
        		}, //default = 7
        dataType : 'json',
        async: true,
        success : function(data) {
        	
        	sentiment_word_score = JSON.parse(JSON.stringify(data));
        	if(type == 1)
        		data = data['positive'];
        	else
        		data = data['negative'];
        	build_wordcloud_sentiment(data,false,front,date_period_string, on_off_text);
        	build_wordTable_sentiment(data,false,front,on_off_text);
        },
        beforeSend:function(xhr, opts) {
        	
        	//$("#period_setting").hide();
        	//$(".member_total_info").html("해당 기간동안 스크랩된 기사 데이터가 없습니다.");
        	$("#member_wordcloud_sentiment").show();
        	$("#sentiment_loadingBar_wordcloud").show();
        	$("#member_wordcloud_sentiment svg").hide();
        	
        	$("#sentiment_member_word-table").show();
        	$("#sentiment_loadingBar_wordtable").show();
        	$("#sentiment_member_word-table_ul").hide();
        	
        	//sentiment_xhr = xhr;
        	/*
        	$("#loadingBar").show();
        	$(".linechart").hide();
        	*/
        },
        complete:function() {
        	
        	$("#sentiment_loadingBar_wordcloud").hide();
        	$("#sentiment_loadingBar_wordtable").hide();
        	
        },
        error : function(e) {
            //alert(e.responseText)
        }
    });
}

// today setting
function ajax_member_word_today_setting(user_seq, type, chk, start, start_date, end_date){
	var on_off_text_member = "";
	/*
	var p_square_check = $(".p_square_check_member");
	for(var i = 0; i < p_square_check.length; i++){
		var p_tag = $(p_square_check[i]);
		if(p_tag.is(':visible')){
			on_off_text_member = p_tag.text();
		}
	}
	*/
	if($("#member_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
		on_off_text_member = "OFF";
	}
	else{
		on_off_text_member = "ON";
	}
	
	var st_date = date_name_return(start_date);
	var ed_date = date_name_return(end_date);
	var date_period_string = st_date;
	if(st_date != ed_date)
		var date_period_string = st_date+" ~ "+ed_date;
	var front = 1;
	$.ajax({
        type : 'POST',
        url : './utils/word_score_by_today_setting.jsp',
        data : {user_seq : user_seq,
        	pair_type : type,
        		start_date : start_date,
        		end_date : end_date,
        		removeCheck : chk,
        		}, //default = 7
        dataType : 'json',
        async: true,
        success : function(data) {
        	// console.log(data); {"word_pair": [], "word" : [] }
        	load_boolean = true;
        	
        	today_word_score = JSON.parse(JSON.stringify(data));
        	
        	if(type == 0)
        		data = today_word_score['word']
        	else
        		data = today_word_score['word_pair']
        	
        	console.log(chk);
        	var start_word_data = data[0];
        	if(chk){
        		start_word_data = data[0];
        	}else{
        		for(var i = 0; i < data.length; i++){
        			if(data[i]['accumulate'] == false){
        				start_word_data = data[i];
        				break;
        			}
        		}
        	}
        	
        	if(start){
        		$(".history").css("display","block");
        		$(".linechart").hide();
        		history_change_today(start_word_data,"member_wordcloud"); // history_change 교체 필요-> 기록을 불러올수 없기 때문
        	}
        	//해당 주기에 데이터가 존재하지 않을 수 있다.
        	if(eval(data).length == 0){	
            	period_info_();
            	$("#period_setting").show();
            }else{
            	$(".member_total_info").html('<li>프리미엄 서비스 출시 이후 고객님의 계정에 어제까지 뷰어에 등록된 모든 기사를 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다.<a href="#" onclick = "showTFIDFPopup()">TF-IDF란?</a></li>'+
            			'<li>스크랩마스터 프리미엄 뷰어에 등록된 기사 수가 적은 경우 워드클라우드의 결과가 다소 미흡해 보일 수 있으나, 이는 시스템 오류가 아닌 점 참고 부탁드립니다.</li>'
            			+'<li>워드클라우드에서 단어를 클릭하면 해당 단어가 기사 내 언급된 날짜별 추이로 아래 그래프에 반영됩니다. 그래프의 특정 위치를 클릭하면 해당 일자와 점수를 확인할 수 있습니다.</li>');
            	$(".sub_tab_member-content").css("display","block");
            	$("#period_setting").show();
            	$("#pair_type_member").css("display","block");
            	//버튼 보이게
            	$("#blobButton_member").css("display","block");
        		$("#blobButton_member_excel").css("display","inline-block");
        		$("#removeSpace").css("display","inline-block");
            	
            	$("#member_score_display").css("display","block");
            	$("#member_wordcloud").css("display","block");
            	$("#member_word-table").css("display","block");
            	
	        	build_wordcloud_todayscore(data,true,front, date_period_string, on_off_text_member);
	            build_wordTable_todayscore(data,true,front, on_off_text_member);
            }
        	$("#member_wordcloud svg").show();
        	$("#member_word-table_ul").show();
        	$("#search_keyword_member_button").show();
        },
        beforeSend:function() {
        	$(".member_total_info").html("<li>해당 기간동안 스크랩된 기사 데이터를 불러오는 중입니다.</li>");
        	//$("#period_setting").hide();
        	//$(".member_total_info").html("해당 기간동안 스크랩된 기사 데이터가 없습니다.");
        	
        	$("#loadingBar_wordcloud").show();
        	$("#member_wordcloud svg").hide();
        	
        	$("#loadingBar_wordtable").show();
        	$("#member_word-table_ul").hide();
        	
        	$(".history").css("display","block");
        	$("#loadingBar").show();
        	$(".linechart").hide();
        	var tag = '프리미엄 등록 기사 '+""+' 주요 키워드 추이 : <span id="text_total"></span> <span onclick="show_history_infoText()" class="line_info_button" style="visibility: visible;cursor: pointer;">ⓘ</span><span class = "member_history_info" style = "float: right; color: #999; font-size: 13px; font-weight: 300;"> 점수는 TF-IDF 알고리즘으로 분석한 결과입니다.</span>'
     		$('.history_info_text_total').html(tag);
        	
        	$("#search_keyword_member_button").hide();
        },
        complete:function() {
        	$("#loadingBar_wordcloud").hide();
        	$("#loadingBar_wordtable").hide();
        	//$("#loadingBar").hide();
        },
        error : function(e) {
        	//alert(e.responseText)
        }
    });
}

function ajax_member_word_period_setting(user_seq, type, chk, start,start_date, end_date){
	var on_off_text_member = "";
	/*
	var p_square_check = $(".p_square_check_member");
	for(var i = 0; i < p_square_check.length; i++){
		var p_tag = $(p_square_check[i]);
		if(p_tag.is(':visible')){
			on_off_text_member = p_tag.text();
		}
	}
	*/
	if($("#member_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
		on_off_text_member = "OFF";
	}
	else{
		on_off_text_member = "ON";
	}
	
	
	var st_date = date_name_return(start_date);
	var ed_date = date_name_return(end_date);
	var date_period_string = st_date;
	if(st_date != ed_date)
		var date_period_string = st_date+" ~ "+ed_date;
	var front = 1;
	$.ajax({
        type : 'POST',
        url : './utils/word_score_by_period_setting.jsp',
        data : {user_seq : user_seq,
        	pair_type : type,
        		start_date : start_date,
        		end_date : end_date,
        		removeCheck : chk,
        		}, //default = 7
        dataType : 'json',
        async: true,
        success : function(data) {
        	load_boolean = true;
        	data.sort(function(a,b) {
        		if(a[2] - b[2] == 0){
        			return a[1] < b[1] ? -1 : a[1] > b[1] ? 1 : 0;
        		}
        		else{
        			return b[2] - a[2];
        		}
        	})
        	if(start){
        		$(".history").css("display","block");
        		$(".linechart").hide();
        		history_change(data[0],"member_wordcloud");
        	}
        	//해당 주기에 데이터가 존재하지 않을 수 있다.
        	if(eval(data).length == 0){	
            	period_info_();
            	$("#period_setting").show();
            }else{
            	
            	$(".member_total_info").html('<li>프리미엄 서비스 출시 이후 고객님의 계정에 어제까지 뷰어에 등록된 모든 기사를 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다.<a href="#" onclick = "showTFIDFPopup()">TF-IDF란?</a></li>'+
            			'<li>스크랩마스터 프리미엄 뷰어에 등록된 기사 수가 적은 경우 워드클라우드의 결과가 다소 미흡해 보일 수 있으나, 이는 시스템 오류가 아닌 점 참고 부탁드립니다.</li>'
            			+'<li>워드클라우드에서 단어를 클릭하면 해당 단어가 기사 내 언급된 날짜별 추이로 아래 그래프에 반영됩니다. 그래프의 특정 위치를 클릭하면 해당 일자와 점수를 확인할 수 있습니다.</li>');
            	$(".sub_tab_member-content").css("display","block");
            	$("#period_setting").show();
            	$("#pair_type_member").css("display","block");
            	//버튼 보이게
            	$("#blobButton_member").css("display","block");
        		$("#blobButton_member_excel").css("display","inline-block");
        		$("#removeSpace").css("display","inline-block");
            	
            	$("#member_score_display").css("display","block");
            	$("#member_wordcloud").css("display","block");
            	$("#member_word-table").css("display","block");
	        	build_wordcloud(data,true,front, date_period_string, on_off_text_member);
	            build_wordTable(data,true,front, on_off_text_member);
            }
        	$("#member_wordcloud svg").show();
        	$("#member_word-table_ul").show();
        	$("#search_keyword_member_button").show();
        },
        beforeSend:function() {
        	$(".member_total_info").html("<li>해당 기간동안 스크랩된 기사 데이터를 불러오는 중입니다.</li>");
        	//$("#period_setting").hide();
        	//$(".member_total_info").html("해당 기간동안 스크랩된 기사 데이터가 없습니다.");
        	
        	$("#loadingBar_wordcloud").show();
        	$("#member_wordcloud svg").hide();
        	
        	$("#loadingBar_wordtable").show();
        	$("#member_word-table_ul").hide();
        	
        	$(".history").css("display","block");
        	$("#loadingBar").show();
        	$(".linechart").hide();
        	var tag = '프리미엄 등록 기사 '+""+' 주요 키워드 추이 : <span id="text_total"></span> <span onclick="show_history_infoText()" class="line_info_button" style="visibility: visible;cursor: pointer;">ⓘ</span><span class = "member_history_info" style = "float: right; color: #999; font-size: 13px; font-weight: 300;"> 점수는 TF-IDF 알고리즘으로 분석한 결과입니다.</span>'
     		$('.history_info_text_total').html(tag);
        	
        	$("#search_keyword_member_button").hide();
        },
        complete:function() {
        	$("#loadingBar_wordcloud").hide();
        	$("#loadingBar_wordtable").hide();
        	//$("#loadingBar").hide();
        },
        error : function(e) {
            //alert(e.responseText)
            
        }
    });
}

//프리미엄 사용자 기간 설정(기간 설정 가능) on/off toggle
function ajax_member_word_period_setting_on_off_toggle(user_seq, type, chk, start,start_date, end_date){
	var on_off_text_member = "";
	
	/*
	var p_square_check = $(".p_square_check_member");
	for(var i = 0; i < p_square_check.length; i++){
		var p_tag = $(p_square_check[i]);
		if(p_tag.is(':visible')){
			on_off_text_member = p_tag.text();
		}
	}
	*/
	if($("#member_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
		on_off_text_member = "OFF";
	}
	else{
		on_off_text_member = "ON";
	}
	
	var st_date = date_name_return(start_date);
	var ed_date = date_name_return(end_date);
	var date_period_string = st_date;
	if(st_date != ed_date)
		var date_period_string = st_date+" ~ "+ed_date;
	var front = 1;
	$.ajax({
        type : 'POST',
        url : './utils/word_score_by_period_setting.jsp',
        data : {user_seq : user_seq,
        	pair_type : type,
        		start_date : start_date,
        		end_date : end_date,
        		removeCheck : chk,
        		}, //default = 7
        dataType : 'json',
        async: true,
        success : function(data) {
        	load_boolean = true;
        	data.sort(function(a,b) {
        		if(a[2] - b[2] == 0){
        			return a[1] < b[1] ? -1 : a[1] > b[1] ? 1 : 0;
        		}
        		else{
        			return b[2] - a[2];
        		}
        	})
        	if(start){
        		$(".history").css("display","block");
        		$(".linechart").hide();
        		history_change(data[0],"member_wordcloud");
        	}
        	//해당 주기에 데이터가 존재하지 않을 수 있다.
        	if(eval(data).length == 0){	
            	period_info_();
            	$("#period_setting").show();
            }else{
            	
            	$(".member_total_info").html('<li>프리미엄 서비스 출시 이후 고객님의 계정에 어제까지 뷰어에 등록된 모든 기사를 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다.<a href="#" onclick = "showTFIDFPopup()">TF-IDF란?</a></li>'+
            			'<li>스크랩마스터 프리미엄 뷰어에 등록된 기사 수가 적은 경우 워드클라우드의 결과가 다소 미흡해 보일 수 있으나, 이는 시스템 오류가 아닌 점 참고 부탁드립니다.</li>'
            			+'<li>워드클라우드에서 단어를 클릭하면 해당 단어가 기사 내 언급된 날짜별 추이로 아래 그래프에 반영됩니다. 그래프의 특정 위치를 클릭하면 해당 일자와 점수를 확인할 수 있습니다.</li>');
            	$(".sub_tab_member-content").css("display","block");
            	$("#period_setting").show();
            	$("#pair_type_member").css("display","block");
            	//버튼 보이게
            	$("#blobButton_member").css("display","block");
        		$("#blobButton_member_excel").css("display","inline-block");
        		$("#removeSpace").css("display","inline-block");
            	
            	//$("#member_score_display").css("display","block");
            	$("#member_wordcloud").css("display","block");
            	$("#member_word-table").css("display","block");
	        	build_wordcloud(data,true,front, date_period_string, on_off_text_member);
	            build_wordTable(data,true,front, on_off_text_member);
            }
        	$("#member_wordcloud svg").show();
        	//$("#member_word-table_ul").show();
        	$("#search_keyword_member_button").show();
        },
        beforeSend:function() {
        	$(".member_total_info").html("<li>해당 기간동안 스크랩된 기사 데이터를 불러오는 중입니다.</li>");
        	//$("#period_setting").hide();
        	//$(".member_total_info").html("해당 기간동안 스크랩된 기사 데이터가 없습니다.");
        	
        	$("#loadingBar_wordcloud").show();
        	$("#member_wordcloud svg").hide();
        	
        	$("#loadingBar_wordtable").show();
        	$("#member_word-table_ul").hide();
        	
        	//$(".history").css("display","block");
        	//$("#loadingBar").show();
        	//$(".linechart").hide();
        	//var tag = '프리미엄 등록 기사 '+""+' 주요 키워드 추이 : <span id="text_total"></span> <span onclick="show_history_infoText()" class="line_info_button" style="visibility: visible;cursor: pointer;">ⓘ</span><span class = "member_history_info" style = "float: right; color: #999; font-size: 13px; font-weight: 300;"> 점수는 TF-IDF 알고리즘으로 분석한 결과입니다.</span>'
     		//$('.history_info_text_total').html(tag);
        	
        	//$("#search_keyword_member_button").hide();
        },
        complete:function() {
        	$("#loadingBar_wordcloud").hide();
        	$("#loadingBar_wordtable").hide();
        	//$("#loadingBar").hide();
        },
        error : function(e) {
            //alert(e.responseText)
            
        }
    });
}

function ajax_member_word_total(user_seq, type, front, start){
	var on_off_text_member = "";
	/*
	var p_square_check = $(".p_square_check_member");
	for(var i = 0; i < p_square_check.length; i++){
		var p_tag = $(p_square_check[i]);
		if(p_tag.is(':visible')){
			on_off_text_member = p_tag.text();
		}
	}
	*/
	
	if($("#member_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
		on_off_text_member = "OFF";
	}
	else{
		on_off_text_member = "ON";
	}
	
	var yester_day = yesterday();
	var user_st_date = date_name_return(user_start_date);
	var date_period_string = user_st_date+" ~ "+yester_day;
	var front = 1;
	$.ajax({
        type : 'POST',
        url : './utils/member_word_score.jsp',
        data : {user_seq : user_seq,
        	pair_type : type,
        	},
        dataType : 'json',
        async: true,
        success : function(data) {
        	data.sort(function(a,b) {
        		if(a[2] - b[2] == 0){
        			return a[1] < b[1] ? -1 : a[1] > b[1] ? 1 : 0;
        		}
        		else{
        			return b[2] - a[2];
        		}
        	})
        	if(start){
        		$(".history").css("display","block");
        		$(".linechart").hide();
        		history_change(data[0],"member_wordcloud");
        	}
        	if(eval(data).length == 0){
        		member_total_info_();
        	}else{
        		$(".member_total_info").html('<li>프리미엄 서비스 출시 이후 고객님의 계정에 어제까지 뷰어에 등록된 모든 기사를 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다.<a href="#" onclick = "showTFIDFPopup()">TF-IDF란?</a></li>'+
        				'<li>스크랩마스터 프리미엄 뷰어에 등록된 기사 수가 적은 경우 워드클라우드의 결과가 다소 미흡해 보일 수 있으나, 이는 시스템 오류가 아닌 점 참고 부탁드립니다.</li>'
        				+'<li>워드클라우드에서 단어를 클릭하면 해당 단어가 기사 내 언급된 날짜별 추이로 아래 그래프에 반영됩니다. 그래프의 특정 위치를 클릭하면 해당 일자와 점수를 확인할 수 있습니다.</li>');
        		$(".sub_tab_member-content").css("display","block");
        		$("#pair_type_member").css("display","block");
        		
        		
        		$("#blobButton_member").css("display","block");
        		$("#blobButton_member_excel").css("display","inline-block");
        		$("#removeSpace").css("display","block");
        		
        		$("#member_score_display").css("display","block");
            	$("#member_wordcloud").css("display","block");
            	$("#member_word-table").css("display","block");
            	$(".history").css("display","block");
	        	build_wordcloud(data,true,front, date_period_string, on_off_text_member);
	            build_wordTable(data,true,front, on_off_text_member);
	            $("#search_keyword_member_button").show();
        	//단어 추이선
            //ajax_word_score_history_return(word_seq,text);
        	}
        },
        beforeSend:function() {
        	/*$(".member_total_info").html("해당 기간동안 스크랩된 기사 데이터를 불러오는 중입니다.");
        	//$("#period_setting").hide();
        	//$(".member_total_info").html("해당 기간동안 스크랩된 기사 데이터가 없습니다.");
        	
        	$("#loadingBar_wordcloud").show();
        	$("#member_wordcloud svg").hide();
        	
        	$("#loadingBar_wordtable").show();
        	$("#member_word-table_ul").hide();*/
        	
        	$(".history").css("display","block");
        	$("#loadingBar").show();
        	$(".linechart").hide();
        	$("#search_keyword_member_button").hide();
        	//var tag = '프리미엄 등록 기사 '+start_date+"~"+end_date+' 주요 키워드 추이 : <span id="text_total"></span> <span onclick="show_history_infoText()" class="line_info_button" style="visibility: visible;">ⓘ</span><span class = "member_history_info" style = "float: right; color: #999; font-size: 13px; font-weight: 300;">점수는 TF-IDF 알고리즘으로 분석한 결과입니다.</span>'
     		//$('.history_info_text_total').html(tag);
        },
        error : function(e) {
            //alert(e.responseText)
        }
    });
}

//오늘의 주요뉴스 on/off toggle
function ajax_member_word_total_on_off_toggle(user_seq, type, front, start) {
	var on_off_text_member = "";
	/*
	var p_square_check = $(".p_square_check_member");
	for(var i = 0; i < p_square_check.length; i++){
		var p_tag = $(p_square_check[i]);
		if(p_tag.is(':visible')){
			on_off_text_member = p_tag.text();
		}
	}
	*/
	
	if($("#member_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
		on_off_text_member = "OFF";
	}
	else{
		on_off_text_member = "ON";
	}
	
	//console.log("on_off_text_member",on_off_text_member);
	
	var yester_day = yesterday();
	var user_st_date = date_name_return(user_start_date);
	var date_period_string = user_st_date+" ~ "+yester_day;
	var front = 1;
	$.ajax({
        type : 'POST',
        url : './utils/member_word_score.jsp',
        data : {user_seq : user_seq,
        	pair_type : type,
        	},
        dataType : 'json',
        async: true,
        success : function(data) {
        	data.sort(function(a,b) {
        		if(a[2] - b[2] == 0){
        			return a[1] < b[1] ? -1 : a[1] > b[1] ? 1 : 0;
        		}
        		else{
        			return b[2] - a[2];
        		}
        	})
        	if(start){
        		$(".history").css("display","block");
        		$(".linechart").hide();
        		history_change(data[0],"member_wordcloud");
        	}
        	if(eval(data).length == 0){
        		member_total_info_();
        	}else{
        		$(".member_total_info").html('<li>프리미엄 서비스 출시 이후 고객님의 계정에 어제까지 뷰어에 등록된 모든 기사를 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다.<a href="#" onclick = "showTFIDFPopup()">TF-IDF란?</a></li>'+
        				'<li>스크랩마스터 프리미엄 뷰어에 등록된 기사 수가 적은 경우 워드클라우드의 결과가 다소 미흡해 보일 수 있으나, 이는 시스템 오류가 아닌 점 참고 부탁드립니다.</li>'
        				+'<li>워드클라우드에서 단어를 클릭하면 해당 단어가 기사 내 언급된 날짜별 추이로 아래 그래프에 반영됩니다. 그래프의 특정 위치를 클릭하면 해당 일자와 점수를 확인할 수 있습니다.</li>');
        		$(".sub_tab_member-content").css("display","block");
        		$("#pair_type_member").css("display","block");
        		
        		
        		$("#blobButton_member").css("display","block");
        		$("#blobButton_member_excel").css("display","inline-block");
        		$("#removeSpace").css("display","block");
        		
        		$("#member_score_display").css("display","block");
            	$("#member_wordcloud").css("display","block");
            	$("#member_word-table").css("display","block");
            	$(".history").css("display","block");
	        	build_wordcloud(data,true,front, date_period_string, on_off_text_member);
	            build_wordTable(data,true,front, on_off_text_member);
	            $("#search_keyword_member_button").show();
        	//단어 추이선
            //ajax_word_score_history_return(word_seq,text);
        	}
        },
        beforeSend:function() {
        	//$(".member_total_info").html("해당 기간동안 스크랩된 기사 데이터를 불러오는 중입니다.");
        	//$("#period_setting").hide();
        	//$(".member_total_info").html("해당 기간동안 스크랩된 기사 데이터가 없습니다.");
        	
        	$("#loadingBar_wordcloud").show();
        	$("#member_wordcloud svg").hide();
        	
        	$("#loadingBar_wordtable").show();
        	$("#member_word-table_ul").hide();
        	
        	//$(".history").css("display","block");
        	//$("#loadingBar").show();
        	//$(".linechart").hide();
        	$("#search_keyword_member_button").hide();
        	//var tag = '프리미엄 등록 기사 '+start_date+"~"+end_date+' 주요 키워드 추이 : <span id="text_total"></span> <span onclick="show_history_infoText()" class="line_info_button" style="visibility: visible;">ⓘ</span><span class = "member_history_info" style = "float: right; color: #999; font-size: 13px; font-weight: 300;">점수는 TF-IDF 알고리즘으로 분석한 결과입니다.</span>'
     		//$('.history_info_text_total').html(tag);
        },
        complete : function() {
        	$("#loadingBar_wordcloud").hide();
        	//$("#member_wordcloud svg").hide();
        	
        	$("#loadingBar_wordtable").hide();
        	//$("#member_word-table_ul").hide();
        },
        error : function(e) {
            //alert(e.responseText)
        }
    });
}

////////////////////////////////////////////////////
function wordcloud(score_data, member, front){
	var words = eval(score_data);
	var max = 0;
	var min = 0;
	var frequency_list = new Array();
	if(words.length == 0)
		return;
	
	if(member){
		if(front === 1){
			IDname = "member_wordcloud";
		}
		else{
			IDname = "member_wordcloud_period";
		}
		max = words[0][2];
		min = words[words.length-1][2];
		
		for(var i = 0; i < words.length; i++){
			var temp = new Array();
			var word = words[i][1];
	       	var score = (words[i][2]-min)/ (max-min) + 0.3;
	        var seq = words[i][0];
	       	//var score = 1/ (1+words[i][1]);
	        temp.push(word);
	        temp.push(score);
	        temp.push(seq);
	        frequency_list.push(temp);
		}
	}
	else{
		if(front === 1){
			IDname = "wordcloud";
		}
		else{
			IDname = "wordcloud_front";
		}
		max = words[0][1];
		min = words[words.length-1][1];
		
		for(var i = 0; i < words.length; i++){
			var temp = new Array();
			var word = words[i][0];
	       	var score = (words[i][1]-min)/ (max-min) + 0.3;
	       	
	        //var score = 1/ (1+words[i][1]);
	        temp.push(word);
	        temp.push(score);
	        frequency_list.push(temp);
		}
	}
	
	
	var canvas = document.getElementById(IDname);
	var options = {
			list: frequency_list,
			fontFamily : "'Noto Sans KR', sans-serif",
			//maskImage : 'C:/Users/tealight/Desktop/hoonzi/bird.png',
			fontWeight:"900",
			shape: "circle",
			drawOutOfBound : false,
			//shrinkToFit:false,
			//minSize : "1000px",
			weightFactor: function (size) {
			    return size * 40;
			  },
			hover : function (){
				
			},
			click : function (item, dimension, event){
				//console.log(event.target.id)
				if(item.length > 2)
					history_change(item, event.target.id);
			},
			//'color':'random-dark',
	}
	
	//WordCloud.minFontSize = "30px";
	WordCloud(canvas, options);
}
///////////////////////////////////////////////////////////

function build_wordcloud(score_data, member,front, date_period_string, on_off_text){
	//document.getElementById("wordcloud").innerHTML = null;
		
	var words = eval(score_data);
	var max = 0;
	var min = 0;
	var pair_type = "";
	var frequency_list = new Array();
	if(words.length == 0)
		return;
	
	if(member){
		IDname = "member_wordcloud";
		
		max = words[0][2];
		min = words[words.length-1][2];
		pair_type = words[0][3];
		
		for(var i = 0; i < words.length; i++){
			var temp_dict = {};
			var word = words[i][1];
			
	       	var score = (words[i][2]-min)/ (max-min) + 0.3;
	        
	       	var seq = words[i][0];
	        pair_type = words[i][3];
	       	//var score = 1/ (1+words[i][1]);
	        /*temp.push(word);
	        temp.push(score);
	        temp.push(seq);
	        frequency_list.push(temp);
	        
	        var temp_dict = {}
	        var word = data[i][0];
	        var score = data[i][1];*/


	        temp_dict['text'] = word;
	        temp_dict["frequency"] = score;
	        temp_dict["seq"] = seq;
	        //temp_dict["pair_type"] = pair_type;
	        frequency_list.push(temp_dict);
		}
		//console.log(frequency_list);
	}
	else{
		IDname = "wordcloud";
		
		max = words[0][1];
		min = words[words.length-1][1];
		
		
		for(var i = 0; i < words.length; i++){
			//var temp = new Array();
			var temp_dict = {};
			var word = words[i][0];
	       	var score = (words[i][1]-min)/ (max-min) + 0.3;
	       	pair_type = words[i][2];
	        //var score = 1/ (1+words[i][1]);
	        /*temp.push(word);
	        temp.push(score);
	        frequency_list.push(temp);*/
	       	temp_dict['text'] = word;
	        temp_dict["frequency"] = score;
	        //temp_dict["pair_type"] = pair_type;
	        //temp_dict["seq"] = seq;
	        frequency_list.push(temp_dict);
		}
	}
    //var x = JSON.parse(frequency_list);
    
    var first_sorting_field = "frequency";
    var second_sorting_field = "text";
    frequency_list.sort(function(a,b) {
    	if(a[first_sorting_field] - b[first_sorting_field] === 0){
    		return a[second_sorting_field] < b[second_sorting_field] ? -1 : a[second_sorting_field] > b[second_sorting_field] ? 1 : 0;
    	}
    	
    	else{
    		return b[first_sorting_field] - a[first_sorting_field];
    	}
    })
    
    
    function showCloud(frequency_list, IDname)
    {
    	
    	$("#"+IDname).children('svg').remove();
    	var weight,width,height;   // change me
    	var domain_max, range_max, domain_min, domain_max;
    	if(on_off_text === "ON"){
    		weight = 3;
        	width = 700;
        	height = 700;
        	range_min = 0, range_max = 150;
    		domain_min = 0, domain_max = 10;
    	}else{
    		weight = 3;
    		width = 700;
    		height = 400;
    		range_min = 0, range_max = 150;
    		domain_min = 0, domain_max = 10;
    	}
    	
    	var fill = d3.scale.category20();
    	var wordScale = d3.scale.linear().range([range_min, range_max]).domain([domain_min, domain_max]).clamp(true); //
		
    	function score_function(d){
    		var text_length = d.text.length;
    		var text_size = wordScale(d.frequency*weight);
    		if(((21 - text_length) * 2) + 31 < text_size){
    			text_size = ((21 - text_length) * 2) + 31
    			console.log(d.text, text_size);
    			return text_size;
    		}
    		else{
    			return text_size;	
    		}
    	}
    	
		d3.layout.cloud().size([width, height]).words(frequency_list)
        //.rotate(function() { return (Math.random() * 2) * 90; })
        .padding(2.5)
        .text(function(d) { return d.text; })
        .rotate(0)
        .font("GmarketSansBold")
        
        .fontSize(function(d) { 
        	return score_function(d); 
        	})
        .on("end", draw)
        .start();
		
		var zoom_group;
          function draw(words) {
            var svg = d3.select("#"+IDname).append("svg")
                .attr("width", width)
                .attr("height", height)
                
                
            zoom_group = svg.append("g")
                .attr("transform", "translate(" + width/2 + "," + height/2 + ")")
            
            zoom_group
              .selectAll("text")
                .data(words)
              .enter().append("text")
                .style("font-size", function(d) { return d.size + "px"; })
                .style("font-family", "GmarketSansBold")
                .style("fill", function(d, i) { return fill(i); })
                .style("color", function(d, i) { return fill(i); })
                .attr("text-anchor", "middle")
                
                .attr("transform", function(d) {
                  return "translate(" + [d.x, d.y] + ")";// + ")rotate(" + d.rotate + ")";
                })
                
              .text(function(d) { return d.text; }).on("click", function(d) {
                      //alert(d.text);
            	 	if(d.seq){
            	 		var item = new Array();
            	 		item.push(d.seq);
            	 		item.push(d.text);
            	 		history_change(item,IDname)	
            	 	}
            	 	
              });
          }
          
          //console.log($("svg"));
          //console.log($("#"+IDname).find('g').offset().left)
          /*
          var left = 0;
          var top = 0;
          $("#"+IDname).find('g').find("text").each(function(index, item){
        	  number_string = $(item).attr("transform").replace("translate(","").replace(")","").split(",");
        	  var x = parseInt(number_string[0]);
          	  var y = parseInt(number_string[1]);
          	  
        	  if(left < x)
        		  left = x;
        	  
        	  if(top > y)
        		  top = y;
          })
          
          if(date_period_string.includes("~")){
        	  left = left-50
          }
		  else{
			  if(date_period_string.includes(":")){
			  	left = left-30
			  }
			  else{
				 left = left;
			  }
		  }
          if(on_off_text === "ON"){
        	  top = top-40;
        	  if(top > -255){
        		  top = -255
        	  }
        	  if(pair_type === "0"){
        		  top = -300
        	  }
          }else{
        	  top = -210
          }
          
          d3.select("#"+IDname).select("g")
          .append("text")
          .attr("x", left)             
          .attr("y", top) //top-30
          .attr("text-anchor", "middle")  
          .style("font-size", "12px")
          .style("color", "#666666")
          .style("font-family", "GmarketSansBold")
          .text(date_period_string)
          */
    }
    showCloud(frequency_list, IDname);
}

//천단위 마다 콤마를 찍어주기 위한 함수
function numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function build_wordTable(score_data,member,front, on_off_text){
	var IDname = "";
	var data = eval(score_data)
	if(typeof data == "undefined")
		return;
	var data_len = data.length;
	var chk = $("#removeCheck").is(":checked");
	/*
	data.sort(function(a,b) {
		if(a[2] - b[2] === 0){
			return a[1] < b[1] ? -1 : a[1] > b[1] ? 1 : 0;
		}
		else{
			return b[2] - a[2];
		}
	})
	*/
	var cnt_limit = 10;
	if(on_off_text === "ON"){
		cnt_limit = 15;
	}
	
	if(member){
		if(front === 1){
			IDname = "member_word-table_ul";
		}
		else{
			IDname = "member_word-table_period_ul";
		}
		$("#"+IDname).empty()
		var cnt = 0;
	    for (var i = 0; i < data_len; i++) {
	    	
	    	var seq = data[i][0];
			var word = data[i][1];
			var score = data[i][2];
			//score = score.toFixed(2);
			score = numberWithCommas(score);
			
			if(data[i].length > 5){
				var member_total_TF = data[i][5];
				if(!chk && member_total_TF == "누적단어")
					continue;
				else{
					if(member_total_TF == "누적단어아님"){
						$("#"+IDname).append('<li style="cursor: pointer"><span class="num_item">'+(i+1)
								+'</span><p class="desc_info" id = '+seq+'><span id = '+seq+'>'+word
								+'</span></p><p class="desc_count">'+score+"</p></li>");
					}else{
						$("#"+IDname).append('<li class = "tag" style="cursor: pointer"><span class="num_item">'+(i+1)
								+'</span><p class="desc_info" id = '+seq+'><span id = '+seq+'>'+word
								+'</span></p><p class="desc_count">'+score+"</p></li>");
					}
				}
				
				 
			}
			else{ //누적 탭 순위 테이블 표시할때
				$("#"+IDname).append('<li style="cursor: pointer"><span class="num_item">'+(i+1)+'</span><p class="desc_info" id = '+seq+'><span id = '+seq+'>'+word+'</span></p><p class="desc_count">'+score+"</p></li>");
			}
			cnt+=1;
			if(cnt == cnt_limit)
				break;
	    }
	}
	else{
		if(front === 1){
			IDname = "total_word_table_ul";
		}
		else{
			IDname = "total_word_table_ul";
		}
		
		$("#"+IDname).empty()
		var cnt = 0;
	    for (var i = 0; i < data_len; i++) {
	    	
			var word = data[i][0];
			var score = data[i][1].toFixed(2);
			
			score = numberWithCommas(score);
			
			$("#"+IDname).append("<li><span class='num_item'>"+(i+1)+"</span><p class='desc_info'><span>"+word+'</span><a href="#" class="rank_srch" title="검색" onclick = "search_keyword(this)">검색</a></p><p class="desc_count">'+score+"</p></li>");
			cnt+=1;
			if(cnt == cnt_limit)
				break;
	    }
	}	
	$("#member_word-table_ul").show();
}

$(document).on('click',".desc_info",function(event){
	//var pcode=$(this); //이거는 해당 element의 id value값을 가져오는것.
	var class_name = $(event.target).attr('class')
	var id_name = $(event.target).attr('id')
	if(class_name === "rank_srch" || class_name === "desc_info")
		return;
	
	if(id_name === "desc_info_sentiment")
		return;
	
	if(id_name === "desc_info_todayscore"){ // 오늘날짜의 점수 조회를 위해
		var text = $(event.target).text();
		// 단어, 단어쌍 여부 조사
		var word_list;
		var pair_type = $('#pair_type_member').children('.active').text();
		if(pair_type == "단어 쌍")
			word_list = today_word_score['word_pair'];
		else
			word_list = today_word_score['word']
		
		var item;
		for(var i = 0; i < word_list.length; i++){
			if(word_list[i]['word'] == text){
				item = word_list[i];
				break;
			}
		}
		history_change_today(item, "member_wordcloud");
		
	}else{ // 아닐때
		var seq = event.target.id;
		var text = $(event.target).text();
		var item = new Array();
		item.push(seq);
		item.push(text);
		history_change(item, "member_wordcloud");
	}
});

function total_info_(){
	$(".total_info").html("<li>데이터가 없습니다.</li>");
	$(".total_info").css("display","block");
	
	$("#pair_type").css("display","none");
	$("#wordcloud").css("display","none");
	$("#word-table").css("display","none");
}

function sunday(){
	$(".total_info").html("<li>오늘은 발행된 신문이 없습니다.</li>");
	$(".total_info").css("display","block");
	
	$("#pair_type").css("display","none");
	$("#wordcloud").css("display","none");
	$("#word-table").css("display","none");
}

function period_info_(){
	$(".member_total_info").html("<li>해당 기간동안 스크랩된 기사 데이터가 없습니다.</li>");
	$(".member_total_info").css("display","block");
	
	$("#pair_type_member").css("display","none");
	
	//버튼도 안보이게 하려고
	$("#blobButton_member").css("display","none");
	$("#blobButton_member_excel").css("display","none");
	$("#removeSpace").css("display","none");
	
	$("#member_wordcloud").css("display","none");
	$("#member_word-table").css("display","none");
	$(".history").css("display","none");
	$(".sub_tab_member-content").css("display","none");
	
	// sentiment_wordcloud 역시 안보이게 하고, 분석 요청도 중지시켜야 함
	$("#member_wordcloud_sentiment").hide();
	$("#sentiment_member_word-table").hide();
	console.log(sentiment_xhr);
	if(sentiment_xhr && sentiment_xhr.readystate != 4){
		sentiment_xhr.abort();
    }
}

function member_total_info_(){
	$(".member_total_info").html("<li>데이터가 없습니다. 스크랩마스터 프리미엄 뷰어에 기사가 등록된 다음 날 분석 결과를 볼 수 있습니다.</li>");
	$(".member_total_info").css("display","block");
	
	$("#pair_type_member").css("display","none");
	//버튼도 안보이게 하려고
	$("#blobButton_member").css("display","none");
	$("#blobButton_member_excel").css("display","none");
	$("#removeSpace").css("display","none");
	
	$("#member_wordcloud").css("display","none");
	$("#member_word-table").css("display","none");
	$(".history").css("display","none");
	
	$(".sub_tab_member-content").css("display","none");
	//$("#member_score_display").css("display","none");#memb
	
}
function dateDiff(_date1, _date2) {
    var diffDate_1 = _date1 instanceof Date ? _date1 :new Date(_date1);
    var diffDate_2 = _date2 instanceof Date ? _date2 :new Date(_date2);
 	
    diffDate_1 =new Date(diffDate_1.getFullYear(), diffDate_1.getMonth()+1, diffDate_1.getDate());
    diffDate_2 =new Date(diffDate_2.getFullYear(), diffDate_2.getMonth()+1, diffDate_2.getDate());
 
    //var diff = Math.abs(diffDate_2.getTime() - diffDate_1.getTime());
    //diff = Math.ceil(diff / (1000 * 3600 * 24));
    
    var diff = Math.abs(diffDate_2.getFullYear() - diffDate_1.getFullYear());
 	
    return diff;
}

function score_history_line_chart(data,period_text, text, IDname, periodCheck){
	var start_date = "";
	var end_date = "";
	var start_i = 0;
	var score_his = eval(data);
	var score_hist_len = score_his.length;
	var check_date_list = [];
	
	if(period_text === "기간설정"){
		start_date = $("#start_datepicker").val();
		end_date = $("#end_datepicker").val();
		period_text = "";
		start_date = new Date(start_date);
		end_date = new Date(end_date);
		/*
		//기간 설정시 해당 기간의 것만 보여줘야 하므로
		if(start_date.getTime() == end_date.getTime()){
			start_date = start_date.addDays(-1);
			end_date = end_date.addDays(1);
		}
		*/
		//1. 해당 기간 리스트 만들기
		check_date_list = getDates(start_date, end_date);
		//2. 해당 기간에 속한 애들만 가시화 결과 리스트에 추가
		
	}else{ //기간 설정 탭이 아니고
		if(!periodCheck){ // 기간내 결과값만 보기
			if(period_text == "주간") start_i = score_his.length - 7;
			else if(period_text == "월간") start_i = score_his.length - 30;
			else if(period_text == "분기") start_i = score_his.length - 90;
			else start_i = 0;
		}	
	}
	
	
	var score_his = eval(data);
	var score_hist_len = score_his.length;
	var timeFormat = 'YYYY-MM-DD';
	var score_list = []
	var date_list = []
	var point_Radius = []
	var point_HitRadius = []
	for(var i = start_i; i < score_hist_len; i++){
		var date = score_his[i][0];
		var score = score_his[i][1];
		if(period_text == "" && !periodCheck){ // 전체기간보기가 체크가 안되어 있어 periodCheck가 false일때
			if(!check_date_list.includes(date)) // 특정기간의 데이터만 보기 위해 생성된 데이트리스트에 가시화 결과를 포함시킬지 말지 여부 판단
				continue;
		}
		if(score == 0){
			point_Radius.push(0)
			point_HitRadius.push(0)
		}
		else{
			point_Radius.push(3)
			point_HitRadius.push(2)
		}
		date_list.push(date);
		score_list.push(score);	
	}
	var date_label = 'year';
	var label_string = "연도";
	var unitStepSize = 1;
	if(date_list.length <= 7){
		date_label = "day";
		label_string = "날짜";
	}
	else if(date_list.length <= 31){
		date_label = "week";
		label_string = "날짜";
		unitStepSize = 7;
	}
	else if(date_list.length <= 90){
		date_label = "month";
		label_string = "월간";
	}
	else if(date_list.length < 365){
		date_label = "month";
		label_string = "월간";
	}else{
		date_label = "year";
		label_string = "연도";
	}		
	var color = Chart.helpers.color;
	var config = {
			type: 'line',
			data: {
				labels: date_list,
				datasets: [{
					label: text,					
					//backgroundColor: color(window.chartColors.red).alpha(0.5).rgbString(),
					//borderColor: window.chartColors.red,
					fill: false,
					data: score_list,
					borderColor : 'rgba(27,66,152,0.7)',
					pointHitRadius : point_HitRadius,
					pointRadius : point_Radius,
					//pointRadius: 0,
				}],
			},
			options: {
				//responsive: false,
				animation: {
		            duration: 0 // general animation time
		        },
		        hover: {
		            animationDuration: 0 // duration of animations when hovering an item
		        },
		        responsiveAnimationDuration: 0,
				title: {
					text: 'Chart.js Time Scale'
				},
				legend: {
			        display: false
			    },
			    
				scales: {
					yAxes: [{
						ticks: {
							beginAtZero: true
						},
						scaleLabel : {
							display: true,
							labelString: '점수',
						}
					}],
					xAxes: [{
						//afterBuildTicks: function(humdaysChart) {    
						    //console.log(humdaysChart);
						    //humdaysChart.ticks[0] = null;
						    //humdaysChart.ticks[humdaysChart.ticks.length-1] = null;
						  //},
						
						gridLines: {
							display : false,
			                //color: "rgba(0, 0, 0, 0)",
			            },
						type: 'time',
						time: {
							unit : date_label,
							//unitStepSize: parseInt(score_hist_len/2),
							displayFormats: {
								day : 'YYYY-MM-DD',
								week : 'YYYY-MM-DD',
		                        month: 'YYYY-MM',
		                        quater : 'YYYY-MM',
		                        year : 'YYYY',
		                    }
		                },
	                	//distrtibution: 'series',
	                	offset: false,
		                ticks: {
		                	minRotation: 0,
		                    maxRotation: 0,
		                    
		                },
		                scaleLabel : {
		                	display : true,
		                	labelString: label_string,//'연도',
		                },
		
		            }]
				},
			}
		};
		
		//console.log(date, score_his[0][0], dateDiff(date, score_his[0][0]));
		//dateDiff(date, score_his[0][0]) == 0 // 기존 로직중 같은 년도일경우 options값 조정 부분
		//전체 다 불러와서 필요한 부분만 보여주는 것으로 바꼈으니 이부분 로직을 수정해준다
		// 1. 전체 보기가 아닐 경우
			// 1. 주간 => 일별
			// 2. 월간 => 주별
			// 3. 분기 => 월별
			// 4. 기간 설정 
				// 기간 수에 따라 다르게 설정 필요
					// 0. 하루 일때 => 값이 중간에 오게끔
					// 1. 7미만 => 일별
					// 2. 30미만 => 주별
					// 3. 90미만 => 월별
					// 4. 그 이상 => 년별
		if(period_text == "월간" && periodCheck == false){ 
			date_label = 'day';
			unitStepSize = 7;
			var change_options = {
					//responsive: false,
					animation: {
			            duration: 0 // general animation time
			        },
			        hover: {
			            animationDuration: 0 // duration of animations when hovering an item
			        },
			        responsiveAnimationDuration: 0,
					title: {
						text: 'Chart.js Time Scale'
					},
					legend: {
				        display: false
				    },
				    
					scales: {
						yAxes: [{
							ticks: {
								beginAtZero: true
							},
							scaleLabel : {
								display: true,
								labelString: '점수',
							}
						}],
						xAxes: [{
							//afterBuildTicks: function(humdaysChart) {    
							    //console.log(humdaysChart);
							    //humdaysChart.ticks[0] = null;
							    //humdaysChart.ticks[humdaysChart.ticks.length-1] = null;
							  //},
							
							gridLines: {
								display : false,
				                //color: "rgba(0, 0, 0, 0)",
				            },
							type: 'time',
							time: {
								unit : 'day',//date_label,
								unitStepSize: unitStepSize,//parseInt(score_hist_len/2),
								
								displayFormats: {
									day : 'YYYY-MM-DD',
									week : 'YYYY-MM-DD',
			                        month: 'YYYY-MM',
			                        quater : 'YYYY-MM',
			                        year : 'YYYY',
			                    }
			                },
		                	//distrtibution: 'series',
		                	offset: false,
			                ticks: {
			                	minRotation: 0,
			                    maxRotation: 0,
			                    //source : 'data',
			                    
			                	
			                },
			                scaleLabel : {
			                	display : true,
			                	labelString: label_string,
			                },
			
			            }]
					},	
			}
			config.options = change_options;
		}
		else if(date_list.length == 1){
			date_label = 'day';
			unitStepSize = 7;
			var change_options = {
					//responsive: false,
					animation: {
			            duration: 0 // general animation time
			        },
			        hover: {
			            animationDuration: 0 // duration of animations when hovering an item
			        },
			        responsiveAnimationDuration: 0,
					title: {
						text: 'Chart.js Time Scale'
					},
					legend: {
				        display: false
				    },
				    
					scales: {
						yAxes: [{
							ticks: {
								beginAtZero: true
							},
							scaleLabel : {
								display: true,
								labelString: '점수',
							}
						}],
						xAxes: [{
							//afterBuildTicks: function(humdaysChart) {    
							    //console.log(humdaysChart);
							    //humdaysChart.ticks[0] = null;
							    //humdaysChart.ticks[humdaysChart.ticks.length-1] = null;
							  //},
							
							gridLines: {
								display : false,
				                //color: "rgba(0, 0, 0, 0)",
				            },
							type: 'time',
							time: {
								unit : 'day',//date_label,
								unitStepSize: unitStepSize,//parseInt(score_hist_len/2),
								
								displayFormats: {
									day : 'YYYY-MM-DD',
									week : 'YYYY-MM-DD',
			                        month: 'YYYY-MM',
			                        quater : 'YYYY-MM',
			                        year : 'YYYY',
			                    }
			                },
		                	//distrtibution: 'series',
		                	offset: true,
			                ticks: {
			                	minRotation: 0,
			                    maxRotation: 0,
			                    //source : 'data',
			                	
			                },
			                scaleLabel : {
			                	display : true,
			                	labelString: label_string,
			                },
			
			            }]
					},	
			}
			config.options = change_options;
			
		}
		//var chart = new Chart(ctx, config);
		
		
		/*if(window.chart){
			console.log("hi")
			window.chart.destroy();
		}*/
		
		var name = "";
		
		name = "lineChart_total";
		
		if(window.chart_total){
			window.chart_total.destroy();
		}
		//console.log(global_period_check);
		var add_periodCheck_button = "";
		if(period_text !== "누적"){
			if(global_period_check){ //$("#periodCheck").is(":checked")
				//console.log("check");
				add_periodCheck_button = '<!-- 위치변경 span 추가 -->'
					+'<span class="check">'
					+'<input type="checkbox" id="periodCheck" checked>'
					+'<label id="periodLabel" for="periodCheck"><span class="label"></span>'
					+'전체기간보기</label>'
					+'</span>';
			}else{
				//console.log("not check");
				add_periodCheck_button = '<!-- 위치변경 span 추가 -->'
					+'<span class="check">'
					+'<input type="checkbox" id="periodCheck">'
					+'<label id="periodLabel" for="periodCheck"><span class="label"></span>'
					+'전체기간보기</label>'
					+'</span>';
			}	
		}
		
		var tag = '프리미엄 등록 기사 '+period_text+' 주요 키워드 추이 : <span id="text_total">'+text+'</span>'
		+'<span onclick="show_history_infoText()" class="line_info_button" style="visibility: visible;cursor: pointer;">ⓘ </span>'
		+add_periodCheck_button
		+'<span class = "member_history_info" style = "float: right; color: #999; font-size: 13px; font-weight: 300;"><span onclick="show_tfidf_infotext()" class="line_info_button" style="visibility: visible;cursor: pointer;">ⓘ</span> 점수는 TF-IDF 알고리즘으로 분석한 결과입니다.</span>'
		
		start_date = $("#start_datepicker").val();
		end_date = $("#end_datepicker").val();
		var today_string = setting_today();
		if(period_text == "오늘" && start_date === today_string && end_date === today_string){
			tag = '프리미엄 등록 기사 '+period_text+' 주요 키워드 추이 : <span id="text_total">'+text+'</span>'
			+'<span onclick="show_history_infoText()" class="line_info_button" style="visibility: visible;cursor: pointer;">ⓘ </span>'
			+'<span class = "member_history_info" style = "float: right; color: #999; font-size: 13px; font-weight: 300;"><span onclick="show_tfidf_infotext()" class="line_info_button" style="visibility: visible;cursor: pointer;">ⓘ</span> 점수는 TF-IDF 알고리즘으로 분석한 결과입니다.</span>'
		}
		
		$('.history_info_text_total').html(tag);
		var ctx = document.getElementById(name);
		//$("#blank_space").show();
		ctx.getContext("2d").clearRect(0, 0, 1200, 300);
		window.chart_total = new Chart(ctx,config);	
		//$("#blank_space").hide();
		$("#loadingBar").hide();
		$(".linechart").show();
		//var ctx = document.getElementById('lineChart').getContext('2d');
		//ctx.canvas.width = 1000;
		//ctx.canvas.height = 300;
}

function history_change(item, IDname){
	global_item = item;
	var period_text = $(".sub_tab_member-link.current").text();
	if(typeof item == "undefined")
		return;
	var word_seq = item[0];
	var text = item[1];
	//$(".history_info_text_total").text("프리미엄 등록 기사 "+t+" 주요 키워드 추이 : "+text);
	
	var periodCheck = global_period_check;
	$(".history").css("display","block");
	ajax_word_score_history_return(word_seq,period_text, text, IDname, periodCheck);
}

function history_change_today(item, IDname){
	var period_text = $(".sub_tab_member-link.current").text();
	if(typeof item == "undefined")
		return;
	var word_seq = "no_word_seq";
	
	var word = item['word']
	var score = item['score']
	score = score.toFixed(2);
	var date = setting_today();
	
	var data = [[date, score]]
	
	var periodCheck = global_period_check; //-> 전체기간보기 button여부, 오늘의 경우엔 포함x
	$(".history").css("display","block");
	
	//ajax_word_score_history_return 의 beforeSend 부분에서 세팅하는 값 가져오기
	$("#loadingBar").show();
    var tag = '프리미엄 등록 기사 '+""+' 주요 키워드 추이 : <span id="text_total"></span> <span class = "member_history_info" style = "float: right; color: #999; font-size: 13px; font-weight: 300;"> <span onclick="show_tfidf_infotext()" class="line_info_button" style="visibility: visible;cursor: pointer;">ⓘ</span> 점수는 TF-IDF 알고리즘으로 분석한 결과입니다.</span>'
	$('.history_info_text_total').html(tag);
    //$(".history_info_text_total").hide();
    $(".linechart").hide();
	
	score_history_line_chart(data, "오늘", word, IDname, false);
	
}

function show_member_score_infoText(){
	var msg = "프리미엄 서비스 출시 이후 고객님의 프리미엄 계정에 등록된 모든 기사를 분석했습니다. 워드 클라우드 단어를 누르면 해당 단어의 점수 추이선이 표시 됩니다.";
	alert(msg);
}

function show_member_score_period_infoText(){
	var msg = "주간은 최근 7일, 월간은 최근 30일, 분기는 최근 90일에 고객님의 프리미엄 계정에 등록된 모든 기사를 분석했습니다";
	alert(msg);
}

function show_history_infoText(){
	var msg = "워드클라우드에서 단어를 클릭하면 해당 단어가 기사 내 언급된 날짜별 추이로 아래 그래프에 반영됩니다.";
	msg+="\n그래프의 특정 위치를 클릭하면 해당 일자와 점수를 확인할 수 있습니다."
	alert(msg);
}

function show_tfidf_infotext() {
	var msg = "TF-IDF 알고리즘이란? \n여러 문서로 이루어진 문서군이 있을 때 어떤 단어가 특정 문서 내에서 얼마나 중요한 것인지를 나타내는 수치 산출 알고리즘입니다.";
	alert(msg);
}


function blockRightClick(){
    //alert("오른쪽 버튼은 사용할 수 없습니다.");
    return false;
}
function blockSelect(){
    //alert("내용을 선택할 수 없습니다.");
    return false;
}

$(function(){
	var start_date = "";
    var end_date = "";
    var type = 0;
    var pair_type = $('#pair_type_member').children('.active').text();
	if(pair_type == "단어 쌍")
		type=1;
    
    $('#date_submit').click(function(){
		//start_date = $("#start_datepicker").val();
		//end_date = $("#end_datepicker").val();
		var chk = $("#removeCheck").is(":checked");
		start_date = $("#start_datepicker").val();

	    end_date = $("#end_datepicker").val();
		
		if(start_date === "" || end_date === "")
			alert("choose date")
		else{
			var pair_type = $('#pair_type_member').children('.active').text();
			var today_string = setting_today();
			type = 0;
			if(pair_type == "단어 쌍")
				type=1;
			if(start_date === today_string || end_date === today_string){
				ajax_member_word_today_setting(user_seq, type, chk, true, start_date, end_date);
				//ajax_member_word_period_setting(user_seq, type, chk, true, start_date, end_date);
			}else{
				ajax_member_word_period_setting(user_seq, type, chk, true, start_date, end_date);
			}
			ajax_member_sentiment_word_period_setting(user_seq, type, chk, true, start_date, end_date);
		}
		
		
	})
	
	$("#start_datepicker").datepicker({
		//showOn: "both", // 버튼과 텍스트 필드 모두 캘린더를 보여준다.
		  showOn: "focus",
		  //buttonImage: "/application/db/jquery/images/calendar.gif", // 버튼 이미지

		  //buttonImageOnly: true, // 버튼에 있는 이미지만 표시한다.

		  changeMonth: true, // 월을 바꿀수 있는 셀렉트 박스를 표시한다.

		  changeYear: true, // 년을 바꿀 수 있는 셀렉트 박스를 표시한다.

		  minDate: '-100y', // 현재날짜로부터 100년이전까지 년을 표시한다.

		  nextText: 'Later', // next 아이콘의 툴팁.

		  prevText: 'prev', // prev 아이콘의 툴팁.

		  numberOfMonths: [1,1], // 한번에 얼마나 많은 월을 표시할것인가. [2,3] 일 경우, 2(행) x 3(열) = 6개의 월을 표시한다.

		  stepMonths: 1, // next, prev 버튼을 클릭했을때 얼마나 많은 월을 이동하여 표시하는가. 

		  yearRange: 'c-100:c+10', // 년도 선택 셀렉트박스를 현재 년도에서 이전, 이후로 얼마의 범위를 표시할것인가.

		  showButtonPanel: true, // 캘린더 하단에 버튼 패널을 표시한다. 

		  //currentText: '오늘 날짜' , // 오늘 날짜로 이동하는 버튼 패널

		  closeText: 'close',  // 닫기 버튼 패널

		  dateFormat: "yy-mm-dd", // 텍스트 필드에 입력되는 날짜 형식.

		  showAnim: "slideDown", //애니메이션을 적용한다.

		  showMonthAfterYear: true , // 월, 년순의 셀렉트 박스를 년,월 순으로 바꿔준다. 

		  dayNamesMin: [ '일', '월', '화', '수', '목', '금', '토'], // 요일의 한글 형식.

		  monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'] // 월의 한글 형식.
	});
    
    $("#end_datepicker").datepicker({
    	showOn: "focus", // 버튼과 텍스트 필드 모두 캘린더를 보여준다.

    	  //buttonImage: "/application/db/jquery/images/calendar.gif", // 버튼 이미지

    	  buttonImageOnly: true, // 버튼에 있는 이미지만 표시한다.

    	  changeMonth: true, // 월을 바꿀수 있는 셀렉트 박스를 표시한다.

    	  changeYear: true, // 년을 바꿀 수 있는 셀렉트 박스를 표시한다.

    	  minDate: '-100y', // 현재날짜로부터 100년이전까지 년을 표시한다.

    	  nextText: '다음 달', // next 아이콘의 툴팁.

    	  prevText: '이전 달', // prev 아이콘의 툴팁.

    	  numberOfMonths: [1,1], // 한번에 얼마나 많은 월을 표시할것인가. [2,3] 일 경우, 2(행) x 3(열) = 6개의 월을 표시한다.

    	  stepMonths: 1, // next, prev 버튼을 클릭했을때 얼마나 많은 월을 이동하여 표시하는가. 

    	  yearRange: 'c-100:c+10', // 년도 선택 셀렉트박스를 현재 년도에서 이전, 이후로 얼마의 범위를 표시할것인가.

    	  showButtonPanel: true, // 캘린더 하단에 버튼 패널을 표시한다. 

    	  //currentText: '오늘 날짜' , // 오늘 날짜로 이동하는 버튼 패널

    	  closeText: 'close',  // 닫기 버튼 패널

    	  dateFormat: "yy-mm-dd", // 텍스트 필드에 입력되는 날짜 형식.

    	  showAnim: "slideDown", //애니메이션을 적용한다.

    	  showMonthAfterYear: true , // 월, 년순의 셀렉트 박스를 년,월 순으로 바꿔준다. 

    	  dayNamesMin: ['일', '월', '화', '수', '목', '금', '토'], // 요일의 한글 형식.

    	  monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'] // 월의 한글 형식.
    });
	
    
});

function img_download(){
	//svg = $("#member_wordcloud svg")[0];
	//console.log($(".tab-link.current").attr("data-tab"));
	
	//이미지 다운로드 할때 날짜 단어 표시 하기 위함
	var date_period_string ="";
	var IDname = "";
	var on_off_text = "";
	var tab_link = $(".tab-link.current").text() // 오주뉴 / 프리미엄
	// 오늘의 뉴스인지 프리미엄 인지
	if(tab_link.includes("오늘의 뉴스")){
		// 오늘의 뉴스라면 주요/1면
		IDname = "wordcloud";
		var sub_tab_link = $(".sub_tab-link.current").text() // 주요뉴스 / 신문 1면
		var pair_type = $("#pair_type li.active").text()
		on_off_text = "";
		/*
		var p_square_check = $(".p_square_check_total");
		for(var i = 0; i < p_square_check.length; i++){
			var p_tag = $(p_square_check[i]);
			if(p_tag.is(':visible')){
				on_off_text = p_tag.text();
			}
		}
		*/
		if($("#total_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
			on_off_text = "OFF";
		}
		else{
			on_off_text = "ON";
		}
		
		var minute10_ago = today_10ago();
		date_period_string = minute10_ago;
	}else{
		//프리미엄이라면 주간, 월간, 분기, 기간 설정
		// 단일 단어/ 단어쌍	
		IDname = "member_wordcloud";
		var sub_tab_link = $(".sub_tab_member-link.current").text();
		var pair_type = $("#pair_type_member li.active").text()
		on_off_text = "";
		/*
		var p_square_check = $(".p_square_check_member");
		for(var i = 0; i < p_square_check.length; i++){
			var p_tag = $(p_square_check[i]);
			if(p_tag.is(':visible')){
				on_off_text = p_tag.text();
			}
		}
		*/
		if($("#member_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
			on_off_text = "OFF";
		}
		else{
			on_off_text = "ON";
		}
		
		
		if(sub_tab_link.includes("누적")){
			//누적
			var yester_day = yesterday();
			var user_st_date = date_name_return(user_start_date);
			date_period_string = user_st_date+" ~ "+yester_day;
		}else if(sub_tab_link.includes("기간")){
			var start_date = $("#start_datepicker").val();
		    var end_date = $("#end_datepicker").val();
			
			//period setting
			var st_date = date_name_return(start_date);
			var ed_date = date_name_return(end_date);
			date_period_string = st_date;
			if(st_date != ed_date)
				date_period_string = st_date+" ~ "+ed_date;
		}else{
			//period
			var today = yesterday();
			var period = 0;
			if(sub_tab_link.includes("주간"))
				period = 7;
			else if(sub_tab_link.includes("월간"))
				period = 30;
			else
				period = 90;
			
			var today_minus_period = today_minus(period);
			date_period_string = today_minus_period+" ~ "+today
		}
		
	}
	var left = 0;
    var top = 0;
    $("#"+IDname).find('g').find("text").each(function(index, item){
  	  number_string = $(item).attr("transform").replace("translate(","").replace(")","").split(",");
  	  var x = parseInt(number_string[0]);
    	  var y = parseInt(number_string[1]);
    	  
  	  if(left < x)
  		  left = x;
  	  
  	  if(top > y)
  		  top = y;
    })
    
    if(date_period_string.includes("~")){
  	  left = left-50
    }
	  else{
		  if(date_period_string.includes(":")){
		  	left = left-30
		  }
		  else{
			 left = left;
		  }
	  }
    if(on_off_text === "ON"){
  	  top = top-40;
  	  if(top > -255){
  		  top = -255
  	  }
    }else{
  	  top = -210
    }
    
    d3.select("#"+IDname).select("g")
    .append("text")
    .attr("id", "wordcloud_date_text")
    .attr("x", left)             
    .attr("y", top) //top-30
    .attr("text-anchor", "middle")  
    .style("font-size", "12px")
    .style("color", "#666666")
    .style("font-family", "GmarketSansBold")
    .text(date_period_string)
			
			
	var tab_name = $(".tab-link.current").attr("data-tab")
	var wordcloud_html;
	var img_width, img_height;
	if(tab_name === "tab-1"){
		wordcloud = document.getElementById("wordcloud").childNodes[7].childNodes[0];
		img_width = wordcloud.getBoundingClientRect().width+10
		img_height = wordcloud.getBoundingClientRect().height+15;
		
	}else{
		wordcloud = document.getElementById("member_wordcloud").childNodes[9].childNodes[0];
		img_width = wordcloud.getBoundingClientRect().width+10
		img_height = wordcloud.getBoundingClientRect().height+10;
		
	}
	
	
	/*svg = document.getElementById("member_wordcloud").childNodes[5];
	var img_width = svg.width.baseVal.value
	var img_height = svg.height.baseVal.value
	
	img_width = wordcloud.getBoundingClientRect().width+7
	img_height = wordcloud.getBoundingClientRect().height+1;*/
	html2canvas(wordcloud, {width : img_width, height: img_height, scrollY: -window.scrollY, scale : 1.5, useCORS : true}).then(function (canvas) {
        var img = canvas.toDataURL('image/png');
        downloadURI(img, "wordcloud.png", img_width, img_height);
   })


}

/*function downloadURL(url, name, img_width, img_height){
	var link = document.createElement("a");
	link.download = name;
	link.href = url;
	link.id = "download_link";
	document.body.appendChild(link);
	link.click();
	link.remove();
	
	/*var imgTmp = new Image();
	imgTmp.crossOrigin = "anonymous";
    imgTmp.src = url;
	imgTmp.width = img_width;
	imgTmp.height = img_height; //gImgWin

	/*var imgWin = window.open("","_system","width="+imgTmp.width+",height="+imgTmp.height+",status=no,toolbar=no,scrollbars=no,resizable=no");
    imgWin.document.write("<html><title>미리보기</title>"
    +"<script type='text/javascript' src='./js/jquery-1.12.4.js'>" +"<"+"/script>"
    +"<body topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>"
    +"<a download = 'wordcloud.png' id='download_link' href='./css/images/ico_down.png'><img src='"+url+"' width="+imgTmp.width+" height="+imgTmp.height+" border=0></a>"
    +"<h3 id = 'text'></h3>"
    +"<script type='text/javascript'>"
    +"alert('hi');$('#download_link')[0].click(function() {alert('hi')});"+"<"+"/script>"
    +"</body></html>");
    imgWin.focus();
    // window.onload = function(){  document.getElementById('download_link').click()}[0].click( function() {alert('click'); console.log('hhhhh')});
    
	
    /*var x = new XMLHttpRequest();
	x.open("GET", url, true);
	x.responseType = 'blob';
	x.onload=function(e){download(x.response, name, 'application/octet-stream');}
	x.send();
	
	
}*/
function downloadURI(img_raw_uri, name, img_width, img_height){
	var link = document.createElement("a");
	//var link = document.getElementById('download_link');
	//link.download = './wordcloud_image/'+name;
	//link.href = img_raw_uri;
	//link.href = './css/images/ico_down.png';
	//link.id = "download_link";
	//div.id = "temp";
	//link.click();
	//link.remove();
	var user_name = new String("<%=sm3ID%>")
	var dates = new Date();
	var year = new String(dates.getFullYear()); // 년도
	var month = new String(dates.getMonth() + 1);  // 월
	if(month.length < 2)
		month = "0"+month;
	
	var day = new String(dates.getDate());  // 날짜
	if(day.length < 2)
		day = "0"+day;
	
	var hours = new String(dates.getHours()); // 시
	if(hours.length < 2)
		hours = "0"+hours;
	
	var minutes = new String(dates.getMinutes());  // 분
	if(minutes.length < 2)
		minutes = "0"+minutes;
	
	var seconds = new String(dates.getSeconds());  // 초
	if(seconds.length < 2)
		seconds = "0"+seconds;
	
	var date = year+month+day+"_"+hours+minutes+seconds;
	file_name_date = year+month+day;
	
	var filename = user_name+"_"+date;
	
	if(name.includes("positive")){
		filename = user_name+"_positive_"+date;
	}
	
	if(name.includes("negative")){
		filename = user_name+"_negative_"+date;
	}
	
	$.ajax({
		type : "POST",
		url : './utils/wordcloud_img_save.jsp',
		data : {
			"imgBase64" : img_raw_uri,
			"filename" : filename,
		}
	}).done(function(o){
		$('#download_link').attr({
			'download':'wordcloud_'+filename+'.png',
			'href':'./wordcloud_image/'+filename
			})
		document.getElementById("download_link").click();
	})
	
	$("#wordcloud_date_text").remove(); //
}


function excel_download(){
	
	var tab_name =$('.tab-link.current').text();
	var sub_tab_name; //var sub_tab_text = $('.sub_tab_member-link.current').text();
	var pair_type;
	var data;
	
	if(tab_name.includes("오늘")){
		sub_tab_name = $('.sub_tab-link.current').text();
		pair_type = $('#pair_type').children('.active').text();
		if(pair_type.includes("쌍"))
			pair_type = "1";
		else
			pair_type = "0";
		
		if(sub_tab_name.includes("1면")){
			var front = "2"
			excel_ajax(tab_name,pair_type, front, "", "", "", "");
		}else{
			var front = "1";
			excel_ajax(tab_name,pair_type, front, "", "", "", "");
		}
		
	}else{ //프리미엄 기사 분석
		sub_tab_name = $('.sub_tab_member-link.current').text();
		pair_type = $('#pair_type_member').children('.active').text();
		if(pair_type.includes("쌍"))
			pair_type = "1";
		else
			pair_type = "0";
		
		if(sub_tab_name.includes("누적")){
			excel_ajax(tab_name,pair_type, front, user_seq, "", "", "");
		}else if(sub_tab_name.includes("주간")){
			var period = "7";
			excel_ajax(tab_name,pair_type, front, user_seq, period, "", "");
		}else if(sub_tab_name.includes("월간")){
			var period = "30";
			excel_ajax(tab_name,pair_type, front, user_seq, period, "", "");
		}else if(sub_tab_name.includes("분기")){
			var period = "90";
			excel_ajax(tab_name,pair_type, front, user_seq, period, "", "");
		}else{
			var start_date = $("#start_datepicker").val();
		    var end_date = $("#end_datepicker").val();
		    var today_string = setting_today();
		    if(start_date === today_string && end_date === today_string) {
		    	console.log("jump");
		    	excel_ajax_today(tab_name,pair_type, front, user_seq, "", start_date, end_date);
		    }else{
		    	excel_ajax(tab_name,pair_type, front, user_seq, "", start_date, end_date);
		    }
		}
		
	}
	
}

function excel_ajax(tab_name, pair_type, front, user_seq, period, start_date, end_date){
	var user_name = new String("<%=sm3ID%>")
	var removeChecked = $("#removeCheck").is(":checked");
	var dates = new Date();
	var year = new String(dates.getFullYear()); // 년도
	var month = new String(dates.getMonth() + 1);  // 월
	if(month.length < 2)
		month = "0"+month;
	
	var day = new String(dates.getDate());  // 날짜
	if(day.length < 2)
		day = "0"+day;
	
	var hours = new String(dates.getHours()); // 시
	if(hours.length < 2)
		hours = "0"+hours;
	
	var minutes = new String(dates.getMinutes());  // 분
	if(minutes.length < 2)
		minutes = "0"+minutes;
	
	var seconds = new String(dates.getSeconds());  // 초
	if(seconds.length < 2)
		seconds = "0"+seconds;
	
	var date = year+month+day+"_"+hours+minutes+seconds;
	//file_name_date = year+month+day;
	file_name_date = date;
	
	var filename = user_name+"_"+date;
	
	$.ajax({
		type : "POST",
		url : './utils/wordcloud_excel_save.jsp',
		data : {
			"tab" : tab_name,
			"pair_type" : pair_type,
			"front" : front,
			"user_seq" : user_seq,
			"period" : period,
			"start_date" : start_date,
			"end_date" : end_date,
			"filename" : filename,
			"removeChecked" : removeChecked
		}
	}).done(function(o){
		$('#download_link').attr({
			'download':'wordcloud_'+file_name_date+'.xls',
			'href':'./wordcloud_excel/'+filename+".xls"
			})
		document.getElementById("download_link").click();
	})
}

function excel_ajax_today(tab_name, pair_type, front, user_seq, period, start_date, end_date){
	if($("#loadingBar_wordcloud").is(":visible")){
		alert("분석중입니다.")
		return;
	}
	
	var start_date = $("#start_datepicker").val();
    var end_date = $("#end_datepicker").val();
	
	var user_name = new String("<%=sm3ID%>")
	var removeChecked = $("#removeCheck").is(":checked");
	var dates = new Date();
	var year = new String(dates.getFullYear()); // 년도
	var month = new String(dates.getMonth() + 1);  // 월
	if(month.length < 2)
		month = "0"+month;
	
	var day = new String(dates.getDate());  // 날짜
	if(day.length < 2)
		day = "0"+day;
	
	var hours = new String(dates.getHours()); // 시
	if(hours.length < 2)
		hours = "0"+hours;
	
	var minutes = new String(dates.getMinutes());  // 분
	if(minutes.length < 2)
		minutes = "0"+minutes;
	
	var seconds = new String(dates.getSeconds());  // 초
	if(seconds.length < 2)
		seconds = "0"+seconds;
	
	var date = year+month+day+"_"+hours+minutes+seconds;
	//file_name_date = year+month+day;
	file_name_date = date;
	
	var filename = user_name+"_"+date;
	
	var word_score_excel = null;
	
	if(today_word_score != null){
		word_score_excel = JSON.stringify(today_word_score);
	}else{
		return;
	}
	
	var type = 0;
	var filename = "";
	if($($("#pair_type_member li")[0]).attr('class').includes("active")){
		type = 1;
		filename = user_name+"_word_"+date;
	}else{
		type = 0;
		filename = user_name+"_word_pair_"+date;
	}
	
	var today_string = setting_today();
	
	/*
			"tab" : tab_name,
			"pair_type" : pair_type,
			"front" : front,
			"user_seq" : user_seq,
			"period" : period,
			"start_date" : start_date,
			"end_date" : end_date,
			"filename" : filename,
			"removeChecked" : removeChecked
	*/
	$.ajax({
		type : "POST",
		url : './utils/excel_word_score_excel_save.jsp',
		data : {
			"tab" : tab_name,
			"pair_type" : pair_type,
			"front" : front,
			"user_seq" : user_seq,
			"period" : period,
			"start_date" : start_date,
			"end_date" : end_date,
			"today_string" : today_string, 
			"filename" : filename,
			"word_score_data" : word_score_excel,
			"type":type,
		}
	}).done(function(o){
		
		$('#download_link').attr({
			'download':'wordcloud_'+filename+'.xls',
			'href':'./wordcloud_excel/'+filename+".xls"
			})
		document.getElementById("download_link").click();
		
	})
}

function showTFIDFPopup(){
	url = "./utils/TFIDF_description.html";
	name = "tfidf description";
	specs = "width = 600, height=700, top=200, left=100, toolbar=no, menubar=no,scrollbar=no, resizeble=yes";

	window.open(url, "_blank", specs);
	return false;
}

function search_keyword_total(){
	//console.log("search_keyword_total");
	var table_infos = $("#total_word_table_ul").children();
	var search_string = "";
	var words = new Array();
	for(var i = 0; i < table_infos.length; i++){
		var word = $(table_infos[i]).children()[1];
		word = $(word).text();
		words.push(word);
		search_string+=word+"_";
	}
	//console.log(words)
	search_string = search_string.slice(0,-1);
	var JSONObject = new Object();
	JSONObject.keywords = words;
	var JSONInfo = JSON.stringify(JSONObject);
	console.log(JSONInfo);
	window.open("sm5search:"+search_string, "keword_search","width = 400, height=300, left=100, top=50");
}

function search_keyword_member(){
	//onsole.log("search_keyword_total");
	var table_infos = $("#member_word-table_ul").children();
	var search_string = "";
	var words = new Array();
	for(var i = 0; i < table_infos.length; i++){
		var word = $(table_infos[i]).children()[1];
		word = $(word).text();
		words.push(word);
		search_string+=word+"_";
	}
	//console.log(words)
	search_string = search_string.slice(0,-1);
	var JSONObject = new Object();
	JSONObject.keywords = words;
	var JSONInfo = JSON.stringify(JSONObject);
	console.log(JSONInfo);
	window.open("sm5search:"+search_string, "keword_search","width = 400, height=300, left=100, top=50");
}

//두 데이트간 데이트 리스트를 만들기 위함
function formatDate(date) {
    var d = new Date(date),
        month = '' + (d.getMonth() + 1),
        day = '' + d.getDate(),
        year = d.getFullYear();

    if (month.length < 2) 
        month = '0' + month;
    if (day.length < 2) 
        day = '0' + day;

    return [year, month, day].join('-');
}

Date.prototype.addDays = function(days) {
    var date = new Date(this.valueOf());
    date.setDate(date.getDate() + days);
    return date;
}

function getDates(startDate, stopDate) {
    var dateArray = new Array();
    var currentDate = startDate;
    while (currentDate <= stopDate) {
        dateArray.push(formatDate(new Date (currentDate)));
        currentDate = currentDate.addDays(1);
    }
    return dateArray;
}

function build_wordcloud_todayscore(score_data, member, front, date_period_string, on_off_text){
//document.getElementById("wordcloud").innerHTML = null;
	var chk = $("#removeCheck").is(":checked");
	
	var type = 0;
	if($($("#pair_type_member_sentiment li")[0]).attr('class').includes("active"))
		type = 1;
	else
		type = -1;
	
	var words = eval(score_data);
	var max = 0;
	var min = 0;
	var pair_type = "";
	
	
	
	var frequency_list = new Array();
	if(words.length == 0)
		return;
	
	IDname = "member_wordcloud";
	
	max = words[0]['score'];
	min = words[words.length-1]['score'];
	
	for(var i = 0; i < words.length; i++){
		var temp_dict = {};
		var word = words[i]['word'];
       	var score = (words[i]['score']-min)/ (max-min) + 0.3;
		var accumulate = words[i]['accumulate']
		
		if(!chk && accumulate == true)// 누적 포함이 아닌데, 누적단어 일때
			continue
		
        temp_dict['text'] = word;
        temp_dict["frequency"] = score;
        temp_dict['score'] = words[i]['score'];
        frequency_list.push(temp_dict);
	}
    
    var first_sorting_field = "frequency";
    var second_sorting_field = "text";
    frequency_list.sort(function(a,b) {
    	if(a[first_sorting_field] - b[first_sorting_field] === 0){
    		return a[second_sorting_field] < b[second_sorting_field] ? -1 : a[second_sorting_field] > b[second_sorting_field] ? 1 : 0;
    	}
    	
    	else{
    		return b[first_sorting_field] - a[first_sorting_field];
    	}
    })
    
    
    function showCloud(frequency_list, IDname)
    {
    	
    	$("#"+IDname).children('svg').remove();
    	var weight,width,height;   // change me
    	var domain_max, range_max, domain_min, domain_max;
    	if(on_off_text === "ON"){
    		weight = 3;
        	width = 700;
        	height = 700;
        	range_min = 0, range_max = 150;
    		domain_min = 0, domain_max = 10;
    	}else{
    		weight = 3;
    		width = 700;
    		height = 400;
    		range_min = 0, range_max = 150;
    		domain_min = 0, domain_max = 10;
    	}
    	
    	var fill = d3.scale.category20();
    	/*
    	var fill;
    	if(type == 1){ //긍정
    		fill = d3.scale.linear().domain([0, 75]).range(['#003799','#4DE6FF']);
    	}else{ //부정
    		fill = d3.scale.linear().domain([0, 75]).range(['#CC2200','#f7ba00']);
    	}
    	*/
    	
    	//var fill = d3.scale.linear().domain([10,75]).range(['#E783C9', '#F3C0F1'])
    	var wordScale = d3.scale.linear().range([range_min, range_max]).domain([domain_min, domain_max]).clamp(true); //
		
    	function score_function(d){
    		var text_length = d.text.length;
    		var text_size = wordScale(d.frequency*weight);
    		if(((21 - text_length) * 2) + 31 < text_size){
    			console.log(d.text, text_size);
    			text_size = ((21 - text_length) * 2) + 31
    			console.log(d.text, text_size);
    			return text_size;
    		}
    		else{
    			return text_size;	
    		}
    	}
    	
		d3.layout.cloud().size([width, height]).words(frequency_list)
        //.rotate(function() { return (Math.random() * 2) * 90; })
        .padding(2.5)
        .text(function(d) { return d.text; })
        .rotate(0)
        .font("GmarketSansBold")
        
        .fontSize(function(d) { 
        	return score_function(d); 
        	})
        .on("end", draw)
        .start();
		
		var zoom_group;
          function draw(words) {
            var svg = d3.select("#"+IDname).append("svg")
                .attr("width", width)
                .attr("height", height)
                
                
            zoom_group = svg.append("g")
                .attr("transform", "translate(" + width/2 + "," + height/2 + ")")
            
            zoom_group
              .selectAll("text")
                .data(words)
              .enter().append("text")
                .style("font-size", function(d) { return d.size + "px"; })
                .style("font-family", "GmarketSansBold")
                .style("fill", function(d, i) { return fill(i); })
                .style("color", function(d, i) { return fill(i); })
                .attr("text-anchor", "middle")
                
                .attr("transform", function(d) {
                  return "translate(" + [d.x, d.y] + ")";// + ")rotate(" + d.rotate + ")";
                })
                
              .text(function(d) { return d.text; }).on("click", function(d) {
                  //alert(d.text);
        	 	var item = {}
          	 	item['word'] = d.text
          	 	item['score'] = d.score
          	 	history_change_today(item, IDname);
            });
          }
    }
    showCloud(frequency_list, IDname);
}

function build_wordcloud_sentiment(score_data, member,front, date_period_string, on_off_text){
	//document.getElementById("wordcloud").innerHTML = null;
	
	var type = 0;
	if($($("#pair_type_member_sentiment li")[0]).attr('class').includes("active"))
		type = 1;
	else
		type = -1;
	
	var words = eval(score_data);
	var max = 0;
	var min = 0;
	var pair_type = "";
	
	
	
	var frequency_list = new Array();
	if(words.length == 0)
		return;
	
	IDname = "member_wordcloud_sentiment";
	
	max = words[0]['score'];
	min = words[words.length-1]['score'];
	
	for(var i = 0; i < words.length; i++){
		var temp_dict = {};
		var word = words[i]['word'];
       	var score = (words[i]['score']-min)/ (max-min) + 0.3;

        temp_dict['text'] = word;
        temp_dict["frequency"] = score;
        frequency_list.push(temp_dict);
	}
    
    var first_sorting_field = "frequency";
    var second_sorting_field = "text";
    frequency_list.sort(function(a,b) {
    	if(a[first_sorting_field] - b[first_sorting_field] === 0){
    		return a[second_sorting_field] < b[second_sorting_field] ? -1 : a[second_sorting_field] > b[second_sorting_field] ? 1 : 0;
    	}
    	
    	else{
    		return b[first_sorting_field] - a[first_sorting_field];
    	}
    })
    
    
    function showCloud(frequency_list, IDname)
    {
    	
    	$("#"+IDname).children('svg').remove();
    	var weight,width,height;   // change me
    	var domain_max, range_max, domain_min, domain_max;
    	if(on_off_text === "ON"){
    		weight = 3;
        	width = 700;
        	height = 700;
        	range_min = 0, range_max = 150;
    		domain_min = 0, domain_max = 10;
    	}else{
    		weight = 3;
    		width = 700;
    		height = 400;
    		range_min = 0, range_max = 150;
    		domain_min = 0, domain_max = 10;
    	}
    	
    	//var fill = d3.scale.category20();
    	var fill;
    	if(type == 1){ //긍정
    		fill = d3.scale.linear().domain([0, 75]).range(['#003799','#4DE6FF']);
    	}else{ //부정
    		fill = d3.scale.linear().domain([0, 75]).range(['#CC2200','#f7ba00']);
    	}
    	
    	//var fill = d3.scale.linear().domain([10,75]).range(['#E783C9', '#F3C0F1'])
    	var wordScale = d3.scale.linear().range([range_min, range_max]).domain([domain_min, domain_max]).clamp(true); //
		
    	function score_function(d){
    		var text_length = d.text.length;
    		var text_size = wordScale(d.frequency*weight);
    		if(((21 - text_length) * 2) + 31 < text_size){
    			console.log(d.text, text_size);
    			text_size = ((21 - text_length) * 2) + 31
    			console.log(d.text, text_size);
    			return text_size;
    		}
    		else{
    			return text_size;	
    		}
    	}
    	
		d3.layout.cloud().size([width, height]).words(frequency_list)
        //.rotate(function() { return (Math.random() * 2) * 90; })
        .padding(2.5)
        .text(function(d) { return d.text; })
        .rotate(0)
        .font("GmarketSansBold")
        
        .fontSize(function(d) { 
        	return score_function(d); 
        	})
        .on("end", draw)
        .start();
		
		var zoom_group;
          function draw(words) {
            var svg = d3.select("#"+IDname).append("svg")
                .attr("width", width)
                .attr("height", height)
                
                
            zoom_group = svg.append("g")
                .attr("transform", "translate(" + width/2 + "," + height/2 + ")")
            
            zoom_group
              .selectAll("text")
                .data(words)
              .enter().append("text")
                .style("font-size", function(d) { return d.size + "px"; })
                .style("font-family", "GmarketSansBold")
                .style("fill", function(d, i) { return fill(i); })
                .style("color", function(d, i) { return fill(i); })
                .attr("text-anchor", "middle")
                
                .attr("transform", function(d) {
                  return "translate(" + [d.x, d.y] + ")";// + ")rotate(" + d.rotate + ")";
                })
                
              .text(function(d) { return d.text; });
          }
    }
    showCloud(frequency_list, IDname);
}

function build_wordTable_todayscore(score_data, member, front, on_off_text){
	var IDname = "";
	var data = eval(score_data)
	if(typeof data == "undefined")
		return;
	var data_len = data.length;
	var chk = $("#removeCheck").is(":checked");
	var cnt_limit = 10;
	if(on_off_text === "ON"){
		cnt_limit = 15;
	}
	IDname = "member_word-table_ul";
	$("#"+IDname).empty()
	var cnt = 0;
    for (var i = 0; i < data_len; i++) {
    	
		var word = data[i]['word'];
		var score = data[i]['score'];
		var accumulate_word = data[i]['accumulate']
		
		score = score.toFixed(2);
		score = numberWithCommas(score);
		
		if(accumulate_word){ //data[i].length > 5
			var member_total_TF = "누적단어"//data[i][5];
			if(!chk && member_total_TF == "누적단어")
				continue;
			else{
				if(member_total_TF == "누적단어아님"){
					$("#"+IDname).append('<li style="cursor: pointer"><span class="num_item">'+(i+1)
							+'</span><p class="desc_info" id = '+seq+'><span id = '+seq+'>'+word
							+'</span></p><p class="desc_count">'+score+"</p></li>");
				}else{
					$("#"+IDname).append('<li class = "tag" style="cursor: pointer"><span class="num_item">'+(i+1)
							+'</span><p class="desc_info"><span id = "desc_info_todayscore">'+word
							+'</span></p><p class="desc_count">'+score+"</p></li>");
				}
			}
		}
		else{ //누적 탭 순위 테이블 표시할때
			$("#"+IDname).append('<li style="cursor: pointer;"><span class="num_item">'+(i+1)
			+'</span><p class="desc_info"><span id="desc_info_todayscore">'+word
			+'</span></p><p class="desc_count">'+score+"</p></li>");
		}
		cnt+=1;
		if(cnt == cnt_limit)
			break;
    }
	$("#"+IDname).show();
}

function build_wordTable_sentiment(score_data,member,front, on_off_text){
	var IDname = "";
	var data = eval(score_data)
	if(typeof data == "undefined")
		return;
	var data_len = data.length;
	var cnt_limit = 10;
	if(on_off_text === "ON"){
		cnt_limit = 15;
	}
	IDname = "sentiment_member_word-table_ul";
	$("#"+IDname).empty()
	var cnt = 0;
    for (var i = 0; i < data_len; i++) {
    	
		var word = data[i]['word'];
		var score = data[i]['score'];
		score = score.toFixed(2);
		score = numberWithCommas(score);
		
		if(data[i].length > 5){
			var member_total_TF = data[i][5];
			if(!chk && member_total_TF == "누적단어")
				continue;
			else{
				if(member_total_TF == "누적단어아님"){
					$("#"+IDname).append('<li style="cursor: pointer"><span class="num_item">'+(i+1)
							+'</span><p class="desc_info" id = '+seq+'><span id = '+seq+'>'+word
							+'</span></p><p class="desc_count">'+score+"</p></li>");
				}else{
					$("#"+IDname).append('<li class = "tag" style="cursor: pointer"><span class="num_item">'+(i+1)
							+'</span><p class="desc_info" id = '+seq+'><span id = '+seq+'>'+word
							+'</span></p><p class="desc_count">'+score+"</p></li>");
				}
			}
			
			 
		}
		else{ //누적 탭 순위 테이블 표시할때
			$("#"+IDname).append('<li style="pointer-events:none;"><span class="num_item">'+(i+1)+'</span><p class="desc_info"><span id="desc_info_sentiment">'+word+'</span></p><p class="desc_count">'+score+"</p></li>");
		}
		cnt+=1;
		if(cnt == cnt_limit)
			break;
    }
	$("#"+IDname).show();	
}

function img_download_sentiment(){
	
	if($("#sentiment_loadingBar_wordcloud").is(":visible")){
		alert("분석중입니다.")
		return;
	}
	//이미지 다운로드 할때 날짜 단어 표시 하기 위함
	var date_period_string ="";
	var IDname = "";
	var on_off_text = "";
	var tab_link = $(".tab-link.current").text() // 오주뉴 / 프리미엄
	//프리미엄이라면 주간, 월간, 분기, 기간 설정
	// 단일 단어/ 단어쌍	
	IDname = "member_wordcloud_sentiment";
	var sub_tab_link = $(".sub_tab_member-link.current").text();
	var pair_type = $("#pair_type_member li.active").text()
	on_off_text = "";
	/*
	var p_square_check = $(".p_square_check_member");
	for(var i = 0; i < p_square_check.length; i++){
		var p_tag = $(p_square_check[i]);
		if(p_tag.is(':visible')){
			on_off_text = p_tag.text();
		}
	}
	*/
	if($("#sentiment_member_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
		on_off_text = "OFF";
	}
	else{
		on_off_text = "ON";
	}
	
	
	if(sub_tab_link.includes("누적")){
		//누적
		var yester_day = yesterday();
		var user_st_date = date_name_return(user_start_date);
		date_period_string = user_st_date+" ~ "+yester_day;
	}else if(sub_tab_link.includes("기간")){
		var start_date = $("#start_datepicker").val();
	    var end_date = $("#end_datepicker").val();
		
		//period setting
		var st_date = date_name_return(start_date);
		var ed_date = date_name_return(end_date);
		date_period_string = st_date;
		console.log(st_date);
		if(st_date != ed_date)
			date_period_string = st_date+" ~ "+ed_date;
	}else{
		//period
		var today = yesterday();
		var period = 0;
		if(sub_tab_link.includes("주간"))
			period = 7;
		else if(sub_tab_link.includes("월간"))
			period = 30;
		else
			period = 90;
		
		var today_minus_period = today_minus(period);
		date_period_string = today_minus_period+" ~ "+today
	}
	var left = 0;
    var top = 0;
    $("#"+IDname).find('g').find("text").each(function(index, item){
  	  number_string = $(item).attr("transform").replace("translate(","").replace(")","").split(",");
  	  var x = parseInt(number_string[0]);
    	  var y = parseInt(number_string[1]);
    	  
  	  if(left < x)
  		  left = x;
  	  
  	  if(top > y)
  		  top = y;
    })
    if(date_period_string.includes("~")){
  	  left = left-50
    }
	  else{
		  if(date_period_string.includes(":")){
		  	left = left-30
		  }
		  else{
			 left = left;
		  }
	  }
    if(on_off_text === "ON"){
  	  top = top-40;
  	  if(top > -255){
  		  top = -255
  	  }
    }else{
  	  top = -210
    }
    d3.select("#"+IDname).select("g")
    .append("text")
    .attr("id", "wordcloud_date_text")
    .attr("x", left)             
    .attr("y", top) //top-30
    .attr("text-anchor", "middle")  
    .style("font-size", "12px")
    .style("color", "#666666")
    .style("font-family", "GmarketSansBold")
    .text(date_period_string)
			
			
	var tab_name = $(".tab-link.current").attr("data-tab")
	var wordcloud_html;
	var img_width, img_height;
	wordcloud = document.getElementById("member_wordcloud_sentiment").childNodes[9].childNodes[0];
	img_width = wordcloud.getBoundingClientRect().width+10
	img_height = wordcloud.getBoundingClientRect().height+10;
	
	
	/*svg = document.getElementById("member_wordcloud").childNodes[5];
	var img_width = svg.width.baseVal.value
	var img_height = svg.height.baseVal.value
	
	img_width = wordcloud.getBoundingClientRect().width+7
	img_height = wordcloud.getBoundingClientRect().height+1;*/
	var file_name = "";
	if($($("#pair_type_member_sentiment li")[0]).attr('class').includes("active")){
		file_name = "wordscore_positive.png";
	}
	else{
		file_name = "wordscore_negative.png";
	}
	
	html2canvas(wordcloud, {width : img_width, height: img_height, scrollY: -window.scrollY, scale : 1.5, useCORS : true}).then(function (canvas) {
        var img = canvas.toDataURL('image/png');
        downloadURI(img, file_name, img_width, img_height);
   })
}

function excel_download_sentiment(){
	
	if($("#sentiment_loadingBar_wordcloud").is(":visible")){
		alert("분석중입니다.")
		return;
	}
	
	var start_date = $("#start_datepicker").val();
    var end_date = $("#end_datepicker").val();
	
	var user_name = new String("<%=sm3ID%>")
	var removeChecked = $("#removeCheck").is(":checked");
	var dates = new Date();
	var year = new String(dates.getFullYear()); // 년도
	var month = new String(dates.getMonth() + 1);  // 월
	if(month.length < 2)
		month = "0"+month;
	
	var day = new String(dates.getDate());  // 날짜
	if(day.length < 2)
		day = "0"+day;
	
	var hours = new String(dates.getHours()); // 시
	if(hours.length < 2)
		hours = "0"+hours;
	
	var minutes = new String(dates.getMinutes());  // 분
	if(minutes.length < 2)
		minutes = "0"+minutes;
	
	var seconds = new String(dates.getSeconds());  // 초
	if(seconds.length < 2)
		seconds = "0"+seconds;
	
	var date = year+month+day+"_"+hours+minutes+seconds;
	//file_name_date = year+month+day;
	file_name_date = date;
	
	var filename = user_name+"_"+date;
	
	if(sentiment_word_score != null){
		var word_score_excel = JSON.stringify(sentiment_word_score);
	}else{
		return;
	}
	
	var type = 0;
	var filename = "";
	if($($("#pair_type_member_sentiment li")[0]).attr('class').includes("active")){
		type = 1;
		filename = user_name+"_positive_"+date;
	}else{
		type = -1;
		filename = user_name+"_negative_"+date;
	}
	
	
	$.ajax({
		type : "POST",
		url : './utils/sentiment_word_score_excel_save.jsp',
		data : {
			"start_date" : start_date,
			"end_date" : end_date,
			"filename" : filename,
			"word_score_data" : word_score_excel,
			"type":type,
		}
	}).done(function(o){
		
		$('#download_link').attr({
			'download':'wordcloud_'+filename+'.xls',
			'href':'./wordcloud_excel/'+filename+".xls"
			})
		document.getElementById("download_link").click();
		
	})
	
}

</script>

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
						 		
	                            <li><input id="blobButton" class="blobButton" type="button" onclick="img_download()" value="이미지 저장"></li>
	                            <li><input id="blobButton" class="blobButton" type="button" onclick="excel_download()" value="엑셀 저장"></li>
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
					 		<div id = "loadingBar_wordtable_total" style="display:none; width:250px; height: 250px">
		               			<img id = "loading-image" src = "./css/ajax-loader.gif"  style = "position: relative; top: 50%; left: 50%; z-index:100;"/>
		               		</div>
					 		<ul class = "rank_li srch" id="total_word_table_ul">
					 		</ul>
					 		<!-- <button id = "search_keyword_total_button" onclick="search_keyword_total()" style = "width:50px; height:20px"> &nbsp;</button>  -->
					 	</div>
					 	<ul class="total_info">
	                        <li>신문 "&{paper_media_count};"종과 인터넷 뉴스 "&{online_media_count};"종을 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다.<a href="#">TF-IDF란?</a></li>
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
					 		
                            <li><input id="blobButton" class="blobButton" type="button" onclick="img_download()" value="이미지 저장"></li>
                            <li><input id="blobButton" class="blobButton" type="button" onclick="excel_download()" value="엑셀 저장"></li>
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
	                    <div id = "loadingBar_wordtable" style="display:none; width:250px; height: 250px">
	               			<img id = "loading-image" src = "./css/ajax-loader.gif"  style = "position: relative; top: 50%; left: 50%; z-index:100;"/>
	               		</div>
	                    <ul class="rank_li srch" id="member_word-table_ul">
	                    </ul>
	                    <!--<button id = "search_keyword_member_button" onclick="search_keyword_member()" style = "width:50px; height:20px">&nbsp;</button>  -->
	                </div>
	                <ul class="member_total_info">
                        <li>프리미엄 서비스 출시 이후 고객님의 계정에 어제까지 뷰어에 등록된 모든 기사를 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다.<a href="#">TF-IDF란?</a></li>
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
					 		
                            <li><input id="blobButton" class="blobButton" type="button" onclick="img_download_sentiment()" value="이미지 저장"></li>
                            <li><input id="blobButton" class="blobButton" type="button" onclick="excel_download_sentiment()" value="엑셀 저장"></li>
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
	                    <div id = "sentiment_loadingBar_wordtable" style="display:none; width:250px; height: 250px">
	               			<img id = "loading-image" src = "./css/ajax-loader.gif"  style = "position: relative; top: 50%; left: 50%; z-index:100;"/>
	               		</div>
	                    <ul class="rank_li srch" id="sentiment_member_word-table_ul">
	                    </ul>
	                    <!--<button id = "search_keyword_member_button" onclick="search_keyword_member()" style = "width:50px; height:20px">&nbsp;</button>  -->
	                </div>
	                <!-- 
	                <ul class="member_total_info">
                        <li>프리미엄 서비스 출시 이후 고객님의 계정에 어제까지 뷰어에 등록된 모든 기사를 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다.<a href="#">TF-IDF란?</a></li>
                        <li>워드클라우드에서 단어를 클릭하면 해당 단어가 기사 내 언급된 날짜별 추이로 아래 그래프에 반영됩니다. 그래프의 특정 위치를 클릭하면 해당 일자와 점수를 확인할 수 있습니다.</li>
                    </ul>
                     -->
			 	</div>
			</div>
            
		</div>
		<a id = "download_link" download ></a>
	</div>
	
<script type="text/javascript">

</script>
</body>
</html>