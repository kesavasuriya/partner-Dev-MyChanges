public with sharing class FieldLevelSecurity {

    public static SFDCAccessController access = new SFDCAccessController();
    public static String NameSpacePrefix = Label.Org_NamePrefix;
    
    public static void checkFieldAccessByCriteria(String fields, String criteria, String sObjectName, Boolean doAddNS) {
        
        List<String> fieldsList = new List<String>();
        Set<String> SystemFields = new Set<String>{'Id'};
            
          if(fields != null) {    
                for(String field : fields.split(',')) {
                    field = field.trim();
                    
                    if(!SystemFields.contains(field)) {
                        
                        if(doAddNS) { //Check and add Namespace if applicable

                            if(field.startsWith(NameSpacePrefix)) {
                                fieldsList.add(field);
                            } else if(field.endsWith('__c')) {
                                fieldsList.add(NameSpacePrefix+field);
                            } else {
                                fieldsList.add(field);
                            }
                            
                        } else {  //Do not add Namespace
                            fieldsList.add(field);    
                        }
                    }
                }
            }   
            
        if(doAddNS && sObjectName != null && !sObjectName.startsWith(NameSpacePrefix) && sObjectName.endsWith('__c')) {
              sObjectName = NameSpacePrefix + sObjectName;
        }

      checkCriteria(criteria, sObjectName, fieldsList);
    }
    
    public static void checkObjectAccessByDelete(String sObjectName) {
    
        if (Boolean.valueOf(Label.HasNamespace)) {
        	if(sObjectName != null && !sObjectName.startsWith(NameSpacePrefix) && sObjectName.endsWith('__c')){
            	sObjectName = NameSpacePrefix + sObjectName;
        	}
        }
        if(access.isAuthorizedToDelete(Schema.getGlobalDescribe().get(sObjectName)) == false){
            throw new SFDCAccessControlException('Access Violation', 
                                                 SFDCAccessControlException.OBJECT_ACCESS_VIOLATION, 
                                                 SFDCAccessControlException.NO_DELETE,
                                                 sObjectName,
                                                 null);
        }
    }
    
    public static Void checkObjectAccessByCreate(String sObjectName) {
    
        if(sObjectName != null && !sObjectName.startsWith(NameSpacePrefix) && sObjectName.endsWith('__c')) {
            sObjectName = NameSpacePrefix + sObjectName;
        }
        
        if(access.isAuthorizedToCreate(Schema.getGlobalDescribe().get(sObjectName)) == false) {
        
            throw new SFDCAccessControlException('Access Violation', 
                                                 SFDCAccessControlException.OBJECT_ACCESS_VIOLATION, 
                                                 SFDCAccessControlException.NO_CREATE,
                                                 sObjectName,
                                                 null);
        }
        
        
    }
    public static Void checkObjectAccessByView(String sObjectName) {
    
        if(sObjectName != null && !sObjectName.startsWith(NameSpacePrefix) && sObjectName.endsWith('__c')){
            sObjectName = NameSpacePrefix + sObjectName;
        }
        if(access.isAuthorizedToView(Schema.getGlobalDescribe().get(sObjectName)) == false) {
        
            throw new SFDCAccessControlException('Access Violation', 
                                                 SFDCAccessControlException.OBJECT_ACCESS_VIOLATION, 
                                                 SFDCAccessControlException.NO_READ,
                                                 sObjectName,
                                                 null);
        }
        
        
    }
    
    public static Void checkObjectAccessByUpdate(String sObjectName) {
        if(sObjectName != null && !sObjectName.startsWith(NameSpacePrefix) && sObjectName.endsWith('__c')) {
            sObjectName = NameSpacePrefix + sObjectName;
        }
        
        if(access.isAuthorizedToUpdate(Schema.getGlobalDescribe().get(sObjectName)) == false) {
        
            throw new SFDCAccessControlException('Access Violation', 
                                                 SFDCAccessControlException.OBJECT_ACCESS_VIOLATION, 
                                                 SFDCAccessControlException.NO_UPDATE,
                                                 sObjectName,
                                                 null);
        }
        
    }
    
    public static void checkCriteria(String criteria, String sObjectName, List<String> fieldsWthNameSpace) {
    
        if(criteria != null) {
            
            if(criteria == 'create') {
                access.assertAuthorizedToCreate(Schema.getGlobalDescribe().get(sObjectName), fieldsWthNameSpace);
            } else if(criteria == 'view') {
                access.assertAuthorizedToView(Schema.getGlobalDescribe().get(sObjectName), fieldsWthNameSpace);
            } else if(criteria == 'update') {
                access.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get(sObjectName), fieldsWthNameSpace);
            }          
        }
        
    }
}