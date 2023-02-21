public with sharing class SuspensionHandler {

    //Unlock a record locked via approval process
    @InvocableMethod(label='Unlock Records' 
                     description='Unlocks a list of records')
    public static void unlock(List<Id> recordIds) {
    
        for(Id sp : recordIds) {
         
            if(Approval.isLocked(sp)) {
                Approval.unlock(sp);
            }   
        }
    }
}