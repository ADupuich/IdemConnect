public with sharing class OrderTriggerHandler {

    public static void doNotUpdateStatusWithoutOrderItem(List<Order> orderToWorkWith) {
        //Check if the Order are related to an orderItem. 
        //In first time we are getting the orderId frem ItemOrder Related to the order in the trigger
        //In this Set I have only Id with orders that have orderItem
        Set<Id> ordWithItemIdSet = new Set<Id>();
        for (orderItem oi : [SELECT Id, OrderId FROM OrderItem WHERE OrderId IN :orderToWorkWith]) {
            ordWithItemIdSet.add(oi.OrderId);
        }
        //And I can check if orders in Trigger has orderItem or Not
        for (Order ord : orderToWorkWith) {
            //Here is the second condition to trigger, we want the trigger goes only if before status was Draft and actual is Actif
            //That's why I catch the order value in before triggering
            Order oldOrder = (Order)Trigger.oldMap.get(ord.Id);
            //Now I can write my full condition
            if (!ordWithItemIdSet.contains(ord.Id) && oldOrder.Status == 'Draft' && ord.Status == 'Actif') {
                ord.addError('Vous ne pouvez pas mettre à jour le statut d\'une commande qui ne possède pas de produits. Ajoutez des produits et réessayez svp.');
            }
        }
    }
    public static void uncheckActiveOnAccount(List<Order> orderToWorkWith) {
        //Firstly I want to know wich Account are triggering
        List<Id> relatedAccountId = new List<Id>();
        for (order o : orderToWorkWith) {
            relatedAccountId.add(o.AccountId);
        }
        //And put them in List of Account involved in trigger
        List<Account> relatedAccount = new List<Account>([SELECT Id, Active__c FROM Account WHERE ID IN :relatedAccountId]);
        //Now I need to request if there other orders on this account
        List<Order> orderOnRelatedAccount = new List<Order>([SELECT Id, AccountId, Account.Active__c FROM Order WHERE AccountId IN :relatedAccountId]);
        //And I put them in a map to use containskey method after
        Map<Id,Account> accountWithOrder = new Map<Id,Account>();
        for (Order o : orderOnRelatedAccount) {
            accountWithOrder.put(o.AccountId, o.Account);
        }
        //Here I can compare accounts triggered and accounts triggered with order
        List<Account> accToUpdate = new List<Account>();
        for (Account acc : relatedAccount) {
            if (!accountWithOrder.containsKey(acc.Id)) {
                acc.Active__c = false;
                accToUpdate.add(acc);
            }
        }
        if (!accToUpdate.isEmpty()) {
            update accToUpdate; 
        }
     
    }
}
