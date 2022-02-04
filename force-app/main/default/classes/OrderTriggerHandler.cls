public with sharing class OrderTriggerHandler {

    public static void doNotUpdateStatusWithoutOrderItem(List<Order> orderToWorkWith) {
        //Vérifier que les order ont des orderItem
        //Dans un premier temps aller chercher les orderItem et leur OrderId dont l'order à déclencher le trigger
        List<OrderItem> ordItemList = new list<OrderItem>([SELECT Id, OrderId FROM OrderItem WHERE OrderId IN :orderToWorkWith]);
        //Je classe ces Orders dans une map pour utiliser la méthode containskey ultérieurement
        Map<Id,Order> orderWithItemMap = new Map<Id,Order>();
        for (OrderItem oi : ordItemList) {
            Order orderWithItem = new Order(Id = oi.OrderId);
            orderWithItemMap.put(orderWithItem.Id,orderWithItem);
        }
        for (Order ord : orderToWorkWith) {
            Order oldOrder = (Order)Trigger.oldMap.get(ord.Id);
            if (!orderWithItemMap.containsKey(ord.Id) && oldOrder.Status == 'Draft' && ord.Status == 'Actif') {
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
        List<Order> orderOnRelatedAccount = new List<Order>([SELECT Id, AccountId FROM Order WHERE AccountId IN :relatedAccountId]);
        //And I put them in a map to use containskey method after
        Map<Id,Account> accountWithOrder = new Map<Id,Account>();
        for (Order o : orderOnRelatedAccount) {
            Account accToAddInMap = new Account();
            accountWithOrder.put(o.AccountId, accToAddInMap);
        }
        //Here I can compare accounts triggered and accounts triggered with order
        for (Account acc : relatedAccount) {
            if (!accountWithOrder.containsKey(acc.Id)) {
                acc.Active__c = false;
                update relatedAccount;
            }
        }
    }
}
