public with sharing class UnitWrapper{
    @AuraEnabled
    public Unit__c unit; 
    @AuraEnabled
    public List<Question__c> questions;
}
