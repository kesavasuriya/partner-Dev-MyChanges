public  with sharing class FindingPersonController {
    
    @AuraEnabled
    public static String getInitialInformation() {
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        initwrap.genderPicklist =  Utility.getPicklistinfo('Contact','Gender__c',false);
        initwrap.statePicklist =  Utility.getPicklistinfo('Contact','Address_State__c',false);
        initwrap.countryPicklist =  Utility.getPicklistinfo('Contact','County_Address__c',false);
        initwrap.selectPersonRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Select Person').getRecordTypeId();

        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String getPersons(String searchJSON, String recordId) {
        
        if(String.isNotBlank(searchJSON)){
            SearchInputWrapper inputWrap = (SearchInputWrapper) JSON.deserialize(searchJSON, SearchInputWrapper.class);
            List<String> jnObjFields = new List<String>{'Id', 'Person__c'};
                String jnObjCondition = 'Intake__c = \'' + String.escapeSingleQuotes(recordId) + '\'' + ' OR ' + 
                'Investigation__c = \'' + String.escapeSingleQuotes(recordId) + '\'' + ' OR ' + 
                'Service_Case__c = \'' + String.escapeSingleQuotes(recordId) + '\'' + ' OR ' + 'Person__c = \'' + String.escapeSingleQuotes(recordId) + '\'';
            
        	List<Person__c> jnObjList = DataService.performQueryOperation(jnObjFields, 'Person__c', jnObjCondition, Utility.queryLimit);   
            List<contact> contactList = new List<contact> ();
            List<String> contactFields = new List<String>{'Id', 'Name', 'FirstName', 'LastName', 'Casevault_PID__c', 'SSN__c', 'Date_of_Birth__c', 'Gender__c', 'Age__c',
                                        'Address_Line_1__c',  'Address_Line_2__c', 'Address_ZipCode__c', 'Address_State__c', 'County_Address__c', 'Address_City__c'};
            String contactJSON = '';
            contactJSON += 'LastName != null AND  Home_Approval__r.Home_Approval_Status__c != \'Approved\' ';
            //contactJSON += 'AND Intake__c = NULL'
            if( String.isNotBlank(inputWrap.casevaultPId) ) {
                
                contactJSON +=  ' AND Casevault_PID__c = \'PE-'+ String.escapeSingleQuotes(inputWrap.casevaultPId) +'\'';
            } else {
                //Date DOB = inputWrap.dob;
                Decimal age = inputWrap.approxAge;
                if( String.isNotBlank(inputWrap.firstName) ) {
                    
                    String firstNameSoundexCode = Soundex_Algorithm.calculateSoundexCode(inputWrap.firstName);
                    if(String.isNotBlank(firstNameSoundexCode)) {
                        contactJSON += ' AND Firstname_soundex_keycode__c = \''+ String.escapeSingleQuotes(firstNameSoundexCode)+ '\'';
                    }
                }
                if( String.isNotBlank(inputWrap.lastName) ) {
                    
                    String lastNameSoundexCode = Soundex_Algorithm.calculateSoundexCode(inputWrap.lastName);
                    if(String.isNotBlank(lastNameSoundexCode)) {
                        contactJSON += ' AND Lastname_soundex_keycode__c = \''+ String.escapeSingleQuotes(lastNameSoundexCode)+ '\'';
                    } 
                }
                if( inputWrap.dob != NULL ) {
                    
                    DateTime startDT = DateTime.newInstance(inputWrap.dob.addYears(-3).year(),inputWrap.dob.addYears(-3).month(),inputWrap.dob.addYears(-3).day());
                    DateTime endDT = DateTime.newInstance(inputWrap.dob.addYears(3).year(),inputWrap.dob.addYears(3).month(),inputWrap.dob.addYears(3).day());
                    contactJSON +=  ' AND Date_of_Birth__c >= ' + startDT.format('yyyy-MM-dd') + ' AND Date_of_Birth__c <= ' +  endDT.format('yyyy-MM-dd');
                }
                if( String.isNotBlank(inputWrap.ssn) ) {
                    
                    contactJSON +=  ' AND SSN__c = \''+ String.escapeSingleQuotes(inputWrap.ssn) +'\'';
                }
                if( String.isNotBlank(inputWrap.stateId) ) {
                    
                    contactJSON +=  ' AND State_Id_Drivers_License__c = \''+ String.escapeSingleQuotes(inputWrap.stateId) +'\'';
                }
                if(String.isNotBlank(inputWrap.gender)) {
                    contactJSON +=  ' AND Gender__c  LIKE \''+ String.escapeSingleQuotes(inputWrap.gender) +'%'+'\'';
                }
                if(inputWrap.approxAge != Null){
                    contactJSON += ' AND Age__c =:age';
                }
                if(String.isNotBlank(inputWrap.addLine1)){
                    contactJSON += ' AND Address_Line_1__c LIKE \''+ String.escapeSingleQuotes(inputWrap.addLine1) +'%'+'\'';
                }
                if(String.isNotBlank(inputWrap.addLine2)){
                    contactJSON += ' AND Address_Line_2__c LIKE \''+ String.escapeSingleQuotes(inputWrap.addLine2) +'%'+'\'';
                }
                if(String.isNotBlank(inputWrap.zipCode)){
                    contactJSON += ' AND Address_ZipCode__c LIKE \''+ String.escapeSingleQuotes(inputWrap.zipCode) +'%'+'\'';
                }
                if(String.isNotBlank(inputWrap.state)){
                    contactJSON += ' AND Address_State__c LIKE \''+ String.escapeSingleQuotes(inputWrap.state) +'%'+'\'';
                }
                if(String.isNotBlank(inputWrap.city)){
                    contactJSON += ' AND Address_City__c LIKE \''+ String.escapeSingleQuotes(inputWrap.city) +'%'+'\'';
                }
                if(String.isNotBlank(inputWrap.country)){
                    contactJSON += ' AND County_Address__c  LIKE\''+ String.escapeSingleQuotes(inputWrap.country) +'%'+'\'';            
                }
            }  
            
            String conIds='';
         if(jnObjList.size() > 0) {
            conIds +=' NOT IN (';

       for(Person__c rec : jnObjList) {
                conIds +='\''+String.escapeSingleQuotes(rec.Person__c)+'\',';
            }
            conIds = conIds.removeEnd(',');
            conIds +=')';

         }
          else{
            conIds +='NOT IN('+'\''+'\')';
        }
            contactJSON += ' AND Id  '+ conIds;  
           	List<SObject> contactsObjList = DataService.performQueryOperation(contactFields, 'Contact', contactJSON, Utility.queryLimit);
            inputWrap.contactList = (List<Contact>)contactsObjList;
            return JSON.serialize(inputWrap.contactList);
        }else{
            return null;
        }
    }
    
    /*@AuraEnabled
    public static String updatePerson(String contactJSON, String objectName) {
        
        if (String.isNotBlank(contactJSON)) {
            Contact updatePerson = (Contact) JSON.deserialize(contactJSON, Contact.class);
            if (String.isNotBlank(updatePerson.Id)) {
                update updatePerson;
                if(objectName == 'Service_Case__c' && String.isNotBlank(updatePerson.Service_Case__c)) {

                    Program_Assignment__c ins = new Program_Assignment__c();
                    ins.Contact__c = updatePerson.Id;
                    ins.Service_Case__c = updatePerson.Service_Case__c;
                    ins.Program_Area__c = 'In Home';
                    ins.Program_Sub_Area__c = 'Family Preservation';
                    ins.Start_Date__c = Date.today();
                    insert ins;
                    
                } else if(objectName == 'Investigation__c' && String.isNotBlank(updatePerson.Investigation__c)) {


                    Program_Assignment__c ins = new Program_Assignment__c();
                    ins.Contact__c = updatePerson.Id;
                    ins.Investigation__c = updatePerson.Investigation__c;
                    ins.Program_Area__c = [SELECT Id, CPS_Response_Type__c FROM Investigation__c WHERE Id = :updatePerson.Investigation__c].CPS_Response_Type__c;
                    ins.Start_Date__c = Date.today();
                    insert ins;
                }
            } 
            return updatePerson.Id;
        } else {
            return null;
        }
    }*/
    
    @AuraEnabled
    public static void addJnObj(String contactId, String recordId, String objectApiName) {

        Person__c perRec = new Person__c ();
        perRec.Person__c = contactId;
        if(objectApiName == 'Case'){
        perRec.Intake__c = recordId;
        }
        else{
             perRec.put(objectApiName,recordId);
        }
		insert perRec;
    }

    @AuraEnabled
    public static Id getProviderId(Id homeApprovalId) {

        return [SELECT Id,Name,Provider__c FROM Home_Approval__c WHERE Id = :homeApprovalId].Provider__c;
    }

    @AuraEnabled
    public static string getCollaterals(Id recordId){
       
        List<Collateral__c> collaterals = [SELECT Name, First_Name__c, Middle_Name__c, Last_Name__c FROM Collateral__c WHERE Service_Case__c = :recordId ORDER BY LastModifiedDate DESC];
        if(collaterals.size() > 0) {
            return JSON.serialize(collaterals);
        } else {
            return null;
        }
    }

    public class SearchInputWrapper {
        
        Public String firstName; 
        Public String ssn;
        Public String middleName;
        Public String lastName;
        Public String stateId;
        Public String aliasName;
        Public Date dob;
        Public String fein;
        Public String socialMediaName;
        Public Decimal approxAge;
        Public String gender;
        Public String complaint;
        Public String addLine1;
        Public String addLine2;
        Public String email;
        Public String casevaultPId;
        Public String cisId;
        Public String phone;
        Public String mdmId;
        Public String zipCode;
        Public String state;
        Public String occupation;
        Public String petition;
        Public String city;
        Public String country;
        Public String old;
        @AuraEnabled
        public List<Contact> contactList;
    }
    public class GetInitialWrapper {
        @AuraEnabled
        public List<Utility.pickListWrap> genderPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> statePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> countryPicklist;
        @AuraEnabled 
        public String selectPersonRecordTypeId;
    }
}