public with sharing class KnowledgeArticleListCtrl{

    @AuraEnabled
    public static List<KnowledgeArticleItem> getRecords(Integer maxResults, String articleType){

        Integer mxr = Integer.valueOf(maxResults);
        List<KnowledgeArticleItem> results = new List<KnowledgeArticleItem>();
        List<Id> sortedIds = new List<Id>();
        Map<Id,KnowledgeArticleItem> kavMap = new Map<Id,KnowledgeArticleItem>();

        String soql = 'select Id,Title,KnowledgeArticleId,ArticleType from '+articleType+'__kav';
        soql+= ' where PublishStatus=\'online\' and language = \'en_US\' limit :mxr';

        try{
          for(Sobject a : Database.query(soql)){
              KnowledgeArticleItem kai = new KnowledgeArticleItem();
              kai.Id = a.Id;
              kai.Title = (String)a.get('Title');
              kai.Rating = 0;
              sortedIds.add((String)a.get('KnowledgeArticleId'));
              kavMap.put((String)a.get('KnowledgeArticleId'), kai);
          }

          Set<Id> parentIdsSet = kavMap.keySet();
          String soqlVoteStats = 'select Id,ParentId,NormalizedScore from '+articleType+'__VoteStat';
          soqlVoteStats+= ' where ParentId in :parentIdsSet and Channel = \'AllChannels\'';

          for(Sobject v : Database.query(soqlVoteStats)){
              if(v.get('NormalizedScore') != null){
                kavMap.get((String)v.get('ParentId')).Rating = ((((Decimal)v.get('NormalizedScore'))/5.0)*100.0).intValue();
              }
          }

          for(Id kavId : sortedIds){
            results.add(kavMap.get(kavId));
          }
        }catch(Exception e){
          //TODO : Return a nice exception in here
        }
        return results;
    }

}
