public class CalculateEmployeeScoreQueueable implements Queueable, Database.AllowsCallouts {
    private Set<Id> employeeIds;
    public CalculateEmployeeScoreQueueable(Set<Id> empIds) {
        this.employeeIds = empIds;
    }

    public void execute(QueueableContext context) {
        try {
            TrainingService.calculateAndUpdateEmployeeScore(employeeIds);
        } catch (Exception ex) {
            TrainingErrorLogger.logException('CalculateEmployeeScoreQueueable.execute', ex);
        }
    }
}