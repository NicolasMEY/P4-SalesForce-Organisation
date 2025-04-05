public with sharing class OpportunityProductDeleteController {
  @AuraEnabled
  public static void deleteOpportunityProduct(Id productId) {
    OpportunityLineItem oliToDelete = [
      SELECT Id
      FROM OpportunityLineItem
      WHERE Product2Id = :productId
      LIMIT 1
    ];

    // Suppression de la ligne de produit
    delete oliToDelete;
  }
}
