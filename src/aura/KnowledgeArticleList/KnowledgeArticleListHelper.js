({

    getRecords : function(component){
        var a = component.get("c.getRecords");
        a.setCallback(this, function(action) {
            if (action.getState() === "SUCCESS") {
                component.set('v.articles',action.getReturnValue());
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
