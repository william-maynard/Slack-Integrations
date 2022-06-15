public with sharing class SlackIntegration {

    public static String encrypt(String dataString, String cryptoKeyString){
        if (dataString == '' || dataString == null) {
            return null;
        }
        
		Blob cryptoKey = EncodingUtil.base64Decode(cryptoKeyString);
        Blob data = Blob.valueOf(dataString);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', cryptoKey, data);
        String dataEncrypted = EncodingUtil.base64Encode(encryptedData);

        return dataEncrypted;
    }


    public static String decrypt(String dataString, String cryptoKeyString) {
        if (dataString == '' || dataString == null) {
            return null;
        }  
        
        Blob cryptoKey = EncodingUtil.base64Decode(cryptoKeyString);
        Blob encryptedBlob = EncodingUtil.base64Decode(dataString); 
        Blob decryptedData = Crypto.decryptWithManagedIV('AES128', cryptoKey, encryptedBlob);
        String decryptedDataString = decryptedData.toString();

        return decryptedDataString;
    }
}