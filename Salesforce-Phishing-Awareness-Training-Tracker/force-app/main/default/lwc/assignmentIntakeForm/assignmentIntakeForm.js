import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import getPicklistValues from '@salesforce/apex/AssignmentController.getPicklistValues';
import saveAssignment from '@salesforce/apex/AssignmentController.saveAssignment';

export default class AssignmentIntakeForm extends NavigationMixin(LightningElement) {
  @track name = '';
  @track module = '';
  @track assignedDate = '';
  @track dueDate = '';
  @track employeeId = '';
  @track moduleOptions = [];
  isSaving = false;

  connectedCallback() {
    // load picklist values via Apex (cacheable)
    getPicklistValues()
      .then(data => {
        // expecting data.Module__c = ['Phishing Basics', ...]
        this.moduleOptions = (data && data.Module__c) ? data.Module__c.map(v => ({ label: v, value: v })) : [];
      })
      .catch(err => console.error('getPicklistValues error', err));
  }

  handleChange(event) {
    const field = event.target.name;
    if (field === 'Name') this.name = event.target.value;
    if (field === 'Module__c') this.module = event.target.value;
    if (field === 'Assigned_Date__c') this.assignedDate = event.target.value;
    if (field === 'Due_Date__c') this.dueDate = event.target.value;
    if (field === 'Employee__c') this.employeeId = event.target.value;
  }

  handleSave() {
    this.isSaving = true;
    const newRec = {
      sobjectType: 'Assignment__c',
      Name: this.name,
      Module__c: this.module,
      Assigned_Date__c: this.assignedDate,
      Due_Date__c: this.dueDate,
      Employee__c: this.employeeId
    };

    saveAssignment({ newAssignment: newRec })
      .then(result => {
        this.dispatchEvent(new ShowToastEvent({ title: 'Saved', message: 'Assignment created', variant: 'success' }));

        this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: { recordId: result.Id, objectApiName: 'Assignment__c', actionName: 'view' }
        });
      })
      .catch(error => {
        this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: error?.body?.message || error.message, variant: 'error' }));
      })
      .finally(() => { this.isSaving = false; });
  }
}
