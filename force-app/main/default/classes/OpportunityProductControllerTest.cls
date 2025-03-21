@isTest
private class OpportunityProductControllerTest {

    @TestSetup
    static void setup() {

        // Créer un produit 
        Product2 product = new Product2(Name = 'Test Product', QuantityInStock__c = 100);
        insert product;

        // méthode spéciale fournie native qui retourne l'ID du Pricebook standard de l'organisation
        Id standardPricebookId = Test.getStandardPricebookId();
       
        // Créer une PricebookEntry avec un prix standard
        PricebookEntry pbeStandard = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = product.Id,
            UnitPrice = 50, // Prix unitaire
            IsActive = true
        );
        insert pbeStandard;

        // Créer une opportunité simple
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Pricebook2Id = standardPricebookId // Pricebook standard
        );
        insert opp;

        // Créer une OpportunityLineItem avec un produit et un prix standard
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbeStandard.Id, 
            Quantity = 2,
            UnitPrice = 50,
            Product2Id = product.Id
        );
        insert oli;
    }

       @isTest
    public static void getOpportunityProductsTest(){
        Opportunity OppTest = [SELECT ID FROM Opportunity WHERE Name = 'Test Opportunity'limit 1];

        Test.startTest();
           List<Map<String, Object>> result=OpportunityProductController.getOpportunityProducts(OppTest.Id);
        Test.stopTest();

        Assert.areEqual(true,result!=null);
       }

        // Possibilité de rajouter  : 
        // Assert.areEqual(true, !result.isEmpty(), 'La liste des produits ne doit pas être vide');
        // Assert.areEqual('Ordinateur', result[0].get('ProductName'), 'Le premier produit doit être un Ordinateur');
        // Assert.areEqual(1000.0, result[0].get('UnitPrice'), 'Le prix unitaire doit être 1000.0');
        // Assert.areEqual(2, result[0].get('Quantity'), 'La quantité doit être 2');

}