public with sharing class KnowledgeArticleListCtrl{

    @AuraEnabled
    public static List<KnowledgeArticleItem> getRecords(Integer maxResults, String articleType, String sortByType, Boolean filterByLanguage){

        //Auxiliary collections
        List<KnowledgeArticleItem> results = new List<KnowledgeArticleItem>();
        Integer mxr = Integer.valueOf(maxResults);
        List<Id> sortedIds = new List<Id>();
        Map<Id,KnowledgeArticleItem> kavMap = new Map<Id,KnowledgeArticleItem>();
        List<Map<String,Object>> sobjects = null;

        try{

          //Grab the running user's language code for use in SOQL queries
          String currentLanguage = UserInfo.getLanguage();

          //Set the stat object suffix depending on the sort type
          String statObject = sortByType=='Views'?'ViewStat':'VoteStat';


          if(Test.isRunningTest()){
            //Construct test maps for tests to avoid validation issues with custom articke types
            Map<String,Object> testObj = new Map<String,Object>();
            testObj.put('Id','kA061000000M55dCAC');
            testObj.put('ParentId','kA161000000M55dCAC');
            testObj.put('NormalizedScore',3.0);
            sobjects = new List<Map<String,Object>>{testObj};
          }else{
            //Start filtering articles based on the article ViewStat or VoteStat objects, always sort by Normalized Score descending
            String soqlVoteStats = 'select Id, ParentId, NormalizedScore from '+articleType+'__'+statObject+' where Channel = \'AllChannels\'';

            //Additional filters if we want to limit results to the current user's language
            if(filterByLanguage){
                // TODO: Filter by language without performing an extra query to avoid governor limit exceptions
                soqlVoteStats+= ' and ParentId in (select KnowledgeArticleId from '+articleType+'__kav where PublishStatus=\'online\' and Language = :currentLanguage)';
            }
            soqlVoteStats+= ' order by NormalizedScore desc limit :mxr';

            //Convert sobjects to maps to make sure we use the same code path as the unit tests
            List<Sobject> voteResults = Database.query(soqlVoteStats);
            sobjects = sObjectsToMap(voteResults, new Set<String>{'Id','ParentId','NormalizedScore'});
          }

          //Create a map of knowledge article items with the current rating (normalized score) information
          for(Map<String,Object> v : sobjects){
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

          //Query for additional knowledge article data for the map entries created in the previous step
          if(Test.isRunningTest()){
            //Construct test maps for tests to avoid validation issues with custom articke typ
            Map<String,Object> testObj = new Map<String,Object>();
            testObj.put('Id','kA061000000M55dCAC');
            testObj.put('KnowledgeArticleId','kA161000000M55dCAC');
            testObj.put('Title','Sample Article');
            testObj.put('ArticleType','How_To');
            sobjects = new List<Map<String,Object>>{testObj};
          }else{
            //TODO : Default to any available language if the article doesn't exist in the user's language
            String soqlKAType = 'select Id,Title,KnowledgeArticleId,ArticleType from '+articleType+'__kav where PublishStatus=\'online\' and KnowledgeArticleId in :sortedIds and Language = :currentLanguage';
            List<Sobject> kaResults = Database.query(soqlKAType);
            sobjects = sObjectsToMap(kaResults, new Set<String>{'Id','KnowledgeArticleId','Title','ArticleType'});
          }

          //Enrich the map data with additional knowledge article information
          for(Map<String,Object> a : sobjects){
              Id kaId = (String)a.get('KnowledgeArticleId');
              KnowledgeArticleItem kai = kavMap.get(kaId);
              kai.Id = (String)a.get('Id');
              kai.Title = (String)a.get('Title');
          }

          //Build a list of knowledge article items using the original sort order provided by the VoteStat or ViewStat queries
          for(Id kavId : sortedIds){
            results.add(kavMap.get(kavId));
          }

        }catch(Exception e){
          //Handle exception
          System.debug(e);
        }

        return results;
    }

    @TestVisible
    private static List<Map<String,Object>> sObjectsToMap(List<SObject> sobjects, Set<String> fields){
        List<Map<String,Object>> result = new List<Map<String,Object>>();
        for(SObject so : sobjects){
            Map<String,Object> soMap = new Map<String,Object>();
            for(String f : fields){
                soMap.put(f, so.get(f));
            }
            result.add(soMap);
        }
        return result;
    }

}
