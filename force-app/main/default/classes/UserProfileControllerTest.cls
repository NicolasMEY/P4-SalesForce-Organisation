@isTest
private class UserProfileControllerTest {

    @isTest
    static void testGetUserProfile() {
        // Créer un profil de test
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        // Créer un utilisateur avec un nom d'utilisateur unique (en utilisant un timestamp)
        String uniqueUsername = 'testuser' + System.currentTimeMillis() + '@example.com'; // Nom d'utilisateur unique

        User u = new User(
            Username = uniqueUsername, // Utilisation du nom d'utilisateur unique
            Email = 'testuser@example.com',
            Alias = 'tuser',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            CompanyName = 'Test Company',
            LastName = 'User',
            FirstName = 'Test',
            IsActive = true,
            EmailEncodingKey = 'ISO-8859-1' // Ajout du champ EmailEncodingKey
        );
        insert u;

        // Appeler la méthode Apex
        Test.startTest();
        String profileName = UserProfileController.getUserProfile(u.Id);
        Test.stopTest();

        // Vérification : le nom du profil retourné doit correspondre à "Standard User"
        System.assertEquals('Standard User', profileName, 'Le profil de l\'utilisateur doit être "Standard User".');
    }
}



