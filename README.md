# Project-Payments

### Please note

- The App is called Project Payments and can be accessed through the 'waffle' menu, and the lighting component can be found on the 'Contacts with Payments' tab.

- Due to time constraints the lightning component functionality is not complete and only allows editing of records.

- All other functionality, including unit tests are completed.

- There is an additional tab in the app named Payments Grid which contains a GridBuddy grid, which has all the functionality outlined in the requirements, this was added in case the customer wasn't aware that this product exists on the AppExchange.

### Assumptions/Additional Information

1. Made payment date required on the field level

2. Made the lookups to Contact Project required. This means that if anyone tried to delete a Contact or Project that is related to a Payment, they will not be able to do so until they clear that relationship

3. Elected to not write batch apex for this coding assignment with the assumption that one project would not have over 50,000 records and one Contact would not make over 50,000 payments

4. Recommendation that we do not delete payments, but to associate a credit with any nulled payment. Still implemented the after delete functionality in the trigger per the assignment

5. Did not add any error handling in the trigger because it would make more sense to look at existing code in the org and decide on an error hanlding framework that would work best

6. The lightning component gets its configuration from a Salesforce report. This was done to make the lightning component's view configurable.  


