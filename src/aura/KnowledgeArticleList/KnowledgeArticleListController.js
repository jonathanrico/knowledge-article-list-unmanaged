({
    doInit : function(component, event, helper) {
      helper.getRecords(component);
    },

    goToRecord : function(component, event, helper){
        helper.goToRecord(component, event);
    }
})
