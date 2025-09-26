public class LMSIntegration {
    @future(callout=true)
    public static void pushCompletionToLMS(Id completionId) {
        try {
            Completion__c c = [SELECT Id, Assignment__c, Employee__c, Score__c FROM Completion__c WHERE Id = :completionId LIMIT 1];
            // Build HTTP request and send to external LMS endpoint
            // HttpRequest req = new HttpRequest(); ...
            // HttpResponse res = new Http().send(req);
        } catch (Exception ex) {
            TrainingErrorLogger.logException('LMSIntegration.pushCompletionToLMS', ex);
        }
    }
}