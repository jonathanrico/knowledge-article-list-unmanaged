({

    getRecords : function(component){
        var maxresults = isNaN(component.get("v.maxresults"))? 10 : parseInt(component.get("v.maxresults"));
        var articletype = component.get("v.articletype");
        var sorttype = component.get("v.sortby");
        var filterbylang = component.get("v.filterByLanguage")==true;
        var a = component.get("c.getRecords");
        a.setParams({
          "maxResults": maxresults,
          "articleType": articletype,
          "sortByType": sorttype,
          "filterByLanguage": filterbylang
        });
        a.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set('v.articles',response.getReturnValue());
            } else {
                alert('Unable to fetch article records');
            }
        });
        $A.enqueueAction(a);
    },

    goToRecord : function(component, event){
        var article_id = event.target.dataset.articleid;
        var urlEvent = $A.get("e.force:navigateToSObject");
        urlEvent.setParams({
            "recordId": article_id
        });
        urlEvent.fire();
    }

})
