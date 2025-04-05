public with sharing class UserProfileController {
  @AuraEnabled(cacheable=true)
  public static Map<String, String> getUserProfile(Id userId) {
    Map<String, String> result = new Map<String, String>();

    // Vérifier que l'utilisateur existe
    List<User> userList = [
      SELECT Id, Profile.Name
      FROM User
      WHERE Id = :userId
      LIMIT 1
    ];
    if (userList.isEmpty()) {
      result.put('role', 'User Not Found');
      return result;
    }

    User foundUser = userList[0];

    List<PermissionSetAssignment> psaList = [
      SELECT
        PermissionSet.Name,
        PermissionSet.PermissionsModifyAllData,
        PermissionSet.PermissionsViewAllData
      FROM PermissionSetAssignment
      WHERE AssigneeId = :userId
    ];

    for (PermissionSetAssignment psa : psaList) {
      if (psa.PermissionSet.PermissionsModifyAllData) {
        result.put('role', 'System Administrator');
        return result;
      }
      if (psa.PermissionSet.PermissionsViewAllData) {
        result.put('role', 'Custom: Sales Profile');
        return result;
      }
    }

    result.put('role', 'Standard User');
    return result;
  }
}
