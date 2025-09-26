trigger CompletionTrigger on Completion__c (after insert, after update) {
    new CompletionTriggerHandler().run();
}