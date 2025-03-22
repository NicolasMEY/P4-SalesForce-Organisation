import { LightningElement, track, api, wire } from "lwc";
import getOpportunityProducts from "@salesforce/apex/OpportunityProductController.getOpportunityProducts";

export default class OpportunityProductList extends LightningElement {
  @api recordId; // ID de l'opportunité
  error; // Pour stocker l'erreur, s'il y en a
  @track products = []; // Liste des produits
  @track columns = [
    { label: "Nom du produit", fieldName: "productName" },
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

  // Il manque la gestion des buttons delete et voir produit

  // il manque la récupération des datas au niveau de la class APEX

  @wire(getOpportunityProducts, { opportunityId: "$recordId" })
  wiredProducts({ data, error }) {
    if (data) {
      // Si la donnée est récupérée, on la stocke dans 'products'
      this.products = data;
      this.error = undefined; // Réinitialiser l'erreur si la récupération est réussie
    } else if (error) {
      // En cas d'erreur, afficher l'erreur
      this.error = error;
      this.products = [];
    }
  }
}
