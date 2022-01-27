public with sharing class DataFactory {
    
    //Generate Accounts
    public static List<Account> createAccount(Integer nAccount) {
        List<Account> accountsForTest = new List<Account>();
        for (Integer i = 0; i<nAccount;i++){
            Account acc = new Account (Name = 'accountTest'+i);
            accountsForTest.add(acc);
        }
        insert accountsForTest;
        return accountsForTest;
    }

    //Generate Order
    public static List<Order> createOrder(List<Account> accountsToAddOrder) {
        List<Order> orders = new List<Order>();
        Id PricebookId = Test.getStandardPricebookId();
        for (Account a : accountsToAddOrder) {
            Order orderToAdd = new Order(
            AccountId = a.Id,
            EffectiveDate = Date.today() +7,
            Pricebook2Id = PricebookId);
            orders.add(orderToAdd);
        }
        insert orders;
        return orders;
    }
    public static Order oneOrder(Id accountId) {
        Id PricebookId = Test.getStandardPricebookId();
        Order order = new Order(
            AccountId = accountId,
            EffectiveDate = Date.today() +7,
            Pricebook2Id = PricebookId);
        insert order;
        return order;
    }
}
