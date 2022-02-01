 @IsTest
 private class BatchAssignTaskToAppropriateAccountTest {
     @TestSetup
     static void makeData(){
         //Be carefull this variable numberOfAccount isn't yet initialise
         integer numberOfAccount = 200;
         DataFactory.createAccount(numberOfAccount);
     }
     @Istest
     static void BatchAssignTaskToAppropriateAccountTest(){
        //add some tasks for 25 accounts
        List<Account> accountToAddTask = new List<Account>();
        accountToAddTask = [SELECT Id, OwnerId FROM account LIMIT 25];
        //be sure the program selected 25 accounts
        System.debug(accountToAddTask.size());
        //Here I don't want to test this method but it's an easier way to add task, don't it ?
        BatchAssignTaskToAppropriateAccount.addTaskToAccounts(accountToAddTask);
        //Now normally, we have 25 accounts with task and I want to be sure there no wrong account selected
        //What the other accounts the method won't selecting ? An account with order
        //We are going to take 25 accounts that doon't have task
        ListToAddOrder = new List<Account>();
        //offset mot clé !! <3
        accountsToAddOrder = [SELECT Id FROM Account WHERE Id !=: accountToAddTask.Id LIMIT 25];
        //be sure the program selected 25 accounts
        System.debug(accountToAddOrder.size());
        //We have 25 accounts, let add them order
        DataFactory.createOrder(accountsToAddOrder);
        //At this time I have 25 accounts with Task and 25 with orders
        //So I want to execute my Batch on the correct selected account List 
        Test.startTest();
        BatchAssignTaskToAppropriateAccount.runBatch();
        Test.stopTest();
        //At this time all of our accounts have a task or an order. So we can compare them. If there is a difference something goes wrong with the batch 
        List<Task> tasksList = new List<Task>();
        tasksList = [SELECT WhatId FROM Task];
        Integer tasksListSize = tasksList.size();
        List<Account> accountsList = new List<Account>();
        accountsList = [SELECT Id FROM Account];
        Integer accountsListSize = accountsList.size();
        Integer accountToAddOrderSize = accountToAddOrder.size();
        //requeter pour une account avec task = 175
        System.assert(0 == accountsListSize - (accountToAddOrderSize + tasksListSize), 'The number of accounts does not match with the account with task + order, the difference equal to'+accountsListSize - accountToAddOrderSize + tasksListSize);
        //J'aurai peut-être besoin d'une condition particulière pour contourner le soucis de date (premier lundi du mois) du batch
        }
    }
