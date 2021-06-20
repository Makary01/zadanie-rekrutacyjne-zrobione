@isTest public class AddCostFormControllerTest {
    @testSetup static void methodName() {
        Account acc = new Account();
        acc.Name = 'test Account';
        insert acc;
        
        List<Opportunity> opportunities = new List<Opportunity>();
        
            Opportunity opp1 = new Opportunity();
        	opp1.Name = 'Test opportunity1';
            opp1.StageName = 'Qualification';
        	opp1.CloseDate = Date.today().addDays(10);
        	opportunities.add(opp1);

            Opportunity opp2 = new Opportunity();
        	opp2.Name = 'Test opportunity2';
            opp2.StageName = 'Proposal/Price Quote';
        	opp2.CloseDate = Date.today().addDays(10);
        	opportunities.add(opp2);
        
        insert opportunities;
        
        List<Paperwork__c> paperworks = new List<Paperwork__c>();
        for(Integer i =0; i<20; i++){
            Paperwork__c ppw = new Paperwork__c();
            ppw.Account__c = acc.Id;
            if(i<5){
                ppw.Opportunity__c = opportunities.get(0).id;
                ppw.Type__c = 'Cost confirmation';
            } else if(i<10){
                ppw.Opportunity__c = opportunities.get(1).id;
                ppw.Type__c = 'Cost confirmation';
            } else if(i<15){
                ppw.Opportunity__c = opportunities.get(0).id;
                ppw.Type__c = 'NDA';
            } else if(i<20){
                ppw.Opportunity__c = opportunities.get(1).id;
                ppw.Type__c = 'NDA';
            }
            paperworks.add(ppw);
        }
        insert paperworks;
    }

    @isTest
    private static void givenOppIdReturnAvailablePaperworks() {
        // Test data setup
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        // Actual test
        Test.startTest();
        List<Paperwork__c> paperworks = AddCostFormController.getAvailablePaperworks(opp.Id);
        Test.stopTest();
    
        // Asserts
        System.assertEquals(5, paperworks.size());

    }

    @isTest
    private static void givenformValuesInputShouldSaveNewCost() {
        // Test data setup
        Account acc = [SELECT Id FROM Account];

        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test opportunity1' ];
        Paperwork__c ppw = AddCostFormController.getAvailablePaperworks(opp.Id).get(0);

        List<String> amountOver10k = new List<String>();
        amountOver10k.add('{');
        amountOver10k.add('"name" : "Test cost1",');
        amountOver10k.add('"account" : "' + acc.Id + '",');
        amountOver10k.add('"opportunity" : "' + opp.Id + '",');
        amountOver10k.add('"paperwork" : "' + ppw.Id + '",');
        amountOver10k.add('"amount" : "73828.72"');
        amountOver10k.add('}');

        List<String> amountUnder10k = new List<String>();
        amountUnder10k.add('{');
        amountUnder10k.add('"name" : "Test cost2",');
        amountUnder10k.add('"account" : "' + acc.Id + '",');
        amountUnder10k.add('"opportunity" : "' + opp.Id + '",');
        amountUnder10k.add('"paperwork" : "' + ppw.Id + '",');
        amountUnder10k.add('"amount" : "228.42"');
        amountUnder10k.add('}');

        String formValuesInput1 = String.join(amountOver10k,'\n');
        String formValuesInput2 = String.join(amountUnder10k,'\n');

        // Actual test
        Test.startTest();
        Boolean result1 = AddCostFormController.saveCost(formValuesInput1);
        Cost__c costInApproval = [SELECT Id FROM Cost__c];

        Boolean result2 = AddCostFormController.saveCost(formValuesInput2);
        Test.stopTest();
    
        // Asserts
        System.assert(result1);
        System.assert(result2);
        System.assertEquals(1,[SELECT Id FROM ProcessInstance WHERE TargetObjectId = :costInApproval.Id].size());
    }

    @isTest
    private static void givenformValuesInputShouldNotSaveNewCost() {
        // Test data setup
        Account acc = [SELECT Id FROM Account];
        
        Opportunity oppValid = [SELECT Id FROM Opportunity WHERE Name = 'Test opportunity1' ];
        Paperwork__c ppwInvalid = [SELECT Id FROM Paperwork__c WHERE Type__c = 'NDA' AND Opportunity__c = :oppValid.Id LIMIT 1];

        List<String> invalidPaperwork = new List<String>();
        invalidPaperwork.add('{');
        invalidPaperwork.add('"name" : "Test cost1",');
        invalidPaperwork.add('"account" : "' + acc.Id + '",');
        invalidPaperwork.add('"opportunity" : "' + oppValid.Id + '",');
        invalidPaperwork.add('"paperwork" : "' + ppwInvalid.Id + '",');
        invalidPaperwork.add('"amount" : "550"');
        invalidPaperwork.add('}');

        Opportunity oppInvalid = [SELECT Id FROM Opportunity WHERE Name = 'Test opportunity2' ];
        Paperwork__c ppwValid = AddCostFormController.getAvailablePaperworks(oppInvalid.Id).get(0);
        
        List<String> InvalidOpportunity = new List<String>();
        InvalidOpportunity.add('{');
        InvalidOpportunity.add('"name" : "Test cost1",');
        InvalidOpportunity.add('"account" : "' + acc.Id + '",');
        InvalidOpportunity.add('"opportunity" : "' + oppInvalid.Id + '",');
        InvalidOpportunity.add('"paperwork" : "' + ppwValid.Id + '",');
        InvalidOpportunity.add('"amount" : "650"');
        InvalidOpportunity.add('}');

        String formValuesInput1 = String.join(invalidPaperwork,'\n');
        String formValuesInput2 = String.join(InvalidOpportunity,'\n');

        // Actual test
        Test.startTest();
        Boolean result1 = AddCostFormController.saveCost(formValuesInput1);
        Boolean result2 = AddCostFormController.saveCost(formValuesInput2);
        Boolean result3 = AddCostFormController.saveCost('invalid input');
        Test.stopTest();
    
        // Asserts
        System.assert(!result1);
        System.assert(!result2);
        System.assert(!result3);
    }
    
    
}