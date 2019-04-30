trigger PaymentTrigger on Payment__c (after insert, after update, after delete) {
    PaymentTriggerHandler handler = new PaymentTriggerHandler();
    handler.execute();
}