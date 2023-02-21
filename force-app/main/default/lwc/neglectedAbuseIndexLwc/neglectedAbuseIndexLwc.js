import { LightningElement ,api, track} from 'lwc';
import getPicklist from '@salesforce/apex/AssessmentController.getNeglectedAbuseIndexPicklist';
import getInit from '@salesforce/apex/AssessmentController.getNeglectedAbuseIndexInfo';
import saveNeglectAbuse from '@salesforce/apex/AssessmentController.upsertfamilyRiskReassessment';
import UtilityBaseElement from 'c/utilityBaseLwc';

export default class NeglectedAbuseIndexLwc extends UtilityBaseElement {
    
    @api serviceCaseId;
    @api assessmentId;
    @api tableAction;
    @track neglectedAbuseIndexRec = {};
    @track option1= [];
    @track option2= [];
    @track options2a = [];
    @track options2b = [];
    @track options3 = [];
    @track options4 = [];
    @track options5 = [];
    @track options6 = [];
    @track options7 = [];
    @track options8 = [];
    @track options9 = [];
    @track options10 = [];
    @track options11 = [];
    @track options12 = [];
    @track options13 = [];
    @track options14 = [];
    @track options15 = [];
    @track options16 = [];
    defaultScore = 0;
    loading = false;
    @track selected7options = [];
    @track selectedValue7options = [];
    @track selected8options = [];
    @track selectedValue8options = [];
    @track selected10options = [];
    @track selectedValue10options = [];
    @track selected16options = [];
    @track selectedValue16options = [];
    show2ab = false;
    @track optionsAlcohol = [];
    show12Yes = false;
    @track optionsDrugs = [];
    show13Yes = false;
    readOnly = false;
    @track options11y = [];
    show11yes = false;

   
    connectedCallback() {

        this.loading = true;
        getPicklist()
        .then(result => {

            let res = JSON.parse(result);
            this.option1 = res.option1.splice(1);
            this.option2 = res.option2.splice(1);
            this.options2a = res.options2a;
            this.options2b = res.options2b;
            this.options3 = res.options3.splice(1);
            this.options4 = res.options4.splice(1);
            this.options5 = res.options5.splice(1);
            this.options6 = res.options6.splice(1);
            this.options7 = res.options7;
            this.options8 = res.options8;
            this.options9 = res.options9.splice(1);
            this.options10 = res.options10;
            this.options11 = res.options11.splice(1);
            this.options12 = res.options12.splice(1);
            this.options13 = res.options13.splice(1);
            this.options14 = res.options14.splice(1);
            this.options15 = res.options15.splice(1);
            this.options16 = res.options16;
            this.optionsAlcohol = res.optionsAlcohol.splice(1);
            this.optionsDrugs = res.optionsDrugs.splice(1);
            this.options11y = res.options11y.splice(1);
            this.loading = false;
            this.doInit();

        }).catch(error => {

            this.errorMessage(error);
        });
        
    }

    doInit() {

        this.loading = true;
        getInit({recordId:this.assessmentId})
        .then( result => {

            let res = JSON.parse(result);
            if(res.assessmentRec != null) {
                this.neglectedAbuseIndexRec = this.checkNamespaceApplicable(res.assessmentRec,false);
                if(this.neglectedAbuseIndexRec.Approval_Status__c == 'Approved') {
                    this.readOnly = true;
                } else if(this.tableAction == 'view') {
                    this.readOnly = true;
                } else if(this.tableAction == 'edit') {
                    this.readOnly = false;
                }
            }

            this.setDefaultValue();
            this.loading = false;

        }).catch(error => {

            this.errorMessage(error);
        });
    }

