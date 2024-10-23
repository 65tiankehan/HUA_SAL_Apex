public without sharing class HUA_FileProcessorService {
    @AuraEnabled
    public static void processCSVFile(String base64Content, String objectTypeName, String operationType,String lineEnding) {
      
        Blob csvFile = EncodingUtil.base64Decode(base64Content);

    
        processCSVFileAsync(csvFile, objectTypeName, operationType,lineEnding);
    }

    @Future(callout=true)
    public static void processCSVFileAsync(Blob csvFile, String objectTypeName, String operationType,String lineEnding) {
        HUA_FileProcessor.processCSVFile(csvFile, objectTypeName, operationType,lineEnding);
    }

   
    @AuraEnabled(cacheable=true)
    public static Map<String, List<Object>> getAllObjects(List<String> objectNames) {
        try {
            return HUA_Meta_tool.getAllObjects(objectNames);
        } catch (Exception e) {
          
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String, List<Object>> getSeatchObjects(String searchText) {
        try {
            System.debug( HUA_Meta_tool.searchObjectsLike(searchText));
            return HUA_Meta_tool.searchObjectsLike(searchText);
        } catch (Exception e) {
          
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}