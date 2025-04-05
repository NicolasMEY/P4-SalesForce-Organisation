@isTest
private class OpportunityProductDeleteControllerTest {
  @TestSetup
  static void setup() {
    // Créer un produit
    Product2 product = new Product2(
      Name = 'Test Product',
      QuantityInStock__c = 100
    );
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
  public static void testDeleteOpportunityProduct() {
    // Récupérer l'OpportunityLineItem inséré dans le setup
    OpportunityLineItem oliToDelete = [
      SELECT Id, Product2Id
      FROM OpportunityLineItem
      WHERE Product2Id IN (SELECT Id FROM Product2 WHERE Name = 'Test Product')
      LIMIT 1
    ];

    Test.startTest();
    // Appeler la méthode de suppression avec le Product2Id
    OpportunityProductDeleteController.deleteOpportunityProduct(
      oliToDelete.Product2Id
    );
    Test.stopTest();

    // Vérifier que la ligne de produit a bien été supprimée
    Integer count = [
      SELECT COUNT()
      FROM OpportunityLineItem
      WHERE Id = :oliToDelete.Id
    ];
    System.assertEquals(
      0,
      count,
      'La ligne de produit n\'a pas été supprimée.'
    );
  }
}
