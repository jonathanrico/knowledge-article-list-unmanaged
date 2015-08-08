public with sharing class KnowledgeArticleListCtrl{

    @AuraEnabled
    public static List<KnowledgeArticleItem> getRecords(){
        List<KnowledgeArticleItem> results = new List<KnowledgeArticleItem>();
        List<Id> sortedIds = new List<Id>();
        Map<Id,KnowledgeArticleItem> kavMap = new Map<Id,KnowledgeArticleItem>();

        for(How_To__kav a : [select Id
                                    ,Title
                                    ,KnowledgeArticleId
                                    ,ArticleType
                                    from How_To__kav
                                    where PublishStatus='online'
                                    and language ='en_US'
                                    limit 10]){
            KnowledgeArticleItem kai = new KnowledgeArticleItem();
            kai.Id = a.Id;
            kai.Title = a.Title;
            kai.Rating = 0;
            sortedIds.add(a.KnowledgeArticleId);
            kavMap.put(a.KnowledgeArticleId, kai);
        }

        for(How_To__VoteStat v : [select Id
                                    ,ParentId
                                    ,NormalizedScore
                                    from How_To__VoteStat
                                    where ParentId in :kavMap.keySet()]){

            if(v.NormalizedScore != null){
              kavMap.get(v.ParentId).Rating = ((v.NormalizedScore/5.0)*100.0).intValue();
            }
        }

        for(Id kavId : sortedIds){
          results.add(kavMap.get(kavId));
        }
        return results;
    }

}
