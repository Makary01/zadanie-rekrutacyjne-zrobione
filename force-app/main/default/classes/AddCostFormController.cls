public with sharing class AddCostFormController {
    
    @AuraEnabled(Cacheable=true)
    public static List<Paperwork__c> getAvailablePaperworks(String opportunityId){
        return [SELECT Id, Name, Account__r.Name FROM Paperwork__c WHERE Opportunity__r.Id = :opportunityId AND Account__c != null AND Type__c = 'Cost confirmation'];
    }
    @AuraEnabled(Cacheable=false)
    public static Boolean saveCost(String formValuesInput){
        
        if(formValuesInput==null) return false;
        
        Cost__c cost = new Cost__c();
        
        try{
            FormValuesObject formValues = (FormValuesObject)JSON.deserialize(formValuesInput, FormValuesObject.class);
            if(String.isNotBlank(formValues.name)) cost.Name = formValues.name;
            cost.Account__c = formValues.account;
            cost.Opportunity__c = formValues.opportunity;
            cost.Paperwork__c = formValues.paperwork;
            cost.Amount__c = formValues.amount;
            Insert cost;
            
            if(formValues.amount<=10000) return true;
            
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setComments('Cost Submitted for approval');
            approvalRequest.setObjectId(cost.Id);
            Approval.ProcessResult approvalResult = Approval.process(approvalRequest);
            return approvalResult.isSuccess();
        
        }catch(Exception e){
            return false;
        }
        
    }
    
    public class FormValuesObject {
        public String name;
        public Id account;
        public Id opportunity;
        public Id paperwork;
        public Decimal amount;
    }
}