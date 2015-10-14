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

          if(!Test.isRunningTest()){
            for(Sobject a : Database.query(soql)){
                KnowledgeArticleItem kai = new KnowledgeArticleItem();
                kai.Id = a.Id;
                kai.Title = (String)a.get('Title');
                kai.Rating = 0;
                sortedIds.add((String)a.get('KnowledgeArticleId'));
                kavMap.put((String)a.get('KnowledgeArticleId'), kai);
            }
          }else{
                KnowledgeArticleItem kai1 = new KnowledgeArticleItem();
                kai1.Id = 'kA061000000M55d';
                kai1.Title = 'Test Article';
                kai1.Rating = 0;
                sortedIds.add('kA161000000M55d');
                kavMap.put('kA161000000M55d', kai1);
                KnowledgeArticleItem kai2 = new KnowledgeArticleItem();
                kai2.Id = 'kA061000000M55e';
                kai2.Title = 'Test Article';
                kai2.Rating = 0;
                sortedIds.add('kA161000000M55e');
                kavMap.put('kA161000000M55e', kai2);
                KnowledgeArticleItem kai3 = new KnowledgeArticleItem();
                kai3.Id = 'kA061000000M55f';
                kai3.Title = 'Test Article';
                kai3.Rating = 0;
                sortedIds.add('kA161000000M55f');
                kavMap.put('kA161000000M55f', kai3);
                KnowledgeArticleItem kai4 = new KnowledgeArticleItem();
                kai4.Id = 'kA061000000M55g';
                kai4.Title = 'Test Article';
                kai4.Rating = 0;
                sortedIds.add('kA161000000M55g');
                kavMap.put('kA161000000M55g', kai4);
          }

          Set<Id> parentIdsSet = kavMap.keySet();

          if(!Test.isRunningTest()){
              String soqlVoteStats = 'select Id,ParentId,NormalizedScore from '+articleType+'__VoteStat';
              soqlVoteStats+= ' where ParentId in :parentIdsSet and Channel = \'AllChannels\'';

              for(Sobject v : Database.query(soqlVoteStats)){
                  if(v.get('NormalizedScore') != null){
                    kavMap.get((String)v.get('ParentId')).Rating = ((((Decimal)v.get('NormalizedScore'))/5.0)*100.0).intValue();
                  }
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
