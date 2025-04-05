// -----------------------------
// IMPORTATIONS DES MODULES LWC ET APEX
// -----------------------------
import { LightningElement, api, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getOpportunityProducts from "@salesforce/apex/OpportunityProductController.getOpportunityProducts";
import deleteOpportunityProduct from "@salesforce/apex/OpportunityProductDeleteController.deleteOpportunityProduct";
import getUserProfile from "@salesforce/apex/UserProfileController.getUserProfile";
import USER_ID from "@salesforce/user/Id";
// -----------------------------
// IMPORTATIONS DES LABELS PERSONNALISÉS
// -----------------------------
import LABEL_Quantity_Problem_Message from "@salesforce/label/c.Quantity_Problem_Message";
import LABEL_Opportunity_Products from "@salesforce/label/c.Opportunity_Products";
import LABEL_No_Product_Lines_Message from "@salesforce/label/c.No_Product_Lines_Message";
import LABEL_Product_Name from "@salesforce/label/c.Product_Name";
import LABEL_Quantity from "@salesforce/label/c.Quantity";
import LABEL_Unit_Price from "@salesforce/label/c.Unit_Price";
import LABEL_Total_Price from "@salesforce/label/c.Total_Price";
import LABEL_Quantity_in_stock from "@salesforce/label/c.Quantity_in_stock";
import LABEL_See_product from "@salesforce/label/c.See_product";
import LABEL_Delete from "@salesforce/label/c.Delete";

export default class OpportunityProductList extends LightningElement {
  // -----------------------------
  // PROPRIÉTÉS PUBLIQUES ET INTERNES
  // -----------------------------
  @api recordId; // ID de l'opportunité
  // @api userId; // ID de l'utilisateur, passer via @api
  error;
  products = []; // Liste des produits
  userRole; // Variable pour stocker le rôle de l'utilisateur
  userId = USER_ID; // Utiliser l'ID de l'utilisateur connecté
  isDataLoaded = false; // Flag pour éviter les appels multiples
  showWarningMessage = false; // Initialisation de la variable pour l'avertissement

  // -----------------------------
  // OBJET DE LABELS POUR UTILISATION DANS LE TEMPLATE
  // -----------------------------
  labels = {
    quantityProblemMessage: LABEL_Quantity_Problem_Message,
    opportunityProducts: LABEL_Opportunity_Products,
    noProductLinesMessage: LABEL_No_Product_Lines_Message
  };
  // -----------------------------
  // DÉFINITION DES COLONNES POUR LA DATATABLE
  // -----------------------------
  columns = [
    { label: LABEL_Product_Name, fieldName: "productName" },
    {
      label: LABEL_Quantity,
      fieldName: "quantity",
      cellAttributes: { class: { fieldName: "stockWarning" } }
    },
    { label: LABEL_Unit_Price, fieldName: "unitPrice" },
    { label: LABEL_Total_Price, fieldName: "totalPrice" },
    {
      label: LABEL_Quantity_in_stock,
      fieldName: "quantityInStock"
    },
    {
      label: LABEL_Delete,
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
      label: LABEL_See_product,
      type: "button",
      fieldName: "view",
      typeAttributes: {
        label: LABEL_See_product,
        iconName: "utility:preview",
        name: "view",
        variant: "brand"
      }
    }
  ];

  //  WIRE : RÉCUPÉRATION DES PRODUITS DE L'OPPORTUNITÉ
  @wire(getOpportunityProducts, { opportunityId: "$recordId" })
  wiredProducts({ data, error }) {
    if (data) {
      this.products = data.map((product) => {
        return {
          ...product,
          productId: product.productId,
          stockWarning:
            product.quantityInStock - product.quantity < 0
              ? "slds-text-color_error slds-theme_shade slds-theme_alert-texture" // Rouge + Fond gris
              : "slds-text-color_success" // Vert (fond normal)
        };
      });
      //  Vérifier si au moins un produit a une quantité insuffisante
      const hasQuantityIssues = this.products.some(
        (product) => product.quantityInStock - product.quantity < 0
      );
      //Si des produits ont un problème de quantité, afficher un message d'avertissement
      this.showWarningMessage = hasQuantityIssues;

      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.products = [];
    }
  }

  //  ACCESSEUR : VÉRIFIE LA PRÉSENCE DE PRODUITS
  get hasProductsOnOpportunity() {
    return this.products.length > 0;
  }

  // WIRE : RÉCUPÉRATION DU RÔLE UTILISATEUR CONNECTÉ
  @wire(getUserProfile, { userId: "$userId" })
  wiredUserProfile({ data, error }) {
    if (this.isDataLoaded) return; // Si les données sont déjà chargées, ne pas effectuer l'appel
    if (this.userId) {
      if (data) {
        if (data.role) {
          this.userRole = data.role;
          this.isDataLoaded = true;
        }
      } else if (error) {
        console.error("Erreur lors de la récupération du rôle:", error);
        alert(error.body.message);
      }
    } else {
      console.error(
        "userId est indéfini. Impossible de récupérer les données de l'utilisateur."
      );
    }
  }

  // ACCESSEUR : COLONNES ADAPTÉES AU PROFIL UTILISATEUR
  get columnsToShow() {
    if (
      this.userRole === "Custom: Sales Profile" ||
      this.userRole === "Standard User"
    ) {
      // Supprimer la colonne "Voir Produit" si le rôle est "Sales Profile" ou "Standard User"
      return this.columns.filter((col) => col.fieldName !== "view");
    }
    return this.columns; // Si l'utilisateur est Admin, garder toutes les colonnes
  }

  // GESTION DES ACTIONS SUR LES LIGNES (View / Delete)
  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    console.log("Données de la ligne complète:", row);
    const productId = row.productId || row.id;

    if (productId) {
      if (actionName === "view") {
        this.handleViewProduct(productId);
      } else if (actionName === "delete") {
        console.log("Tentative de suppression du produit avec ID :", productId);
        this.handleDeleteProduct(productId);
      }
    } else {
      console.log("Erreur : ID du produit manquant dans l'événement");
    }
  }

  // SUPPRESSION D’UN PRODUIT DEPUIS LE SERVEUR
  handleDeleteProduct(productId) {
    if (!productId) {
      return;
    }
    // Sauvegarde des produits avant suppression
    const originalProducts = [...this.products];
    // Suppression serveur
    deleteOpportunityProduct({ productId })
      .then(() => {
        console.log("Produit supprimé côté serveur");
        // Met à jour la liste des produits APRÈS confirmation
        this.products = this.products.filter(
          (product) => product.productId !== productId
        );
        return refreshApex(this.wiredRelatedProducts);
      })
      .then(() => {
        console.log("Produits dans la section 'Related' rafraîchis");
      })
      .catch((error) => {
        console.error("Erreur lors de la suppression du produit :", error);
        // Restaure la liste d'origine si échec
        this.products = originalProducts;
      });
  }

  // REDIRECTION VERS LA FICHE PRODUIT
  handleViewProduct(productId) {
    if (productId) {
      window.location.href = `/lightning/r/Product2/${productId}/view`;
    } else {
      console.log("Produit non valide, ID manquant");
    }
  }
}
