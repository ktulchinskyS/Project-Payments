@isTest
public with sharing class PaymentTriggerHandlerTests {

	@isTest
	private static void PaymentTriggerHandler_testSinglePayment() {
		// data setup
		Account[] testAccounts = getTestAccounts(1, true);
		Contact testContact = getTestContacts(1, true, testAccounts)[0];
		Project__c testProject = getTestProjects(1, true)[0];
		Payment__c testPayment = getTestPayments(1, false)[0];
		testPayment.Contact__c = testContact.Id;
		testPayment.Project__c = testProject.Id;
		testPayment.Amount__c = 100;
		testPayment.Payment_date__c = Date.Today();

		Contact currentContact = [SELECT Last_payment_date__c, Payments_total__c FROM Contact WHERE Id = :testContact.Id];
		// verify last payment and payment total prior to payment insert	
		System.assertEquals(null, currentContact.Last_payment_date__c);
		System.assertEquals(null, currentContact.Payments_total__c);
		
		Project__c currentProject = [SELECT Payments_total__c FROM Project__c WHERE Id = :testProject.Id];
		System.assertEquals(null, currentProject.Payments_total__c);

		Test.startTest();
		insert testPayment;
		Test.stopTest();

		// verify last payment and payment total after payment insert
		Contact updatedContact = [SELECT Last_payment_date__c, Payments_total__c FROM Contact WHERE Id = :testContact.Id];
		System.assertEquals(Date.Today(), updatedContact.Last_payment_date__c);
		System.assertEquals(100, updatedContact.Payments_total__c);
		
		Project__c updatedProject = [SELECT Payments_total__c FROM Project__c WHERE Id = :testProject.Id];
        System.assertEquals(100, updatedProject.Payments_total__c);
		
	}

	@isTest
	private static void PaymentTriggerHandler_testMultiplePayments() {
        // data setup
        Account[] testAccounts = getTestAccounts(1, true);
        Contact[] testContacts = getTestContacts(2, true, testAccounts);
        Contact testContact1 = testContacts[0];
        Contact testContact2 = testContacts[1];
        Project__c[] testProjects = getTestProjects(2, true);
        Project__c testProject1 = testProjects[0];
        Project__c testProject2 = testProjects[1];
        
        Date today = Date.Today();
        Date yesterday = today.addDays(-1);
        Date twoDaysAgo = today.addDays(-2);
        
        Payment__c[] testPayments = getTestPayments(4, false);
        Payment__c[] paymentsToInsert = new Payment__c[]{};
        
        // 2 payments for testContact1 and testProject1
        Payment__c testPayment1 = testPayments[0];
        testPayment1.Contact__c = testContact1.Id;
        testPayment1.Project__c = testProject1.Id;
        testPayment1.Amount__c = 100;
        testPayment1.Payment_date__c = today;
        paymentsToInsert.add(testPayment1);
        
        Payment__c testPayment2 = testPayments[1]; 
        testPayment2.Contact__c = testContact1.Id;
        testPayment2.Project__c = testProject1.Id;
        testPayment2.Amount__c = 200;
        testPayment2.Payment_date__c = yesterday;
        paymentsToInsert.add(testPayment2);
        
        // and 2 payments for testContact2 and testProject2
        Payment__c testPayment3 = testPayments[2];
        testPayment3.Contact__c = testContact2.Id;
        testPayment3.Project__c = testProject2.Id;
        testPayment3.Amount__c = 200;
        testPayment3.Payment_date__c = yesterday;
        paymentsToInsert.add(testPayment3);
        
        Payment__c testPayment4 = testPayments[3]; 
        testPayment4.Contact__c = testContact2.Id;
        testPayment4.Project__c = testProject2.Id;
        testPayment4.Amount__c = 300;
        testPayment4.Payment_date__c = twoDaysAgo;
        paymentsToInsert.add(testPayment4);
        
        Test.startTest();
        insert testPayments;
        Test.stopTest();
        
        // verify last payment and payment total after payment insert
        Map<Id, Contact> updatedContacts = new Map<Id, Contact>([SELECT Last_payment_date__c, 
                                                                        Payments_total__c 
                                                                    FROM Contact 
                                                                    WHERE Id IN (:testContact1.Id, :testContact2.Id)]);
        
        // verify testContact1
        System.assertEquals(today, updatedContacts.get(testContact1.Id).Last_payment_date__c);
        System.assertEquals(300, updatedContacts.get(testContact1.Id).Payments_total__c);
        // verify testContact2
        System.assertEquals(yesterday, updatedContacts.get(testContact2.Id).Last_payment_date__c);
        System.assertEquals(500, updatedContacts.get(testContact2.Id).Payments_total__c);
        
        Map<Id, Project__c> updatedProjects = new Map<Id, Project__c>([SELECT Payments_total__c 
                                                                        FROM Project__c 
                                                                        WHERE Id IN (:testProject1.Id, :testProject2.Id)]);
        // verify testProject1
        System.assertEquals(300, updatedProjects.get(testProject1.Id).Payments_total__c);
        // verify testProject1
        System.assertEquals(500, updatedProjects.get(testProject2.Id).Payments_total__c);
        
	}

	//TODO: these should also be implemented
	//@isTest
	//private static void PaymentTriggerHandler_testUpdatePaymentDate() {

	//}

	//@isTest
	//private static void PaymentTriggerHandler_testUpdatePaymentAmount() {
		
	//}

	//@isTest
	//private static void PaymentTriggerHandler_testUpdatePaymentContact() {
		
	//}

	//@isTest
	//private static void PaymentTriggerHandler_testUpdatePaymentProject() {
		
	//}

	//@isTest
	//private static void PaymentTriggerHandler_testDeletePayment() {
	//}

	// method that creates test Accounts
	private static Account[] getTestAccounts(Integer numberOfAccounts, Boolean isInsert) {
		Account[] testAccounts = new Account[]{};
		for (Integer i=0; i<numberOfAccounts; i++) {
			Account testAccount = new Account(Name='Test Account');	
			testAccounts.add(testAccount);
		}
		
		if (isInsert) {
			insert testAccounts;
		}

		return testAccounts;
	}

	// method that creates test Contacts
	private static Contact[] getTestContacts(Integer numberOfContacts, Boolean isInsert, Account[] accounts) {
		Contact[] testContacts = new Contact[]{};	
		Id accountId;
		if (accounts != null && !accounts.isEmpty() && accounts.size() < numberOfContacts) {
			accountId = accounts[0].Id;
		} else if (accounts == null || accounts.isEmpty()) {
			accountId = getTestAccounts(1, true)[0].Id;
		}

		for (Integer i=0; i<numberOfContacts; i++) {
			Contact testContact = new Contact(FirstName='John', LastName='Johnson');	
			testContact.AccountId = accountId == null? accounts[i].Id : accountId;
			testContacts.add(testContact);
		}
		
		if (isInsert) {
			insert testContacts;
		}

		return testContacts;
	}

	// method that creates test Projects
	private static Project__c[] getTestProjects(Integer numberOfProjects, Boolean isInsert) {
		Project__c[] testProjects = new Project__c[]{};
		for (Integer i=0; i<numberOfProjects; i++) {
			Project__c testProject = new Project__c(Name='Test Project');	
			testProjects.add(testProject);
		}
		
		if (isInsert) {
			insert testProjects;
		}

		return testProjects;
	}

	// method that creates test Payments
	private static Payment__c[] getTestPayments(Integer numberOfPayments, Boolean isInsert) {
		Payment__c[] testPayments = new Payment__c[]{};
		for (Integer i=0; i<numberOfPayments; i++) {
			Payment__c testPayment = new Payment__c(Name='Test Payment');	
			testPayments.add(testPayment);
		}
		
		if (isInsert) {
			insert testPayments;
		}

		return testPayments;
	}
}