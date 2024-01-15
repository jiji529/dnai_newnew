package text_processing;

import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;

import org.apache.lucene.analysis.ko.morph.AnalysisOutput;
import org.apache.lucene.analysis.ko.morph.CompoundEntry;
import org.apache.lucene.analysis.ko.morph.CompoundNounAnalyzer;
import org.apache.lucene.analysis.ko.morph.MorphAnalyzer;
import org.apache.lucene.analysis.ko.morph.MorphException;
import org.apache.lucene.analysis.ko.morph.WordSegmentAnalyzer;

/** 
* @FileName    : ArirangAnalyzerHandler.java 
* @Project     : search-core 
* @Date        : 2015. 8. 17. 
* @작성자         			 : 	  Yujoo 
* @변경이력     			 :  아리랑 형태소 분석기 라이브러리를 사용하여, 형태소 분석을 하는데, 필요한 기능들을 다루는 클레스
* @프로그램 설명    	 : 
*/
public class ArirangAnalyzerHandler {
	/** 
	* @Method Name : morphAnalyze 
	* @변경이력    			 : 
	* @Method 설명     : 형태소 분석
	* @param source
	* @return
	* @throws MorphException 
	*/
	public String morphAnalyze(String source) throws MorphException {
		MorphAnalyzer maAnal = new MorphAnalyzer(); // 형태소 분석기 
		
		StringBuilder result = new StringBuilder();
		
		StringTokenizer stok = new StringTokenizer(source, " ");
		while (stok.hasMoreTokens()) {
			String token = stok.nextToken();
			List<AnalysisOutput> outList = maAnal.analyze(token);
			for (AnalysisOutput o : outList) {
				result.append(o).append(" ");
			}
		}
		return result.toString();
	}

	/** 
	* @Method Name : wordSpaceAnalyze 
	* @변경이력    			 : 
	* @Method 설명     : 뛰어 쓰기
	* @param source
	* @param force
	* @return
	* @throws MorphException 
	*/
	public String wordSpaceAnalyze(String source, boolean force) throws MorphException {
		WordSegmentAnalyzer wsAnal = new WordSegmentAnalyzer();
		
		StringBuilder result = new StringBuilder();
		
		String s;
		if (force)
			s = source.replace(" ", "");
		else
			s = source;
		List<List<AnalysisOutput>> outList = wsAnal.analyze(s);
		for (List<AnalysisOutput> o : outList) {
			for (AnalysisOutput analysisOutput : o) {
				result.append(analysisOutput.getSource()).append(" ");
			}

		}

		return result.toString();
	}

	/** 
	* @Method Name : wordSpaceAnalyze 
	* @변경이력    			 : 
	* @Method 설명     : 뛰어 쓰기
	* @param source
	* @return
	* @throws MorphException 
	*/
	public String wordSpaceAnalyze(String source) throws MorphException {
		return wordSpaceAnalyze(source, false);
	}

	/** 
	* @Method Name : compoundNounAnalyze 
	* @변경이력    			 : 
	* @Method 설명     : 복합 명사 분해
	* @param source
	* @return
	* @throws MorphException 
	*/
	public String compoundNounAnalyze(String source) throws MorphException {
		CompoundNounAnalyzer cnAnal = new CompoundNounAnalyzer(); // 복합어 분석기
		
		StringBuilder result = new StringBuilder();
		
		List<CompoundEntry> outList = cnAnal.analyze(source);
		for (CompoundEntry o : outList) {
			result.append(o.getWord()).append(" ");
		}

		return result.toString();
	}

	/** 
	* @Method Name : guideWord 
	* @변경이력    			 : 
	* @Method 설명     : 색인어 추출
	* @param source
	* @return
	* @throws MorphException 
	*/
	public String guideWord(String source) throws MorphException {
		MorphAnalyzer maAnal = new MorphAnalyzer(); // 형태소 분석기 
	
		StringTokenizer stok = new StringTokenizer(source, " "); // 쿼리문을 뛰어쓰기 기준으로 토큰화
		
		StringBuilder result = new StringBuilder();
		
		while (stok.hasMoreTokens()) {
			
			String token = stok.nextToken();
			
			List<AnalysisOutput> outList = maAnal.analyze(token);
			for (AnalysisOutput o : outList) {
				
				result.append(o.getStem());
				
				for (CompoundEntry s : o.getCNounList()) {
						result.append("+" + s.getWord());
				}
			
				result.append(",");
			}
		}
		String s = result.toString();
		if (s.endsWith(","))
			s = s.substring(0, s.length() - 1);
		return s;
	}
	
	/** 
	* @Method Name : extractNoun 
	* @변경이력    			 : 
	* @Method 설명     : 명사 추출
	* @param searchQuery
	* @return
	* @throws MorphException 
	*/
	public ArrayList<String> extractNoun(String searchQuery) throws MorphException{
		ArrayList<String> nounList = new ArrayList<String>();		
		
		MorphAnalyzer maAnal = new MorphAnalyzer(); // 형태소 분석기 
		StringTokenizer stok = new StringTokenizer(searchQuery, " "); // 쿼리문을 뛰어쓰기 기준으로 토큰화
		
		// 색인어 분석기를 통해 토큰에서 색인어 추출
		while (stok.hasMoreTokens()) {
			String token = stok.nextToken();
			
			// 형태소 분석
			List<AnalysisOutput> indexList = maAnal.analyze(token);
			
			for (AnalysisOutput morpheme : indexList) 
				// 명사 추출 , 모르는 단어의 경우 바이그램 결과 추출, 해당 추출결과를 배제하기 위해 patn이 1인 결과만 반환
				if(morpheme.getPos() == 'N')// && morpheme.getPatn() == 1)
					nounList.add(morpheme.getStem());
		}
		
		return nounList;
	}
}