    handleSave() {

        this.setFinalRiskLevel();
        this.neglectedAbuseIndexRec.Department_is_unable_to_locate_child__c = false;
        this.neglectedAbuseIndexRec.FamilyInitialRiskAssessmentStage__c = '3';
        this.neglectedAbuseIndexRec.FIRA_racterisitics_of_children__c = this.selected7options.length > 0 ? this.selected7options.join(';') : this.selectedValue7options.join(';');
        this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_assessment__c = this.selected8options.length > 0 ? this.selected8options.join(';') : this.selectedValue8options.join(';');
        this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_characteristics__c = this.selected10options.length > 0 ? this.selected10options.join(';') : this.selectedValue10options.join(';');
        this.neglectedAbuseIndexRec.FIRA_Housing__c = this.selected16options.length > 0 ? this.selected16options.join(';') : this.selectedValue16options.join(';');
        if(!this.onValidate()) {
            this.loading = true;
            saveNeglectAbuse({ familyRiskReassessmentJSON : JSON.stringify(this.checkNamespaceApplicable(this.neglectedAbuseIndexRec,true))})
            .then( result => {

                this.loading = false;
                this.title = 'Success!';
                this.type = 'success';
                this.message = 'Record saved successfully';
                this.fireToastMsg();
                const stageEvent = new CustomEvent('stage',{detail : { stage : '3',assRecId : result}});
                this.dispatchEvent(stageEvent);
                this.doInit();
                
                
            }) .catch(error => {
                this.errorMessage(error);    
            })
        } else {

            this.title = "Error!";
            this.message = "Required fields are missing";
            this.type = "error";
            this.fireToastMsg();
        
        }
    }


