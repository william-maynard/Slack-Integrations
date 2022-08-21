public class Logger {

    private static List<Object> objects = new List<Object>();
    private static boolean isException = false;

    public static void log(Object register) {
        objects.add(register);
    }
    public static void logException(Object register) {
        objects.add(register);
        isException = true;
    }

    public static void commitWork() {
        String body = JSON.serializePretty(objects);
        Debug_Log__c debuglog = new Debug_Log__c();
        debuglog.Log_Body__c = body;
        debuglog.isException__c = isException;
        insert debuglog;
    }

   
}
