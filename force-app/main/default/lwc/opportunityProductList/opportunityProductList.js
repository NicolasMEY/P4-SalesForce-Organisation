import { LightningElement, track } from "lwc";

export default class OpportunityProductList extends LightningElement {
  @track products = []; // Liste des produits
  @track columns = [
    { label: "Nom du produit", fieldName: "name" },
    { label: "Quantité", fieldName: "quantity" },
    { label: "Prix unitaire", fieldName: "unitPrice" },
    { label: "Prix Total", fieldName: "totalPrice" },
    { label: "Quantité en Stock", fieldName: "stockQuantity" },
    {
      label: "Supprimer",
      type: "button",
      typeAttributes: {
        label: "Supprimer",
        name: "delete",
        variant: "destructive"
      }
    },
    {
      label: "Voir produit",
      type: "button",
      typeAttributes: {
        label: "Voir produit",
        name: "view",
        variant: "neutral"
      }
    }
  ];
}
