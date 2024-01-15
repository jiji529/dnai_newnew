<%@page import="java.text.DecimalFormat"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="connect.DB"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%
//주요 키워드 분기별 워드 스코어 리턴
DB db = new DB();
String sm3ID = request.getParameter("sm3ID");
JSONArray user_seq_ = db.user_seq_return(sm3ID);
String user_seq = user_seq_.get(0).toString();
String pair_type = request.getParameter("pair_type");
String start_date = request.getParameter("start_date");
String end_date = request.getParameter("end_date");

if(!start_date.contains("-"))
	start_date = start_date.substring(0,4)+"-"+start_date.substring(4,6)+"-"+start_date.substring(6,8);

if(!end_date.contains("-"))
	end_date = end_date.substring(0,4)+"-"+end_date.substring(4,6)+"-"+end_date.substring(6,8);

//JSONArray word_score = db.member_word_score_period_date_setting(user_seq, pair_type, start_date, end_date);
//response.setContentType("application/json");

%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>wordcloud img download</title>
 <link rel="stylesheet" href="../css/style.css">
 <link id="load-css-0" rel="stylesheet" type="text/css" href="../css/tooltip.css">
 <link id="load-css-1" rel="stylesheet" type="text/css" href="../css/util.css">
 <link id="load-css-2" rel="stylesheet" type="text/css" href="../css/table.css">
 <link id="load-css-3" rel="stylesheet" type="text/css" href="../css/format.css">

<script type="text/javascript" src="../js/webfont.js"></script>

<script type="text/javascript" src="../js/jquery-1.12.4.js"></script>
<script type="text/javascript" src="../js/jquery.min.js"></script>
<script type="text/javascript" src="../js/jquery-ui.js"></script>
<script type="text/javascript" src="../js/datepicker-ko.js"></script>
<script type="text/javascript" src="../js/jquery-ui.min.js"></script>

<script type="text/javascript" src="../js/html2canvas.js"></script>
<script type="text/javascript" src="../js/canvas-toBlob.js"></script>
<script type="text/javascript" src="../js/dom-to-image.js"></script>
<script type="text/javascript" src="../js/FileSaver.js"></script>
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/FileSaver.js/1.3.8/FileSaver.min.js"></script>
<script type="text/javascript" src="../js/download.js"></script>

<script type="text/javascript" src="../js/loader.js"></script>
<script src="../js/d3.v3.min.js" type="text/JavaScript"></script>
<script src="../js/d3.layout.cloud.js" type="text/JavaScript"></script>
<script type="text/javascript" src="../js/moment.js"></script>
<script type="text/javascript" src="../js/Chart.bundle.min.js"></script>
<script type="text/javascript" src="../js/Chart.min.js"></script>
<script type="text/javascript" src="../js/fontfaceonload.js"></script>
<script src="https://cdn.jsdelivr.net/npm/es6-promise@4/dist/es6-promise.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/es6-promise@4/dist/es6-promise.auto.min.js"></script> 
<script type="text/javascript">

WebFont.load({
	  custom: {
	    families: ['GmarketSansBold'],
	  }
	});
$(document).ready(function(){
	
	var score_data = "";
	FontFaceOnload('GmarketSansBold', {
		success : function() {
			build_wordcloud(score_data, true, 1);
			$("#blobButton").trigger("click");
		}
	})
});

function WinClose()
{
	window.close();
	self.close();
  	window.open('','_self').close(); 
  	self.opener = self;
  	window.close();
}
function build_wordcloud(score_data, member, front){
	//document.getElementById("wordcloud").innerHTML = null;
	
	var words = eval(score_data);
	var max = 0;
	var min = 0;
	var pair_type = "";
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
		if(front === 1){
			IDname = "wordcloud";
		}
		else{
			IDname = "wordcloud";
		}
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
        .padding(3)
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
                .style("fill", function(d, i) { return fill(i); })//
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
            	 	}
            	 	
              });
          }
          
    }
    showCloud(frequency_list, IDname);
    console.log("complete")
}

function img_download(){
	//svg = $("#member_wordcloud svg")[0];
	wordcloud = document.getElementById("member_wordcloud").childNodes[0].childNodes[0];
	svg = document.getElementById("member_wordcloud").childNodes[0];
	var img_width = svg.width.baseVal.value
	var img_height = svg.height.baseVal.value
	var img = "";
	
	/*$("g").ready(function(){
		console.log("hi")
		console.log(wordcloud.getBoundingClientRect())
		console.log(wordcloud.getBoundingClientRect().width+1)
		img_width = wordcloud.getBoundingClientRect().width+1
		console.log($("g").outerWidth(true))
	})*/
	img_width = wordcloud.getBoundingClientRect().width+10
	img_height = wordcloud.getBoundingClientRect().height+5;
	html2canvas(wordcloud, {width : img_width, height: img_height, scale : 1.5}).then(function (canvas) {
        img = canvas.toDataURL('image/png');
        downloadURL(img, canvas, "wordcloud.png");
   })

}

function downloadURL(url,canvas, name){
	var link = document.createElement("a");
	
	if (navigator.appVersion.toString().indexOf('.NET') > 0){
		//img = canvas.toDataURL("application/octet-stream");
		
	   /*console.log(canvas.msToBlob());
	   //window.open(url);
		url1 = URL.createObjectURL(canvas.msToBlob())
		console.log(url1);
		//download(document.getElementById("member_wordcloud"), name, 'application/octet-stream');
		console.log(canvas.toDataURL('application/octet-stream'))
		console.log("bye")
		
		/*link.download = name;
		link.href = img;
		link.id = "download_link";
		link.type = "application/octet-stream";
		document.body.appendChild(link);
		link.click();*/
		//link.remove();
		//var blob = new Blob([canvas], {type : 'image/png'})
		
		/*link.target = "_blank";
		link.href = url;
		link.id = "download_link";
		document.body.appendChild(link);
		link.click();
		link.remove();*/
		
		
		//wordcloud = document.getElementById("member_wordcloud")//.childNodes[0].childNodes[0];
		/*html2canvas(wordcloud, {
		      onrendered: function(canvas) {
		         // document.body.appendChild(canvas);
		         console.log(canvas.toDataURL('image/jpeg'));
		       window.open(canvas.toDataURL('image/jpeg'));
		     }
		  }).then(function(canvas){
			  window.open(canvas.toDataURL('image/jpeg'));
		  });*/
		//window.navigator.msSaveOrOpenBlob(canvas.msToBlob(), name);
		  
		  
		  /*wordcloud = document.getElementById("member_wordcloud").childNodes[0].childNodes[0];
		  domtoimage.toBlob(wordcloud)
		    .then(function (blob) {
		    	console.log(blob);
		        window.saveAs(blob, 'my-node.png');
		    });*/
		    
		alert("다운로드 시 크롬 실행 필요")
	}
	else{
		domtoimage.toBlob(wordcloud)
	    .then(function (blob) {
	    	console.log(blob);
	        window.saveAs(blob, 'my-node.png');
	    });
		link.download = name;
		link.href = url;
		link.id = "download_link";
		document.body.appendChild(link);
		link.click();
		link.remove();	
		
		
	}
	
}
</script>
</head>
<body>
<h3 style="display:hidden;">wordcloud download API</h3>
<input id="blobButton" type="hidden" onclick="img_download()" value="image download" />
<div id="member_wordcloud" class="cloud box" style="font-family: GmarketSansBold;"></div>
</body>
</html>