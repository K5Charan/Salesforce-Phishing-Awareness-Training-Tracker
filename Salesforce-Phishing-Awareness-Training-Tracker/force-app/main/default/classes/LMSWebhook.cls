@RestResource(urlMapping='/lms/completion/*')
global with sharing class LMSWebhook {
    @HttpPost
    global static void receiveCompletion() {
        RestRequest req = RestContext.request;
        Map<String,Object> payload = (Map<String,Object>) JSON.deserializeUntyped(req.requestBody.toString());

        String assignmentId = (String) payload.get('assignmentId');
        Decimal score = payload.containsKey('score') ? Decimal.valueOf(String.valueOf(payload.get('score'))) : null;

        Assignment__c a = [SELECT Id, Employee__c FROM Assignment__c WHERE Id = :assignmentId LIMIT 1];

        Completion__c c = new Completion__c(
            Assignment__c = a.Id,
            Employee__c   = a.Employee__c,
            Score__c      = score,
            Completion_Date__c = Date.today()
        );
        insert c;

        a.Status__c = 'Completed';
        update a;

        RestContext.response.statusCode = 200;
    }
}