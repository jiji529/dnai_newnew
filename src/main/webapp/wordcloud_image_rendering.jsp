<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="connect.DB"%>   
    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>DNA wordcloud</title>
<link rel="stylesheet" href="./css/style.css">
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
google.charts.load('current',{
    'packages' : ['corechart','table']});
google.charts.setOnLoadCallback(drawChart);




function drawChart(){
	var type = "0";
	ajax_total_word_score(type, 2);
	//ajax_member_word_period(user_seq,type, 7, 2,false);
}

function ajax_total_word_score(type, front){
	$.ajax({
        type : 'POST',
        url : './utils/total_word_score.jsp',
        data : {pair_type : type,
        		front : front},
        dataType : 'json',
        async: false,
        success : function(data) {
            //data, total or member, front
        	build_wordcloud(data,false,front);
        },
        error : function(e) {
            //alert(e.responseText)
        }
    });
}

////////////////////////////////////////////////////

function build_wordcloud(score_data, member,front){
	//document.getElementById("wordcloud").innerHTML = null;
		
	var words = eval(score_data);
	var max = 0;
	var min = 0;
	var pair_type = "";
	var frequency_list = new Array();
	if(words.length == 0)
		return;
	
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
    	var weight = 3,   // change me
        width = 700,
        height = 400;
		
    	var domain_max = 10, range_max = 150;
    	
    	if(pair_type == '1')
    		range_max = 150;
    	
    	var fill = d3.scale.category20();
    	var wordScale = d3.scale.linear().domain([0, domain_max]).range([0, range_max]).clamp(true);
		d3.layout.cloud().size([width, height]).words(frequency_list)
        //.rotate(function() { return (Math.random() * 2) * 90; })
        .padding(2.5)
        .text(function(d) { return d.text; })
        .rotate(0)
        .font("GmarketSansBold")
        
        .fontSize(function(d) { return wordScale(d.frequency*weight); })
        .on("end", draw)
        .start();

          function draw(words) {
            d3.select("#"+IDname).append("svg")
                .attr("width", width)
                .attr("height", height)
                
              .append("g")
                .attr("transform", "translate(" + width/2 + "," + height/2 + ")")
                
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
          
          /*var left = 0;
          var top = 0;
          $("#"+IDname).find('g').find("text").each(function(index, item){
        	  number_string = $(item).attr("transform").replace("translate(","").replace(")","").split(",");
        	  var x = parseInt(number_string[0]);
          	  var y = parseInt(number_string[1]);
          	  
        	  if(left < x)
        		  left = x;
        	  
        	  if(top > y)
        		  top = y;
          })*/
          
          
          /*d3.select("#"+IDname).select("g").append("text")
          .attr("x", left)             
          .attr("y", -210)
          .attr("text-anchor", "middle")  
          .style("font-size", "12px")
          .style("color", "#666666")
          .style("font-family", "GmarketSansBold")*/
          
    }
    showCloud(frequency_list, IDname);
    img_download();
}


function img_download(){
	console.log("img_download");
	//svg = $("#member_wordcloud svg")[0];
	//console.log($(".tab-link.current").attr("data-tab"));
	var tab_name = $(".tab-link.current").attr("data-tab")
	var wordcloud_html;
	var img_width, img_height;
	wordcloud = document.getElementById("wordcloud").childNodes[3].childNodes[0];
	img_width = wordcloud.getBoundingClientRect().width+3
	img_height = wordcloud.getBoundingClientRect().height+1;
		
	
	
	/*svg = document.getElementById("member_wordcloud").childNodes[5];
	var img_width = svg.width.baseVal.value
	var img_height = svg.height.baseVal.value
	
	img_width = wordcloud.getBoundingClientRect().width+7
	img_height = wordcloud.getBoundingClientRect().height+1;*/
	html2canvas(wordcloud, {width : img_width, height: img_height, scale : 1.5, useCORS : true}).then(function (canvas) {
        var img = canvas.toDataURL('image/png');
        downloadURI(img, "wordcloud.png", img_width, img_height);
   })


}

function downloadURI(img_raw_uri, name, img_width, img_height){
	var link = document.createElement("a");
	
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
	if(minutes < 10){
		minutes = "00";
	}else{
		var m = minutes % 10;
		minutes -= m;
	}
	

	var seconds = new String(dates.getSeconds());  // 초
	if(seconds.length < 2)
		seconds = "0"+seconds;
	
	var date = year+month+day+"_"+hours+minutes+seconds;
	file_name_date = year+month+day+"_"+hours+minutes;
	
	var filename = file_name_date+".png";
	var count = 0;
	$.ajax({
		type : "POST",
		url : './utils/wordcloud_img_save.jsp',
		data : {
			"imgBase64" : img_raw_uri,
			"filename" : filename,
		}
	}).done(function(o){
		
		$('#download_link').attr({
			'download':file_name_date+".png",
			'href':'./wordcloud_image/'+filename
			})
		//document.getElementById("download_link").click();
	})

}

</script>

</head>
<body>
	<div class="container">
		
		
		
		<div id="tab-1" class="tab-content current wrap" >
			
                <div class="tab_tit">
                	<div class="inner">
						<ul class="sub_tabs">
							<li class="sub_tab-link current" data-tab="today_total" style="cursor: pointer"><h1>오늘의 주요 키워드</h1></li>
						</ul>
					</div>
				</div>
			
			
		 	<div class = "score_display" id = "total_score_display"> <!-- display:none  visibility:hidden-->]
		 		<div class="inner">
		 				
				 		<div id = "wordcloud" class= "cloud box" >
				 			<h3 class="box_tit" style="cursor: pointer">워드 클라우드</h3>	
				 		</div>
					 	
				</div>
			</div>
		</div>
		
		<a id = "download_link" download ></a>
	</div>
	
<script type="text/javascript">

</script>
</body>
</html>