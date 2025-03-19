public with sharing class UserProfileController {
    @AuraEnabled(cacheable=true)
    public static String getUserProfile(Id userId) {
        User currentUser = [SELECT Profile.Name FROM User WHERE Id = :userId LIMIT 1];
        return currentUser.Profile.Name;
    }
}
