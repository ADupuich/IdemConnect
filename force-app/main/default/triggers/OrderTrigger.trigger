trigger OrderTrigger on ORDER (before update) {
    //mettre le trigger sur une liste pas sur une unité, raisonner avec les listes
    List<Order> orderListTriggering = new List<Order>();
    orderListTriggering = trigger.new;
    if(Trigger.isUpdate) {
        if(Trigger.isBefore){
            OrderTriggerHandler.doNotUpdateStatusWithoutOrderItem(orderListTriggering); 
        }
    }
    //faire attention au after / before si l'account-Id est bien capturé
    if (Trigger.isDelete) {
        
    }
}