public with sharing class SchedulerAddTaskOnAccount implements Schedulable{
    public void execute(SchedulableContext SC){ 
        database.executebatch(new BatchAssignTaskToAppropriateAccount());
    }
 }