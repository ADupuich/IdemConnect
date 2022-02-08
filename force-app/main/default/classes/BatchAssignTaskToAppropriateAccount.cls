public with sharing class BatchAssignTaskToAppropriateAccount implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext info){
        //affiner la selction des accounts pour ne prendre que les accounts depuis le dernier premier lundi du mois
        //faire une selection des accounts sans order ? et ou selection des accounts sans tâches ... comment faire
        Set<Id> taskWhatIDs = new Set<Id>();
        for (Task t : [SELECT WhatId FROM Task WHERE What.type = 'Account']) {
            taskWhatIDs.add(t.whatId);
        }
        return Database.getQueryLocator([SELECT Id, OwnerId FROM Account WHERE Id NOT IN (SELECT AccountId FROM Order) AND Id NOT IN :taskWhatIDs]);
    }
    public void execute(Database.BatchableContext info, List<Account>scope){
        RecordingService.addTaskToAccounts(scope);
    }
    //possibilité de créer une classe de service pour mettre cette méthode
    public void finish(Database.BatchableContext info){
	}
}