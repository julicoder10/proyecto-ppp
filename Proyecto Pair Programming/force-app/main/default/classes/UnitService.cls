public with sharing class UnitService {

    public static void getUnitIds(Id unitId, String jsonAnswer) {

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

        insert questions;
    }

}

