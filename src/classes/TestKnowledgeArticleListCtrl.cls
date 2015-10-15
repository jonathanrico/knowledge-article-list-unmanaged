@isTest
private class TestKnowledgeArticleListCtrl{

    static testMethod void testArticleList(){
        Test.startTest();
            List<KnowledgeArticleItem> result = KnowledgeArticleListCtrl.getRecords(1,'How_To','Rating', false);
            System.assert(result != null);
            System.assert(result.size() == 1);
        Test.stopTest();
    }

    static testMethod void testSObjectToMapConversion(){
        Test.startTest();
            Account dummyAccount = new Account();
            dummyAccount.Name = 'TestAccount';
            List<Map<String,Object>> result = KnowledgeArticleListCtrl.sObjectsToMap(new List<Account>{dummyAccount}, new Set<String>{'Name'});
            System.assert(result != null);
            System.assert(result.size() == 1);
        Test.stopTest();
    }

}
