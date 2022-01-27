public with sharing class BatchAssignTaskToAppropriateAccount {
    public BatchAssignTaskToAppropriateAccount() {
            //Selector
            //methode de Batch
    }

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