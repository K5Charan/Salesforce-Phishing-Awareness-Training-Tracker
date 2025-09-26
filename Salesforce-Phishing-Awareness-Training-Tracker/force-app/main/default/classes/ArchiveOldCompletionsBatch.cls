public class ArchiveOldCompletionsBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date cutoff = Date.today().addYears(-1);
        return Database.getQueryLocator([
            SELECT Id, Status__c FROM Completion__c
            WHERE Status__c = 'Completed' AND CreatedDate < :cutoff
        ]);
    }
    public void execute(Database.BatchableContext bc, List<Completion__c> scope) {
        for (Completion__c c : scope) c.Status__c = 'Archived';
        try { update scope; } catch (DmlException ex) { TrainingErrorLogger.logException('ArchiveOldCompletionsBatch.execute', ex); }
    }
    public void finish(Database.BatchableContext bc) {
        // Optional: send a summary email using SingleEmailMessage or log
    }
}