public with sharing class SFDCAccessControlException extends Exception {

    public Static String GENERIC = 'GENERIC';                                   //This error type is a generic access violation.
    public Static String OBJECT_ACCESS_VIOLATION = 'OBJECT_ACCESS_VIOLATION';   //This error type is a object access violation.
    public Static String FIELD_ACCESS_VIOLATION = 'FIELD_ACCESS_VIOLATION';     //This error type is a field level access violation.
    public Static String SHARING_ACCESS_VIOLATION = 'SHARING_ACCESS_VIOLATION'; //This error type is a sharing access violation.
    public Static String NO_RECORD_FOUND = 'NO_RECORD_FOUND';                   //This error type is a no record found violation.
    public Static String FIELD_NOT_FOUND = 'FIELD_NOT_FOUND';                   //This error type is a field not found violation.

    public Static String NO_READ = 'We don\'t have read permission';      //This error is due to the user not having the read permission on the specific object/field/record.
    public Static String NO_CREATE = 'We don\'t have create permission';  //This error is due to the user not having the create permission on the specific object/field/record.
    public Static String NO_UPDATE = 'We don\'t have update permission';  //This error is due to the user not having the update permission on the specific object/field/record.
    public Static String NO_DELETE = 'We don\'t have delete permission';  //This error is due to the user not having the delete permission on the specific object/field/record.
    

    // Constructor for SFDCAccessControlException for throwing custom error message.
   
    public SFDCAccessControlException(String eText, String eType, String eReason, String eObject, String eField) {
        
        String message = eType + ' - ' + eReason + ' - ' + eObject;
        if (String.isNotBlank(eField)) {
            
            message += ' - ' + eField;   
        }
        this.setMessage(message);
    }
    
     public static String SFDCAccessControlExceptionMsg(String eText, String eType, String eReason, String eObject, String eField) {
        
        String message = eType + ' - ' + eReason + ' - ' + eObject;
        if (String.isNotBlank(eField)) {
            
            message += ' - ' + eField;   
        }
         return message;
    }

}