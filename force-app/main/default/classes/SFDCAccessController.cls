public with sharing class SFDCAccessController {

    /**
     * OperationMode - this enum defines the DB operations mode to be used.
     * <br>
     * You can set the operation mode in the constructor or later using the setOperatoinMode() method.
     * If you use the default constructor, we will set it to ALL_OR_NONE.
     */
    public enum OperationMode {
        /**
         * Will make sure all required fields have the proper permissions before any operation takes place.
         */
        ALL_OR_NONE,
        /**
         * Will only set fields that are allowed. Other fields will be omitted from operation, but operation will continue.
         */
        BEST_EFFORT
    }
    
    
    public OperationMode omode {get;set;} // the current operation mode of this instance.

    public SFDCAccessController() {
        omode = OperationMode.ALL_OR_NONE; // defaults to all or none
    }
    
    // Shortcut function
    public Map<string,Schema.SObjectField> getFieldMap(SObjectType someType){
        return someType.getDescribe().fields.getMap();
    }


    /* Return a list of sobject fields that are viewable by this user 
     * (i.e. isAccessible() returns true)
     * This is the optimized version when the fieldMap is already available
     */
    public List<Schema.SObjectField> getViewableFields(Map<string,Schema.SObjectField> fieldsMap) {
        List<Schema.SObjectField> fields = new List<Schema.SObjectField>{};
        for(string key:fieldsMap.keySet()) {
            if(fieldsMap.get(key).getDescribe().isAccessible()) {
                fields.add(fieldsMap.get(key));
            }
        }
        return fields;
    }
    
    /* Return a list of sobject fields that are viewable by this user 
     */ 
    public List<Schema.SObjectField> getViewableFields(SObjectType someType) {
        Map<string,Schema.SObjectField> fieldsMap = getFieldMap(someType);
        return getViewableFields(fieldsMap);
    }
    
    public List<Schema.SObjectField> getViewableFields(SObject sobj) {
        return getViewableFields(sobj.getSObjectType());
    }
    
    public void assertAuthorizedToView(Schema.SObjectType someType, List<Schema.SObjectField> fields) {
        checkAuthorizedToView(someType, fields, true);
    }
    
    public void assertAuthorizedToCreate(Schema.SObjectType someType, List<Schema.SObjectField> fields) {
        checkAuthorizedToCreate(someType, fields, true);
    }
    
    public void assertAuthorizedToUpdate(Schema.SObjectType someType, List<Schema.SObjectField> fields) {
        checkAuthorizedToUpdate(someType, fields, true);
    }
    
    public void assertAuthorizedToView(Schema.SObjectType someType, List<string> fields) {
        checkAuthorizedToView(someType, fields, true);
    }
        
    public void assertAuthorizedToCreate(Schema.SObjectType someType, List<string> fields) {
        checkAuthorizedToCreate(someType, fields, true);
    }
    
    public void assertAuthorizedToUpdate(Schema.SObjectType someType, List<string> fields) {
        checkAuthorizedToUpdate(someType, fields, true);
    }

    
    public boolean isAuthorizedToView(Schema.SObjectType someType, List<Schema.SObjectField> fields) {
        return checkAuthorizedToView(someType, fields, false);
    }
    
    public boolean isAuthorizedToView(Schema.SObjectType someType, List<string> fieldNames) {
        return checkAuthorizedToView(someType, fieldNames, false);
    }
    
    public boolean isAuthorizedToUpdate(Schema.SObjectType someType, List<string> fieldNames) {
        return checkAuthorizedToUpdate(someType, fieldNames, false);
    }
   
    public boolean isAuthorizedToUpdate(Schema.SObjectType someType, List<Schema.SObjectField> fields) {
        return checkAuthorizedToUpdate(someType, fields, false);
    }
    
    public boolean isAuthorizedToCreate(Schema.SObjectType someType, List<string> fieldNames) {
        return checkAuthorizedToCreate(someType, fieldNames, false);
    }
    
    public boolean isAuthorizedToCreate(Schema.SObjectType someType, List<Schema.SObjectField> fields) {
        return checkAuthorizedToCreate(someType, fields, false);
    }
    
    boolean checkAuthorizedToCreate(Schema.SObjectType someType, List<string> fieldNames, boolean throwException) {
        Schema.DescribeSObjectResult objDesc = someType.getDescribe();
        if (!objDesc.isCreateable()){
            //Util.log('checkAuthorizedToCreate - Object: ' + someType + ' is not createable');
            if (throwException) {
                throw new SFDCAccessControlException('Access Violation', 
                                                        SFDCAccessControlException.OBJECT_ACCESS_VIOLATION, 
                                                        SFDCAccessControlException.NO_CREATE,
                                                        someType.getDescribe().getName(),
                                                        null);
            } else {
                return false;
            }
        }
        Map<string, Schema.SObjectField> fMap = someType.getDescribe().fields.getMap();
        
        //Util.log('checkAuthorizedToCreate - FieldMap: ' +  fMap.keySet());
        
        for (string f : fieldNames) {
            Schema.SObjectField sObjectFld = fMap.get(f);
       
            if (sObjectFld == null) {
                //Util.log('checkAuthorizedToCreate - Field: ' + f + ' is  null');
                throw new SFDCAccessControlException('Field not found', 
                                                        SFDCAccessControlException.FIELD_NOT_FOUND, 
                                                        SFDCAccessControlException.GENERIC,
                                                        objDesc.getName(),
                                                        f);
            }
            if (!sObjectFld.getDescribe().isCreateable()){
                //Util.log('checkAuthorizedToCreate - Field: ' + f + ' is  not createable');
                if (throwException) {
                    throw new SFDCAccessControlException('Access Violation', 
                                                            SFDCAccessControlException.FIELD_ACCESS_VIOLATION, 
                                                            SFDCAccessControlException.NO_CREATE,
                                                            someType.getDescribe().getName(),
                                                            sObjectFld.getDescribe().getName());
                    
                } else {
                    return false;
                }
            }
        }
        //Util.log('checkAuthorizedToCreate - Type: ' + someType + ' fieldNames ' + fieldNames +  ' are createable');
        return true;
    }
    
    public boolean checkAuthorizedToCreate(Schema.SObjectType someType, List<Schema.SObjectField> fields, boolean throwException) {
        // check at object-level first
        if (!someType.getDescribe().isCreateable()){
            //Util.log('checkAuthorizedToCreate - Object: ' + someType + ' is not createable');
            if (throwException) {
                throw new SFDCAccessControlException('Access Violation', 
                                                        SFDCAccessControlException.OBJECT_ACCESS_VIOLATION, 
                                                        SFDCAccessControlException.NO_CREATE,
                                                        someType.getDescribe().getName(),
                                                        null);
            } else {
                return false;
            }
        }
        
        // check each field
        for (Schema.SObjectField f : fields) {
            if (!f.getDescribe().isCreateable()){
                if (throwException) {
                    throw new SFDCAccessControlException('Access Violation', 
                                                            SFDCAccessControlException.FIELD_ACCESS_VIOLATION, 
                                                            SFDCAccessControlException.NO_CREATE,
                                                            someType.getDescribe().getName(),
                                                            f.getDescribe().getName());
                } else {
                    return false;
                }
            }
        }
        //Util.log('checkAuthorizedToCreate - Type: ' + someType + ' fields ' + fields +  ' are createable');
        return true;
    }
    
    
    /* Returns a list of sobject fields that are updateable by this user.
     * This is the optimized version when the fieldMap is already available
     */ 
    public List<Schema.SObjectField> getUpdateableFields(Map<string,Schema.SObjectField> fieldsMap) {
        List<Schema.SObjectField> fields = new List<Schema.SObjectField>{};
        for(string key:fieldsMap.keySet()) {
            if(fieldsMap.get(key).getDescribe().isUpdateable()) {
                fields.add(fieldsMap.get(key));
            }
        }
        return fields;
    }
    
    /* Returns a list of sobject fields that are updateable by this user.
     */ 
    public List<Schema.SObjectField> getUpdateableFields(SObjectType someType) {
        Map<string,Schema.SObjectField> fieldsMap = getFieldMap(someType);
        return getUpdateableFields(fieldsMap);
    }
    
    public List<Schema.SObjectField> getUpdateableFields(SObject sobj) {
        return getUpdateableFields(sobj.getSObjectType());
    }

    /* Returns a list of sobject fields that are createable by this user
     * This is the optimized version when the fieldMap is already available
     */ 
    public List<Schema.SObjectField> getCreatableFields(Map<string,Schema.SObjectField> fieldsMap) {
        List<Schema.SObjectField> fields = new List<Schema.SObjectField>{};
        for(string key:fieldsMap.keySet()) {
            if(fieldsMap.get(key).getDescribe().isCreateable()) {
                fields.add(fieldsMap.get(key));
            }
        }
        return fields;
    }
    
    public List<Schema.SObjectField> getCreatableFields(SObject sobj) {
        return getCreatableFields(sobj.getSObjectType());
    }
    
    public List<Schema.SObjectField> getCreatableFields(SObjectType someType) {
        Map<string,Schema.SObjectField> fieldsMap = getFieldMap(someType);
        return getCreatableFields(fieldsMap);
    }
    

    /* 
     * Check to see if the user can delete this object type.
     */
    public boolean isAuthorizedToDelete(Schema.SObjectType someType) {
        // we only need to check CRUD
        return someType.getDescribe().isDeletable();
    }
    public boolean isAuthorizedToView(Schema.SObjectType someType) {
        // we only need to check CRUD
        return someType.getDescribe().isAccessible();
    }
    public boolean isAuthorizedToCreate(Schema.SObjectType someType) {
        // we only need to check CRUD
        return someType.getDescribe().isCreateable();
    }
    public boolean isAuthorizedToUpdate(Schema.SObjectType someType) {
        // we only need to check CRUD
        return someType.getDescribe().isUpdateable();
    }
    
    boolean checkAuthorizedToView(Schema.SObjectType someType, List<Schema.SObjectField> fields, boolean throwException) {
        // check at object-level first
        if (!someType.getDescribe().isAccessible()){
            if (throwException) {
                throw new SFDCAccessControlException('Access Violation', 
                                                        SFDCAccessControlException.OBJECT_ACCESS_VIOLATION, 
                                                        SFDCAccessControlException.NO_READ,
                                                        someType.getDescribe().getName(),
                                                        null);
            } else {
                return false;
            }
        }
        
        // check each field
        for (Schema.SObjectField f : fields) {
            if (!f.getDescribe().isAccessible()){
                if (throwException) {
                    throw new SFDCAccessControlException('Access Violation', 
                                                            SFDCAccessControlException.FIELD_ACCESS_VIOLATION, 
                                                            SFDCAccessControlException.NO_READ,
                                                            someType.getDescribe().getName(),
                                                            f.getDescribe().getName());
                } else {
                    return false;
                }
            }
        }
        return true;
    }
    
    boolean checkAuthorizedToView(Schema.SObjectType someType, List<string> fieldNames, boolean throwException) {
        Schema.DescribeSObjectResult objDesc = someType.getDescribe();
        if (!objDesc.isAccessible()){
            if (throwException) {
                throw new SFDCAccessControlException('Access Violation', 
                                                        SFDCAccessControlException.OBJECT_ACCESS_VIOLATION, 
                                                        SFDCAccessControlException.NO_READ,
                                                        someType.getDescribe().getName(),
                                                        null);
                //throw new throwErrorException('Not have access on in this user');
            } else {
                return false;
            }
        }
        
        Map<string, Schema.SObjectField> fMap = someType.getDescribe().fields.getMap();
        for (string f : fieldNames) {
            Schema.SObjectField sObjectFld = fMap.get(f);
            if (sObjectFld == null) {
                throw new SFDCAccessControlException('Field not found', 
                                                        SFDCAccessControlException.FIELD_NOT_FOUND, 
                                                        SFDCAccessControlException.GENERIC,
                                                        objDesc.getName(),
                                                        f);
            }
            if (!sObjectFld.getDescribe().isAccessible()){
                if (throwException) {
                    throw new SFDCAccessControlException('Access Violation', 
                                                            SFDCAccessControlException.FIELD_ACCESS_VIOLATION, 
                                                            SFDCAccessControlException.NO_READ,
                                                            someType.getDescribe().getName(),
                                                            sObjectFld.getDescribe().getName());
                                   

                    
                } else {
                    return false;
                }
            }
        }
        return true;
    }
    
    boolean checkAuthorizedToUpdate(Schema.SObjectType someType, List<Schema.SObjectField> fields, boolean throwException) {
        // check at object-level first
        if (!someType.getDescribe().isUpdateable()){
            if (throwException) {
                throw new SFDCAccessControlException('Access Violation', 
                                                        SFDCAccessControlException.OBJECT_ACCESS_VIOLATION, 
                                                        SFDCAccessControlException.NO_UPDATE,
                                                        someType.getDescribe().getName(),
                                                        null);
            } else {
                return false;
            }
        }
        
        // check each field
        for (Schema.SObjectField f : fields) {
            if (!f.getDescribe().isUpdateable()){
                if (throwException) {
                    throw new SFDCAccessControlException('Access Violation', 
                                                            SFDCAccessControlException.FIELD_ACCESS_VIOLATION, 
                                                            SFDCAccessControlException.NO_UPDATE,
                                                            someType.getDescribe().getName(),
                                                            f.getDescribe().getName());
                } else {
                    return false;
                }
            }
        }
        return true;
    }
        
    boolean checkAuthorizedToUpdate(Schema.SObjectType someType, List<string> fieldNames, boolean throwException) {
        Schema.DescribeSObjectResult objDesc = someType.getDescribe();
        if(!objDesc.isUpdateable()){
            if (throwException) {
                throw new SFDCAccessControlException('Access Violation', 
                                                        SFDCAccessControlException.OBJECT_ACCESS_VIOLATION, 
                                                        SFDCAccessControlException.NO_UPDATE,
                                                        someType.getDescribe().getName(),
                                                        null);
            } else {
                return false;
            }
        }
        Map<string, Schema.SObjectField> fMap = someType.getDescribe().fields.getMap();
        for (string f : fieldNames) {
            Schema.SObjectField sObjectFld = fMap.get(f);
            if (sObjectFld == null) {
                throw new SFDCAccessControlException('Field not found', 
                                                        SFDCAccessControlException.FIELD_NOT_FOUND, 
                                                        SFDCAccessControlException.GENERIC,
                                                        objDesc.getName(),
                                                        f);
            }
            if (!sObjectFld.getDescribe().isUpdateable()){
                if (throwException) {
                    throw new SFDCAccessControlException('Access Violation', 
                                                            SFDCAccessControlException.FIELD_ACCESS_VIOLATION, 
                                                            SFDCAccessControlException.NO_UPDATE,
                                                            someType.getDescribe().getName(),
                                                            sObjectFld.getDescribe().getName());
                } else {
                    return false;
                }
            }
        }
        return true;
    }
}