trigger AssignmentTrigger on Assignment__c (before insert, before update, after insert, after update) {
    new AssignmentTriggerHandler().run();
}