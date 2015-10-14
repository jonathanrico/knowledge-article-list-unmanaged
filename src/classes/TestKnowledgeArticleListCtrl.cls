@isTest
private class TestKnowledgeArticleListCtrl{

    static testMethod void testArticleList(){
        Test.startTest();
            List<KnowledgeArticleItem> result = KnowledgeArticleListCtrl.getRecords(4,'How_To');
            System.assert(result != null);
            System.assert(result.size() == 4);
        Test.stopTest();
    }

}
