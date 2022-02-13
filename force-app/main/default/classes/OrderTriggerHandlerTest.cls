@Istest
private class OrderTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        Integer nAccount = 3;
        DataFactory.createAccount(nAccount);
        //Add the value true to active checkbox
        List<Account> accountForTestTriggerHandler = new List<Account>();
        accountForTestTriggerHandler = [SELECT Id, Active__c FROM Account];
        for (account a : accountForTestTriggerHandler) {
            a.Active__c = true;
            update a;
        }
        //Create order for this account
        DataFactory.createOrder(accountForTestTriggerHandler);
    }
    @Istest
    private static void orderTriggerHandlerAfterDeleteTest() {
        Test.startTest();
        //For successfull test you need to make the LIMIT = nAccount of @TestSetup - 1
        List<Order> orderToDelete = new List<Order>([SELECT Id,AccountId FROM Order LIMIT 2]);
        //We are going to add one order on specific account here. We want to be sure that the trigger don't uncheck box when one order left on the account
        Order orderToTargetAccount = orderToDelete.get(0);
        Id accountTargetedId = orderToTargetAccount.AccountId;
        DataFactory.oneOrder(accountTargetedId);
        //The order has been added now. We have 11 orders that we are going to delete
        for (Order o : orderToDelete) {
            delete(o);            
        }
        Test.stopTest();
        //We are going to verify if we have some account with Active__c is false. We are expecting to find 10 accounts. I know we deleted 11 but on one account we added 1 order. 
        //So one order left on ths account and his checkbox must stay true
        List<Account> accountWithActiveFalse = new List<Account>([SELECT Id FROM Account WHERE Active__c = FALSE]);
        System.assert(accountWithActiveFalse.size() > 0, 'TRIGGER AFTER DELETE : There is no account with Active uncheck');
        System.assert(accountWithActiveFalse.size() == 1, 'TRIGGER AFTER DELETE : The number with active uncheck is wrong, there is '+accountWithActiveFalse.size()+' accounts');
        //To be sure check that we can find an order with the previous selected accountID
        List<Order> orderAddedBeforeDelete = new List<Order>([SELECT Id FROM Order WHERE AccountId =: accountTargetedId]);
        System.assert(orderAddedBeforeDelete.size() > 0, 'TRIGGER AFTER DELETE : There is no order with the 2 orders on the selected accountId');
        System.assert(orderAddedBeforeDelete.size() == 1, 'TRIGGER AFTER DELETE : We do not find the correct number of order on the 2 orders account. There is '+orderAddedBeforeDelete.size()+' orders.');
    }
    @Istest
    private static void orderTriggerHandlerBeforeUpdateTest() {
        Product2 testProduct = DataFactory.createProduct();
        //We choose the LIMIT equal to orders create in @TestSetup - 1 because we want that one order left with order but without product to check if the trigger stuck it
        List<Order> orderToAddItem = new List<Order>([SELECT Id, Pricebook2Id FROM Order LIMIT 2]);
        Order ordForPriceBookId = new Order();
        ordForPriceBookId = orderToAddItem.get(0);
        PricebookEntry Price = DataFactory.createPricebookEntry(ordForPriceBookId, testProduct);
        for (Order o : orderToAddItem) {
            OrderItem orderItem = DataFactory.createOrderItem(o, testProduct, Price);
        }
        Test.startTest();
        //Select all our orders and try to put there status in activated
        List<Order> orderChangingStatus = new List<Order>();
        orderChangingStatus = [SELECT Id, Status FROM Order];
        for (order o : orderChangingStatus) {
            o.Status = 'Actif';
            try{
                update o;
            } catch (Exception e){
                system.debug('exception : ' + e.getMessage()); 
            }
        }
        Test.stopTest();
        //If the trigger made the job we should find one order here
        List<Order> orderWithDraftStatus = new List<Order>();
        orderWithDraftStatus = [SELECT Id FROM Order WHERE Status = 'Draft'];
        System.assert(orderWithDraftStatus.size() == 1, 'TRIGGER BEFORE UPDATE : There is not the good number of drafted order, there is '+orderWithDraftStatus.size()+' order with Draft status');
        System.assert(orderWithDraftStatus.size() > 0, 'TRIGGER BEFORE UPDATE : There should be one or more orders with Draft Status');
    }
}
