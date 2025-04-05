// Le but de cette class est de fournir une méthode qui permet de récupérer les lignes de produits liées à une opportunité spécifique (OpportunityId)

public with sharing class OpportunityProductController {
  @AuraEnabled(cacheable=true)
  public static List<Map<String, Object>> getOpportunityProducts(
    Id opportunityId
  ) {
    // Vérifier si l'opportunité existe
    if (opportunityId == null) {
      throw new AuraHandledException(
        'L\'ID de l\'opportunité ne peut pas être null.'
      );
    }

    // Requête SOQL ==> récupèrer les lignes de produits associées à l'opportunité donnée. Chaque ligne de produit contient des informations comme le nom du produit, le prix unitaire, le prix total, la quantité en stock

    List<OpportunityLineItem> opportunityLineItem = [
      SELECT
        Product2.Id,
        Product2.Name,
        Unitprice,
        TotalPrice,
        Quantity,
        Product2.QuantityInStock__c
      FROM OpportunityLineItem
      WHERE opportunityId = :opportunityId
    ];

    // liste pour stocker les informations des produits, contient tous les productInfo ...
    List<Map<String, Object>> productDetails = new List<Map<String, Object>>();

    // Parcours des lignes de produits pour ajouter les informations dans une map
    for (OpportunityLineItem oli : opportunityLineItem) {
      Map<String, Object> productInfo = new Map<String, Object>();
      productInfo.put('productName', oli.Product2.Name);
      productInfo.put('unitPrice', oli.Unitprice);
      productInfo.put('totalPrice', oli.TotalPrice);
      productInfo.put('quantity', oli.Quantity);
      productInfo.put('quantityInStock', oli.Product2.QuantityInStock__c);
      productInfo.put('productId', oli.Product2.Id); // Ajout de l'ID du produit
      productDetails.add(productInfo);
    }
    return productDetails;
  }
}
