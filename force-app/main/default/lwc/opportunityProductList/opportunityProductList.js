import { LightningElement, api, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getOpportunityProducts from "@salesforce/apex/OpportunityProductController.getOpportunityProducts";
import deleteOpportunityProduct from "@salesforce/apex/OpportunityProductDeleteController.deleteOpportunityProduct";
import getUserProfile from "@salesforce/apex/UserProfileController.getUserProfile";

export default class OpportunityProductList extends LightningElement {
  @api recordId; // ID de l'opportunité
  error;
  products = []; // Liste des produits
  userRole; // Variable pour stocker le rôle de l'utilisateur

  columns = [
    { label: "Nom du produit", fieldName: "productName" },
    {
      label: "Quantité",
      fieldName: "quantity",
      cellAttributes: { class: { fieldName: "stockWarning" } }
    },
    { label: "Prix unitaire", fieldName: "unitPrice" },
    { label: "Prix Total", fieldName: "totalPrice" },
    {
      label: "Quantité en Stock",
      fieldName: "quantityInStock"
    },
    {
      label: "Supprimer",
      type: "button-icon",
      fieldName: "delete",
      typeAttributes: {
        iconName: "utility:delete",
        name: "delete",
        variant: "neutral",
        alternativeText: "Supprimer",
        "data-id": { fieldName: "Id" } // Permet de passer l'ID du produit dans chaque ligne
      }
    },
    {
      label: "Voir produit",
      type: "button",
      fieldName: "view",
      typeAttributes: {
        label: "View product",
        iconName: "utility:preview",
        name: "view",
        variant: "brand"
      },
      // On conditionne l'affichage du bouton en fonction du rôle de l'utilisateur
      hidden: false // Initialement visible, on part du principe que c'est l'admin qui esrt connecté
    }
  ];

  // Récupérer les produits de l'opportunité, stockés dans "products"
  @wire(getOpportunityProducts, { opportunityId: "$recordId" })
  wiredProducts({ data, error }) {
    if (data) {
      this.products = data.map((product) => {
        console.log("Row data:", product);
        return {
          ...product,
          productId: product.productId,
          stockWarning:
            product.quantityInStock - product.quantity < 0
              ? "slds-text-color_error"
              : "slds-text-color_success"
        };
      });
      // Vérifier si au moins un produit a une quantité insuffisante
      const hasQuantityIssues = this.products.some(
        (product) => product.quantityInStock - product.quantity < 0
      );
      // Si des produits ont un problème de quantité, afficher un message d'avertissement
      if (hasQuantityIssues) {
        this.showWarningMessage = true;
      } else {
        this.showWarningMessage = false;
      }

      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.products = [];
    }
  }

  // return true si des produits son récupérés
  get hasProductsOnOpportunity() {
    return this.products.length > 0;
  }

  // Appel pour récupérer le rôle de l'utilisateur connecté
  @wire(getUserProfile, { userId: "$userId" })
  wiredUserProfile({ data, error }) {
    if (data) {
      this.userRole = data; // Le rôle de l'utilisateur est récupéré
    } else if (error) {
      console.error("Erreur lors de la récupération du rôle:", error);
    }
  }

  handleRowAction(event) {
    // Récupérer le nom de l'action (view, delete, etc.)
    const actionName = event.detail.action.name;
    // Récupérer les données de la ligne sur laquelle l'action a été effectuée
    const row = event.detail.row;
    // Afficher les données de la ligne pour vérifier la structure
    console.log("Données de la ligne complète:", row);
    // Essayer de récupérer l'ID du produit (productId ou id selon la strcuture du champs)
    const productId = row.productId || row.id;

    // Vérifier si l'ID est bien défini
    if (productId) {
      // Si l'action est "view", rediriger vers la page produit
      if (actionName === "view") {
        this.handleViewProduct(productId);
      }
      // Si l'action est "delete", appeler la méthode pour supprimer
      else if (actionName === "delete") {
        console.log("Tentative de suppression du produit avec ID :", productId);
        this.handleDeleteProduct(productId);
      }
    } else {
      console.log("Erreur : ID du produit manquant dans l'événement");
    }
  }

  // Supprimer un produit
  handleDeleteProduct(productId) {
    if (!productId) {
      return;
    }
    // Supprimer le produit localement d'abord
    const originalProducts = [...this.products];
    this.products = this.products.filter(
      (product) => product.productId !== productId
    );
    // Effectuer la suppression côté serveur en arrière-plan
    deleteOpportunityProduct({ productId })
      .then(() => {
        console.log("Produit supprimé côté serveur");
        // Rafraîchir les données de produits liés dans "Related"
        return refreshApex(this.wiredRelatedProducts);
      })
      .then(() => {
        console.log("Produits dans la section 'Related' rafraîchis");
      })
      .catch((error) => {
        console.error("Erreur lors de la suppression du produit :", error);
        // Si l'appel échoue, restaurer l'élément dans la liste
        this.products = originalProducts;
      });
  }

  // Migration vers une page produit
  handleViewProduct(productId) {
    if (productId) {
      window.location.href = `/lightning/r/Product2/${productId}/view`;
    } else {
      console.log("Produit non valide, ID manquant");
    }
  }

  // Méthode pour vérifier si le bouton "Voir produit" doit être caché
  // Si l'utilisateur est un Commercial ou un Utilisateur standard, on cache le bouton
  get hideViewButton() {
    return (
      this.userRole === "Commercial" || this.userRole === "Utilisateur standard"
    );
  }

  // Message si la liste est vide
  get noProductMessage() {
    return this.userLanguage === "fr"
      ? "Aucun produit n’est présent pour le moment."
      : "No product available on the opportunity.";
  }

  // Affichage d'une case en rouge si la quantité en stock - la quantité actuelle est inférieure à 0
  get stockClass() {
    return this.products.some((product) => product.stockQuantity < 0)
      ? "slds-text-color_error"
      : "";
  }
}
