@isTest
private class UserProfileControllerTest {

    @isTest
    static void testGetUserProfile() {

        // Créer un profil de test
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        // Créer un utilisateur avec un nom d'utilisateur unique (en utilisant un timestamp)
        String uniqueUsername = 'testuser' + System.currentTimeMillis() + '@example.com'; 
        // ça va permettre que chaque exécution du test utilise un nom d'utilisateur différent, car SalesForce exige que chaque Username soit unique

        User u = new User (
            Username = uniqueUsername,
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
            EmailEncodingKey = 'ISO-8859-1'
        );
        insert u;

        // Appeler la méthode Apex
        Test.startTest();
        String profileRole = UserProfileController.getUserProfile(u.Id);
        Test.stopTest();

        // Vérification ==> on vérifie le rôle (Admin, Commercial, etc.)
        System.assertEquals('Utilisateur standard', profileRole, 'Le rôle de l\'utilisateur doit être "Utilisateur standard".');
    }
}
