/**
 * 이전 코드를 못알아 먹겠어서 다시 만들자.
 */

let online_media_list = "";
let online_media_count = 0;
//let user_seq = eval(user_seq)[0];

google.charts.load('current',{
    'packages' : ['corechart','table']});
google.charts.setOnLoadCallback(drawChart);
let sentiment_word_score = null;
let sentiment_xhr;

Date.prototype.addDays = function(days) {
    var date = new Date(this.valueOf());
    date.setDate(date.getDate() + days);
    return date;
}

function downloadURI_FORNEW(img_raw_uri, name, img_width, img_height){
	let link = document.createElement("a");
	let dates = new Date();
	let year = new String(dates.getFullYear()); // 년도
	let month = new String(dates.getMonth() + 1);  // 월
	if(month.length < 2)
		month = "0"+month;
	
	let day = new String(dates.getDate());  // 날짜
	if(day.length < 2)
		day = "0"+day;
	
	let hours = new String(dates.getHours()); // 시
	if(hours.length < 2)
		hours = "0"+hours;
	
	let minutes = new String(dates.getMinutes());  // 분
	if(minutes.length < 2)
		minutes = "0"+minutes;
	
	let seconds = new String(dates.getSeconds());  // 초
	if(seconds.length < 2)
		seconds = "0"+seconds;
	
	// let date = year+month+day+"_"+hours+minutes+seconds;
	let date = document.getElementById('cal_date').value.replace(/-/gi, "")+"_"+hours+minutes+seconds;	
	file_name_date = year+month+day;
	
	let filename = user_name+"_"+date;
	
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
			'download': filename+'.png', //'wordcloud_'
			'href':'./wordcloud_image/'+filename
			})
		document.getElementById("download_link").click();
	})
	
	$("#wordcloud_date_text").remove();
}

function downloadURI(img_raw_uri, name, img_width, img_height){
	let link = document.createElement("a");
	let dates = new Date();
	let year = new String(dates.getFullYear()); // 년도
	let month = new String(dates.getMonth() + 1);  // 월
	if(month.length < 2)
		month = "0"+month;
	
	let day = new String(dates.getDate());  // 날짜
	if(day.length < 2)
		day = "0"+day;
	
	let hours = new String(dates.getHours()); // 시
	if(hours.length < 2)
		hours = "0"+hours;
	
	let minutes = new String(dates.getMinutes());  // 분
	if(minutes.length < 2)
		minutes = "0"+minutes;
	
	let seconds = new String(dates.getSeconds());  // 초
	if(seconds.length < 2)
		seconds = "0"+seconds;
	
	let date = year+month+day+"_"+hours+minutes+seconds;	
	file_name_date = year+month+day;
	
	let filename = user_name+"_"+date;
	
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
			'download': filename+'.png', //'wordcloud_'
			'href':'./wordcloud_image/'+filename
			})
		document.getElementById("download_link").click();
	})
	
	$("#wordcloud_date_text").remove();
}

//오늘 점수 저장을 위해
let today_word_score = null;

function new_obj(obj){
	return JSON.parse(JSON.stringify(obj));
}

function drawChart() {
	let type = "0";
	// dnai_total
	
	// dnai_member
}

$(document).ready(function() {
	
	// mouse right click abandon
	$(document).bind("contextmenu", function() {
		return false;
	});
	
	$("ul.inner li").click(function() {
		$("#period_setting").hide();
		$("li.check").hide();
		$("#sentiment_score_display").hide();
		let tab_id = $(this).attr('data-tab');
		
		$('ul.inner li').removeClass('current');
		$('.tab-content').removeClass('current');

		$(this).addClass('current');
		$("#"+tab_id).addClass('current');
		
		$("#periodLabel").hide();
		let sub_tab_text = $('.sub_tab_member-link.current').text();
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
	});
	
	common_func.init();
	dnai_today.init();
	dnai_member.init();
});

