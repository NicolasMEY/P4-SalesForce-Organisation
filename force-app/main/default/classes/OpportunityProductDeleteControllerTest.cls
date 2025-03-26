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

    // Méthode spéciale qui retourne l'ID du Pricebook standard
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

    // Créer une OpportunityLineItem avec le produit et le prix standard
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
    // Récupérer l'Opportunity insérée dans le setup
    Opportunity opp = [
      SELECT Id
      FROM Opportunity
      WHERE Name = 'Test Opportunity'
      LIMIT 1
    ];

    // Récupérer l'OpportunityLineItem inséré dans le setup
    List<OpportunityLineItem> oliList = [
      SELECT Id
      FROM OpportunityLineItem
      WHERE OpportunityId = :opp.Id
      LIMIT 1
    ];

    // Vérifier si l'OpportunityLineItem existe
    System.assertEquals(
      oliList.size(),
      1,
      'L\'OpportunityLineItem n\'a pas été inséré correctement.'
    );

    OpportunityLineItem oliToDelete = oliList[0]; // Récupérer l'OpportunityLineItem à supprimer

    Test.startTest();
    // Appeler la méthode de suppression
    OpportunityProductDeleteController.deleteOpportunityProduct(oliToDelete.Id);
    Test.stopTest();

    // Vérifier que la ligne de produit a été supprimée
    List<OpportunityLineItem> deletedOli = [
      SELECT Id
      FROM OpportunityLineItem
      WHERE Id = :oliToDelete.Id
    ];

    // Vérifier que l'OpportunityLineItem n'existe plus
    System.assertEquals(
      deletedOli.size(),
      0,
      'La ligne de produit n\'a pas été supprimée.'
    );
  }
}
