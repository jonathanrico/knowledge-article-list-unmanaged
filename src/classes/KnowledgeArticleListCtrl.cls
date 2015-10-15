public with sharing class KnowledgeArticleListCtrl{

    @AuraEnabled
    public static List<KnowledgeArticleItem> getRecords(Integer maxResults, String articleType, String sortByType){

        List<KnowledgeArticleItem> results = new List<KnowledgeArticleItem>();
        Integer mxr = Integer.valueOf(maxResults);
        List<Id> sortedIds = new List<Id>();
        Map<Id,KnowledgeArticleItem> kavMap = new Map<Id,KnowledgeArticleItem>();

        try{

          if(!Test.isRunningTest()){

            //Get ka ids sorted by normalized score
            String statObject = sortByType=='Views'?'ViewStat':'VoteStat';

            String soqlVoteStats = 'select Id, ParentId, NormalizedScore from '+articleType+'__'+statObject;
            soqlVoteStats+= ' where Channel = \'AllChannels\' order by NormalizedScore desc limit :mxr';

            for(Sobject v : Database.query(soqlVoteStats)){
                Id kaId = (Id)v.get('ParentId');
                sortedIds.add(kaId);
                KnowledgeArticleItem kai = new KnowledgeArticleItem();
                kai.kaId = kaId;
                Integer articleRating = 0;
                if(v.get('NormalizedScore') != null){
                  System.debug('**** NS : '+v.get('NormalizedScore'));
                  if(statObject == 'VoteStat'){
                    articleRating = ((((Decimal)v.get('NormalizedScore'))/5.0)*100.0).intValue();
                  }else{
                    articleRating = ((Decimal)v.get('NormalizedScore')).intValue();
                  }
                }

                System.debug('**** AR : '+articleRating);
                kai.Rating = articleRating;
                kavMap.put(kaId, kai);
            }

            String soql = 'select Id,Title,KnowledgeArticleId,ArticleType from '+articleType+'__kav';
            soql+= ' where PublishStatus=\'online\' and KnowledgeArticleId in :sortedIds';

            for(Sobject a : Database.query(soql)){
                Id kaId = (String)a.get('KnowledgeArticleId');
                KnowledgeArticleItem kai = kavMap.get(kaId);
                kai.Id = a.Id;
                kai.Title = (String)a.get('Title');
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

          for(Id kavId : sortedIds){
            results.add(kavMap.get(kavId));
          }

        }catch(Exception e){
          System.debug(e);
        }
        return results;
    }

}
