public with sharing class SlackObjects {
   
    public class SFUser{
        public String id;
        public String token;

        public SFUser(String id, String token){
            this.id = id;
            this.token = token;
        }
    }

    public class Conversation {
        public String id;
        public String name;
        public Integer numbersMembers;
        public Boolean isDirectMessage;
        public Boolean isChannel;
        public Boolean isGroup;
    }

}