    handleChange(event) {

        let eventName = event.target.name;
        let eventValue = event.target.value;
        let eventType = event.target.type;

        if(eventType != 'checkbox' && eventName != 'FIRA_racterisitics_of_children__c' && eventName != 'FIRA_Primary_caregiver_assessment__c' && eventName != 'FIRA_Primary_caregiver_characteristics__c' && eventName != 'FIRA_Housing__c') {
            this.neglectedAbuseIndexRec[eventName] = eventValue;
        }

        if(eventType == 'checkbox') {
            this.neglectedAbuseIndexRec[eventName] = event.target.checked;
        }

        if(eventName == 'FIRA_Current_Report_is_for__c') {
            if(eventValue == 'Neglect') {
                this.neglectedAbuseIndexRec.FIRA_Current_Report_Neglect_Score__c = 1;
                this.neglectedAbuseIndexRec.FIRA_Current_Report_Abuse_Score__c = 0;
            } else if(eventValue == 'Abuse') {
                this.neglectedAbuseIndexRec.FIRA_Current_Report_Neglect_Score__c = 0;
                this.neglectedAbuseIndexRec.FIRA_Current_Report_Abuse_Score__c = 1;
            } else if(eventValue == 'Both') {
                this.neglectedAbuseIndexRec.FIRA_Current_Report_Neglect_Score__c = 1;
                this.neglectedAbuseIndexRec.FIRA_Current_Report_Abuse_Score__c = 1;
            } else {
                this.neglectedAbuseIndexRec.FIRA_Current_Report_Neglect_Score__c = 0;
                this.neglectedAbuseIndexRec.FIRA_Current_Report_Abuse_Score__c = 0;
            }
        }

        if(eventName == 'FIRA_Prior_CPS_Response__c') {
            if(eventValue == 'No') {
                this.neglectedAbuseIndexRec.FIRA_Prior_CPS_Neglect_Score__c = 0;
                this.neglectedAbuseIndexRec.FIRA_Prior_CPS_Abuse_Score__c = 0;
                this.neglectedAbuseIndexRec.FIRA_Prior_Neglect__c = null;
                this.neglectedAbuseIndexRec.FIRA_Prior_Abuse__c = null;
                this.neglectedAbuseIndexRec.FIRA_Prior_Neglect_Score__c = 0;
                this.neglectedAbuseIndexRec.FIRA_Prior_Abuse_Score__c = 0;
                this.show2ab = false;
            } else if(eventValue == 'Yes') {
                this.neglectedAbuseIndexRec.FIRA_Prior_CPS_Neglect_Score__c = 1;
                this.neglectedAbuseIndexRec.FIRA_Prior_CPS_Abuse_Score__c = 0;
                this.show2ab = true;
            }
        }

        if(eventName == 'FIRA_Prior_Neglect__c') {
            if(eventValue == 'None') {
                this.neglectedAbuseIndexRec.FIRA_Prior_Neglect_Score__c = 0;
            } else if(eventValue == 'One' || eventValue == 'Two') {
                this.neglectedAbuseIndexRec.FIRA_Prior_Neglect_Score__c = 1;
            } else if(eventValue == 'Three or More') {
                this.neglectedAbuseIndexRec.FIRA_Prior_Neglect_Score__c = 2;
            }
        }

        if(eventName == 'FIRA_Prior_Abuse__c') {
            if(eventValue == 'None') {
                this.neglectedAbuseIndexRec.FIRA_Prior_Abuse_Score__c = 0;
            } else if(eventValue == 'One' || eventValue == 'Two') {
                this.neglectedAbuseIndexRec.FIRA_Prior_Abuse_Score__c = 1;
            } else if(eventValue == 'Three or More') {
                this.neglectedAbuseIndexRec.FIRA_Prior_Abuse_Score__c = 2;
            }
        }

        if(eventName == 'FIRA_Household_previously_had_open_IHFS__c') {
            if(eventValue == 'No') {
                this.neglectedAbuseIndexRec.FIRA_Household_previously_Neglect_Score__c = 0;
                this.neglectedAbuseIndexRec.FIRA_Household_previously_Abuse_Score__c = 0;
            } else if(eventValue == 'Yes') {
                this.neglectedAbuseIndexRec.FIRA_Household_previously_Neglect_Score__c = 1;
                this.neglectedAbuseIndexRec.FIRA_Household_previously_Abuse_Score__c = 1;
            }
        }

        if(eventName == 'FIRA_Number_of_children_identified__c') {
            if(eventValue == 'Zero,One,Two or Three') {
                this.neglectedAbuseIndexRec.FIRA_Number_of_children_neglect_score__c = 0;
            } else if(eventValue == 'Four or More') {
                this.neglectedAbuseIndexRec.FIRA_Number_of_children_neglect_score__c = 1;
            }
        }

        if(eventName == 'FIRA_Prior_non_accidential_injury__c') {
            if(eventValue == 'No') {
                this.neglectedAbuseIndexRec.FIRA_Prior_non_accidential_Abuse_Score__c = 0;
            } else if(eventValue == 'Yes') {
                this.neglectedAbuseIndexRec.FIRA_Prior_non_accidential_Abuse_Score__c = 1;
            }
        }

        if(eventName == 'FIRA_Age_of_youngest_child__c') {
            if(eventValue == '2 or older') {
                this.neglectedAbuseIndexRec.FIRA_Age_of_youngest_child_neglect_score__c = 0;
            } else if(eventValue == 'Under 2') {
                this.neglectedAbuseIndexRec.FIRA_Age_of_youngest_child_neglect_score__c = 1;
            }
        }

        if(eventName == 'FIRA_racterisitics_of_children__c') {
            this.selected7options = eventValue;
            this.neglectedAbuseIndexRec.FIRA_Characteristic_child_neglect_score__c = 0;
            this.neglectedAbuseIndexRec.FIRA_Characteristic_child_Abuse_Score__c = 0;
            if((!(this.selected7options.includes('None of the above'))) || this.selected7options[this.selected7options.length - 1] != 'None of the above') {
                if(this.selected7options.includes('Medically fragile/failure to thrive')) {
                    this.neglectedAbuseIndexRec.FIRA_Characteristic_child_neglect_score__c = this.neglectedAbuseIndexRec.FIRA_Characteristic_child_neglect_score__c + 1;
                }
                if(this.selected7options.includes('Positive toxicology screen at birth')) {
                    this.neglectedAbuseIndexRec.FIRA_Characteristic_child_neglect_score__c = this.neglectedAbuseIndexRec.FIRA_Characteristic_child_neglect_score__c + 1;
                }
                if(this.selected7options.includes('Physical disability')) {
                    this.neglectedAbuseIndexRec.FIRA_Characteristic_child_neglect_score__c = this.neglectedAbuseIndexRec.FIRA_Characteristic_child_neglect_score__c + 1;
                }
                if(this.selected7options.includes('Developmental disability')) {
                    this.neglectedAbuseIndexRec.FIRA_Characteristic_child_Abuse_Score__c = this.neglectedAbuseIndexRec.FIRA_Characteristic_child_Abuse_Score__c + 1;
                }
                if(this.selected7options.includes('Delinquency history')) {
                    this.neglectedAbuseIndexRec.FIRA_Characteristic_child_Abuse_Score__c = this.neglectedAbuseIndexRec.FIRA_Characteristic_child_Abuse_Score__c + 1;
                }
                if(this.selected7options.includes('Mental health/behavior problems')) {
                    this.neglectedAbuseIndexRec.FIRA_Characteristic_child_Abuse_Score__c = this.neglectedAbuseIndexRec.FIRA_Characteristic_child_Abuse_Score__c + 1;
                }
            } else if(this.selected7options.includes('None of the above') && this.selected7options[this.selected7options.length - 1] == 'None of the above') {
                this.selected7options = ['None of the above'];
                this.selectedValue7options = ['None of the above'];
            } 
            if(this.selected7options.includes('None of the above') && this.selected7options[this.selected7options.length - 1] != 'None of the above') {
                
                var row = this.selected7options.find(element => element == 'None of the above');
                let rows = [...this.selected7options];
                rows.splice(this.selected7options.indexOf(row), 1);
                this.selected7options = rows;
                this.selectedValue7options = rows;
            }
        }

        if(eventName == 'FIRA_Primary_caregiver_assessment__c') {

            this.selected8options = eventValue;
            this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_neglect_score__c = 0;
            if((!(this.selected8options.includes('None of the above'))) || this.selected8options[this.selected8options.length - 1] != 'None of the above') {
                if(this.selected8options.includes('Blames child')) {
                    this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_neglect_score__c = this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_neglect_score__c + 1;
                }
                if(this.selected8options.includes('Justifies maltreatment of the child')) {
                    this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_neglect_score__c = this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_neglect_score__c + 2;
                }
                
            } else if(this.selected8options.includes('None of the above') && this.selected8options[this.selected8options.length - 1] == 'None of the above') {
                this.selected8options = ['None of the above'];
                this.selectedValue8options = ['None of the above'];
            } 
            if(this.selected8options.includes('None of the above') && this.selected8options[this.selected8options.length - 1] != 'None of the above') {
                
                var row = this.selected8options.find(element => element == 'None of the above');
                let rows = [...this.selected8options];
                rows.splice(this.selected8options.indexOf(row), 1);
                this.selected8options = rows;
                this.selectedValue8options = rows;
            }
        }

        if(eventName == 'FIRA_Primary_caregiver_characteristics__c') {

            this.selected10options = eventValue;
            this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_charac_Abuse__c = 0;
            if((!(this.selected10options.includes('None of the above'))) || this.selected10options[this.selected10options.length - 1] != 'None of the above') {
                if(this.selected10options.includes('Provides insufficient emotional/psychological support')) {
                    this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_charac_Abuse__c = this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_charac_Abuse__c + 1;
                }
                if(this.selected10options.includes('Employs excessive/inappropiate discipline')) {
                    this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_charac_Abuse__c = this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_charac_Abuse__c + 1;
                }
                if(this.selected10options.includes('Domineering caregiver')) {
                    this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_charac_Abuse__c = this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_charac_Abuse__c + 1;
                }
                
            } else if(this.selected10options.includes('None of the above') && this.selected10options[this.selected10options.length - 1] == 'None of the above') {
                this.selected10options = ['None of the above'];
                this.selectedValue10options = ['None of the above'];
            } 
            if(this.selected10options.includes('None of the above') && this.selected10options[this.selected10options.length - 1] != 'None of the above') {
                
                var row = this.selected10options.find(element => element == 'None of the above');
                let rows = [...this.selected10options];
                rows.splice(this.selected10options.indexOf(row), 1);
                this.selected10options = rows;
                this.selectedValue10options = rows;
            }
        }

        if(eventName == 'FIRA_Primary_caregiver_past_alcohol__c') {
            if(eventValue == 'Yes') {
                this.show12Yes = true;
            } else {
                this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_alcohol_abuse__c = 0;
                this.neglectedAbuseIndexRec.FIRA_Alcohol_Select_one__c = false;
                this.neglectedAbuseIndexRec.FIRA_Alcohol_values__c = null;
                this.neglectedAbuseIndexRec.Drugs_value__c = null;
                this.neglectedAbuseIndexRec.FIRA_Drugs_Select_One__c = false;
                this.show12Yes = false;
            }
        }

        if(eventName == 'FIRA_Alcohol_values__c' || eventName == 'Drugs_value__c') {
            var alcoholScore = 0;
            var drugScore = 0;
            if(this.neglectedAbuseIndexRec.FIRA_Alcohol_values__c != 'Currently in treatment' && this.neglectedAbuseIndexRec.FIRA_Alcohol_values__c != null) {
                alcoholScore = 1;
            } 
            if(this.neglectedAbuseIndexRec.Drugs_value__c != 'Currently in treatment' && this.neglectedAbuseIndexRec.Drugs_value__c != null) {
                drugScore = 1;
            }
            this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_alcohol_abuse__c = drugScore + alcoholScore;
        }

        if(eventName == 'FIRA_Secondary_Caregiver_has_alcohol__c') {
            if(eventValue == 'Yes') {
                this.show13Yes = true;
            } else {
                this.neglectedAbuseIndexRec.FIRA_Secondary_care_has_alcohol_abuse__c = 0;
                this.neglectedAbuseIndexRec.FIRA_Secondary_Alcohol_values__c = null;
                this.neglectedAbuseIndexRec.FIRA_Secondary_Drugs_value__c = null;
                this.neglectedAbuseIndexRec.Alcohol_Select_one__c = false;
                this.neglectedAbuseIndexRec.FIRA_Secondary_Drugs_Select_One__c = false;
                this.show13Yes = false;
            }
        }

        if(eventName == 'FIRA_Secondary_Alcohol_values__c' || eventName == 'FIRA_Secondary_Drugs_value__c') {
            var alcoholScoreSecondary = 0;
            var drugScoreSecondary = 0;
            if(this.neglectedAbuseIndexRec.FIRA_Secondary_Alcohol_values__c != 'Currently in treatment' && this.neglectedAbuseIndexRec.FIRA_Secondary_Alcohol_values__c != null) {
                alcoholScoreSecondary = 1;
            } 
            if(this.neglectedAbuseIndexRec.FIRA_Secondary_Drugs_value__c != 'Currently in treatment' && this.neglectedAbuseIndexRec.FIRA_Secondary_Drugs_value__c != null) {
                drugScoreSecondary = 1;
            }
            this.neglectedAbuseIndexRec.FIRA_Secondary_care_has_alcohol_abuse__c = drugScoreSecondary + alcoholScoreSecondary;
        }

        if(eventName == 'FIRA_Primary_caregiver_has_history__c') {
            if(eventValue == 'Yes') {
                this.neglectedAbuseIndexRec.FIRA_Primary_caregiv_has_history_neglect__c = 1;
                this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_has_history_abuse__c = 1;
            } else {
                this.neglectedAbuseIndexRec.FIRA_Primary_caregiv_has_history_neglect__c = 0;
                this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_has_history_abuse__c = 0;
            }

        }

        if(eventName == 'FIRA_Primary_caregiver_provides_physical__c') {
            if(eventValue == 'No') {
                this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_provides_neglect__c = 1;
            } else {
                this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_provides_neglect__c = 0;
            }
        }

        if(eventName == 'FIRA_Primary_caregiver_has_past_mental__c') {
            if(eventValue == 'Yes') {
                this.neglectedAbuseIndexRec.FIRA_Primary_caregive_has_mental_neglect__c = 1;
                this.show11yes = true;
            } else {
                this.neglectedAbuseIndexRec.FIRA_Primary_caregive_has_mental_neglect__c = 0;
                this.neglectedAbuseIndexRec.Primary_caregiver_has_past_Yes__c = null;
                this.show11yes = false;
            }
        }

        if(eventName == 'FIRA_Two_or_more_incidents__c') {
            if(eventValue == 'Yes') {
                this.neglectedAbuseIndexRec.FIRA_Two_or_more_incidents_Abuse__c = 2;
            } else {
                this.neglectedAbuseIndexRec.FIRA_Two_or_more_incidents_Abuse__c = 0;
            }

        }

        if(eventName == 'FIRA_Housing__c') {
            this.selected16options = eventValue;
            this.neglectedAbuseIndexRec.FIRA_Housing_Neglect_Score__c = 0;
            if(this.selected16options.includes('Current housing physically unsafe')) {
                this.neglectedAbuseIndexRec.FIRA_Housing_Neglect_Score__c = this.neglectedAbuseIndexRec.FIRA_Housing_Neglect_Score__c + 1;
            }
            if(this.selected16options.includes('Homeless at time CPS response began')) {
                this.neglectedAbuseIndexRec.FIRA_Housing_Neglect_Score__c = this.neglectedAbuseIndexRec.FIRA_Housing_Neglect_Score__c + 2;
            }
        }

        this.totalScore();

    }

