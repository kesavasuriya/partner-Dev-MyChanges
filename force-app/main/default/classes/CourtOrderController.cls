public with sharing class CourtOrderController {
    
    @AuraEnabled
    public static String getPickList() {
        
        getInitialWrapper initWrap = new getInitialWrapper();
        initWrap.Childspermanencyplancontinues= Utility.getPicklistinfo('Court__c','Child_s_permanency_plan_continues_to_be__c',false);
        initWrap.HearingOutcome= Utility.getPicklistinfo('Court__c','Hearing_Outcome__c',true);
        initWrap.RemovalEpisode= Utility.getPicklistinfo('Court__c','Removal_Episode__c',false);
        
        return  JSON.serialize(initWrap);
    }
    @AuraEnabled
    public static Court__c getCourtOrderRecord(Id CourtOrderId){
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Child_s_Home_Is_Contrary__c,Child_s_Home__c,Reasonable_Efforts_Could_Not_Be_Made__c,'+
                                                      'Efforts_Were_Made_To_Prevent_Removal__c,Efforts_Were_Not_Made_To_Prevent_Removal__c,Waived_Reunification_Efforts__c,Child_s_permanency_plan_continues_to_be__c,'+
                                                      'Reasonable_efforts_were_made_to_finalize__c,Reasonable_efforts_were_not_made__c,Permanency_plan_of_reunification_may_be__c,Voluntary_placement_is_in_the_bet__c,'+
                                                      'Voluntary_placement_is_not_in_the_besti__c,Reasonable_efforts_were_unable_to_be__c,Court_order_specifies_who_the_child__c,Court_order_delay_removal__c,Court_Orders_are_not_signed_by_the_judge__c,'+
                                                      'Court_Order_Received_By_LDSS__c,The_Court_Order_Specifies_action_s__c,The_Court_Order_Specifies_a_Placement__c,Visitations_Court_Ordered__c,Services_Court_Ordered__c,'+
                                                      'Hearing_Outcome__c,Court_Order_Date__c,Removal_Episode__c,Court_Order_Details__c,Child_s_Home_Comments__c,Child_s_Home_Is_Contrary_Comments__c,Reasonable_Efforts_Could_Not_Be_Comments__c,'+
                                                      'Efforts_Were_Made_To_Prevent_Comments__c,Waived_Reunification_Efforts_Comments__c,Efforts_Were_Not_Made_Prevent_Comments__c,Reasonable_efforts_were_made_to_Comments__c,'+
                                                      'Reasonable_efforts_were_not_made_Comment__c,Permanency_plan_of_reunification_Comment__c,Voluntary_placement_the_bet_Comments__c,Voluntary_placement_is_not_best_Comments__c,'+
                                                      'Reasonable_efforts_were_unable_Comments__c,Court_order_specifies_who_child_Comments__c,Court_order_delay_removal_Comments__c,Court_Orders_are_not_signed_by_Comments__c,'+
                                                      'Court_Order_Received_By_LDSS_Comments__c,The_Court_Order_Specifies_action_Comment__c,Visitations_Court_Ordered_Comments__c,The_Court_Order_Placement_Comments__c,'+
                                                      'Services_Court_Ordered_Comments__c,Type_of_Petition__c,Other_Client_named_on_Petition__c', 'view', 'Court__c',  Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','Contact', Boolean.valueOf(Label.HasNamespace));
        
        Court__c courtOrderRecord=[SELECT Child_s_Home_Is_Contrary__c,Child_s_Home__c,Reasonable_Efforts_Could_Not_Be_Made__c,
                                   Efforts_Were_Made_To_Prevent_Removal__c,Efforts_Were_Not_Made_To_Prevent_Removal__c,Waived_Reunification_Efforts__c,Child_s_permanency_plan_continues_to_be__c,
                                   Reasonable_efforts_were_made_to_finalize__c,Reasonable_efforts_were_not_made__c,Permanency_plan_of_reunification_may_be__c,Voluntary_placement_is_in_the_bet__c,
                                   Voluntary_placement_is_not_in_the_besti__c,Reasonable_efforts_were_unable_to_be__c,Court_order_specifies_who_the_child__c,Court_order_delay_removal__c,Court_Orders_are_not_signed_by_the_judge__c,
                                   Court_Order_Received_By_LDSS__c,The_Court_Order_Specifies_action_s__c,The_Court_Order_Specifies_a_Placement__c,Visitations_Court_Ordered__c,Services_Court_Ordered__c,
                                   Hearing_Outcome__c,Court_Order_Date__c,Removal_Episode__c,Court_Order_Details__c,Child_s_Home_Comments__c,Child_s_Home_Is_Contrary_Comments__c,Reasonable_Efforts_Could_Not_Be_Comments__c,
                                   Efforts_Were_Made_To_Prevent_Comments__c,Waived_Reunification_Efforts_Comments__c,Efforts_Were_Not_Made_Prevent_Comments__c,Reasonable_efforts_were_made_to_Comments__c,
                                   Reasonable_efforts_were_not_made_Comment__c,Permanency_plan_of_reunification_Comment__c,Voluntary_placement_the_bet_Comments__c,Voluntary_placement_is_not_best_Comments__c,
                                   Reasonable_efforts_were_unable_Comments__c,Court_order_specifies_who_child_Comments__c,Court_order_delay_removal_Comments__c,Court_Orders_are_not_signed_by_Comments__c,
                                   Court_Order_Received_By_LDSS_Comments__c,The_Court_Order_Specifies_action_Comment__c,Visitations_Court_Ordered_Comments__c,The_Court_Order_Placement_Comments__c,
                                   Services_Court_Ordered_Comments__c,Other_Client_named_on_Petition__r.Name,Type_of_Petition__c
                                   FROM Court__c WHERE Id=:CourtOrderId LIMIT :Utility.queryLimit];
        return courtOrderRecord;
    }
    @AuraEnabled
    public static string upsertCourtOrderRecord(String CourtOrderRecords){
        FieldLevelSecurity.checkFieldAccessByCriteria('Child_s_Home__c,Child_s_Home_Is_Contrary__c,Reasonable_Efforts_Could_Not_Be_Made__c,Efforts_Were_Made_To_Prevent_Removal__c,'+
                                                      'Waived_Reunification_Efforts__c,Efforts_Were_Not_Made_To_Prevent_Removal__c,Reasonable_efforts_were_made_to_finalize__c,Reasonable_efforts_were_not_made__c,'+
                                                      'Permanency_plan_of_reunification_may_be__c,Voluntary_placement_is_in_the_bet__c,Voluntary_placement_is_not_in_the_besti__c,'+
                                                      'Reasonable_efforts_were_unable_to_be__c,Court_order_specifies_who_the_child__c,Court_order_delay_removal__c,Court_Orders_are_not_signed_by_the_judge__c,'+
                                                      'Court_Order_Received_By_LDSS__c,The_Court_Order_Specifies_action_s__c,Visitations_Court_Ordered__c,The_Court_Order_Specifies_a_Placement__c,'+
                                                      'Services_Court_Ordered__c,Child_s_Home_Comments__c,Child_s_Home_Is_Contrary_Comments__c,Reasonable_Efforts_Could_Not_Be_Comments__c,'+
                                                      'Efforts_Were_Made_To_Prevent_Comments__c,Waived_Reunification_Efforts_Comments__c,Efforts_Were_Not_Made_Prevent_Comments__c,'+
                                                      'Child_s_permanency_plan_continues_to_be__c,Reasonable_efforts_were_made_to_Comments__c,Reasonable_efforts_were_not_made_Comment__c,'+
                                                      'Permanency_plan_of_reunification_Comment__c,Voluntary_placement_the_bet_Comments__c,Voluntary_placement_is_not_best_Comments__c,'+
                                                      'Reasonable_efforts_were_unable_Comments__c,Court_order_specifies_who_child_Comments__c,Court_order_delay_removal_Comments__c,'+
                                                      'Hearing_Outcome__c,Court_Order_Date__c,Removal_Episode__c,Court_Orders_are_not_signed_by_Comments__c,Court_Order_Received_By_LDSS_Comments__c,'+
                                                      'The_Court_Order_Specifies_action_Comment__c,Visitations_Court_Ordered_Comments__c,The_Court_Order_Placement_Comments__c,'+
                                                      'Services_Court_Ordered_Comments__c,Court_Order_Details__c','create','Court__c',  Boolean.valueOf(Label.HasNamespace));
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Child_s_Home__c,Child_s_Home_Is_Contrary__c,Reasonable_Efforts_Could_Not_Be_Made__c,Efforts_Were_Made_To_Prevent_Removal__c,'+
                                                      'Waived_Reunification_Efforts__c,Efforts_Were_Not_Made_To_Prevent_Removal__c,Reasonable_efforts_were_made_to_finalize__c,Reasonable_efforts_were_not_made__c,'+
                                                      'Permanency_plan_of_reunification_may_be__c,Voluntary_placement_is_in_the_bet__c,Voluntary_placement_is_not_in_the_besti__c,'+
                                                      'Reasonable_efforts_were_unable_to_be__c,Court_order_specifies_who_the_child__c,Court_order_delay_removal__c,Court_Orders_are_not_signed_by_the_judge__c,'+
                                                      'Court_Order_Received_By_LDSS__c,The_Court_Order_Specifies_action_s__c,Visitations_Court_Ordered__c,The_Court_Order_Specifies_a_Placement__c,'+
                                                      'Services_Court_Ordered__c,Child_s_Home_Comments__c,Child_s_Home_Is_Contrary_Comments__c,Reasonable_Efforts_Could_Not_Be_Comments__c,'+
                                                      'Efforts_Were_Made_To_Prevent_Comments__c,Waived_Reunification_Efforts_Comments__c,Efforts_Were_Not_Made_Prevent_Comments__c,'+
                                                      'Child_s_permanency_plan_continues_to_be__c,Reasonable_efforts_were_made_to_Comments__c,Reasonable_efforts_were_not_made_Comment__c,'+
                                                      'Permanency_plan_of_reunification_Comment__c,Voluntary_placement_the_bet_Comments__c,Voluntary_placement_is_not_best_Comments__c,'+
                                                      'Reasonable_efforts_were_unable_Comments__c,Court_order_specifies_who_child_Comments__c,Court_order_delay_removal_Comments__c,'+
                                                      'Hearing_Outcome__c,Court_Order_Date__c,Removal_Episode__c,Court_Orders_are_not_signed_by_Comments__c,Court_Order_Received_By_LDSS_Comments__c,'+
                                                      'The_Court_Order_Specifies_action_Comment__c,Visitations_Court_Ordered_Comments__c,The_Court_Order_Placement_Comments__c,'+
                                                      'Services_Court_Ordered_Comments__c,Court_Order_Details__c','update','Court__c',  Boolean.valueOf(Label.HasNamespace));
        Court__c createCourtOrder = (Court__c) JSON.deserialize(CourtOrderRecords, Court__c.class);
        upsert createCourtOrder;
        return createCourtOrder.Id;
        
        
    }
    
    @AuraEnabled
  	public static String uploadFile(String base64, String filename, String recordId) {
        ContentVersion cv = createContentVersion(base64, filename);
        ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
        if (cv == null || cdl == null) { return null; }
        return cdl.Id;
  	}
    
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
          FieldLevelSecurity.checkFieldAccessByCriteria('VersionData,Title,PathOnClient','create','ContentVersion', Boolean.valueOf(Label.HasNamespace));
          insert cv;
          return cv;
        
  	}
    
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [
              SELECT ContentDocumentId 
              FROM ContentVersion 
              WHERE Id =: contentVersionId LIMIT :Utility.queryLimit
            ].ContentDocumentId;
            cdl.LinkedEntityId = recordId;
            // ShareType is either 'V', 'C', or 'I'
            // V = Viewer, C = Collaborator, I = Inferred
            cdl.ShareType = 'V';
           
              insert cdl;
              return cdl;
           
  	}
    
    @AuraEnabled
    public static Map<ID, String> getRelatedFilesByRecordId(String recordId) {
            // Get record file IDs        
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId LIMIT :Utility.queryLimit];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
        
        List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
                                     FROM ContentVersion WHERE ContentDocumentId IN : fileIDs ORDER By CreatedDate ASC LIMIT :Utility.queryLimit];
        Map<ID, String> mapIdTitle = new Map<ID, String>();
        for (ContentVersion docLink : docs) {
            mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
        }
        return mapIdTitle;
    }

    
    public class getInitialWrapper { 
        @AuraEnabled
        public List<Utility.pickListWrap> Childspermanencyplancontinues;
        @AuraEnabled
        public List<Utility.pickListWrap> HearingOutcome;
        @AuraEnabled
        public List<Utility.pickListWrap> RemovalEpisode;
    }
}