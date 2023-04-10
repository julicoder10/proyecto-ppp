public with sharing class triggerController {

    public static void checkQnA(List<UserUnit__c> newUserUnits, Map<Id, UserUnit__c> oldUserUnits) {
        
        Map<Id, String> unitResults = new Map<Id, String>(); // Map para almacenar los resultados de las comprobaciones de las respuestas
        
        List<UserUnit__c> answeredUnits = new List<UserUnit__c>(); // Lista para almacenar los UserUnit__c que fueron respondidos
        
        for (UserUnit__c newUserUnit : newUserUnits) {
            UserUnit__c oldUserUnit = oldUserUnits.get(newUserUnit.Id);
            if (newUserUnit.State__c == 'Answered' && oldUserUnit.State__c == 'Draft') {
                answeredUnits.add(newUserUnit);
            }
        }
        
        if (!answeredUnits.isEmpty()) {
            List<UserOption__c> userOptions = [SELECT Option__r.Correct__c, UserQuestion__r.UserUnit__c FROM UserOption__c WHERE UserQuestion__r.UserUnit__c IN :answeredUnits];
            

            // Creo un for para recorrer las options filtradas por unit.
            for (UserOption__c userOption : userOptions) {
                if (userOption.Option__r.Correct__c && unitResults.get(userOption.UserQuestion__r.UserUnit__c) != 'Fail') {
                    // Si la opción es correcta y el resultado no es Fail, se asigna el valor Success
                    unitResults.put(userOption.UserQuestion__r.UserUnit__c, 'Success');

                } else {
                    // Si la opción es incorrecta o el resultado ya es Fail, se asigna el valor Fail
                    unitResults.put(userOption.UserQuestion__r.UserUnit__c, 'Fail');
                }
            }
            
            // Actualizar el estado de los UserUnit__c en base a los resultados almacenados en el Map
            List<UserUnit__c> userUnitsToUpdate = new List<UserUnit__c>();
            for (UserUnit__c answeredUnit : answeredUnits) {
                answeredUnit.State__c = unitResults.get(answeredUnit.Id);
                userUnitsToUpdate.add(answeredUnit);
            }
            update userUnitsToUpdate;
        }
    }
}
