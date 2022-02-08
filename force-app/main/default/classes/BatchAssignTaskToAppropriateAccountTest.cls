 @IsTest
 private class BatchAssignTaskToAppropriateAccountTest {
     @TestSetup
     static void makeData(){
         //Be carefull this variable numberOfAccount isn't yet initialise
         integer numberOfAccount = 15;
         DataFactory.createAccount(numberOfAccount);
     }
     @Istest
     static void BatchAssignTaskToAppropriateAccountTest(){
        //add some tasks for 25 accounts
        List<Account> accountToAddTask = new List<Account>();
        accountToAddTask = [SELECT Id, OwnerId FROM account LIMIT 5];
        //Here I don't want to test this method but it's an easier way to add task, don't it ?
        RecordingService.addTaskToAccounts(accountToAddTask);
        //Now normally, we have 25 accounts with task and I want to be sure there no wrong account selected
        //What the other accounts the method won't selecting ? An account with order
        //We are going to take 25 accounts that doon't have task
        List<Account> accountToAddOrder = new List<Account>([SELECT Id FROM Account WHERE Id NOT IN :accountToAddTask LIMIT 5]);
        //offset mot clé !! <3
        //We have 25 accounts, let add them order
        DataFactory.createOrder(accountToAddOrder);
        //At this time I have 25 accounts with Task and 25 with orders
        //So I want to execute my Batch on the correct selected account List 
        String CRON_DATE = '0 0 5 7 3 ? 2022';
        List<Account> accountWithoutTaskAndOrder = new List<Account>([SELECT Id FROM Account WHERE Id NOT IN :accountToAddTask AND Id  NOT IN :accountToAddOrder]);
        Test.startTest();
        BatchAssignTaskToAppropriateAccount batch = new BatchAssignTaskToAppropriateAccount();
        Database.executeBatch(batch);
        List<Task> lt =[SELECT Id FROM Task WHERE WhatId IN:accountWithoutTaskAndOrder];
        System.assertEquals(0, lt.size(), 'Task exist before job has run');
        Test.stopTest();
        //At this time all of our accounts have a task or an order. So we can compare them. If there is a difference something goes wrong with the batch 
        lt =[SELECT Id FROM Task WHERE WhatId IN:accountWithoutTaskAndOrder];
        //requeter pour une account avec task = 175
        System.assertEquals(accountWithoutTaskAndOrder.size(),
            lt.size(),
            'Tasks were not created');
        //J'aurai peut-être besoin d'une condition particulière pour contourner le soucis de date (premier lundi du mois) du batch
        }
    }
