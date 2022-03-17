public without sharing class X11_FAQArticles {

    @AuraEnabled
    public static String fetchIntialData(String searchKey){
        List<Knowledge__kav> knowledgeLst = new List<Knowledge__kav>();
        try{
            String publishStatus = 'Online';
            String whereCondition = 'WHERE PublishStatus = '+'\''+publishStatus+'\'';
            /*if(!String.isBlank(searchKey)){
                whereCondition += 'AND Title LIKE '+'%'+'\''+searchKey+'\''+'%';
            }*/
            String knowledgeQuery = 'Select Id, PublishStatus, Title, UrlName, Summary FROM Knowledge__kav ';
            List<Knowledge__kav> knowledgeList = Database.query(knowledgeQuery + whereCondition);
            if(!String.isBlank(searchKey)){
                for(Knowledge__kav objKnowledge: knowledgeList){
                    if(objKnowledge.Title.containsIgnoreCase(searchKey) || objKnowledge.Summary.containsIgnoreCase(searchKey)){
                        knowledgeLst.add(objKnowledge);
                    }
                }
            }else{
                return JSON.serialize(knowledgeList);
            }
        }catch(Exception e){
            X11_Utility.logError(e,'X11_FAQArticles','fetchIntialData');
        }
       	return JSON.serialize(knowledgeLst);
    }
}