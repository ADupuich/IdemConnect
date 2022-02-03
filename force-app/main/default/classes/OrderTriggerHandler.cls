public with sharing class OrderTriggerHandler {
    Order orderToWorkWith = new Order();
    public OrderTriggerHandler() {
        //sans doute avoir besoin d'un if ou try à cause du blovage généré par le trigger
        //attention trigger sur status Activated
        //si product alors update
        //sinon ne rien faire ou un print scrin pour voir l'erreur
    }
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
    public static void uncheckActiveOnAccount(Order orderToWorkWith) {
        //si la dernière order d'un compte est supprimé alors la case active de l'account en question et décoché
        List<Order> orderRelated = new List<Order>();
        orderRelated = [SELECT Id, Account.Active__c FROM order WHERE AccountId =: orderToWorkWith.AccountId];
        if (!orderRelated.isEmpty()) {
            //refaire le travail sur account
            Order orderWeNeed = orderRelated.get(0);
            orderWeNeed.Account.Active__c = false;
            update orderWeNeed;
        }

    }
}
