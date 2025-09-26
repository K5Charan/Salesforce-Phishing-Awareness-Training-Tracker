public with sharing class TrainingErrorLogger {
    public static void logException(String context, Exception ex) {
        try {
            Error_Log__c logRec = new Error_Log__c(
                Name = 'ApexError-' + Datetime.now().getTime(),
                Context__c = context,
                Message__c = ex.getMessage()
            );
            insert logRec;
        } catch (Exception e) {
            // Last resort: avoid throwing further exceptions during logging
            System.debug('Failed to persist error log: ' + e.getMessage());
        }
    }
}