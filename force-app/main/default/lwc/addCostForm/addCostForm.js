import { LightningElement, api, wire } from 'lwc';

import getAvailablePaperworks from '@salesforce/apex/AddCostFormController.getAvailablePaperworks';
import saveCost from '@salesforce/apex/AddCostFormController.saveCost';

export default class CostForm extends LightningElement {

    disabled = false;
    msg = '';
    msgStyle = '';

    @api opportunityId;
    @wire(getAvailablePaperworks, { opportunityId: '$opportunityId' }) paperworkObjects;

    formValues = {'name': ''};

    handleFormInputChange(event) {
        this.formValues[event.target.name] = event.target.value;
    }


    save(){
        let inputFields = [];
        let input = [...this.template.querySelectorAll('lightning-input')];
        let inputField = [...this.template.querySelectorAll('lightning-input-field')];
        let inputCombobox = [...this.template.querySelectorAll('lightning-combobox')];
        
        inputFields = input.concat(inputField,inputCombobox);
        
        const isInputsCorrect = 
        inputFields.reduce((validSoFar, field) => {
                field.reportValidity();
                return validSoFar && field.reportValidity();
            }, true);
            this.disabled = isInputsCorrect;
        if (isInputsCorrect) {
            this.callSaveCost();
        }
    }
    

    callSaveCost() {
        this.formValues.opportunity = this.opportunityId;
        saveCost({ formValuesInput: JSON.stringify(this.formValues) })
            .then((result) => {
                if(result){
                    this.msg = 'Saved';
                    this.msgStyle = 'color: rgb(69 198 90);'
                }else{
                    this.msg = 'Error';
                    this.msgStyle = 'color: rgb(234 0 30);'
                }
            })
            .catch((error) => {
                this.msg = 'Error';
                this.msgStyle = 'color: rgb(234 0 30);'
                console.log(error);
            });

    }

    // cost Name
    costName = {
        name: 'name',
        type: 'text',
        fieldLabel: 'Name',
        fieldId: 'costName',
        required: false,
        variant: 'label-hidden',
        placeholder: 'Enter Name',
        max:'255',
        min:'1'
    }


    // account lookup
    accountLookup = {
        name: 'account',
        childObjectApiName: 'Cost__c',
        targetFieldApiName: 'Account__c',
        fieldId: 'accountLookup',
        fieldLabel: 'Account',
        required: true,
        variant: 'label-hidden',
    }

    // paperwork select
    paperworkSelect = {
        name: 'paperwork',
        fieldLabel: 'Paperwork',
        required: true,
        placeholder: 'Select Paperwork',
        variant: 'label-hidden',
        fieldId: 'selectPaperwork',
    }
    get paperworkOptions() {
        let returnOptions = [];
        if (this.paperworkObjects.data) {
            this.paperworkObjects.data.forEach(paperwork => {
                const optionLabel = paperwork.Name + ' (With account: ' + paperwork.Account__r.Name + ')';
                const optionValue = paperwork.Id;
                returnOptions.push({ label: optionLabel, value: optionValue });
            });
        }
        return returnOptions;
    }

    // cost amount
    costAmount = {
        name: 'amount',
        type: 'number',
        fieldLabel: 'Amount',
        fieldId: 'costAmount',
        formatter: 'currency',
        required: true,
        variant: 'label-hidden',
        placeholder: 'Enter amount',
        step: '0.01',
        min: '0.01',
    }

        // save button
    saveButton = {
        variant: 'brand',
        label: 'Save',
        title: 'Save',
        iconName: 'utility:save'
    }

    clearButton = {
        label: 'Clear',
        title: 'Clear',
        iconName: 'utility:clear',
        onclick: function(){
            let inputFields = [];
        let input = [...this.template.querySelectorAll('lightning-input')];
        let inputField = [...this.template.querySelectorAll('lightning-input-field')];
        let inputCombobox = [...this.template.querySelectorAll('lightning-combobox')];
        
        inputFields = input.concat(inputField,inputCombobox);

        inputFields.forEach(function(field){
            field.value = null;
        })
        this.formValues = {'name': ''};
        this.msg = '';
        this.disabled = false;
        }
    }

}