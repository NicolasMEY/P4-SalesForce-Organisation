@isTest
private class OpportunityProductControllerTest {
    @isTest
    static void testGetOpportunityProducts() {
        
        // Création de données de test
        Product2 product = new Product2(Name = 'Test Product', QuantityInStock__c = 100);
        insert product;

        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
        insert opp;

        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, Product2Id = product.Id, Quantity = 2, UnitPrice = 50, TotalPrice = 100);
        insert oli;

        // Appel de la méthode Apex
        Test.startTest();
        List<Map<String, Object>> result = OpportunityProductController.getOpportunityProducts(opp.Id);
        Test.stopTest();

        // Vérifications
        System.assertNotEquals(0, result.size(), 'Il doit y avoir des produits associés à cette opportunité.');
        System.assertEquals('Test Product', result[0].get('productName'), 'Le nom du produit doit être "Test Product".');
        System.assertEquals(50, result[0].get('unitPrice'), 'Le prix unitaire doit être 50.');
        System.assertEquals(100, result[0].get('totalPrice'), 'Le prix total doit être 100.');
        System.assertEquals(2, result[0].get('quantity'), 'La quantité doit être 2.');
        System.assertEquals(100, result[0].get('quantityInStock'), 'La quantité en stock doit être 100.');
    }
}










