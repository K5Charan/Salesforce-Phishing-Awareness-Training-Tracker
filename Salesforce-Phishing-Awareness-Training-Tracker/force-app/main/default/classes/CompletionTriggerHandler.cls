public class CompletionTriggerHandler {
    public void run() {
        if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
            Set<Id> empIds = new Set<Id>();
            for (Completion__c c : (List<Completion__c>) Trigger.new) {
                if (c.Employee__c != null) empIds.add(c.Employee__c);
            }
            if (!empIds.isEmpty()) {
                System.enqueueJob(new CalculateEmployeeScoreQueueable(empIds));
            }
        }
    }
}