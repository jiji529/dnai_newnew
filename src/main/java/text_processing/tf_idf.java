package text_processing;

import java.util.*;

public class tf_idf {
	/**
     * @param doc  list of strings
     * @param term String represents a term
     * @return term frequency of term in document
     */
    public double tf(List<String> doc, String term) {
        double result = 0;
        for (String word : doc) {
            if (term.equalsIgnoreCase(word))
                result++;
        }
        return result / (double)doc.size();
    }
    
    public double tf_2(Map<String, Integer> doc, String word) {
    	
    	double total = 0.0;
    	for(int val : doc.values()) {
    		total += val;
    	}
    	
    	return (double)doc.get(word) / total; // result;
    }

    /**
     * @param docs list of list of strings represents the dataset
     * @param term String represents a term
     * @return the inverse term frequency of term in documents
     */
    public double idf(List<List<String>> docs, String term) {
        double n = 0;
        for (List<String> doc : docs) {
            for (String word : doc) {
                if (term.equalsIgnoreCase(word)) {
                    n++;
                    break;
                }
            }
        }
        return  Math.log(1+(double)docs.size() / ((double) n));
    }
    
    public double idf_2(Map<String, Integer> docs, int docs_size, String word) {
//    	if(word.equals("코로나 확산")) {
//    		System.out.println(word+"idf = " +Math.log((double)docs_size / 1+(double) docs.get(word)));
//    	}
    	return Math.log((double)docs_size / ((double) docs.get(word)));
    }

    /**
     * @param doc  a text document
     * @param docs all documents
     * @param term term
     * @return the TF-IDF of term
     */
    public double tfIdf(List<String> doc, List<List<String>> docs, String term) {
        return tf(doc, term) * idf(docs, term);

    }
    
    public double tfIdf_2(Map<String, Integer> doc, Map<String, Integer> docs, int docs_size, String word) {
    	return tf_2(doc,word) * idf_2(docs,docs_size,word);
    }
    
    public double tfIdf_3(List<String> doc, Map<String, Integer> docs, int docs_size, String word) {
    	return tf(doc, word) * idf_2(docs,docs_size,word);
    }

    public static void main(String[] args) {
        List<String> doc1 = Arrays.asList("Lorem", "ipsum hi", "dolor", "ipsum hi", "sit", "ipsum hi");
        List<String> doc2 = Arrays.asList("Vituperata", "incorrupte", "at", "ipsum hi", "pro", "quo");
        List<String> doc3 = Arrays.asList("Has", "persius", "disputationi", "id", "simul");
        List<List<String>> documents = Arrays.asList(doc1, doc2, doc3);

        tf_idf calculator = new tf_idf();
        double tfidf = calculator.tfIdf(doc1, documents, "ipsum hi");
        tfidf += calculator.tfIdf(doc2, documents, "ipsum hi");
//        tfidf += calculator.tfIdf(doc3, documents, "ipsum hi");
//        System.out.println("TF-IDF (ipsum hi) = " + tfidf);
        Map<String, Double> score_board = new HashMap<String, Double>();
        for(List<String> doc : documents) {
        	for(String token : doc) {
        		double score = calculator.tfIdf(doc, documents, token);
        		if(score_board.containsKey(token))
        			score_board.put(token, score_board.get(token)+score);
        		else
        			score_board.put(token, score);
        	}
        }
        System.out.println(score_board);
        
        //1번째 식
        Map<String, Integer> idf_map = new HashMap<String, Integer>();
        for(List<String>doc : documents) {
        	for(String token : new HashSet<String>(doc)) {
        		if(idf_map.containsKey(token)) {
        			idf_map.put(token, idf_map.get(token)+1);
        		}else {
        			idf_map.put(token, 1);
        		}
        	}
        }
        
        score_board = new HashMap<String, Double>();
        for(List<String> doc : documents) {
        	for(String token : doc) {
        		double score = calculator.tfIdf_3(doc, idf_map, documents.size(), token);
        		if(score_board.containsKey(token))
        			score_board.put(token, score_board.get(token)+score);
        		else
        			score_board.put(token, score);
        	}
        }
        System.out.println(score_board);
        
        
        // 2번째 식
        List<Map<String, Integer>> content_token_count_map_list = new ArrayList<Map<String, Integer>>();
        Map<String, Integer> total_count_map = new HashMap<String, Integer>();
        for(List<String> doc : documents) {
        	Map<String, Integer> token_count_map = new HashMap<String, Integer>();
        	
        	for(String token : doc) {
        		if(token_count_map.containsKey(token))
        			token_count_map.put(token, token_count_map.get(token)+1);
        		else
        			token_count_map.put(token, 1);
        	}
        	
        	content_token_count_map_list.add(token_count_map);
        	
        	for(String token : new HashSet<String>(doc)) {
        		if(total_count_map.containsKey(token))
        			total_count_map.put(token, total_count_map.get(token)+1);
        		else
        			total_count_map.put(token, 1);
        	}
        }
        
//        double score = calculator.tfIdf_2(content_token_count_map_list.get(0), total_count_map, documents.size(), "ipsum hi");
//        score += calculator.tfIdf_2(content_token_count_map_list.get(1), total_count_map, documents.size(), "ipsum hi");
        score_board = new HashMap<String, Double>();
        for(Map<String, Integer> content_token_count_map : content_token_count_map_list) {
        	for(String token : content_token_count_map.keySet()) {
        		double score = calculator.tfIdf_2(content_token_count_map, total_count_map, documents.size(), token);
        		if(score_board.containsKey(token))
        			score_board.put(token, score_board.get(token)+score);
        		else
        			score_board.put(token, score);
        	}
        }
        
        System.out.println(score_board);
        
    }
}
