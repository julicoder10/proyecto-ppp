trigger UnitResponse on UserUnit__c (before update) {
    triggerController.checkQnA(Trigger.new, Trigger.oldMap);
}