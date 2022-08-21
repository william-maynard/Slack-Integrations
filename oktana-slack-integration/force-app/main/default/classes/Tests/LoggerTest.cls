@isTest
public class LoggerTest {

    @isTest
    public static void givenARegisterWhenCallingLoggerDotCommitWorkThenLogIsSuccessfullyInserted() { 
        
        Logger.log('This is a Log');

        Test.startTest();
        Logger.commitWork();
        Test.stopTest();

        Debug_Log__c debuglogExpected = new Debug_Log__c();
        debuglogExpected.Log_Body__c = '[ "This is a Log" ]';
        debuglogExpected.isException__c = false;

        Debug_Log__c debuglogActual = queryOneLog();

        system.assertEquals(debuglogExpected.Log_Body__c, debuglogActual.Log_Body__c);
        system.assertEquals(debuglogExpected.isException__c, debuglogActual.isException__c);
    }

    @isTest
    public static void givenARegisterExceptionWhenCallingLoggerDotCommitWorkThenLogIsSuccessfullyInserted() { 
        
        Logger.logException('This is an Exception Log');

        Test.startTest();
        Logger.commitWork();
        Test.stopTest();

        Debug_Log__c debuglogExpected = new Debug_Log__c();
        debuglogExpected.Log_Body__c = '[ "This is an Exception Log" ]';
        debuglogExpected.isException__c = true;

        Debug_Log__c debuglogActual = queryOneLog();

        system.assertEquals(debuglogExpected.Log_Body__c, debuglogActual.Log_Body__c);
        system.assertEquals(debuglogExpected.isException__c, debuglogActual.isException__c);
    }

    private static Debug_Log__c queryOneLog() {
        return [SELECT Log_Body__c, isException__c FROM Debug_Log__c LIMIT 1][0];
    }
    
}
