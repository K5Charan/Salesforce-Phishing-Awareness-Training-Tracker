public class ScheduleArchiveCompletionsJob implements Schedulable {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new ArchiveOldCompletionsBatch(), 200);
    }
}
// Example schedule expression to run daily at 2:00 AM:
// System.schedule('Archive Completions Nightly', '0 0 2 * * ?', new ScheduleArchiveCompletionsJob());