@isTest
private class TrainingIntegrationTest {
    @testSetup
    static void setupData() {
        // Insert employee (no Name field assignment, Salesforce generates one automatically)
        Employee__c emp = new Employee__c();
        insert emp;

        Assignment__c a = new Assignment__c(
            Name = 'Phishing Module 1',
            Employee__c = emp.Id,
            Assigned_Date__c = Date.today().addDays(-5),
            Due_Date__c = Date.today().addDays(5),
            Status__c = 'Assigned'
        );
        insert a;

        Completion__c c = new Completion__c(
            Name = 'Completion1',
            Employee__c = emp.Id,
            Assignment__c = a.Id,
            Score__c = 80,
            Status__c = 'Completed'
        );
        insert c;
    }

    static testMethod void testCompletionTriggerAndScoreCalc() {
        Employee__c emp = [SELECT Id, Overall_Training_Score__c FROM Employee__c LIMIT 1];

        Test.startTest();
        // Add a new completion
        Assignment__c asg = [SELECT Id FROM Assignment__c LIMIT 1];
        Completion__c newC = new Completion__c(
            Employee__c = emp.Id,
            Assignment__c = asg.Id,
            Score__c = 60,
            Status__c = 'Completed'
        );
        insert newC;
        Test.stopTest();

        Employee__c updated = [
            SELECT Id, Overall_Training_Score__c, Trainin__c
            FROM Employee__c
            WHERE Id = :emp.Id
        ];
        System.assertNotEquals(null, updated.Overall_Training_Score__c, 'Score should be set after trigger processing');
        System.assert(updated.Trainin__c == 'Passed' || updated.Trainin__c == 'Needs Retraining', 'Status must be set correctly');
    }

    static testMethod void testAssignmentValidation() {
        Assignment__c bad = new Assignment__c(
            Name = 'Bad',
            Employee__c = [SELECT Id FROM Employee__c LIMIT 1].Id,
            Assigned_Date__c = Date.today(),
            Due_Date__c = Date.today().addDays(-1)
        );
        Database.SaveResult sr = Database.insert(bad, false);
        System.assert(!sr.isSuccess(), 'Validation should prevent insert when due date < assigned date');
    }

    static testMethod void testBatchArchive() {
        Completion__c oldc = new Completion__c(
            Name = 'Old',
            Employee__c = [SELECT Id FROM Employee__c LIMIT 1].Id,
            Status__c = 'Completed'
        );
        insert oldc;

        Test.startTest();
        Database.executeBatch(new ArchiveOldCompletionsBatch());
        Test.stopTest();

        // You can query and assert archive status here if needed
    }
}