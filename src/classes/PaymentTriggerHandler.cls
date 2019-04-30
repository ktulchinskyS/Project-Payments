public class PaymentTriggerHandler extends TriggerHandler {
    
    // add any methods that need to be called before insert
    private void beforeInsert(List<SObject> paymentList) {
        //Not much going on here...
    }
    
    // add any methods that need to be called before update
    private void beforeUpdate(List<SObject> paymentList) {
       //Not much going on here...
    }

    // add any methods that need to be called before delete
    private void beforeDelete(List<SObject> paymentList) { 
        //Not much going on here...
    }

    // add any methods that need to be called after insert
    private void afterInsert(List<SObject> paymentList) {
        processPayments((List<Payment__c>)paymentList);
    }

    // add any methods that need to be called after update
    private void afterUpdate(List<SObject> paymentList) {
        processPayments((List<Payment__c>)paymentList);
    }

    // add any methods that need to be called after delete
    private void afterDelete(List<SObject> paymentList) {
        processPayments((List<Payment__c>)paymentList);
    }

    private void processPayments(List<Payment__c> paymentList) {
        Set<Id> contactIds = new Set<Id>();
        Set<Id> projectIds = new Set<Id>();
        Map<Id, Payment__c[]> contactIdToRelatedPayments = new Map<Id, Payment__c[]>();
        Map<Id, Payment__c[]> projectIdToRelatedPayments = new Map<Id, Payment__c[]>();
        
        // get all contacts and projects for any inserted, updated or deleted payments
        for (Payment__c payment : paymentList) {
            contactIds.add(payment.Contact__c);
            projectIds.add(payment.Project__c);
        }

        // query for all payments related to contacts and projects from list of ids above
        Payment__c[] allPayments = [SELECT Contact__c, Project__c, Payment_date__c, Amount__c FROM Payment__c WHERE Contact__c IN :contactIds OR Project__c IN :projectIds  ORDER BY Payment_Date__c DESC LIMIT 50000];

        // populate maps of contact/project to related payments
        for (Payment__c payment : allPayments) {
            Id contactId = payment.Contact__c;
            Id projectId = payment.Project__c;
            Payment__c[] paymentsByContact = contactIdToRelatedPayments.get(contactId);
            Payment__c[] paymentsByProject = projectIdToRelatedPayments.get(projectId);
            
            if (paymentsByContact == null) {
                paymentsByContact = new Payment__c[]{};
            }
            paymentsByContact.add(payment);
            contactIdToRelatedPayments.put(contactId, paymentsByContact);

            if (paymentsByProject == null) {
                paymentsByProject = new Payment__c[]{};
            } 
            paymentsByProject.add(payment);
            projectIdToRelatedPayments.put(projectId, paymentsByProject);
        }

        Contact[] contactsToUpdate = new Contact[]{};
        Project__c[] projectsToUpdate = new Project__c[]{};

        // set the last payment date and total payment for contact
        for (Id contactId : contactIdToRelatedPayments.keySet()) {
            Contact contactToUpdate = new Contact(Id=contactId);
            Payment__c[] payments = contactIdToRelatedPayments.get(contactId);
            // query for payments was ordered by payment date, so the latest payment
            // should be the first payment added to the list
            contactToUpdate.Last_payment_date__c = payments[0].Payment_date__c;
            contactToUpdate.Payments_total__c = getTotalPayments(payments);
            contactsToUpdate.add(contactToUpdate);
        }

        // set the last payment date and total payment for project
        for (Id projectId : projectIdToRelatedPayments.keySet()) {
            Project__c projectToUpdate = new Project__c(Id=projectId);
            Payment__c[] payments = projectIdToRelatedPayments.get(projectId);
            projectToUpdate.Payments_total__c = getTotalPayments(projectIdToRelatedPayments.get(projectId));
            projectsToUpdate.add(projectToUpdate);
        }

        // NOTE: no try/catch here, see error handling note in assumptions/additional information
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }

        if (!projectsToUpdate.isEmpty()) {
            update projectsToUpdate;
        }

    }

    // method to get total payments
    private Double getTotalPayments(List<Payment__c> payments) {
        Double totalAmount = 0;
        for (Payment__c payment : payments) {
            totalAmount = totalAmount + payment.Amount__c;
        }

        return totalAmount;
    }
}