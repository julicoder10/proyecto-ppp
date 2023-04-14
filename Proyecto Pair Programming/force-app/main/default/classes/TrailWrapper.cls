public with sharing class TrailWrapper {

    @AuraEnabled
    public Trail__c trail;
    @AuraEnabled
    public Integer progressTrail;
    @AuraEnabled
    public List<Module__c> modules;
    
    public Set<Id> passedModuleIds;
    
    public Set<Id> passedUnitIds;

    @AuraEnabled
    public List<Id> getPassedModuleIds() {
        return new List<Id>(passedModuleIds);
    }
    
    @AuraEnabled
    public List<Id> getPassedUnitIds() {
        return new List<Id>(passedUnitIds);
    }
}
