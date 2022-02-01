public with sharing class OrderTriggerHandler {
    Order orderToWorkWith = new Order();
    public OrderTriggerHandler() {
        //sans doute avoir besoin d'un if ou try à cause du blovage généré par le trigger
        //attention trigger sur status Activated
        //si product alors update
        //sinon ne rien faire ou un print scrin pour voir l'erreur
    }
    public static void doNotUpdateStatusWithoutOrderItem(List<Order> orderToWorkWith) {
        //Comparer les trigger.old et trigger.new
        Map<Id,Order> orderWithItemMap = new Map<Id,Order>([SELECT Id, (SELECT Id FROM OrderItems WHERE OrderId IN :orderToWorkWith) FROM Order]);
        for (Order ord : orderToWorkWith) {
            if (orderWithItemMap.containsKey(ord.Id)) {
                Order oldOrder = (Order)Trigger.oldMap.get(ord.Id);
                if (oldOrder.Status != ord.Status) {
                    //vérifier que l'order a des order items
                        ord.Status = 'Actif';
                        update ord;               
                } else {
                    update ord;
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Vous ne pouvez pas mettre à jour le statut d\'/une commande qui ne possède pas de produits. Ajoutez des produits et réessayez svp.'));
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
