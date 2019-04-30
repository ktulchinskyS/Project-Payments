public abstract class TriggerHandler {

    private abstract void beforeInsert(List<SObject> records);

    private abstract void beforeUpdate(List<SObject> records);

    private abstract void beforeDelete(List<SObject> records);

    private abstract void afterInsert(List<SObject> records);

    private abstract void afterUpdate(List<SObject> records);

    private abstract void afterDelete(List<SObject> records);

    public void execute() {

        if (Trigger.isBefore) {
            if(Trigger.isInsert) {
                beforeInsert(trigger.New);
            } else if(Trigger.isUpdate) {
                beforeUpdate(trigger.New);
            } else if (Trigger.isDelete) {
                beforeDelete(trigger.Old);
            } 
        } else if (Trigger.isAfter) {
             if(Trigger.isInsert) {
                afterInsert(trigger.New);
            } else if(Trigger.isUpdate) {
                afterUpdate(trigger.New);
            } else if (Trigger.isDelete) {
                afterDelete(trigger.Old);
            } 
        }
    }
}