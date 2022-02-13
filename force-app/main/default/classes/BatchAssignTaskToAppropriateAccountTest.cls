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
        List<Account> accountToAddTask = new List<Account>([SELECT Id, OwnerId FROM account LIMIT 25]);
        RecordingService.addTaskToAccounts(accountToAddTask);
        //What the other accounts the method won't selecting ? An account with order
        List<Account> accountToAddOrder = new List<Account>([SELECT Id FROM Account WHERE Id NOT IN :accountToAddTask LIMIT 25]);
        //offset mot clé !! <3
        DataFactory.createOrder(accountToAddOrder);
        //At this time I have 25 accounts with Task and 25 with orders
        //So I want to execute my Batch on the correct selected account List
        List<Account> accountWithoutTaskAndOrder = new List<Account>([SELECT Id FROM Account WHERE Id NOT IN :accountToAddTask AND Id  NOT IN :accountToAddOrder]);
            Test.startTest();
            BatchAssignTaskToAppropriateAccount batch = new BatchAssignTaskToAppropriateAccount();
            Database.executeBatch(batch);
            List<Task> lt =[SELECT Id FROM Task WHERE WhatId IN:accountWithoutTaskAndOrder];
            //Here is to be sure the Batch hasn't down the job already
            System.assertEquals(0, lt.size(), 'Task exist before job has run');
            Test.stopTest();
        //I actualize lt list
        lt =[SELECT Id FROM Task WHERE WhatId IN:accountWithoutTaskAndOrder];
        //now if the Bach down the job both lists size will be equal
        System.assertEquals(accountWithoutTaskAndOrder.size(),lt.size(),'Tasks were not created');
        }
    
    @isTest
    static void SchedulerAddTaskOnAccountTest() {
        //add some tasks for 25 accounts
        List<Account> accountToAddTask = new List<Account>([SELECT Id, OwnerId FROM account LIMIT 25]);
        RecordingService.addTaskToAccounts(accountToAddTask);
        //What the other accounts the method won't selecting ? An account with order
        List<Account> accountToAddOrder = new List<Account>([SELECT Id FROM Account WHERE Id NOT IN :accountToAddTask LIMIT 25]);
        //offset mot clé !! <3
        DataFactory.createOrder(accountToAddOrder);
        //At this time I have 25 accounts with Task and 25 with orders
        //So I want to execute my Batch on the correct selected account List
        List<Account> accountWithoutTaskAndOrder = new List<Account>([SELECT Id FROM Account WHERE Id NOT IN :accountToAddTask AND Id  NOT IN :accountToAddOrder]);
        // Dummy CRON expression: 5:00 AM first monday of month
            Test.startTest();
            // Schedule the test job
            String CRON_EXP = '0 0 5 ? 3 2#1';
            String JobId = System.schedule('ScheduledApexTest', CRON_EXP, new SchedulerAddTaskOnAccount());
            // Get the information from the CronTrigger API object 
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
            Test.stopTest();
        System.assertEquals(CRON_EXP, ct.CronExpression, 'The CRON expressions are not the same');
    }
}
