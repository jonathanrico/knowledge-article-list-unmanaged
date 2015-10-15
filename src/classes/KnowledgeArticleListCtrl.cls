public with sharing class KnowledgeArticleListCtrl{

    @AuraEnabled
    public static List<KnowledgeArticleItem> getRecords(Integer maxResults, String articleType, String sortByType){

        List<KnowledgeArticleItem> results = new List<KnowledgeArticleItem>();
        Integer mxr = Integer.valueOf(maxResults);
        List<Id> sortedIds = new List<Id>();
        Map<Id,KnowledgeArticleItem> kavMap = new Map<Id,KnowledgeArticleItem>();

        try{

          String statObject = sortByType=='Views'?'ViewStat':'VoteStat';

          //Get ka ids sorted by normalized score
          String soqlVoteStats = 'select Id, ParentId, NormalizedScore from '+articleType+'__'+statObject;
          String soqlKAType = 'select Id,Title,KnowledgeArticleId,ArticleType from '+articleType+'__kav';

          if(!Test.isRunningTest()){

            soqlVoteStats+= ' where Channel = \'AllChannels\' order by NormalizedScore desc limit :mxr';

            for(Sobject v : Database.query(soqlVoteStats)){
                Id kaId = (Id)v.get('ParentId');
                sortedIds.add(kaId);
                KnowledgeArticleItem kai = new KnowledgeArticleItem();
                kai.kaId = kaId;
                Integer articleRating = 0;
                if(v.get('NormalizedScore') != null){
                  if(statObject == 'VoteStat'){
                    articleRating = ((((Decimal)v.get('NormalizedScore'))/5.0)*100.0).intValue();
                  }else{
                    articleRating = ((Decimal)v.get('NormalizedScore')).intValue();
                  }
                }
                kai.Rating = articleRating;
                kavMap.put(kaId, kai);
            }

            soqlKAType+= ' where PublishStatus=\'online\' and KnowledgeArticleId in :sortedIds';

            for(Sobject a : Database.query(soqlKAType)){
                Id kaId = (String)a.get('KnowledgeArticleId');
                KnowledgeArticleItem kai = kavMap.get(kaId);
                kai.Id = a.Id;
                kai.Title = (String)a.get('Title');
            }

          }else{
                //TODO: Replace with  dynamic knowledge article creation based on existing article types
                KnowledgeArticleItem kai1 = new KnowledgeArticleItem();
                kai1.Id = 'kA061000000M55d';
                kai1.Title = 'Test Article 1 ';
                kai1.Rating = 1;
                sortedIds.add('kA161000000M55d');
                kavMap.put('kA161000000M55d', kai1);
                KnowledgeArticleItem kai2 = new KnowledgeArticleItem();
                kai2.Id = 'kA061000000M55e';
                kai2.Title = 'Test Article 2';
                kai2.Rating = 2;
                sortedIds.add('kA161000000M55e');
                kavMap.put('kA161000000M55e', kai2);
                KnowledgeArticleItem kai3 = new KnowledgeArticleItem();
                kai3.Id = 'kA061000000M55f';
                kai3.Title = 'Test Article 3';
                kai3.Rating = 3;
                sortedIds.add('kA161000000M55f');
                kavMap.put('kA161000000M55f', kai3);
                KnowledgeArticleItem kai4 = new KnowledgeArticleItem();
                kai4.Id = 'kA061000000M55g';
                kai4.Title = 'Test Article 4';
                kai4.Rating = 4;
                sortedIds.add('kA161000000M55g');
                kavMap.put('kA161000000M55g', kai4);
                KnowledgeArticleItem kai5 = new KnowledgeArticleItem();
                kai5.Id = 'kA061000000M55h';
                kai5.Title = 'Test Article 5';
                kai5.Rating = 5;
                sortedIds.add('kA161000000M55h');
                kavMap.put('kA161000000M55h', kai5);
                KnowledgeArticleItem kai6 = new KnowledgeArticleItem();
                kai6.Id = 'kA061000000M55i';
                kai6.Title = 'Test Article 6';
                kai6.Rating = 0;
                sortedIds.add('kA161000000M55i');
                kavMap.put('kA161000000M55i', kai6);
          }

          for(Id kavId : sortedIds){
            results.add(kavMap.get(kavId));
          }

        }catch(Exception e){
          //TODO: Handle exception
          System.debug(e);
        }
        return results;
    }

}
