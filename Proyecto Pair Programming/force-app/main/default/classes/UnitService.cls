public with sharing class UnitService {

    @AuraEnabled(cacheable = false)
    public static Boolean getUnitIds(Id unitId, String jsonAnswer) {

        // parseamos el jsonAnswer a un map.
        Map<Id, Id> questionsMap = (Map<Id, Id>) JSON.deserializeStrict(jsonAnswer, Map<Id, Id>.class);

        //Tengo un list que almacena los ids de mis options(respuestas de mis preguntas en list questions).
        List<Options__c> options = New List<Options__c>();


        //busco la unidad con el id "unitId" en la base de datos
        Unit__c unit = [SELECT module__c FROM Unit__c WHERE Id=:unitId];
        //busco el modulo relacionado con el id de unidad asociados al usuario, si no existe , signfica que es la primera pregunta , creo el UserModule
        //veo si existe el userModule , sino lo creo
        //uso userInfo.getUserId() para obtener el id del usuario actual
        UserModule__c module;
        try{
            module = [SELECT Id FROM UserModule__c WHERE Module__c = :unit.Module__c  AND User__c = :UserInfo.getUserId() AND Status__c = 'In Progress'];
            }catch (Exception e){

            module = new UserModule__c(User__c = userInfo.getUserId(),
            Module__c = unit.Module__c,
            Status__c = 'In Progress');
            insert module;
           } 
        //creo el UserUnit en estado draft
        UserUnit__c unitResp = new UserUnit__c(
            Unit__c = unitId,
            UserModule__c = module.Id,
            State__c = 'Draft',
            User__c = UserInfo.getUserId()
          );

          //Tengo un list que almacena los ids de mis questions.
        List<UserQuestion__c> questions = New List<UserQuestion__c>();

          for(Id q : questionsMap.keySet()) {
            // Código a ejecutar para cada key del mapa
            UserQuestion__c questionKey = new UserQuestion__c(Unit__c=unitId, Question__c=q);

            questions.add(questionKey);
        }

        unitResp.State__c = 'Answered';

        insert questions;

        update unitResp;

        // ATENCION --- Quizás deba hacer otra query para traerme el unitResp actualizado a Success.

        if(unitResp.State__c == 'Success'){
            return true;
        }else{
            return false;
        }
    }

    @AuraEnabled(cacheable = false)
    public static TrailWrapper getTrailWrapper(Id trailId) {
        TrailWrapper wrapper = new TrailWrapper();
        
        wrapper.trail = [SELECT Name, Description__c
                 FROM Trail__c 
                 WHERE Id = :trailId];
        
        // Obtener los registros de TrailModule__c que están relacionados con el trailId dado
        List<TrailModule__c> trailModules = [SELECT Module__c FROM TrailModule__c WHERE Trail__c = :trailId];

        List<Id> moduleIds = new List<Id>();
        for (TrailModule__c tm : trailModules) {
            moduleIds.add(tm.Module__c);
        }

        // Obtener los módulos relacionados a través de la relación Module__c en los registros de TrailModule__c
        //List<Module__c> modules = [SELECT Id, Name, Description__c FROM Module__c WHERE Id IN :moduleIds];
        List<Module__c> modules = [SELECT Id, Name, Description__c, Points__c, TotalTime__c, (SELECT Id, Name, Time__c, Points__c FROM Units__r) FROM Module__c WHERE Id IN :moduleIds];
        wrapper.modules = modules;

        List<UserUnit__c> userUnits = [SELECT Id, State__c, Unit__c FROM UserUnit__c WHERE Unit__c IN (SELECT Id FROM Unit__c WHERE Module__c IN :modules) AND User__c = :UserInfo.getUserId() AND State__c = 'Success'];

        Set<Id> passedModuleIds = new Set<Id>();
        Set<Id> passedUnitIds = new Set<Id>();

        // Iterar por los registros de UserUnit__c para obtener los módulos y unidades aprobadas
        for (UserUnit__c userUnit : userUnits) {
            passedModuleIds.add(userUnit.Unit__r.Module__c); // Agregar el Id del módulo aprobado al conjunto de passedModuleIds
            passedUnitIds.add(userUnit.Unit__c); // Agregar el Id de la unidad aprobada al conjunto de passedUnitIds
        }

        wrapper.passedModuleIds = passedModuleIds;
        wrapper.passedUnitIds = passedUnitIds;
    
        wrapper.progressTrail = Math.round((100.0 * passedUnitIds.size()) / wrapper.modules.size());
       
        return wrapper;
    }

    @AuraEnabled(cacheable = false)    
    public static UnitWrapper getUnitWrapper(Id unitId) {
        UnitWrapper wrapper = new UnitWrapper();
    
        // Query for Unit__c record and populate wrapper.unit
        wrapper.unit = [SELECT Id, Name, Time__c, Points__c, Content__c  FROM Unit__c WHERE Id = :unitId];

        // Query for related Question__c records and their related Options__c records and populate wrapper.questions
        wrapper.questions = [SELECT Id, Name, Content__c, (SELECT Id, Name, Content__c FROM Options__r) FROM Question__c WHERE Unit__c =: unitId];
    
        return wrapper;
    }
}