    totalScore() {
        this.neglectedAbuseIndexRec.Total_Abuse_Score__c = parseInt(this.neglectedAbuseIndexRec.FIRA_Current_Report_Abuse_Score__c) + parseInt(this.neglectedAbuseIndexRec.FIRA_Prior_CPS_Abuse_Score__c) + 
                        parseInt(this.neglectedAbuseIndexRec.FIRA_Prior_Abuse_Score__c) + parseInt(this.neglectedAbuseIndexRec.FIRA_Household_previously_Abuse_Score__c) + parseInt(this.neglectedAbuseIndexRec.FIRA_Prior_non_accidential_Abuse_Score__c) + 
                        parseInt(this.neglectedAbuseIndexRec.FIRA_Characteristic_child_Abuse_Score__c) + parseInt(this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_provides_abuse__c) + parseInt(this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_charac_Abuse__c) + 
                        parseInt(this.neglectedAbuseIndexRec.FIRA_Primary_caregive_has_mental_abuse__c) + parseInt(this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_alcohol_abuse__c) + parseInt(this.neglectedAbuseIndexRec.FIRA_Secondary_care_has_alcohol_abuse__c) + 
                        parseInt(this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_has_history_abuse__c) + parseInt(this.neglectedAbuseIndexRec.FIRA_Two_or_more_incidents_Abuse__c) ;

        this.neglectedAbuseIndexRec.Total_Neglect_Score__c = parseInt(this.neglectedAbuseIndexRec.FIRA_Current_Report_Neglect_Score__c) + parseInt(this.neglectedAbuseIndexRec.FIRA_Prior_CPS_Neglect_Score__c) +  parseInt(this.neglectedAbuseIndexRec.FIRA_Prior_Neglect_Score__c) +  parseInt(this.neglectedAbuseIndexRec.FIRA_Household_previously_Neglect_Score__c) +  parseInt(this.neglectedAbuseIndexRec.FIRA_Number_of_children_neglect_score__c) 
                                                            +  parseInt(this.neglectedAbuseIndexRec.FIRA_Age_of_youngest_child_neglect_score__c) +  parseInt(this.neglectedAbuseIndexRec.FIRA_Characteristic_child_neglect_score__c) +  parseInt(this.neglectedAbuseIndexRec.FIRA_Primary_caregive_has_mental_neglect__c) +  parseInt(this.neglectedAbuseIndexRec.FIRA_Primary_caregiv_has_history_neglect__c) +  
                                                            parseInt(this.neglectedAbuseIndexRec.FIRA_Housing_Neglect_Score__c) + parseInt(this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_provides_neglect__c ) + parseInt(this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_neglect_score__c);
    }

