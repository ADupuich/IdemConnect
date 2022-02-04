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
            Pricebook2Id = PricebookId,
            Status ='Draft');
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
            Pricebook2Id = PricebookId,
            Status = 'Draft');
        insert order;
        return order;
    }
    public static Product2 createProduct() {
        Product2 testProduct = new Product2(
            Name = 'produit test', 
            Family = 'Testeur');
            insert testProduct;
            return testProduct;
    }
    public static PricebookEntry createPricebookEntry(Order o, Product2 p) {
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = o.Pricebook2Id,
            Product2Id = p.Id,
            UnitPrice = 1,
            IsActive = true,
            UseStandardPrice = false);
        insert standardPrice;
        return standardPrice;
    }
    public static OrderItem createOrderItem(Order o, Product2 p, PricebookEntry pbe) {
        OrderItem oi = new OrderItem(
            OrderId = o.Id,
            Product2Id = p.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice =1);
        insert oi;
        return oi;  
    }
}
