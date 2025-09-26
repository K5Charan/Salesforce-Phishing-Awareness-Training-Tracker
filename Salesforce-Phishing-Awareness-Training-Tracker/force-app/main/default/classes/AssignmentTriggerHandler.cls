public class AssignmentTriggerHandler {
    public void run() {
        if (Trigger.isBefore && Trigger.isInsert) handleBeforeInsert();
        if (Trigger.isBefore && Trigger.isUpdate) handleBeforeUpdate();
        if (Trigger.isAfter && Trigger.isInsert) handleAfterInsert();
        if (Trigger.isAfter && Trigger.isUpdate) handleAfterUpdate();
    }

    private void handleBeforeInsert() {
        for (Assignment__c a : (List<Assignment__c>) Trigger.new) {
            if (a.Assigned_Date__c != null && a.Due_Date__c != null &&
                a.Due_Date__c < a.Assigned_Date__c) {
                a.addError('Due Date cannot be before Assigned Date.');
            }
        }
    }

    private void handleBeforeUpdate() {
        // Prevent inappropriate status transitions if needed
    }

    private void handleAfterInsert() {
        // Create follow-up Task for employee (bulkified)
        List<Task> tasks = new List<Task>();
        Set<Id> empIds = new Set<Id>();
        for (Assignment__c a : (List<Assignment__c>) Trigger.new) {
            if (a.Employee__c != null) {
                tasks.add(new Task(Subject='New Training Assigned', OwnerId = a.Employee__c, WhatId = a.Id, ActivityDate = Date.today()));
                empIds.add(a.Employee__c);
            }
        }
        if (!tasks.isEmpty()) {
            try { insert tasks; } catch(Exception ex) { TrainingErrorLogger.logException('AssignmentTriggerHandler.handleAfterInsert:insertTasks', ex); }
        }
        if (!empIds.isEmpty()) {
            System.enqueueJob(new CalculateEmployeeScoreQueueable(empIds));
        }
    }

    private void handleAfterUpdate() {
        // If assignment status changed to Completed, recalc score for that employee
        Set<Id> empIds = new Set<Id>();
        for (Assignment__c a : (List<Assignment__c>) Trigger.new) {
            Assignment__c oldA = (Assignment__c) Trigger.oldMap.get(a.Id);
            if (oldA != null && oldA.Status__c != 'Completed' && a.Status__c == 'Completed' && a.Employee__c != null) {
                empIds.add(a.Employee__c);
            }
        }
        if (!empIds.isEmpty()) System.enqueueJob(new CalculateEmployeeScoreQueueable(empIds));
    }
}