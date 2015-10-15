public with sharing class KnowledgeArticleItem{

    @AuraEnabled  public String Id {get;set;}
    @AuraEnabled  public String kaId {get;set;}
    @AuraEnabled  public String Title {get;set;}
    @AuraEnabled  public Integer Rating {get;set;}

    public KnowledgeArticleItem(){}

}
