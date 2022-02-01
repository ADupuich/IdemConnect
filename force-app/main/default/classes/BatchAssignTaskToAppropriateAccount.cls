global class BatchAssignTaskToAppropriateAccount implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext info){
        //affiner la selction des accounts pour ne prendre que les accounts depuis le dernier premier lundi du mois
        //faire une selection des accounts sans order ? et ou selection des accounts sans tâches ... comment faire
        return Database.QueryLocator('SELECT Id FROM Account');
    }

    global void execute(Database.BatchableContext info, List<Account>scope){
        BatchAssignTaskToAppropriateAccount.addTaskToAccounts(scope);
    }
    //possibilité de créer une classe de service pour mettre cette méthode
    public static void addTaskToAccounts(List<Account> accList) {
        List<Task> tskList = new List<Task>();
        for(Account a : accList) {
            if (a.field != null) {
                Task tsk = new Task();
                tsk.suject = 'Call';
                tsk.Status = 'Open';
                tsk.Priority = 'Normal';
                tsk.WhatId = a.Id;
                tsk.OwnerId = a.OwnerId;
                tskList.add(tsk);
            }
        if (tskList != null && tskList.size() > 0) {
            insert tskList;
            }
        }
    }
}