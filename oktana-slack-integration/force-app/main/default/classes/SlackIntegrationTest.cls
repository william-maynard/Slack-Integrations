@isTest
private with sharing class SlackIntegrationTest {
    private static String json = 'xoxp-3331607868951-3348554113556-3579730000528-0bab6fe771a836e8fb95f3de4ecb004e';
    private static String jsonEncrypted = 'OMHfQXJI+J/KJKzAfoQB4y6KcAAVRVpEe8BQGuhdih0OEyCjm/y5si3khxyw3LEoE7H4Mn8nidm+AG4R4Oq7AFnStElmpZgGERXLzUhOMTiHfdQuUV3kLKHHdWer3g2Q';  
    private static String key = ChatterConstant.cryptoKey;
    
    @isTest 
    private static void testEncrypt(){
        String encryptedString = SlackIntegration.encrypt(json, key);
        
        System.assert(encryptedString != '');
    }
    
    // Generate firts the testEncrypt then copy and past the token encrypted
    @isTest
    private static void testDecrypt(){  
        String decryptedString = SlackIntegration.decrypt(jsonEncrypted, key);
        
        System.assertEquals(json, decryptedString,'');
    } 
    
    @isTest
    private static void testEncryptReturnError(){
        String stringNull = SlackIntegration.encrypt(null, key);

        System.assert(stringNull == null);
        
        String stringEmpty = SlackIntegration.encrypt('', key);
 
        System.assert(stringEmpty == null);
    }

    @isTest
    private static void testDecryptReturnError(){
        String stringNull= SlackIntegration.decrypt('', key);

        System.assert(stringNull == null);
        
        String stringEmpty = SlackIntegration.decrypt(null, key);
 
        System.assert(stringEmpty == null);
    }
}