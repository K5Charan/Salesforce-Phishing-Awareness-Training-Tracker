public with sharing class TrainingService {
    // Recalculate and persist Overall_Training_Score__c and Training_Status__c for given employees
    public static void calculateAndUpdateEmployeeScore(Set<Id> employeeIds) {
        if (employeeIds == null || employeeIds.isEmpty()) return;
        try {
            // Aggregate average score per employee
            List<AggregateResult> aggs = [
                SELECT Employee__c emp, AVG(Score__c) avgScore
                FROM Completion__c
                WHERE Employee__c IN :employeeIds
                GROUP BY Employee__c
            ];

            Map<Id, Decimal> avgScoreByEmp = new Map<Id, Decimal>();
            for (AggregateResult ar : aggs) {
                avgScoreByEmp.put((Id)ar.get('emp'), (Decimal)ar.get('avgScore'));
            }

            List<Employee__c> empsToUpdate = new List<Employee__c>();
            for (Id empId : employeeIds) {
                Decimal avgScore = avgScoreByEmp.containsKey(empId) ? avgScoreByEmp.get(empId) : 0;
                Employee__c e = new Employee__c(Id = empId);
                e.Overall_Training_Score__c = avgScore;
                e.Trainin__c = (avgScore >= 70) ? 'Passed' : (avgScore == 0 ? 'Pending' : 'Needs Retraining');
                empsToUpdate.add(e);
            }
            if (!empsToUpdate.isEmpty()) update empsToUpdate;
        } catch (Exception ex) {
            TrainingErrorLogger.logException('TrainingService.calculateAndUpdateEmployeeScore', ex);
        }
    }

    // Mark overdue assignments (used by scheduled/batch job)
    public static void markOverdueAssignments() {
        try {
            Date today = Date.today();
            List<Assignment__c> overdue = [
                SELECT Id, Status__c FROM Assignment__c
                WHERE Due_Date__c < :today AND Status__c != 'Completed' AND Status__c != 'Overdue'
            ];
            for (Assignment__c a : overdue) a.Status__c = 'Overdue';
            if (!overdue.isEmpty()) update overdue;
        } catch (Exception ex) {
            TrainingErrorLogger.logException('TrainingService.markOverdueAssignments', ex);
        }
    }
}