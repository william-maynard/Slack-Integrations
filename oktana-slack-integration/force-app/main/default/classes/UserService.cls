public without sharing class UserService {
    
    public static User getNexUser(){
        Integer index = SFUtilities.getIterationIndex();
        return SFUtilities.getUserWithToken(index);
    }

    public static void setNextUser(){
        Integer index = SFUtilities.getIterationIndex();
        index = index + 1;
        SFUtilities.setIterationIndex(index);
    }
}
