public without sharing class SFUtilities {

    public static User getUserWithToken(Integer index){
        List<User> userList = UserSelector.getUsersIdWithToken();      
        return userList[index];
    }

    public static Integer getIterationIndex(){
        UserIndex__c customSetting = UserIndex__c.getValues('Index');
        return customSetting.Index__c.intValue();
    }

    public static void setIterationIndex(Integer index){
        UserIndex__c userIndex = UserIndex__c.getInstance('Index');
        userIndex.Index__c = index;
        update userIndex;
    }
}
