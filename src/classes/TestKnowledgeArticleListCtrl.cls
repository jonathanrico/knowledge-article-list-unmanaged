@isTest
private class TestKnowledgeArticleListCtrl{

    static testMethod void testArticleList(){
        Test.startTest();
            List<KnowledgeArticleItem> result = KnowledgeArticleListCtrl.getRecords(6,'How_To','Rating');
            System.assert(result != null);
            System.assert(result.size() == 6);
        Test.stopTest();
    }

}