    setDefaultValue() {

        if(this.neglectedAbuseIndexRec.FIRA_Current_Report_Neglect_Score__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Current_Report_Neglect_Score__c = 0;
        }
        if(this.neglectedAbuseIndexRec.FIRA_Current_Report_Abuse_Score__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Current_Report_Abuse_Score__c = 0;
        } 

        if(this.neglectedAbuseIndexRec.FIRA_Prior_CPS_Neglect_Score__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Prior_CPS_Neglect_Score__c = 0;
        }
        if(this.neglectedAbuseIndexRec.FIRA_Prior_CPS_Abuse_Score__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Prior_CPS_Abuse_Score__c = 0;
        } 

        if(this.neglectedAbuseIndexRec.FIRA_Prior_Neglect_Score__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Prior_Neglect_Score__c = 0;
        }
        if(this.neglectedAbuseIndexRec.FIRA_Prior_Abuse_Score__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Prior_Abuse_Score__c = 0;
        }
        
        if(this.neglectedAbuseIndexRec.FIRA_Household_previously_Neglect_Score__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Household_previously_Neglect_Score__c = 0;
        }
        if(this.neglectedAbuseIndexRec.FIRA_Household_previously_Abuse_Score__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Household_previously_Abuse_Score__c = 0;
        }

        if(this.neglectedAbuseIndexRec.FIRA_Number_of_children_neglect_score__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Number_of_children_neglect_score__c = 0;
        }
        if(this.neglectedAbuseIndexRec.FIRA_Number_of_children_Abuse_Score__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Number_of_children_Abuse_Score__c = 0;
        }

        if(this.neglectedAbuseIndexRec.FIRA_Prior_non_accidential_neglect_score__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Prior_non_accidential_neglect_score__c = 0;
        }
        if(this.neglectedAbuseIndexRec.FIRA_Prior_non_accidential_Abuse_Score__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Prior_non_accidential_Abuse_Score__c = 0;
        }

        if(this.neglectedAbuseIndexRec.FIRA_Age_of_youngest_child_neglect_score__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Age_of_youngest_child_neglect_score__c = 0;
        }
        if(this.neglectedAbuseIndexRec.FIRA_Age_of_youngest_child_Abuse_score__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Age_of_youngest_child_Abuse_score__c = 0;
        }

        if(this.neglectedAbuseIndexRec.FIRA_Characteristic_child_neglect_score__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Characteristic_child_neglect_score__c = 0;
        }
        if(this.neglectedAbuseIndexRec.FIRA_Characteristic_child_Abuse_Score__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Characteristic_child_Abuse_Score__c = 0;
        }

        if(this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_neglect_score__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_neglect_score__c = 0;
        }
        if(this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_abuse_score__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_abuse_score__c = 0;
        }

        if(this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_provides_neglect__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_provides_neglect__c = 0;
        }
        if(this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_provides_abuse__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_provides_abuse__c = 0;
        }

        if(this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_charac_neglect__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_charac_neglect__c = 0;
        }
        if(this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_charac_Abuse__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_charac_Abuse__c = 0;
        }

        if(this.neglectedAbuseIndexRec.FIRA_Primary_caregive_has_mental_neglect__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Primary_caregive_has_mental_neglect__c = 0;
        }
        if(this.neglectedAbuseIndexRec.FIRA_Primary_caregive_has_mental_abuse__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Primary_caregive_has_mental_abuse__c = 0;
        }

        if(this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_alcohol_neglect__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_alcohol_neglect__c = 0;
        }
        if(this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_alcohol_abuse__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_alcohol_abuse__c = 0;
        }

        if(this.neglectedAbuseIndexRec.FIRA_Secondary_care_has_alcohol_neglect__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Secondary_care_has_alcohol_neglect__c = 0;
        }
        if(this.neglectedAbuseIndexRec.FIRA_Secondary_care_has_alcohol_abuse__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Secondary_care_has_alcohol_abuse__c = 0;
        }

        if(this.neglectedAbuseIndexRec.FIRA_Primary_caregiv_has_history_neglect__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Primary_caregiv_has_history_neglect__c = 0;
        }
        if(this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_has_history_abuse__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_has_history_abuse__c = 0;
        }

        if(this.neglectedAbuseIndexRec.FIRA_Two_or_more_incidents_neglect__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Two_or_more_incidents_neglect__c = 0;
        }
        if(this.neglectedAbuseIndexRec.FIRA_Two_or_more_incidents_Abuse__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Two_or_more_incidents_Abuse__c = 0;
        }

        if(this.neglectedAbuseIndexRec.FIRA_Housing_Neglect_Score__c == null) {
            this.neglectedAbuseIndexRec.FIRA_Housing_Neglect_Score__c = 0;
        }
        if(this.neglectedAbuseIndexRec.Housing_Abuse_Score__c == null) {
            this.neglectedAbuseIndexRec.Housing_Abuse_Score__c = 0;
        }

        if(this.neglectedAbuseIndexRec.Total_Neglect_Score__c == null) {
            this.neglectedAbuseIndexRec.Total_Neglect_Score__c = 0;
        }
        if(this.neglectedAbuseIndexRec.Total_Abuse_Score__c == null) {
            this.neglectedAbuseIndexRec.Total_Abuse_Score__c = 0;
        }
        if(this.neglectedAbuseIndexRec.FIRA_racterisitics_of_children__c != null){
            this.selectedValue7options = this.neglectedAbuseIndexRec.FIRA_racterisitics_of_children__c.split(';');
        }
        if(this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_assessment__c != null){
            this.selectedValue8options = this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_assessment__c.split(';');
        }
        if(this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_characteristics__c != null){
            this.selectedValue10options = this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_characteristics__c.split(';');
        }
        if(this.neglectedAbuseIndexRec.FIRA_Housing__c != null){
            this.selectedValue16options = this.neglectedAbuseIndexRec.FIRA_Housing__c.split(';');
        }
        if(this.neglectedAbuseIndexRec.FIRA_Prior_CPS_Response__c == 'Yes') {
            this.show2ab = true;
        }
        if(this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_past_alcohol__c == 'Yes') {
            this.show12Yes = true;
        }
        if(this.neglectedAbuseIndexRec.FIRA_Secondary_Caregiver_has_alcohol__c == 'Yes') {
            this.show13Yes = true;
        }
        if(this.neglectedAbuseIndexRec.FIRA_Primary_caregiver_has_past_mental__c == 'Yes') {
            this.show11yes = true;
        }
    }

