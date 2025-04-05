@isTest
private class UserProfileControllerTest {
  @isTest
  static void testGetUserProfile_StandardUser() {
    // Créer un utilisateur de type "Standard User"
    User testUser = createTestUser(); // Aucun permission set ajouté

    Test.startTest();
    // Appeler la méthode pour obtenir le profil de l'utilisateur
    Map<String, String> result = UserProfileController.getUserProfile(
      testUser.Id
    );
    Test.stopTest();

    // Vérifier que le rôle est "Standard User" sans permission spéciale
    System.assertEquals('Standard User', result.get('role'));
  }

  // Méthode utilitaire pour créer un utilisateur de type "Standard User"
  private static User createTestUser() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    User u = new User(
      Alias = 'tuser',
      Email = 'testuser@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'testuser' + Math.random() + '@example.com'
    );
    insert u;
    return u;
  }
}
