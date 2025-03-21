public with sharing class UserProfileController {
    @AuraEnabled(cacheable=true)

    public static String getUserProfile(Id userId) {
        
        User currentUser = [SELECT Profile.Name FROM User WHERE Id = :userId LIMIT 1];
        // return currentUser.Profile.Name;

        // On détermine le rôle d'un utilisateur (admin ou commercial) en fonction de ses autorisations, plutôt que de son profil ou de la langue pour résoudre les problèmes liés à l'internationalisation ==> On utilise les permissions au lieu de dépendre des traductions des profils.

        List<PermissionSetAssignment> psaList = [
        SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSet.PermissionsModifyAllData = true AND PermissionSet.PermissionsViewAllData = true
        ];

        // Par défaut, on considère que l'utilisateur est commercial
        Boolean isAdmin = false;
        Boolean isCommercial = false;

        for (PermissionSetAssignment psa : psaList) {
            if (psa.PermissionSet.PermissionsModifyAllData) {
            isAdmin = true;
            break; // Si une des permissions est vraie, l'utilisateur est admin
            }

            if(psa.PermissionSet.PermissionsViewAllData){
                isCommercial = true;
            }
        }

        // Retoure le role basé sur les permissions, indépendamment de la langue
        if(isAdmin) {
            return 'Admin';
        } else if (isCommercial) {
            return 'Commercial';
        }else {
            return 'Utilisateur standard';
        }
    }
}