    setFinalRiskLevel() {

        if(this.neglectedAbuseIndexRec.Total_Neglect_Score__c >= 0 || this.neglectedAbuseIndexRec.Total_Abuse_Score__c >= 0 ) {
            if(this.neglectedAbuseIndexRec.Total_Abuse_Score__c >= 8 || this.neglectedAbuseIndexRec.Total_Neglect_Score__c >= 9) {
                this.neglectedAbuseIndexRec.FINAL_RISK_LEVEL__c = 'Very High';
            } else if(this.neglectedAbuseIndexRec.Total_Abuse_Score__c >= 5 || this.neglectedAbuseIndexRec.Total_Neglect_Score__c >= 5) {
                this.neglectedAbuseIndexRec.FINAL_RISK_LEVEL__c = 'High';
            } else if(this.neglectedAbuseIndexRec.Total_Abuse_Score__c >= 2 || this.neglectedAbuseIndexRec.Total_Neglect_Score__c >= 2) {
                this.neglectedAbuseIndexRec.FINAL_RISK_LEVEL__c = 'Moderate';
            } else {
                this.neglectedAbuseIndexRec.FINAL_RISK_LEVEL__c = 'Low';
            }
        }   
    }

    errorMessage(error) {

        this.loading = false;
        let errorMsg;
        this.title ="Error!";
        this.type ="error";
        if(error) {
            let errors = this.reduceErrors(error);
            errorMsg = errors.join('; ');
        } else {
            errorMsg = 'Unknown Error';
        }
        this.message = errorMsg;
        this.fireToastMsg();
    }

    onValidate(){
        const allValid = [
            ...this.template.querySelectorAll("lightning-input"),...this.template.querySelectorAll("lightning-combobox"),...this.template.querySelectorAll("lightning-textarea"),...this.template.querySelectorAll("lightning-dual-listbox"),...this.template.querySelectorAll("lightning-radio-group")
            ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
            }, true);
            return !allValid;
    }
}