// Le but de cette class est de fournir une méthode qui permet de récupérer les produits associés à une opportunité

public with sharing class OpportunityProductController {
@AuraEnabled(cacheable=true)

public static List<OpportunityLineItem> getOpportunityProducts(Id opportunityId) {
    // Vérifier si l'opportunity existe
    if (opportunityId == null) {
        throw new AuraHandledException('L\'ID de l\'opportunité ne peut pas être null.');
    }
 // On récupère les lignes de produits associées à l'opportunité donnée. Chaque ligne de produit contient des informations comme le nom du produit, le prix unitaire, le prix total, la quantité en stock
 List<OpportunityLineItem> products = [SELECT Product2.Name, Unitprice, TotalPrice, Quantity, QuantityInStock__c FROM OpportunityLineItem WHERE opportunityId = :opportunityId];
 // Enfin on retourne la liste des lignes de produits associées à l'opportunité
 return products;
}

}