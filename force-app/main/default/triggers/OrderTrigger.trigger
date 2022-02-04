trigger OrderTrigger on ORDER (before update, after delete) {
    //mettre le trigger sur une liste pas sur une unité, raisonner avec les listes
    if(Trigger.isUpdate) {
        OrderTriggerHandler.doNotUpdateStatusWithoutOrderItem(Trigger.new); 
    }
    //faire attention au after / before si l'account-Id est bien capturé
    if (Trigger.isDelete) {
        OrderTriggerHandler.uncheckActiveOnAccount(Trigger.old);
    }
}