let common_func = {
		online_media_list : "",
		online_media_count : 0,
		paper_media_count : 0,
		init : function() {
			let online_media_info = common_func.online_media_return();
			this.online_media_list = online_media_info['media_list'];
			this.online_media_count = online_media_info['media_count'];
			this.paper_media_count = common_func.paper_media_return();
		},
		setting_today : function() {
			let today = new Date();
			let year = today.getFullYear();
			let month = today.getMonth() + 1;
			let date = today.getDate();
			
			if(month < 10)
				month = "0"+month;
			if(date < 10)
				date = "0"+date;
			
			let today_string = year+"-"+month+"-"+date;
			
			return today_string;
		},
		setting_yesterday : function() {
			let today = new Date();  
			let year = today.getFullYear(); // 년도
			let month = today.getMonth() + 1;  // 월
			let date = today.getDate()-1;  // 날짜
			
			if(month < 10)
				month = "0"+month;
			if(date < 10)
				date = "0"+date;
			
			let yester_day = year+"-"+month+"-"+date;
			
			
			
			today = new Date();   
			year = today.getFullYear(); // 년도
			month = today.getMonth() + 1;  // 월
			date = today.getDate()-7;  // 날짜
			
			if(month < 10)
				month = "0"+month;
			if(date < 10)
				date = "0"+date;
			
			let yester_day_minus7 = year+"-"+month+"-"+date;
			
//			document.getElementById('start_datepicker').value = yester_day;
//			document.getElementById('end_datepicker').value = yester_day;
			
			return yester_day;
		},
		yesterday_string : function() {
			let yester_day = common_func.setting_yesterday();
			
			let week = new Array('일', '월', '화', '수', '목', '금', '토')
			let date = new Date();
			date.setDate(date.getDate() - 1);
			let day_name = week[date.getDay()];
			
			return yester_day+"("+day_name+")";
		},
		today_minus : function(period) { //워드클라우드 날짜 표시(주간, 월간, 분기)
			let week = new Array('일', '월', '화', '수', '목', '금', '토')

			let date = new Date(); 
			date.setDate(date.getDate() - (period+1));
			
			let year = date.getFullYear(); 
			let month = new String(date.getMonth()+1); 
			let day = new String(date.getDate()); 
			let day_name = week[date.getDay()];
			// 한자리수일 경우 0을 채워준다. 
			if(month.length == 1){ 
			  month = "0" + month; 
			} 
			if(day.length == 1){ 
			  day = "0" + day; 
			} 
			return year+'-'+month+'-'+day+"("+day_name+")";
		},
		today_10_minute_ago : function() { //워드클라우드 날짜 표시 (오늘의 키워드)
			let week = new Array('일', '월', '화', '수', '목', '금', '토')
			let date = new Date();
			date.setMinutes(date.getMinutes() - 20);
			let minus_minute = date.getMinutes() % 10;
			date.setMinutes(date.getMinutes() - minus_minute + 10);
			
			let year = date.getFullYear(); 
			let month = new String(date.getMonth()+1); 
			let day = new String(date.getDate());
			let day_name = week[date.getDay()];
			let Hour = new String(date.getHours());
			let minute = new String(date.getMinutes());
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
			return year+'-'+month+'-'+day+"("+day_name+")"+" "+Hour+":"+minute;
		},
		getDates : function(startDate, stopDate) {
			let dateArray = new Array();
			let currentDate = startDate;
			while (currentDate <= stopDate) {
		        dateArray.push(common_func.formatDate(new Date (currentDate)));
		        currentDate = currentDate.addDays(1);
		    }
		    return dateArray;
		},
		formatDate : function(date) {
			let d = new Date(date),
	        month = '' + (d.getMonth() + 1),
	        day = '' + d.getDate(),
	        year = d.getFullYear();

		    if (month.length < 2) 
		        month = '0' + month;
		    if (day.length < 2) 
		        day = '0' + day;
	
		    return [year, month, day].join('-');
		},
		date_name_return : function(date) { //워드클라우드 날짜표시 (누적, 기간설정의 경우 요일도 반환하기 위해)
			let week = new Array('일', '월', '화', '수', '목', '금', '토')
			let split_date = date.split("-")
			let date_ = new Date(date);//new Date(split_date[0], split_date[1], split_date[2]);
			
			let year = date_.getFullYear();  
			let month = new String(date_.getMonth()+1); 
			let day = new String(date_.getDate());
			
			//date.setMonth(date.getMonth() - 1);
			let day_name = week[date_.getDay()];
			// 한자리수일 경우 0을 채워준다. 
			if(month.length == 1){ 
			  month = "0" + month; 
			} 
			if(day.length == 1){ 
			  day = "0" + day; 
			}
			return year+'-'+month+'-'+day+"("+day_name+")"
		},
		online_media_return : function() {
			let online_media_list = "";
			let online_media_count = 0;
			
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
			return {"media_list":online_media_list, "media_count":online_media_count};
		},
		paper_media_return : function() {
			let paper_media_count = 0;
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
		},
		show_history_infoText : function() {
			let msg = "워드클라우드에서 단어를 클릭하면 해당 단어가 기사 내 언급된 날짜별 추이로 아래 그래프에 반영됩니다.";
			msg+="\n그래프의 특정 위치를 클릭하면 해당 일자와 점수를 확인할 수 있습니다."
			alert(msg);
		},
		show_tfidf_infotext : function() {
			let msg = "TF-IDF 알고리즘이란? \n여러 문서로 이루어진 문서군이 있을 때 어떤 단어가 특정 문서 내에서 얼마나 중요한 것인지를 나타내는 수치 산출 알고리즘입니다.";
			alert(msg);
		},
		on_button_func : function() {
			$(".desc_info").off("click", function(event) {
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
		},
}

var dnai_today = {
		online_media_list : "",
		online_media_count : 0,
		paper_media_count : 0,
		today_word_score : null,
		today_word_score_pair : null,
		today_1_word_score : null,
		today_1_word_score_pair : null,
		current_dateTime : null,
		remove_word_list : [],
		init : function() {
			this.online_media_list = common_func.online_media_list;
			this.online_media_count = common_func.online_media_count;
			this.paper_media_count = common_func.paper_media_count;
			this.ajax_word_score();
			this.on_button_func();
			
			// 국방부 날짜 선택 관련 추가 함수
			this.setting_cal_date();
			this.initCalDate();
			
			this.current_dateTime = new Date();
			
			if(edit_valid == false) {
				$("#editing_action").hide();
			}
		},
		setting_cal_date : function() {
			// 달력 세팅
			$("#cal_date").datepicker({
				//showOn: "both", // 버튼과 텍스트 필드 모두 캘린더를 보여준다.
				  showOn: "focus",
				  //buttonImage: "/application/db/jquery/images/calendar.gif", // 버튼 이미지

				  //buttonImageOnly: true, // 버튼에 있는 이미지만 표시한다.

				  changeMonth: true, // 월을 바꿀수 있는 셀렉트 박스를 표시한다.

				  changeYear: true, // 년을 바꿀 수 있는 셀렉트 박스를 표시한다.

				  minDate: new Date('2020-06-01'), // 유의미한 데이터가 2020-06-01부터 존재하므로, 2020-06-01부터 가능하도록 처리한다.
				  
				  maxDate: new Date(common_func.setting_today()), // 오늘 이후 날짜는 데이터가 없음으로 비활성화 처리한다.

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
			
			let cal_date = common_func.setting_today();
			document.getElementById('cal_date').value = cal_date;
			
			// 이전 날짜 선택버튼 세팅			
			$("#cal_prev").click(function() {
				let today = new Date(cal_date);
				let currentDate = new Date($("#cal_date").val());
				currentDate.setDate(currentDate.getDate() - 1); // 현재 날짜에 1일을 더함
				$("#cal_date").datepicker("setDate", currentDate); // DatePicker의 날짜를 업데이트
				$("#cal_date").trigger("change");
				
				if(currentDate < today) {
					$('.cal_next').removeClass('disabled');
				}
			});			
			
			// 다음 날짜 선택버튼 세팅
			$("#cal_next").click(function() {
				let today = new Date(cal_date);
				let currentDate = new Date($("#cal_date").val());
				
				if(currentDate < today) {
					currentDate.setDate(currentDate.getDate() + 1); // 현재 날짜에 1일을 더함
					$("#cal_date").datepicker("setDate", currentDate); // DatePicker의 날짜를 업데이트
					$("#cal_date").trigger("change");
					if(currentDate >= today) {
						$('.cal_next').addClass('disabled');
					}
				}
			});
			
			// 국방부 계정에 한정해서 열어주도록 처리함 
			// 전체 다 열도록 처리하면서 주석처리함
			/* if(user_name=='mnd1' || user_name=='mnd2') {
				$('.cal').css('display','block');
			} */
		},
		initCalDate() {
			$('#cal_date').change(function() { 				
				$.ajax({
					type : 'POST',
			        url : './utils/total_word_score/word_score_by_day.jsp',
			        data : {
			        	sel_date : $('#cal_date').val()
			        },
			        dataType : 'json',
			        async: true,
			        success : function(data) {
			        	data = new_obj(data);
			        	dnai_today.today_word_score = data['today_word_score'];
			        	dnai_today.today_word_score_pair = data['today_word_score_pair'];
			        	dnai_today.today_1_word_score = data['today_1_word_score'];
			        	dnai_today.today_1_word_score_pair = data['today_1_word_score_pair'];
			        },
			        beforeSend : function() {
			        	$("#loadingBar_wordcloud_total").show();
			        	$("#wordcloud svg").hide();
			        	
			        	$("#loadingBar_wordtable_total").show();
			        	$("#total_word_table_ul").hide(); 
			        	
			        	// 진행중에 날짜 바뀜을 막기 위한 처리			        	
			        	$('#cal_prev').attr('disabled',true);
			        	$('#cal_date').attr('disabled',true);
			        	$('#cal_next').attr('disabled',true);			        	
			        },
			        error : function(e) {
			        	alert(e.responseText);
			        	
			        	// 에러발생시에도, 날짜선택 비활성을 풀어준다.
						$('#cal_prev').removeAttr('disabled',true);
			        	$('#cal_date').removeAttr('disabled',true);		        	
						$('.cal_next').removeAttr('disabled',true);
			        }
				}).done(function(){
					dnai_today.draw_function();
					
					// 전부 랜더링 된 이후라면, 날짜선택 비활성을 풀어준다.
					$('#cal_prev').removeAttr('disabled',true);
		        	$('#cal_date').removeAttr('disabled',true);		        	
					$('.cal_next').removeAttr('disabled',true);
				});				
			})
		},		
		search_keyword : function(obj) { // 검색 버튼 누를 경우 활성화
			let paper_1 = $(".sub_tab-link.current").text();
			let online_media_list_parameter = new_obj(dnai_today.online_media_list);
			online_media_list_parameter = online_media_list_parameter.slice(0,-1);
			let flag = false;
			if(paper_1.includes("1면")) {
				flag = true;
			}
			let parent = $(obj).parent();
			let keyword = parent.children('span').text();
			let cal_date = document.getElementById('cal_date').value.replace(/-/gi, "");
			
			window.open("sm5search:"+keyword+"|"+online_media_list_parameter+"|"+flag+"|"+cal_date, "keword_search","width = 400, height=300, left=100, top=50");
		},
		ajax_word_score : function() {
			$.ajax({
				type : 'POST',
		        url : './utils/total_word_score/word_score.jsp',
		        data : {},
		        dataType : 'json',
		        async: true,
		        success : function(data) {
		        	data = new_obj(data);
		        	dnai_today.today_word_score = data['today_word_score'];
		        	dnai_today.today_word_score_pair = data['today_word_score_pair'];
		        	dnai_today.today_1_word_score = data['today_1_word_score'];
		        	dnai_today.today_1_word_score_pair = data['today_1_word_score_pair'];
		        },
		        beforeSend : function() {
		        	$("#loadingBar_wordcloud_total").show();
		        	$("#wordcloud svg").hide();
		        	
		        	$("#loadingBar_wordtable_total").show();
		        	$("#total_word_table_ul").hide(); //
		        },
		        error : function(e) {
		        	alert(e.responseText);
		        }
			}).done(function(){
				dnai_today.draw_function();
			});
		},
		on_button_func : function() {
			$('ul.sub_tabs li').click(function(){
				let tab_id = $(this).attr('data-tab');
				$('ul.sub_tabs li').removeClass('current');
				$('.sub_tab-content').removeClass('current');
				$(this).addClass('current');
				$("#"+tab_id).addClass('current');
				
				let front = 1;
				let front_text = $(this).text()
				if(front_text.indexOf("1면") >= 0){
					front = 2;
				}
				let type = 0;
				let pair_type = $('#pair_type').children('.active').text();
				if(pair_type == '단어 쌍'){
					type = 1;
				}
				if($("#save_action").is(":visible")) {
					$("#save_action").hide();
					$("#cancel_action").hide();
					dnai_today.remove_word_list = [];
					$("#editing_action").show();
				}
				
				
				dnai_today.draw_function();
			});
			$("#pair_type").on('click','li', function(event){
				if(typeof($(event.target).attr('id')) != "undefined" && $(event.target).attr("id").includes("before"))
					return;	
				
				$("#pair_type li").removeClass('active');
				$(event.target).addClass('active');
				let pair_type = $(event.target).text()
				let type = 0;
				if(pair_type == "단어 쌍")
					type = 1;
				
				let front = 1;
				let front_text = $('.sub_tab-link.current').text()
				if(front_text.indexOf("1면") >= 0){
					front = 2;
				}
				
				if($("#save_action").is(":visible")) {
					$("#save_action").hide();
					$("#cancel_action").hide();
					dnai_today.remove_word_list = [];
					$("#editing_action").show();
				}
				dnai_today.draw_function();
			});
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
				if($("#save_action").is(":visible")) {
					dnai_today.draw_function_edit();
				}else{
					dnai_today.draw_function();
				}
			});
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
				if($("#save_action").is(":visible")) {
					dnai_today.draw_function_edit();
				}else{
					dnai_today.draw_function();
				}
			});
			
			$("#totalImgDownload").off("click").on("click", function() {
				dnai_today.img_download();
			});
			$("#totalExcelDownload").off("click").on("click", function() {
				dnai_today.excel_download();
			});
			$("#editing_action").off("click").on("click", function() {
				$("#save_action").show();
				$("#cancel_action").show();
				$("#editing_action").hide();
				dnai_today.draw_function_edit();
			});
			$("#save_action").off("click").on("click", function() {
				$("#save_action").hide();
				$("#editing_action").show();
				$("#cancel_action").hide();
				
				dnai_today.draw_function();
			});
			$("#cancel_action").off("click").on("click", function(){
				$("#save_action").hide();
				$("#editing_action").show();
				$("#cancel_action").hide();
				dnai_today.remove_word_list = [];

				dnai_today.draw_function();
			}); 
		},
		draw_function : function() { // 경우에 따라 조건에 맞는 워드클라우드를 그려주기 위함
			let timeDiff = new Date().getTime() - dnai_today.current_dateTime.getTime();
			timeDiff = timeDiff / 1000 / 60;
			if(timeDiff > 10) {
				dnai_today.current_dateTime = new Date();
				dnai_today.ajax_word_score();
				return;
			}
			
			let current_tab = $("ul.sub_tabs li.current").text();
			let pair_type = $("#pair_type li.active").text();

			let input_data = null;
			if(current_tab.includes("1면")) {
				if(pair_type.includes("단일")) {
					input_data = new_obj(dnai_today.today_1_word_score);
				}else{
					input_data = new_obj(dnai_today.today_1_word_score_pair);
				}
				
				if(input_data.length == 0) {
					dnai_today.sunday();
				}else{
					$(".total_info").html('<li class="media_count_info"></li><li>10분마다 갱신됩니다.</li>');
					$(".total_info").css("display","block");
					
					$("#pair_type").css("display","block");
					$("#wordcloud").css("display","block");
					$("#word-table").css("display","block");
					
					let media_count_info = "신문 "+this.paper_media_count+"종과 인터넷 뉴스 "+this.online_media_count+"종을 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다."+"<a>TF-IDF란?</a>"
					$(".media_count_info").empty();
					$(".media_count_info").html(media_count_info);
				}
				
			}else{
				if(pair_type.includes("단일")) {
					input_data = new_obj(dnai_today.today_word_score);
				}else{
					input_data = new_obj(dnai_today.today_word_score_pair);
				}
				
				if(input_data.length == 0) {
					dnai_today.total_info_();
				}else{
					$(".total_info").html('<li class="media_count_info"></li><li>10분마다 갱신됩니다.</li>');
					$(".total_info").css("display","block");
					
					$("#pair_type").css("display","block");
					$("#wordcloud").css("display","block");
					$("#word-table").css("display","block");
					
					let media_count_info = "신문 "+this.paper_media_count+"종과 인터넷 뉴스 "+this.online_media_count+"종을 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다."+"<a>TF-IDF란?</a>"
					$(".media_count_info").empty();
					$(".media_count_info").html(media_count_info);
				}
			}
			$(".media_count_info a").off("click").on("click", function() {
				url = "./utils/TFIDF_description.html";
				name = "tfidf description";
				specs = "width = 600, height=700, top=200, left=100, toolbar=no, menubar=no,scrollbar=no, resizeble=yes";

				window.open(url, "_blank", specs);
				return false;
			});
			
			dnai_today.build_wordcloud(input_data);
			dnai_today.build_wordtable(input_data);
		},
		build_wordcloud : function(data) {
			let on_off_text_total = "OFF";
			if($("#total_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
				on_off_text_total = "OFF";
			}
			else{
				on_off_text_total = "ON";
			}
			let words = new_obj(data);
			let max = 0;
			let min = Infinity;
			let frequency_list = new Array();
			if(words.length == 0) { return; }
			
			let IDname = "wordcloud";
			
			for(let i = 0; i < words.length; i++) {
				let word = words[i][0];
				let score = words[i][1];
				if(dnai_today.remove_word_list.includes(word)) { continue;}
				if(max < score) { max = score; }
				if(min > score) { min = score; }
			}
			
//			max = words[0][1];
//			min = words[words.length-1][1];
			for(let i = 0; i < words.length; i++){
				let temp_dict = {};
				let word = words[i][0];
				if(dnai_today.remove_word_list.includes(word)) {
					continue;
				}
				
		       	let score = (words[i][1]-min)/ (max-min) + 0.3;
		       	temp_dict['text'] = word;
		        temp_dict["frequency"] = score;
		        frequency_list.push(temp_dict);
			}
			let first_sorting_field = "frequency";
		    let second_sorting_field = "text";
		    frequency_list.sort(function(a,b) {
		    	if(a[first_sorting_field] - b[first_sorting_field] === 0){
		    		return a[second_sorting_field] < b[second_sorting_field] ? -1 : a[second_sorting_field] > b[second_sorting_field] ? 1 : 0;
		    	}
		    	
		    	else{
		    		return b[first_sorting_field] - a[first_sorting_field];
		    	}
		    });
		    
		    function showCloud(frequency_list, IDname)
		    {
		    	
		    	$("#"+IDname).children('svg').remove();
		    	var weight,width,height;   // change me
		    	var domain_max, range_max, domain_min, domain_max;
		    	if(on_off_text_total === "ON"){
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
//		            	 	if(d.seq){
//		            	 		var item = new Array();
//		            	 		item.push(d.seq);
//		            	 		item.push(d.text);
//		            	 		history_change(item,IDname)	
//		            	 	}
		            	 	
		              });
		          }
		    }
		    showCloud(frequency_list, IDname);
		    $("#loadingBar_wordcloud_total").hide();
		},
		build_wordtable : function(data) {
			let on_off_text_total = "OFF";
			if($("#total_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
				on_off_text_total = "OFF";
			}
			else{
				on_off_text_total = "ON";
			}
			if(typeof data == "undefined")
				return;
			let data_len = data.length;
			let chk = $("#removeCheck").is(":checked");
			let cnt_limit = 10;
			if(on_off_text_total === "ON"){
				cnt_limit = 15;
			}
			
			let IDname = "total_word_table_ul";
			$("#"+IDname).empty()
			var cnt = 0;
			let display_order = 1;
		    for (var i = 0; i < data_len; i++) {
		    	
				var word = data[i][0];
				var score = data[i][1].toFixed(2);
				
				if(dnai_today.remove_word_list.includes(word)) {
					continue;
				}
				
				score = score.toLocaleString("ko-kr");
				
				$("#"+IDname).append("<li><span class='num_item'>"+(display_order)+"</span><p class='desc_info'><span>"+word+'</span><a class="rank_srch" title="검색">검색</a></p><p class="desc_count">'+score+"</p></li>");
				cnt+=1; display_order += 1;
				if(cnt == cnt_limit)
					break;
		    }
		    $(".rank_srch").off("click").on("click", function() {
				dnai_today.search_keyword(this);
			});
		    $("#loadingBar_wordtable_total").hide();
		    $("#total_word_table_ul").show();
		},
		
		draw_function_edit : function() {
			let current_tab = $("ul.sub_tabs li.current").text();
			let pair_type = $("#pair_type li.active").text();
			let input_data = null;
			if(current_tab.includes("1면")) {
				if(pair_type.includes("단일")) {
					input_data = new_obj(dnai_today.today_1_word_score);
				}else{
					input_data = new_obj(dnai_today.today_1_word_score_pair);
				}
				
				if(input_data.length == 0) {
					dnai_today.sunday();
				}
			}else{
				if(pair_type.includes("단일")) {
					input_data = new_obj(dnai_today.today_word_score);
				}else{
					input_data = new_obj(dnai_today.today_word_score_pair);
				}
				if(input_data.length == 0) {
					dnai_today.total_info_();
				}
			}
			dnai_today.build_wordcloud_edit(input_data);
			dnai_today.build_wordtable_edit(input_data);
		},
		build_wordcloud_edit : function(data) {
			let on_off_text_total = "OFF";
			if($("#total_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
				on_off_text_total = "OFF";
			}
			else{
				on_off_text_total = "ON";
			}
			let words = new_obj(data);
			let max = 0;
			let min = Infinity;
			let frequency_list = new Array();
			if(words.length == 0) { return; }
			
			let IDname = "wordcloud";
			
			for(let i = 0; i < words.length; i++) {
				let word = words[i][0];
				let score = words[i][1];
				if(dnai_today.remove_word_list.includes(word)) { continue;}
				if(max < score) { max = score; }
				if(min > score) { min = score; }
			}
			
//			max = words[0][1];
//			min = words[words.length-1][1];
			for(let i = 0; i < words.length; i++){
				let temp_dict = {};
				let word = words[i][0];
				
				if(dnai_today.remove_word_list.includes(word)) {
					continue;
				}
				
		       	let score = (words[i][1]-min)/ (max-min) + 0.3;
		       	temp_dict['text'] = word;
		        temp_dict["frequency"] = score;
		        frequency_list.push(temp_dict);
			}
			let first_sorting_field = "frequency";
		    let second_sorting_field = "text";
		    frequency_list.sort(function(a,b) {
		    	if(a[first_sorting_field] - b[first_sorting_field] === 0){
		    		return a[second_sorting_field] < b[second_sorting_field] ? -1 : a[second_sorting_field] > b[second_sorting_field] ? 1 : 0;
		    	}
		    	
		    	else{
		    		return b[first_sorting_field] - a[first_sorting_field];
		    	}
		    });
		    
		    function showCloud(frequency_list, IDname)
		    {
		    	
		    	$("#"+IDname).children('svg').remove();
		    	var weight,width,height;   // change me
		    	var domain_max, range_max, domain_min, domain_max;
		    	if(on_off_text_total === "ON"){
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
//		            	 	if(d.seq){
//		            	 		var item = new Array();
//		            	 		item.push(d.seq);
//		            	 		item.push(d.text);
//		            	 		history_change(item,IDname)	
//		            	 	}
		            	 	
		              });
		          }
		    }
		    showCloud(frequency_list, IDname);
		    $("#loadingBar_wordcloud_total").hide();
		},
		build_wordtable_edit : function(data) {
			let on_off_text_total = "OFF";
			if($("#total_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
				on_off_text_total = "OFF";
			}
			else{
				on_off_text_total = "ON";
			}
			if(typeof data == "undefined")
				return;
			let data_len = data.length;
			let chk = $("#removeCheck").is(":checked");
			let cnt_limit = 10;
			if(on_off_text_total === "ON"){
				cnt_limit = 15;
			}
			
			let IDname = "total_word_table_ul";
			$("#"+IDname).empty()
			var cnt = 0;
		    for (var i = 0; i < data_len; i++) {
		    	
				let word = data[i][0];
				let score = data[i][1].toFixed(2);
				
				score = score.toLocaleString("ko-kr");
				
				let li = "";
				if(dnai_today.remove_word_list.includes(word)) {
					li = "<li style='cursor: pointer'><input type='checkbox' val='"+word+"'/><span class='num_item'>"+(i+1)+"</span><p class='desc_info'><span>"+word+'</span><a class="rank_srch" title="검색">검색</a></p><p class="desc_count">'+score+"</p></li>"
				}else{
					li = "<li style='cursor: pointer'><input type='checkbox' checked val='"+word+"' checked/><span class='num_item'>"+(i+1)+"</span><p class='desc_info'><span>"+word+'</span><a class="rank_srch" title="검색">검색</a></p><p class="desc_count">'+score+"</p></li>"
				}
				
				$("#"+IDname).append(li);
//				cnt+=1;
//				if(cnt == cnt_limit)
//					break;
		    }
		    $(".rank_srch").off("click").on("click", function() {
				dnai_today.search_keyword(this);
			});
		    $("#"+IDname+" input").off("click").on("click", function() {
		    	let input_chk = $(this).prop("checked");
		    	let word = $(this).attr("val");
		    	if(input_chk == false) {
		    		dnai_today.remove_word_list.push(word);
		    	}else{
		    		let index = dnai_today.remove_word_list.indexOf(word);
		    		if(index > -1){ dnai_today.remove_word_list.splice(index, 1); }
		    	}
		    	dnai_today.build_wordcloud_edit(data);
		    });
		    $("#loadingBar_wordtable_total").hide();
		    $("#total_word_table_ul").show();
		},
		total_info_ : function() {
			$(".total_info").html("<li>데이터가 없습니다.</li>");
			$(".total_info").css("display","block");
			
			$("#pair_type").css("display","none");
			$("#wordcloud").css("display","none");
			$("#word-table").css("display","none");
		},
		sunday : function() {
			$(".total_info").html("<li>오늘은 발행된 신문이 없습니다.</li>");
			$(".total_info").css("display","block");
			
			$("#pair_type").css("display","none");
			$("#wordcloud").css("display","none");
			$("#word-table").css("display","none");
		},
		today_10ago : function() {
			let week = new Array('일', '월', '화', '수', '목', '금', '토')
			let date = new Date();
			date.setMinutes(date.getMinutes() - 20);
			let minus_minute = date.getMinutes() % 10;
			date.setMinutes(date.getMinutes() - minus_minute + 10);
			
			let year = date.getFullYear(); 
			let month = new String(date.getMonth()+1); 
			let day = new String(date.getDate());
			/* let day_name = week[date.getDay()]; */
			var cal_date_num = parseInt(new Date(document.getElementById('cal_date').value).getDay());
			let day_name = week[cal_date_num];
			let Hour = new String(date.getHours());
			let minute = new String(date.getMinutes());
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
			// return year+'-'+month+'-'+day+"("+day_name+")"+" "+Hour+":"+minute;
			return document.getElementById('cal_date').value+"("+day_name+")"+" "+Hour+":"+minute;			
		},
		img_download : function() {
			let IDname = "wordcloud";
			let sub_tab_link = $(".sub_tab-link.current").text() // 주요뉴스 / 신문 1면
			let pair_type = $("#pair_type li.active").text()
			on_off_text = "";
			if($("#total_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
				on_off_text = "OFF";
			}
			else{
				on_off_text = "ON";
			}
			
			var minute10_ago = dnai_today.today_10ago();
			date_period_string = minute10_ago;
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
			html2canvas(wordcloud, {width : img_width, height: img_height, scrollY: -window.scrollY, scale : 1.5, useCORS : true}).then(function (canvas) {
		        var img = canvas.toDataURL('image/png');
		        downloadURI_FORNEW(img, "wordcloud.png", img_width, img_height);
		    });
		},
		excel_download : function() {
			let tab_name = $(".tab-link.current").text();
			let pair_type = $("#pair_type li.active").text();
			if(pair_type == "단어 쌍") { pair_type = "1"; }
			else{ pair_type = "0"; }
			
			let front = "";
			let sub_tab_name = $('.sub_tab-link.current').text();
			if(sub_tab_name.includes("1면")) { front = "2"; }
			else { front = "1"; }
			
			let removeChecked = $("#removeCheck").is(":checked");
			let period = "";
			let start_date = "";
			let end_date = "";
			
			
			let dates = new Date();
			let year = new String(dates.getFullYear()); // 년도
			let month = new String(dates.getMonth() + 1);  // 월
			if(month.length < 2)
				month = "0"+month;
			
			let day = new String(dates.getDate());  // 날짜
			if(day.length < 2)
				day = "0"+day;
			
			let hours = new String(dates.getHours()); // 시
			if(hours.length < 2)
				hours = "0"+hours;
			
			let minutes = new String(dates.getMinutes());  // 분
			if(minutes.length < 2)
				minutes = "0"+minutes;
			
			let seconds = new String(dates.getSeconds());  // 초
			if(seconds.length < 2)
				seconds = "0"+seconds;
			
			// let date = year+month+day+"_"+hours+minutes+seconds;
			let date = document.getElementById('cal_date').value.replace(/-/gi, "")+"_"+hours+minutes+seconds;			
			//file_name_date = year+month+day;
			file_name_date = date;
			
			let filename = user_name+"_"+date;
			
			$.ajax({
				type : "POST",
				url : './utils/wordcloud_excel_save_by_day.jsp',
				data : {
					"tab" : tab_name,
					"pair_type" : pair_type,
					"front" : front,
					"user_seq" : user_seq,
					"period" : period,
					"start_date" : start_date,
					"end_date" : end_date,
					"filename" : filename,
					"removeChecked" : removeChecked,
					"cal_date" : document.getElementById('cal_date').value
				}
			}).done(function(o){
				$('#download_link').attr({
					'download':'wordcloud_'+file_name_date+'.xls',
					'href':'./wordcloud_excel/'+filename+".xls"
					})
				document.getElementById("download_link").click();
			});
		},
};

var dnai_member = {
		period_check : true,
		global_item : [],
		member_word_score : null,
		member_word_score_pair : null,
		member_pos_word_score : null,
		member_neg_word_score : null,
		remove_word_list : [],
		remove_sentiment_word_list : [],
		user_seq : 0,
		init : function() {
			this.user_seq = user_seq[0];
			if(typeof(dnai_member.user_seq) == "undefined"){
				$("#tab_two").hide();
				$("#tab-2").hide();
				return;
			}else{
				this.user_seq = user_seq[0];
			}
			this.ajax_member_total_word_score();
			// 어제 날짜로 세팅
			this.setting_yester_day();
			this.on_button_func();
			
			$(".member_total_info").html('<li>프리미엄 서비스 출시 이후 고객님의 계정에 어제까지 뷰어에 등록된 기사(가판 제외)를 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다.<a>TF-IDF란?</a></li>'+
        			'<li>스크랩마스터 프리미엄 뷰어에 등록된 기사 수가 적은 경우 워드클라우드의 결과가 다소 미흡해 보일 수 있으나, 이는 시스템 오류가 아닌 점 참고 부탁드립니다.</li>'
        			+'<li>워드클라우드에서 단어를 클릭하면 해당 단어가 기사 내 언급된 날짜별 추이로 아래 그래프에 반영됩니다. 그래프의 특정 위치를 클릭하면 해당 일자와 점수를 확인할 수 있습니다.</li>');
			$(".member_total_info a").off("click").on("click", function() {
				url = "./utils/TFIDF_description.html";
				name = "tfidf description";
				specs = "width = 600, height=700, top=200, left=100, toolbar=no, menubar=no,scrollbar=no, resizeble=yes";

				window.open(url, "_blank", specs);
				return false;
			});
			
			if(edit_valid == false) {
				$("#editing_action_member").hide();
				$("#editing_action_sentiment").hide();
			}
		},
		setting_yester_day : function() {
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
			
			
			let yester_day = common_func.setting_yesterday();
			document.getElementById('start_datepicker').value = yester_day;
			document.getElementById('end_datepicker').value = yester_day;
		},
		ajax_member_total_word_score : function() {
			$.ajax({
				type : 'POST',
		        url : './utils/total_word_score/member_total_word_score.jsp',
		        data : {
		        	user_seq : dnai_member.user_seq,
		        },
		        dataType : 'json',
		        async: true,
		        success : function(data) {
		        	data = new_obj(data);
		        	dnai_member.member_word_score = data['total_member_word_score'];
		        	dnai_member.member_word_score_pair = data['total_member_word_score_pair'];
		        	if(dnai_member.member_word_score.length == 0 && dnai_member.member_word_score_pair.length == 0) {
		        		dnai_member.member_total_info_();
		        	}else{
		        		$(".sub_tab_member-content").css("display","block");
	                	$("#pair_type_member").css("display","block");
	                	
		        		$("#blobButton_member").css("display","block");
		        		$("#blobButton_member_excel").css("display","inline-block");
		        		$("#removeSpace").css("display","block");
		        		
		        		$("#member_score_display").css("display","block");
		            	$("#member_wordcloud").css("display","block");
		            	$("#member_word-table").css("display","block");
		            	$(".history").css("display","block");
		        		
		        		$(".member_total_info").html('<li>프리미엄 서비스 출시 이후 고객님의 계정에 어제까지 뷰어에 등록된 기사(가판 제외)를 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다.<a>TF-IDF란?</a></li>'+
			        			'<li>스크랩마스터 프리미엄 뷰어에 등록된 기사 수가 적은 경우 워드클라우드의 결과가 다소 미흡해 보일 수 있으나, 이는 시스템 오류가 아닌 점 참고 부탁드립니다.</li>'
			        			+'<li>워드클라우드에서 단어를 클릭하면 해당 단어가 기사 내 언급된 날짜별 추이로 아래 그래프에 반영됩니다. 그래프의 특정 위치를 클릭하면 해당 일자와 점수를 확인할 수 있습니다.</li>');
						$(".member_total_info a").off("click").on("click", function() {
							url = "./utils/TFIDF_description.html";
							name = "tfidf description";
							specs = "width = 600, height=700, top=200, left=100, toolbar=no, menubar=no,scrollbar=no, resizeble=yes";

							window.open(url, "_blank", specs);
							return false;
						});
		        	}
		        },
		        beforeSend : function() {
		        	$("#loadingBar_wordcloud").show();
		        	$("#member_wordcloud svg").hide();
		        	
		        	$("#loadingBar_wordtable").show();
		        	$("#member_word-table_ul").hide(); //
		        },
		        error : function(e) {
		        	alert(e.responseText);
		        }
			}).done(function(){
	        	dnai_member.draw_function();
			});
		},
		ajax_member_word_score_period : function() {
			
			let period = $("ul.sub_tabs_member li.current").text();
			if(period == "주간") { period = 7; }
			else if(period == "월간") { period = 30; }
			else if(period == "분기") { period = 90; }
			else { return; }
			
			let chk = $("#removeCheck").is(":checked");
			
			$.ajax({
				type : 'POST',
		        url : './utils/total_word_score/member_period_word_score.jsp',
		        data : {
		        	user_seq : dnai_member.user_seq,
		        	period : period,
		        	removeChecked : chk,
		        },
		        dataType : 'json',
		        async: true,
		        success : function(data) {
		        	data = new_obj(data);
		        	dnai_member.member_word_score = data['period_member_word_score'];
		        	dnai_member.member_word_score_pair = data['period_member_word_score_pair'];
		        	
		        	if(dnai_member.member_word_score.length == 0 && dnai_member.member_word_score_pair.length == 0) {
		        		dnai_member.member_total_info_();
		        	}else{
		        		$(".sub_tab_member-content").css("display","block");
	                	$("#pair_type_member").css("display","block");
	                	
		        		$("#blobButton_member").css("display","block");
		        		$("#blobButton_member_excel").css("display","inline-block");
		        		$("#removeSpace").css("display","block");
		        		
		        		$("#member_score_display").css("display","block");
		            	$("#member_wordcloud").css("display","block");
		            	$("#member_word-table").css("display","block");
		            	$(".history").css("display","block");
		        		
		        		$(".member_total_info").html('<li>프리미엄 서비스 출시 이후 고객님의 계정에 어제까지 뷰어에 등록된 기사(가판 제외)를 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다.<a>TF-IDF란?</a></li>'+
			        			'<li>스크랩마스터 프리미엄 뷰어에 등록된 기사 수가 적은 경우 워드클라우드의 결과가 다소 미흡해 보일 수 있으나, 이는 시스템 오류가 아닌 점 참고 부탁드립니다.</li>'
			        			+'<li>워드클라우드에서 단어를 클릭하면 해당 단어가 기사 내 언급된 날짜별 추이로 아래 그래프에 반영됩니다. 그래프의 특정 위치를 클릭하면 해당 일자와 점수를 확인할 수 있습니다.</li>');
						$(".member_total_info a").off("click").on("click", function() {
							url = "./utils/TFIDF_description.html";
							name = "tfidf description";
							specs = "width = 600, height=700, top=200, left=100, toolbar=no, menubar=no,scrollbar=no, resizeble=yes";

							window.open(url, "_blank", specs);
							return false;
						});
		        	}
		        },
		        beforeSend : function() {
		        	$(".member_total_info").html("<li>해당 기간동안 스크랩된 기사 데이터를 불러오는 중입니다.</li>");
		        	
		        	$("#loadingBar_wordcloud").show();
		        	$("#member_wordcloud svg").hide();
		        	
		        	$("#loadingBar_wordtable").show();
		        	$("#member_word-table_ul").hide();
		        	
		        	$(".history").css("display","block");
		        	$("#loadingBar").show();
		        	$(".linechart").hide();
		        	var tag = '프리미엄 등록 기사 '+""+' 주요 키워드 추이 : <span id="text_total"></span> <span class="line_info_button" style="visibility: visible;cursor: pointer;">ⓘ</span><span class = "member_history_info" style = "float: right; color: #999; font-size: 13px; font-weight: 300;"> 점수는 TF-IDF 알고리즘으로 분석한 결과입니다.</span>'
		     		$('.history_info_text_total').html(tag);
		        	
		        	$("#search_keyword_member_button").hide();
		        },
		        error : function(e) {
		        	alert(e.responseText);
		        }
			}).done(function(){
	        	dnai_member.draw_function();
			});
		},
		ajax_member_word_score_user_setting : function() {
			
			let start_date = $("#start_datepicker").val();
			let end_date = $("#end_datepicker").val();
			let chk = $("#removeCheck").is(":checked");
			let pair_type = $("#pair_type_member li.active").text();
			if(pair_type.includes("쌍")) { pair_type = "1"; }
			else{ pair_type = "0"; }
			
			let url = "";
			let today = common_func.setting_today();
			if(start_date == today && end_date == today) {
				url = './utils/total_word_score/word_score_by_today_setting.jsp';
			}else{
				url = './utils/total_word_score/member_user_setting_date_word_score.jsp';
			}
			$.ajax({
				type : 'POST',
		        url : url,
		        data : {
		        	user_seq : dnai_member.user_seq,
		        	start_date : start_date,
		        	end_date : end_date,
		        	pair_type : pair_type,
		        	removeChecked : chk,
		        },
		        dataType : 'json',
		        async: true,
		        success : function(data) {
		        	data = new_obj(data);
		        	
		        	if(data['period_member_word_score'].length == 0 && data['period_member_word_score_pair'] == 0){
	        			dnai_member.period_info_();
	        		}else{
	        			$(".member_total_info").html('<li>프리미엄 서비스 출시 이후 고객님의 계정에 어제까지 뷰어에 등록된 기사(가판 제외)를 <strong>TF-IDF 알고리즘</strong>을 활용하여 분석했습니다.<a>TF-IDF란?</a></li>'+
	                			'<li>스크랩마스터 프리미엄 뷰어에 등록된 기사 수가 적은 경우 워드클라우드의 결과가 다소 미흡해 보일 수 있으나, 이는 시스템 오류가 아닌 점 참고 부탁드립니다.</li>'
	                			+'<li>워드클라우드에서 단어를 클릭하면 해당 단어가 기사 내 언급된 날짜별 추이로 아래 그래프에 반영됩니다. 그래프의 특정 위치를 클릭하면 해당 일자와 점수를 확인할 수 있습니다.</li>');
	        			$(".member_total_info a").off("click").on("click", function() {
	        				url = "./utils/TFIDF_description.html";
	        				name = "tfidf description";
	        				specs = "width = 600, height=700, top=200, left=100, toolbar=no, menubar=no,scrollbar=no, resizeble=yes";

	        				window.open(url, "_blank", specs);
	        				return false;
	        			});
	        			
	        			$(".sub_tab_member-content").css("display","block");
	                	$("#pair_type_member").css("display","block");
	                	//버튼 보이게
	                	$("#blobButton_member").css("display","block");
	            		$("#blobButton_member_excel").css("display","inline-block");
	            		$("#removeSpace").css("display","inline-block");
	                	
	                	$("#member_score_display").css("display","block");
	                	$("#member_wordcloud").css("display","block");
	                	$("#member_word-table").css("display","block");
	                	
	                	$("#member_wordcloud svg").show();
	                	$("#member_word-table_ul").show();
	                	$("#search_keyword_member_button").show();
	        		}
		        	dnai_member.member_word_score = data['period_member_word_score'];
		        	dnai_member.member_word_score_pair = data['period_member_word_score_pair'];
		        },
		        beforeSend : function() {
		        	$(".member_total_info").html("<li>해당 기간동안 스크랩된 기사 데이터를 불러오는 중입니다.</li>");
		        	
		        	$("#loadingBar_wordcloud").show();
		        	$("#member_wordcloud svg").hide();
		        	
		        	$("#loadingBar_wordtable").show();
		        	$("#member_word-table_ul").hide();
		        	
		        	$(".history").css("display","block");
		        	$("#loadingBar").show();
		        	$(".linechart").hide();
		        	var tag = '프리미엄 등록 기사 '+""+' 주요 키워드 추이 : <span id="text_total"></span> <span class="line_info_button" style="visibility: visible;cursor: pointer;">ⓘ</span><span class = "member_history_info" style = "float: right; color: #999; font-size: 13px; font-weight: 300;"> 점수는 TF-IDF 알고리즘으로 분석한 결과입니다.</span>'
		     		$('.history_info_text_total').html(tag);
		        	
		        	$("#search_keyword_member_button").hide();
		        },
		        error : function(e) {
		        	alert(e.responseText);
		        }
			}).done(function(){
	        	dnai_member.draw_function();
			});
		},
		ajax_word_score_history_return : function() {
			let word_seq = dnai_member.global_item[0];
			
			if(word_seq == null || word_seq == "null" || word_seq == "no_word_seq") {
				let date = common_func.setting_today();
        		let word = dnai_member.global_item[1];
        		let score = 0;
        		for(let word_info of dnai_member.member_word_score){
        			if(word_info[1] == word) {
        				score = word_info[2];
        				break;
        			}
        		}
        		for(let word_info of dnai_member.member_word_score_pair) {
        			if(word_info[1] == word){
        				score = word_info[2];
        				break;
        			}
        		}
        		data = [[date, score]];
        		$(".history").css("display","block");
        		dnai_member.score_history_line_chart(data);
        		return;
			}
			
			//단어 추이선
			$.ajax({
		        type : 'POST',
		        url : './utils/word_score_history.jsp',
		        data : {
		        	word_seq : word_seq,
		        	user_seq : dnai_member.user_seq,
		        	},
		        dataType : 'json',
		        async: true,
		        success : function(data) {
		        	dnai_member.score_history_line_chart(data);
		        },
		        beforeSend:function(){
		            //(이미지 보여주기 처리)
		            $("#loadingBar").show();
		            var tag = '프리미엄 등록 기사 '+""+' 주요 키워드 추이 : <span id="text_total"></span> <span class = "member_history_info" style = "float: right; color: #999; font-size: 13px; font-weight: 300;"> <span class="line_info_button tfidf" style="visibility: visible;cursor: pointer;">ⓘ</span> 점수는 TF-IDF 알고리즘으로 분석한 결과입니다.</span>'
		    		$('.history_info_text_total').html(tag);
		            $(".linechart").hide();
		        },
		        complete:function(){
		        },
		        error : function(e) {
		        }
		    }).done(function() {
		    	$(".history").css("display","block");
		    });
		},
		ajax_member_sentiment_word_period_setting : function() {
			if(sentiment_xhr && sentiment_xhr.readystate != 4){
				sentiment_xhr.abort();
		    }
			let start_date = $("#start_datepicker").val();
			let end_date = $("#end_datepicker").val();
			sentiment_xhr = $.ajax({ 
		        type : 'POST',
		        url : './utils/member_sentiment_word_cloud.jsp',
		        data : {user_seq : dnai_member.user_seq,
		        		start_date : start_date,
		        		end_date : end_date,
		        		}, //default = 7
		        dataType : 'json',
		        async: true,
		        success : function(data) {
		        	sentiment_word_score = new_obj(data);
		        	dnai_member.member_pos_word_score = sentiment_word_score['positive'];
		        	dnai_member.member_neg_word_score = sentiment_word_score['negative'];
		        	
		        	let sen_data = dnai_member.member_pos_word_score;
		        	let select_sentiment = $("#pair_type_member_sentiment li.active").text();
		        	if(select_sentiment.includes("부정")) {
		        		sen_data = dnai_member.member_neg_word_score;
		        	}else{
		        		sen_data = dnai_member.member_pos_word_score;
		        	}
		        	
		        	dnai_member.build_wordcloud_sentiment(sen_data);
		        	dnai_member.build_wordtable_sentiment(sen_data);
		        },
		        beforeSend:function(xhr, opts) {
		        	$("#member_wordcloud_sentiment").show();
		        	$("#sentiment_loadingBar_wordcloud").show();
		        	$("#member_wordcloud_sentiment svg").hide();
		        	
		        	$("#sentiment_member_word-table").show();
		        	$("#sentiment_loadingBar_wordtable").show();
		        	$("#sentiment_member_word-table_ul").hide();
		        },
		        complete:function() {
		        	$("#sentiment_loadingBar_wordcloud").hide();
		        	$("#sentiment_loadingBar_wordtable").hide();
		        	
		        	$("#member_wordcloud_sentiment svg").show();
		        	$("#sentiment_member_word-table_ul").show();
		        },
		        error : function(e) {
		        	console.log(e);
		        }
		    });
		},
		draw_function : function() {
			let data = null;
			let pair_type = $("#pair_type_member li.active").text();
			if(pair_type == "단어 쌍") { data = dnai_member.member_word_score_pair; }
			else { data = dnai_member.member_word_score; }
			
			dnai_member.build_wordcloud(data);
			dnai_member.build_wordtable(data);
		},
		draw_function_sentiment : function() {
			let data = null;
			let type = $("#pair_type_member_sentiment li.active").text();
			if(type.includes("긍정")) { data = dnai_member.member_pos_word_score; }
			else{ data = dnai_member.member_neg_word_score; }
			
			dnai_member.build_wordcloud_sentiment(data);
			dnai_member.build_wordtable_sentiment(data);
		},
		build_wordcloud : function(data) {
			let IDname = "member_wordcloud";
			let words = new_obj(data);
			if(data.length == 0) { return; }
			
			let on_off_text_total = "OFF";
			if($("#member_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
				on_off_text_total = "OFF";
			}
			else{
				on_off_text_total = "ON";
			}
			
			// 누적 단어 제거
			let chk = $("#removeCheck").is(":checked");
			
			let max = 0; //words[0][2];
			let min = Infinity; //words[words.length-1][2];
			
			for(let i = 0; i < words.length; i++){
				let word = words[i][1];
				let score = Number(words[i][2]);
				
				if(dnai_member.remove_word_list.includes(word)) { continue; }
				if(max < score ) { max = score; }
				if(min > score ) { min = score; }
			}
			if(max == min) { max = min+1; }
			
			let pair_type = words[0][3];
			let frequency_list = new Array();
			if(words.length == 0) { return; }
			
			for(let i = 0; i < words.length; i++){
				let temp_dict = {};
				let word = words[i][1];
		       	let score = (words[i][2]-min)/ (max-min) + 0.3;
		       	
		       	if(dnai_member.remove_word_list.includes(word)) { continue; }
		       	
		       	if(words[i][5] != null) {
		       		if(chk == false && words[i][5] == "누적단어"){
		       			continue;
		       		}
		       	}
		       	
		       	let seq = words[i][0];
		        pair_type = words[i][3];
		        temp_dict['text'] = word;
		        temp_dict["frequency"] = score;
		        temp_dict["seq"] = seq;
		        frequency_list.push(temp_dict);
			}
			let first_sorting_field = "frequency";
		    let second_sorting_field = "text";
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
		    	if(on_off_text_total === "ON"){
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
	            	 		var item = new Array();
	            	 		item.push(d.seq);
	            	 		item.push(d.text);
	            	 		dnai_member.history_change(item);	
		              });
		          }
		    }
		    showCloud(frequency_list, IDname);
		    
		    let item_1 = new Array();
		    item_1.push(frequency_list[0].seq);
		    item_1.push(frequency_list[0].text);
		    dnai_member.history_change(item_1);
		    
		    $("#loadingBar_wordcloud").hide();
		    $("#member_wordcloud svg").show();
		},
		build_wordtable : function(data) {
			if(typeof data == "undefined") {return;}
			let data_len = data.length;
			let chk = $("#removeCheck").is(":checked");
			
			let on_off_text_total = "OFF";
			if($("#member_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
				on_off_text_total = "OFF";
			}
			else{
				on_off_text_total = "ON";
			}
			let cnt_limit = 10;
			if(on_off_text_total === "ON"){
				cnt_limit = 15;
			}
			IDname = "member_word-table_ul";
			$("#"+IDname).empty();
			let cnt = 0;
			let display_order = 1;
		    for (let i = 0; i < data_len; i++) {
		    	let seq = data[i][0];
				let word = data[i][1];
				let score = data[i][2];
				//score = score.toFixed(2);
				score = score.toLocaleString("ko-kr");
				
				if(dnai_member.remove_word_list.includes(word)) { continue; }
				
				if(data[i].length > 5){
					let member_total_TF = data[i][5];
					if(!chk && member_total_TF == "누적단어")
						continue;
					else{
						if(member_total_TF == "누적단어아님"){
							$("#"+IDname).append('<li style="cursor: pointer"><span class="num_item">'+(display_order)
									+'</span><p class="desc_info" id = '+seq+'><span id = '+seq+'>'+word
									+'</span></p><p class="desc_count">'+score+"</p></li>");
						}else{
							$("#"+IDname).append('<li class = "tag" style="cursor: pointer"><span class="num_item">'+(display_order)
									+'</span><p class="desc_info" id = '+seq+'><span id = '+seq+'>'+word
									+'</span></p><p class="desc_count">'+score+"</p></li>");
						}
						display_order+=1;
					}
					
					 
				}
				else{ //누적 탭 순위 테이블 표시할때
					let li = '<li style="cursor: pointer">'
							+'<span class="num_item">'+(display_order)+'</span>'
							+'<p class="desc_info" id = '+seq+'><span id = '+seq+'>'+word+'</span></p>'
							+'<p class="desc_count">'+score+"</p></li>";
					$("#"+IDname).append(li);
					display_order+=1;
				}
				cnt+=1;
				if(cnt == cnt_limit)
					break;
				
		    }
		    $("#loadingBar_wordtable").hide();
		    $("#member_word-table_ul").show();
		    
		    
		    $("#member_word-table_ul .desc_info").off("click").on("click", function() {
		    	let seq = $(this).attr("id");
		    	let text = $(this).text();
		    	let item = new Array();
		    	item.push(seq);
		    	item.push(text);
		    	dnai_member.history_change(item);
		    });
		    
		},
		build_wordcloud_sentiment : function(data){
			
			let score_data = new_obj(data);
			if(score_data.length == 0) { return; }
			let type = $("#pair_type_member_sentiment li.active").text();
			if(type.includes("긍정")) { type = 1; }
			else{ type = -1; }
			
			let words = score_data;
			let max = 0; //words[0]['score'];
			let min = Infinity; //words[words.length-1]['score'];
			
			for(let i = 0; i < words.length; i++) {
				let word = words[i]['word'];
				let score = Number(words[i]['score']);
				
				if(dnai_member.remove_sentiment_word_list.includes(word)) { continue; }
				
				if(max < score) { max = score; }
				if(min > score) { min = score; }
			}
			if(max == min) { max = min + 1;}
			
			let on_off_text_total = "OFF";
			if($("#sentiment_member_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
				on_off_text_total = "OFF";
			}
			else{
				on_off_text_total = "ON";
			}
			
			let frequency_list = new Array();
			if(words.length == 0) { return; }
			let IDname = "member_wordcloud_sentiment";
			

			for(let i = 0; i < words.length; i++){
				let temp_dict = {};
				let word = words[i]['word'];
		       	let score = (words[i]['score']-min)/ (max-min) + 0.3;

		       	if(dnai_member.remove_sentiment_word_list.includes(word)) { continue; }
		       	
		        temp_dict['text'] = word;
		        temp_dict["frequency"] = score;
		        frequency_list.push(temp_dict);
			}
		    
		    let first_sorting_field = "frequency";
		    let second_sorting_field = "text";
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
		    	let weight,width,height;   // change me
		    	let domain_max, range_max, domain_min;
		    	if(on_off_text_total === "ON"){
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
		    	
		    	//let fill = d3.scale.category20();
		    	let fill;
		    	if(type == 1){ //긍정
		    		fill = d3.scale.linear().domain([0, 75]).range(['#003799','#4DE6FF']);
		    	}else{ //부정
		    		fill = d3.scale.linear().domain([0, 75]).range(['#CC2200','#f7ba00']);
		    	}
		    	
		    	//let fill = d3.scale.linear().domain([10,75]).range(['#E783C9', '#F3C0F1'])
		    	let wordScale = d3.scale.linear().range([range_min, range_max]).domain([domain_min, domain_max]).clamp(true); //
				
		    	function score_function(d){
		    		let text_length = d.text.length;
		    		let text_size = wordScale(d.frequency*weight);
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
				
		          function draw(words) {
		            let svg = d3.select("#"+IDname).append("svg")
		                .attr("width", width)
		                .attr("height", height)
		                
		                
		            let zoom_group = svg.append("g")
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
		},
		build_wordtable_sentiment : function(data) {
			if(typeof data == "undefined") {return;}
			let score_data = new_obj(data);
			if(score_data.length == 0) { return; }
			let type = $("#pair_type_member_sentiment li.active").text();
			if(type.includes("긍정")) { type = 1; }
			else{ type = -1; }
			
			let data_len = data.length;
			let cnt_limit = 10;
			let on_off_text_total = "OFF";
			if($("#sentiment_member_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
				on_off_text_total = "OFF";
			}
			else{
				on_off_text_total = "ON";
			}
			if(on_off_text_total === "ON"){
				cnt_limit = 15;
			}
			
			let IDname = "sentiment_member_word-table_ul";
			$("#"+IDname).empty();
			
			let cnt = 0;
			let display_order = 1;
			for (let i = 0; i < data_len; i++) {
		    	
				let word = data[i]['word'];
				let score = data[i]['score'];
				score = score.toFixed(2);
				score = score.toLocaleString("ko-kr");
				
				if(dnai_member.remove_sentiment_word_list.includes(word)) { continue; }
				
				if(data[i].length > 5){
					let member_total_TF = data[i][5];
					if(!chk && member_total_TF == "누적단어")
						continue;
					else{
						if(member_total_TF == "누적단어아님"){
							$("#"+IDname).append('<li style="cursor: pointer"><span class="num_item">'+(display_order)
									+'</span><p class="desc_info" id = '+seq+'><span id = '+seq+'>'+word
									+'</span></p><p class="desc_count">'+score+"</p></li>");
						}else{
							$("#"+IDname).append('<li class = "tag" style="cursor: pointer"><span class="num_item">'+(display_order)
									+'</span><p class="desc_info" id = '+seq+'><span id = '+seq+'>'+word
									+'</span></p><p class="desc_count">'+score+"</p></li>");
						}
						display_order += 1;
					}
				}
				else{ //누적 탭 순위 테이블 표시할때
					$("#"+IDname).append('<li style="pointer-events:none;"><span class="num_item">'+(display_order)+'</span><p class="desc_info"><span id="desc_info_sentiment">'+word+'</span></p><p class="desc_count">'+score+"</p></li>");
					display_order += 1;
				}
				cnt+=1;
				if(cnt == cnt_limit)
					break;
		    }
			$("#"+IDname).show();
		},
		history_change : function(item) {
			let period_text = $(".sub_tab_member-link.current").text();
			if(typeof item == "undefined") { return; }
			dnai_member.global_item = item;
			dnai_member.ajax_word_score_history_return();
		},
		score_history_line_chart : function(data) {
			let period_text = $(".sub_tab_member-link.current").text();
			let word_seq = dnai_member.global_item[0];
			let text = dnai_member.global_item[1];
			
			if(word_seq == null || word_seq == "no_word_seq" || word_seq == 'null') {
				period_text = "오늘";
			}
			
			let start_i = 0;
			let IDname = "member_wordcloud";
			
			let score_his = data;
			let score_hist_len = score_his.length;
			let check_date_list = [];
			
			if(period_text === "기간설정"){
				start_date = $("#start_datepicker").val();
				end_date = $("#end_datepicker").val();
				period_text = "";
				start_date = new Date(start_date);
				end_date = new Date(end_date);
				//1. 해당 기간 리스트 만들기
				check_date_list = common_func.getDates(start_date, end_date);
				//2. 해당 기간에 속한 애들만 가시화 결과 리스트에 추가
				
			}else{ //기간 설정 탭이 아니고
				if(!dnai_member.period_check){ // 기간내 결과값만 보기
					if(period_text == "주간") start_i = score_his.length - 7;
					else if(period_text == "월간") start_i = score_his.length - 30;
					else if(period_text == "분기") start_i = score_his.length - 90;
					else start_i = 0;
				}	
			}
			var timeFormat = 'YYYY-MM-DD';
			var score_list = []
			var date_list = []
			var point_Radius = []
			var point_HitRadius = []
			for(var i = start_i; i < score_hist_len; i++){
				var date = score_his[i][0];
				var score = score_his[i][1];
				if(period_text == "" && dnai_member.period_check == false){ // 전체기간보기가 체크가 안되어 있어 periodCheck가 false일때
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
				if(period_text == "월간" && dnai_member.period_check == false){ 
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
									gridLines: {
										display : false,
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
				
				var name = "";
				
				name = "lineChart_total";
				
				if(window.chart_total){
					window.chart_total.destroy();
				}
				var add_periodCheck_button = "";
				if(period_text !== "누적"){
					if(dnai_member.period_check){ //$("#periodCheck").is(":checked")
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
				+'<span class="line_info_button" style="visibility: visible;cursor: pointer;">ⓘ </span>'
				+add_periodCheck_button
				+'<span class = "member_history_info" style = "float: right; color: #999; font-size: 13px; font-weight: 300;"><span class="line_info_button tfidf" style="visibility: visible;cursor: pointer;">ⓘ</span> 점수는 TF-IDF 알고리즘으로 분석한 결과입니다.</span>'
				
				start_date = $("#start_datepicker").val();
				end_date = $("#end_datepicker").val();
				var today_string = common_func.setting_today();
				if(period_text == "오늘" && start_date === today_string && end_date === today_string){
					tag = '프리미엄 등록 기사 '+period_text+' 주요 키워드 추이 : <span id="text_total">'+text+'</span>'
					+'<span class="line_info_button" style="visibility: visible;cursor: pointer;">ⓘ </span>'
					+'<span class = "member_history_info" style = "float: right; color: #999; font-size: 13px; font-weight: 300;"><span class="line_info_button tfidf" style="visibility: visible;cursor: pointer;">ⓘ</span> 점수는 TF-IDF 알고리즘으로 분석한 결과입니다.</span>'
				}
				
				$('.history_info_text_total').html(tag);
				var ctx = document.getElementById(name);
				ctx.getContext("2d").clearRect(0, 0, 1200, 300);
				window.chart_total = new Chart(ctx,config);	
				$("#loadingBar").hide();
				$(".linechart").show();
				
				$("#periodCheck").off("click").on("click", function() {
					let chk = $("#periodCheck").is(":checked");
					dnai_member.period_check = chk;
					let IDname = "member_wordcloud";
					dnai_member.history_change(dnai_member.global_item);
				});
				$(".line_info_button").off("click").on("click", function() {
					common_func.show_history_infoText();
				});
				$(".tfidf").off("click").on("click", function() {
					common_func.show_tfidf_infotext();
				});
		},
		
		
		draw_function_edit : function() {
			let data = null;
			let pair_type = $("#pair_type_member li.active").text();
			if(pair_type == "단어 쌍") { data = dnai_member.member_word_score_pair; }
			else { data = dnai_member.member_word_score; }
			
			dnai_member.build_wordcloud_edit(data);
			dnai_member.build_wordtable_edit(data);
		},
		build_wordcloud_edit : function(data) {
			let IDname = "member_wordcloud";
			let words = new_obj(data);
			if(data.length == 0) { return; }
			
			let on_off_text_total = "OFF";
			if($("#member_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
				on_off_text_total = "OFF";
			}
			else{
				on_off_text_total = "ON";
			}
			
			// 누적 단어 제거
			let chk = $("#removeCheck").is(":checked");
			
			let max = 0;
			let min = Infinity;
			
			for(let i = 0; i < words.length; i++){
				let word = words[i][1];
				let score = Number(words[i][2]);
				
				if(dnai_member.remove_word_list.includes(word)) { continue; }
				
				if(max < score) { max = score; }
				if(min > score) { min = score; }
			}
			if(max == min) { max = min+1; }
			
			let pair_type = words[0][3];
			let frequency_list = new Array();
			if(words.length == 0) { return; }
			
			for(let i = 0; i < words.length; i++){
				let temp_dict = {};
				let word = words[i][1];
		       	let score = (words[i][2]-min)/ (max-min) + 0.3;
		       	
		       	if(dnai_member.remove_word_list.includes(word)) { continue; }
		       	
		       	if(words[i][5] != null) {
		       		if(chk == false && words[i][5] == "누적단어"){
		       			continue;
		       		}
		       	}
		       	
		       	let seq = words[i][0];
		        pair_type = words[i][3];
		        temp_dict['text'] = word;
		        temp_dict["frequency"] = score;
		        temp_dict["seq"] = seq;
		        frequency_list.push(temp_dict);
			}
			let first_sorting_field = "frequency";
		    let second_sorting_field = "text";
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
		    	if(on_off_text_total === "ON"){
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
	            	 		var item = new Array();
	            	 		item.push(d.seq);
	            	 		item.push(d.text);
	            	 		dnai_member.history_change(item);	
		              });
		          }
		    }
		    showCloud(frequency_list, IDname);
		    
		    let item_1 = new Array();
		    item_1.push(frequency_list[0].seq);
		    item_1.push(frequency_list[0].text);
		    dnai_member.history_change(item_1);
		    
		    $("#loadingBar_wordcloud").hide();
		    $("#member_wordcloud svg").show();
		},
		build_wordtable_edit : function(data) {
			if(typeof(data) == "undefined") {return;}
			let data_len = data.length;
			let chk = $("#removeCheck").is(":checked");
			
			let on_off_text_total = "OFF";
			if($("#member_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
				on_off_text_total = "OFF";
			}
			else{
				on_off_text_total = "ON";
			}
			let cnt_limit = 10;
			if(on_off_text_total === "ON"){
				cnt_limit = 15;
			}
			IDname = "member_word-table_ul";
			$("#"+IDname).empty();
			let cnt = 0;
			let display_order = 1;
		    for (let i = 0; i < data_len; i++) {
		    	let seq = data[i][0];
				let word = data[i][1];
				let score = data[i][2];
				//score = score.toFixed(2);
				score = score.toLocaleString("ko-kr");
				
				if(data[i].length > 5){
					let member_total_TF = data[i][5];
					if(!chk && member_total_TF == "누적단어")
						continue;
					else{
						let li = "";
						if(member_total_TF == "누적단어아님"){
							if(dnai_member.remove_word_list.includes(word)) {
								li = '<li style="cursor: pointer">'
								+'<input type="checkbox" val="'+word+'"/>'
								+'<span class="num_item">'+(display_order)
								+'</span><p class="desc_info" id = '+seq+'>'
								+'<span id = '+seq+'>'+word
								+'</span></p><p class="desc_count">'+score+"</p></li>";
							}else{
								li = '<li style="cursor: pointer">'
								+'<input type="checkbox" val="'+word+'" checked/>'
								+'<span class="num_item">'+(display_order)
								+'</span><p class="desc_info" id = '+seq+'>'
								+'<span id = '+seq+'>'+word
								+'</span></p><p class="desc_count">'+score+"</p></li>";
							}
						}else{
							if(dnai_member.remove_word_list.includes(word)) {
								li = '<li style="cursor: pointer">'
								+'<input type="checkbox" val="'+word+'"/>'
								+'<span class="num_item">'+(display_order)
								+'</span><p class="desc_info" id = '+seq+'>'
								+'<span id = '+seq+'>'+word
								+'</span></p><p class="desc_count">'+score+"</p></li>";
							}else{
								li = '<li style="cursor: pointer">'
								+'<input type="checkbox" val="'+word+'" checked/>'
								+'<span class="num_item">'+(display_order)
								+'</span><p class="desc_info" id = '+seq+'>'
								+'<span id = '+seq+'>'+word
								+'</span></p><p class="desc_count">'+score+"</p></li>";
							}
						}
						
						$("#"+IDname).append(li);
						display_order+=1;
					}
					
					 
				}
				else{ //누적 탭 순위 테이블 표시할때
					
					let li = "";
					if(dnai_member.remove_word_list.includes(word)) {
						li = '<li style="cursor: pointer">'
						+'<input type="checkbox" val='+word+'/>'
						+'<span class="num_item">'+(i+1)
						+'</span><p class="desc_info" id = '+seq+'>'
						+'<span id = '+seq+'>'+word+'</span></p><p class="desc_count">'+score+"</p></li>";
					}else{
						li = '<li style="cursor: pointer">'
							+'<input type="checkbox" val='+word+' checked/>'
							+'<span class="num_item">'+(i+1)
							+'</span><p class="desc_info" id = '+seq+'>'
							+'<span id = '+seq+'>'+word+'</span></p><p class="desc_count">'+score+"</p></li>";
					}
					
					$("#"+IDname).append(li);
				}
//				cnt+=1;
//				if(cnt == cnt_limit)
//					break;
				
		    }
		    $("#loadingBar_wordtable").hide();
		    $("#member_word-table_ul").show();
		    
		    $("#member_word-table_ul .desc_info").off("click");
		    $("#member_word-table_ul input").off("click").on("click", function() {
		    	let remove_chk = $(this).prop("checked");
		    	let word = $(this).attr("val");
		    	if(remove_chk == true) {
		    		let index = dnai_member.remove_word_list.indexOf(word);
		    		if(index > -1) { dnai_member.remove_word_list.splice(index, 1); }
		    	}else{
		    		dnai_member.remove_word_list.push(word);
		    	}
		    	dnai_member.build_wordcloud_edit(data);
		    });
		},
		
		draw_function_sentiment_edit : function() {
			let data = null;
			let type = $("#pair_type_member_sentiment li.active").text();
			if(type.includes("긍정")) { data = dnai_member.member_pos_word_score; }
			else{ data = dnai_member.member_neg_word_score; }
			
			dnai_member.build_wordcloud_sentiment_edit(data);
			dnai_member.build_wordtable_sentiment_edit(data);
		},
		build_wordcloud_sentiment_edit : function(data) {
			let score_data = new_obj(data);
			if(score_data.length == 0) { return; }
			let type = $("#pair_type_member_sentiment li.active").text();
			if(type.includes("긍정")) { type = 1; }
			else{ type = -1; }
			
			let words = score_data;
			let max = 0;//words[0]['score'];
			let min = Infinity; //words[words.length-1]['score'];
			
			for(let i = 0; i < words.length; i++){
				let word = words[i]['word'];
				let score = Number(words[i]['score']);
				
				if(dnai_member.remove_sentiment_word_list.includes(word)) { continue; }
				
				if(max < score) { max = score; }
				if(min > score) { min = score; }
			}
			if(max == min) {max = min+1;}
			
			let on_off_text_total = "OFF";
			if($("#sentiment_member_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
				on_off_text_total = "OFF";
			}
			else{
				on_off_text_total = "ON";
			}
			
			let frequency_list = new Array();
			if(words.length == 0) { return; }
			let IDname = "member_wordcloud_sentiment";
			

			for(let i = 0; i < words.length; i++){
				let temp_dict = {};
				let word = words[i]['word'];
		       	let score = (words[i]['score']-min)/ (max-min) + 0.3;
		       	
		       	if(dnai_member.remove_sentiment_word_list.includes(word)) { continue; }
		       	
		        temp_dict['text'] = word;
		        temp_dict["frequency"] = score;
		        frequency_list.push(temp_dict);
			}
		    
		    let first_sorting_field = "frequency";
		    let second_sorting_field = "text";
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
		    	let weight,width,height;   // change me
		    	let domain_max, range_max, domain_min;
		    	if(on_off_text_total === "ON"){
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
		    	
		    	//let fill = d3.scale.category20();
		    	let fill;
		    	if(type == 1){ //긍정
		    		fill = d3.scale.linear().domain([0, 75]).range(['#003799','#4DE6FF']);
		    	}else{ //부정
		    		fill = d3.scale.linear().domain([0, 75]).range(['#CC2200','#f7ba00']);
		    	}
		    	
		    	//let fill = d3.scale.linear().domain([10,75]).range(['#E783C9', '#F3C0F1'])
		    	let wordScale = d3.scale.linear().range([range_min, range_max]).domain([domain_min, domain_max]).clamp(true); //
				
		    	function score_function(d){
		    		let text_length = d.text.length;
		    		let text_size = wordScale(d.frequency*weight);
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
				
		          function draw(words) {
		            let svg = d3.select("#"+IDname).append("svg")
		                .attr("width", width)
		                .attr("height", height)
		                
		                
		            let zoom_group = svg.append("g")
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
		},
		build_wordtable_sentiment_edit : function(data) {
			if(typeof data == "undefined") {return;}
			let score_data = new_obj(data);
			if(score_data.length == 0) { return; }
			let type = $("#pair_type_member_sentiment li.active").text();
			if(type.includes("긍정")) { type = 1; }
			else{ type = -1; }
			
			let data_len = data.length;
			let cnt_limit = 10;
			let on_off_text_total = "OFF";
			if($("#sentiment_member_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
				on_off_text_total = "OFF";
			}
			else{
				on_off_text_total = "ON";
			}
			if(on_off_text_total === "ON"){
				cnt_limit = 15;
			}
			
			let IDname = "sentiment_member_word-table_ul";
			$("#"+IDname).empty();
			
			let cnt = 0;
			let display_order = 1;
		    for (let i = 0; i < data_len; i++) {
		    	let seq = null;
		    	let word = data[i]['word'];
				let score = data[i]['score'];
				score = score.toFixed(2);
				score = score.toLocaleString("ko-kr");
				
				if(data[i].length > 5){
					let member_total_TF = data[i][5];
					if(!chk && member_total_TF == "누적단어")
						continue;
					else{
						let li = "";
						if(member_total_TF == "누적단어아님"){
							if(dnai_member.remove_sentiment_word_list.includes(word)) {
								li = '<li style="cursor: pointer">'
									+'<input type="checkbox" val="'+word+'"/>'
									+'<span class="num_item">'+(display_order)
								+'</span><p class="desc_info" id = '+seq+'>'
								+'<span id = '+seq+'>'+word
								+'</span></p><p class="desc_count">'+score+"</p></li>";
							}else{
								li = '<li style="cursor: pointer">'
									+'<input type="checkbox" val="'+word+'" checked/>'
								+'<span class="num_item">'+(display_order)
								+'</span><p class="desc_info" id = '+seq+'>'
								+'<span id = '+seq+'>'+word
								+'</span></p><p class="desc_count">'+score+"</p></li>";
							}
						}else{
							if(dnai_member.remove_sentiment_word_list.includes(word)) {
								li = '<li style="cursor: pointer">'
									+'<input type="checkbox" val="'+word+'"/>'
								+'<span class="num_item">'+(display_order)
								+'</span><p class="desc_info" id = '+seq+'>'
								+'<span id = '+seq+'>'+word
								+'</span></p><p class="desc_count">'+score+"</p></li>";
							}else{
								li = '<li style="cursor: pointer">'
									+'<input type="checkbox" val="'+word+'" checked/>'
								+'<span class="num_item">'+(display_order)
								+'</span><p class="desc_info" id = '+seq+'>'
								+'<span id = '+seq+'>'+word
								+'</span></p><p class="desc_count">'+score+"</p></li>";
							}
						}
						
						$("#"+IDname).append(li);
						display_order+=1;
					}
				}
				else{ //누적 탭 순위 테이블 표시할때
					
					let li = "";
					if(dnai_member.remove_sentiment_word_list.includes(word)) {
						li = '<li style="cursor: pointer">'
							+'<input type="checkbox" val='+word+'/>'
						+'<span class="num_item">'+(i+1)
						+'</span><p class="desc_info" id = '+seq+'>'
						+'<span id = '+seq+'>'+word+'</span></p><p class="desc_count">'+score+"</p></li>";
					}else{
						li = '<li style="cursor: pointer">'
							+'<input type="checkbox" val='+word+' checked/>'
							+'<span class="num_item">'+(i+1)
							+'</span><p class="desc_info" id = '+seq+'>'
							+'<span id = '+seq+'>'+word+'</span></p><p class="desc_count">'+score+"</p></li>";
					}
					$("#"+IDname).append(li);
				}
		    }
			$("#"+IDname).show();
			
			$("#sentiment_member_word-table_ul input").off("click").on("click", function() {
				let remove_chk = $(this).prop("checked");
		    	let word = $(this).attr("val");
		    	if(remove_chk == true) {
		    		let index = dnai_member.remove_sentiment_word_list.indexOf(word);
		    		if(index > -1) { dnai_member.remove_sentiment_word_list.splice(index, 1); }
		    	}else{
		    		dnai_member.remove_sentiment_word_list.push(word);
		    	}
		    	dnai_member.build_wordcloud_sentiment_edit(data);
			});
		},
		
		member_total_info_ : function() {
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
		},
		period_info_ : function() {
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
			if(sentiment_xhr && sentiment_xhr.readystate != 4){
				sentiment_xhr.abort();
		    }
		},
		img_download : function() {
			//프리미엄이라면 주간, 월간, 분기, 기간 설정
			// 단일 단어/ 단어쌍	
			let IDname = "member_wordcloud";
			let sub_tab_link = $(".sub_tab_member-link.current").text();
			let pair_type = $("#pair_type_member li.active").text()
			on_off_text = "";
			let date_period_string = ""
			/*
			let p_square_check = $(".p_square_check_member");
			for(let i = 0; i < p_square_check.length; i++){
				let p_tag = $(p_square_check[i]);
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
				let yester_day = common_func.yesterday_string();
				let user_st_date = common_func.date_name_return(user_start_date);
				date_period_string = user_st_date+" ~ "+yester_day;
			}else if(sub_tab_link.includes("기간")){
				let start_date = $("#start_datepicker").val();
			    let end_date = $("#end_datepicker").val();
				
				//period setting
				let st_date = common_func.date_name_return(start_date);
				let ed_date = common_func.date_name_return(end_date);
				date_period_string = st_date;
				if(st_date != ed_date)
					date_period_string = st_date+" ~ "+ed_date;
			}else{
				//period
				let today = common_func.yesterday_string();
				let period = 0;
				if(sub_tab_link.includes("주간"))
					period = 7;
				else if(sub_tab_link.includes("월간"))
					period = 30;
				else
					period = 90;
				
				let today_minus_period = common_func.today_minus(period);
				date_period_string = today_minus_period+" ~ "+today
			}
			let left = 0;
		    let top = 0;
		    $("#"+IDname).find('g').find("text").each(function(index, item){
		  	  number_string = $(item).attr("transform").replace("translate(","").replace(")","").split(",");
		  	  let x = parseInt(number_string[0]);
		    	  let y = parseInt(number_string[1]);
		    	  
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
					
					
			let tab_name = $(".tab-link.current").attr("data-tab")
			let wordcloud_html;
			let img_width, img_height;
			if(tab_name === "tab-1"){
				wordcloud = document.getElementById("wordcloud").childNodes[7].childNodes[0];
				img_width = wordcloud.getBoundingClientRect().width+10
				img_height = wordcloud.getBoundingClientRect().height+15;
				
			}else{
				wordcloud = document.getElementById("member_wordcloud").childNodes[9].childNodes[0];
				img_width = wordcloud.getBoundingClientRect().width+10
				img_height = wordcloud.getBoundingClientRect().height+10;
				
			}
			html2canvas(wordcloud, {width : img_width, height: img_height, scrollY: -window.scrollY, scale : 1.5, useCORS : true}).then(function (canvas) {
		        let img = canvas.toDataURL('image/png');
		        downloadURI(img, "wordcloud.png", img_width, img_height);
		   })
		},
		excel_download : function() {
			let front = "0";
			let period = "";
			let tab_name =$('.tab-link.current').text();
			let sub_tab_name = $('.sub_tab_member-link.current').text();
			
			let start_date = "";
		    let end_date = "";
			if(sub_tab_name.includes("누적")) {}
			else if(sub_tab_name.includes("주간")) { period = "7"; }
			else if(sub_tab_name.includes("월간")) { period = "30"; }
			else if(sub_tab_name.includes("분기")) { period = "90"; }
			else {
				start_date = $("#start_datepicker").val();
				end_date = $("#end_datepicker").val();
			}
			let pair_type = $('#pair_type_member').children('.active').text();
			if(pair_type.includes("쌍")) { pair_type = "1"; }
			else { pair_type = "0"; }
		    
			let removeChecked = $("#removeCheck").is(":checked");
			let dates = new Date();
			let year = new String(dates.getFullYear()); // 년도
			let month = new String(dates.getMonth() + 1);  // 월
			if(month.length < 2)
				month = "0"+month;
			
			let day = new String(dates.getDate());  // 날짜
			if(day.length < 2)
				day = "0"+day;
			
			let hours = new String(dates.getHours()); // 시
			if(hours.length < 2)
				hours = "0"+hours;
			
			let minutes = new String(dates.getMinutes());  // 분
			if(minutes.length < 2)
				minutes = "0"+minutes;
			
			let seconds = new String(dates.getSeconds());  // 초
			if(seconds.length < 2)
				seconds = "0"+seconds;
			
			let date = year+month+day+"_"+hours+minutes+seconds;
			//file_name_date = year+month+day;
			file_name_date = date;
			
			let filename = user_name+"_"+date;
			
			$.ajax({
				type : "POST",
				url : './utils/wordcloud_excel_save.jsp',
				data : {
					"tab" : tab_name,
					"pair_type" : pair_type,
					"front" : front,
					"user_seq" : dnai_member.user_seq,
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
			});
		},
		sentiment_img_download : function() {
			if($("#sentiment_loadingBar_wordcloud").is(":visible")){
				alert("분석중입니다.")
				return;
			}
			//이미지 다운로드 할때 날짜 단어 표시 하기 위함
			let date_period_string ="";
			let IDname = "";
			let on_off_text = "";
			let tab_link = $(".tab-link.current").text() // 오주뉴 / 프리미엄
			//프리미엄이라면 주간, 월간, 분기, 기간 설정
			// 단일 단어/ 단어쌍	
			IDname = "member_wordcloud_sentiment";
			let sub_tab_link = $(".sub_tab_member-link.current").text();
			let pair_type = $("#pair_type_member li.active").text()
			on_off_text = "";
			if($("#sentiment_member_wordcloud_rect").attr("class").includes("on")){ // 기본형인지
				on_off_text = "OFF";
			}
			else{
				on_off_text = "ON";
			}
			if(sub_tab_link.includes("누적")){
				//누적
				let yester_day = common_func.yesterday_string();
				let user_st_date = common_func.date_name_return(user_start_date);
				date_period_string = user_st_date+" ~ "+yester_day;
			}else if(sub_tab_link.includes("기간")){
				let start_date = $("#start_datepicker").val();
			    let end_date = $("#end_datepicker").val();
				
				//period setting
				let st_date = common_func.date_name_return(start_date);
				let ed_date = common_func.date_name_return(end_date);
				date_period_string = st_date;
				console.log(st_date);
				if(st_date != ed_date)
					date_period_string = st_date+" ~ "+ed_date;
			}else{
				//period
				let today = common_func.yesterday_string();
				let period = 0;
				if(sub_tab_link.includes("주간"))
					period = 7;
				else if(sub_tab_link.includes("월간"))
					period = 30;
				else
					period = 90;
				
				let today_minus_period = common_func.today_minus(period);
				date_period_string = today_minus_period+" ~ "+today
			}
			let left = 0;
		    let top = 0;
		    $("#"+IDname).find('g').find("text").each(function(index, item){
		  	  number_string = $(item).attr("transform").replace("translate(","").replace(")","").split(",");
		  	  let x = parseInt(number_string[0]);
		    	  let y = parseInt(number_string[1]);
		    	  
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
					
					
			let tab_name = $(".tab-link.current").attr("data-tab")
			let wordcloud_html;
			let img_width, img_height;
			wordcloud = document.getElementById("member_wordcloud_sentiment").childNodes[9].childNodes[0];
			img_width = wordcloud.getBoundingClientRect().width+10
			img_height = wordcloud.getBoundingClientRect().height+10;
			
			
			/*svg = document.getElementById("member_wordcloud").childNodes[5];
			let img_width = svg.width.baseVal.value
			let img_height = svg.height.baseVal.value
			
			img_width = wordcloud.getBoundingClientRect().width+7
			img_height = wordcloud.getBoundingClientRect().height+1;*/
			let file_name = "";
			if($($("#pair_type_member_sentiment li")[0]).attr('class').includes("active")){
				file_name = "wordscore_positive.png";
			}
			else{
				file_name = "wordscore_negative.png";
			}
			
			html2canvas(wordcloud, {width : img_width, height: img_height, scrollY: -window.scrollY, scale : 1.5, useCORS : true}).then(function (canvas) {
		        let img = canvas.toDataURL('image/png');
		        downloadURI(img, file_name, img_width, img_height);
		   })
		},
		sentiment_excel_download : function() {
			if($("#sentiment_loadingBar_wordcloud").is(":visible")){
				alert("분석중입니다.")
				return;
			}
			
			let start_date = $("#start_datepicker").val();
		    let end_date = $("#end_datepicker").val();
			
			//let user_name = user_name; //new String("<%=sm3ID%>")
			let removeChecked = $("#removeCheck").is(":checked");
			let dates = new Date();
			let year = new String(dates.getFullYear()); // 년도
			let month = new String(dates.getMonth() + 1);  // 월
			if(month.length < 2)
				month = "0"+month;
			
			let day = new String(dates.getDate());  // 날짜
			if(day.length < 2)
				day = "0"+day;
			
			let hours = new String(dates.getHours()); // 시
			if(hours.length < 2)
				hours = "0"+hours;
			
			let minutes = new String(dates.getMinutes());  // 분
			if(minutes.length < 2)
				minutes = "0"+minutes;
			
			let seconds = new String(dates.getSeconds());  // 초
			if(seconds.length < 2)
				seconds = "0"+seconds;
			
			let date = year+month+day+"_"+hours+minutes+seconds;
			//file_name_date = year+month+day;
			file_name_date = date;
			
			let filename = user_name+"_"+date;
			
			let word_score_excel = {
				"positive":dnai_member.member_pos_word_score,
				"negative":dnai_member.member_neg_word_score,
			};
			word_score_excel = JSON.stringify(word_score_excel);
			let type = 0;
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
				
			});
		},
		on_button_func : function() {
			$("ul.sub_tabs_member li").off("click").on("click", function() {
				let tab_id = $(this).attr('data-tab');
				$("#period_setting").hide();
				$("#sentiment_score_display").hide();
				$('ul.sub_tabs_member li').removeClass('current');
				
				$(this).addClass('current');
				$("#"+tab_id).addClass('current');
				
				$(".linechart").hide();
				$("li.check").hide();
				$("#periodLabel").hide();
				
				let period = $(this).text();
				if(period == "누적") {
					$("li.check").hide();
					$("#periodLabel").hide();
					$("#member_wordcloud_shape").attr("style", "position: absolute; top: 95px; right: 380px;");
			  		dnai_member.ajax_member_total_word_score();
				}else if(period == "기간설정") {
					$("#period_setting").show();
			    	$("#sentiment_score_display").show();
			    	$("li.check").show();
			    	$("#periodLabel").show();
			    	$("#member_wordcloud_shape").attr("style", "position: absolute; top: 130px; right: 380px;");
			    	let start_date = $("#start_datepicker").val();
					let end_date = $("#end_datepicker").val();
					dnai_member.ajax_member_word_score_user_setting(start_date, end_date);
					dnai_member.ajax_member_sentiment_word_period_setting();
				}else{
					$("li.check").show();
			    	$("#periodLabel").show();
			    	$("#member_wordcloud_shape").attr("style", "position: absolute; top: 95px; right: 380px;");
					dnai_member.ajax_member_word_score_period();
				}
				
				if($("#save_action_member").is(":visible")) {
					$("#save_action_member").hide();
					$("#cancel_action_member").hide();
					$("#editing_action_member").show();
					
					dnai_member.remove_word_list = [];
				}
				
			});
			$("#pair_type_member li").off("click").on("click", function() {
				if(typeof($(event.target).attr('id')) != "undefined" && $(event.target).attr("id").includes("before"))
					return;
				if($(this).attr("class") == "check") { return; }
				let chk = $("#removeCheck").is(":checked");
				$("#pair_type_member li").removeClass('active');
				$(event.target).addClass('active');
				let period = $('.sub_tab_member-link.current').text();
				if(period == "기간설정"){
					$("#member_wordcloud_shape").attr("style", "position: absolute; top: 130px; right: 380px;");
				}else{
					$("#member_wordcloud_shape").attr("style", "position: absolute; top: 95px; right: 380px;");
				}
				if($("#save_action_member").is(":visible")) {
					$("#save_action_member").hide();
					$("#cancel_action_member").hide();
					$("#editing_action_member").show();
					
					dnai_member.remove_word_list = [];
				}
				dnai_member.draw_function();
			});
			//프리미엄 뉴스 직사각형2
			$("#member_wordcloud_rect").click(function() {
				$("#member_wordcloud_square").removeClass("on");
				$("#member_wordcloud_rect").addClass("on");
				
				$("#member_wordcloud").removeClass("vt");
				$("#member_word-table").removeClass("vt");
				
				if($("#save_action_member").is(":visible")) {
					dnai_member.draw_function_edit();
				}else{
					dnai_member.draw_function();
				}
			})
			//프리미엄 뉴스 정사각형2
			$("#member_wordcloud_square").click(function() {
				$("#member_wordcloud_rect").removeClass("on");
				$("#member_wordcloud_square").addClass("on");
				
				$("#member_wordcloud").addClass("vt");
				$("#member_word-table").addClass("vt");
				
				if($("#save_action_member").is(":visible")) {
					dnai_member.draw_function_edit();
				}else{
					dnai_member.draw_function();
				}
			})
			$("#removeCheck").on("click",function(event){
				let chk = $("#removeCheck").is(":checked");
				$("#period_setting").hide();
				$(".linechart").hide();
				let period = $('.sub_tab_member-link.current').text();
				if(period == "기간설정") {
					$("#period_setting").show();
			    	$("#sentiment_score_display").show();
			    	$("li.check").show();
			    	$("#periodLabel").show();
			    	$("#member_wordcloud_shape").attr("style", "position: absolute; top: 130px; right: 380px;");
			    	let start_date = $("#start_datepicker").val();
					let end_date = $("#end_datepicker").val();
					dnai_member.ajax_member_word_score_user_setting(start_date, end_date);
				}else{
					$("li.check").show();
			    	$("#periodLabel").show();
			    	$("#member_wordcloud_shape").attr("style", "position: absolute; top: 95px; right: 380px;");
					dnai_member.ajax_member_word_score_period();
				}
				if($("#save_action_member").is(":visible")) {
					$("#save_action_member").hide();
					$("#cancel_action_member").hide();
					$("#editing_action_member").show();
					
					dnai_member.remove_word_list = [];
				}
			});

			$("#pair_type_member_sentiment").on('click','li', function(event){
				if($("#sentiment_loadingBar_wordtable").is(':visible'))
					return;
				
				if($(event.target).attr("id").includes("before"))
					return;
				
				$("#pair_type_member_sentiment li").removeClass('active');
				$(event.target).addClass('active');
				
				if($("#save_action_sentiment").is(":visible")) {
					$("#save_action_sentiment").hide();
					$("#cancel_action_sentiment").hide();
					$("#editing_action_sentiment").show();
				}
				dnai_member.remove_sentiment_word_list = [];
				dnai_member.draw_function_sentiment();
			});
			//기간 설정 긍부정 워드 클라우드 직사각형
			$("#sentiment_member_wordcloud_rect").click(function() {
				if($("#sentiment_loadingBar_wordtable").is(':visible'))
					return;
				
				$("#sentiment_member_wordcloud_square").removeClass("on");
				$("#sentiment_member_wordcloud_rect").addClass("on");
				
				$("#member_wordcloud_sentiment").removeClass("vt");
				$("#sentiment_member_word-table").removeClass("vt");
				
				if($("#save_action_sentiment").is(":visible")) {
					dnai_member.draw_function_sentiment_edit();
				}else{
					dnai_member.draw_function_sentiment();
				}
			})
			//기간 설정 긍부정 워드 클라우드 정사각형
			$("#sentiment_member_wordcloud_square").click(function() {
				if($("#sentiment_loadingBar_wordtable").is(':visible'))
					return;
				
				$("#sentiment_member_wordcloud_rect").removeClass("on");
				$("#sentiment_member_wordcloud_square").addClass("on");
				
				$("#member_wordcloud_sentiment").addClass("vt");
				$("#sentiment_member_word-table").addClass("vt");
		
				if($("#save_action_sentiment").is(":visible")) {
					dnai_member.draw_function_sentiment_edit();
				}else{
					dnai_member.draw_function_sentiment();
				}
			});
			$("#date_submit").off("click").on("click", function() {
				let chk = $("#removeCheck").is(":checked");
				let start_date = $("#start_datepicker").val();
			    let end_date = $("#end_datepicker").val();
			    if(start_date === "" || end_date === ""){
			    	alert("choose date");
			    	return;
			    }else{
			    	dnai_member.ajax_member_word_score_user_setting();
			    	dnai_member.ajax_member_sentiment_word_period_setting();
			    }
			    if($("#save_action_member").is(":visible")) {
					$("#save_action_member").hide();
					$("#cancel_action_member").hide();
					$("#editing_action_member").show();
					
					dnai_member.remove_word_list = [];
				}
			});
			$("#memberCloudImgDownload").off("click").on("click", function() {
				dnai_member.img_download();
			});
			$("#memberCloudExcelDownload").off("click").on("click", function() {
				dnai_member.excel_download();
			});
			$("#memberSentimentCloudImgDownload").off("click").on("click", function() {
				dnai_member.sentiment_img_download();
			});
			$("#memberSentimentCloudExcelDownload").off("click").on("click", function() {
				dnai_member.sentiment_excel_download();
			});
			
			// 프리미엄 사용자 워드 클라우드 편집 기능 
			$("#editing_action_member").off("click").on("click", function() {
				$("#save_action_member").show();
				$("#cancel_action_member").show();
				$("#editing_action_member").hide();
				
				dnai_member.draw_function_edit();
			});
			$("#save_action_member").off("click").on("click", function() {
				$("#save_action_member").hide();
				$("#cancel_action_member").hide();
				$("#editing_action_member").show();
				
				dnai_member.draw_function();
			});
			$("#cancel_action_member").off("click").on("click", function() {
				$("#save_action_member").hide();
				$("#cancel_action_member").hide();
				$("#editing_action_member").show();
				
				dnai_member.remove_word_list = [];
				dnai_member.draw_function();
			});
			
			// 프리미엄 사용자 감성 워드 클라우드 편집 기능
			$("#editing_action_sentiment").off("click").on("click", function() {
				$("#save_action_sentiment").show();
				$("#cancel_action_sentiment").show();
				$("#editing_action_sentiment").hide();
				dnai_member.draw_function_sentiment_edit();
			});
			$("#save_action_sentiment").off("click").on("click", function() {
				$("#save_action_sentiment").hide();
				$("#cancel_action_sentiment").hide();
				$("#editing_action_sentiment").show();
				dnai_member.draw_function_sentiment();
			});
			$("#cancel_action_sentiment").off("click").on("click", function() {
				$("#save_action_sentiment").hide();
				$("#cancel_action_sentiment").hide();
				$("#editing_action_sentiment").show();
				
				dnai_member.remove_sentiment_word_list = [];
				dnai_member.draw_function_sentiment();
			});
			
		}
};