public class AddressVerificationController {
    
	public static Contact_Address__c rec = new Contact_Address__c();
    public static string error;
    @InvocableMethod(callout=true label='verify address')
    public static List<String> XMLgen(List<Contact_Address__c> records){
        
        system.debug(records);
        rec = records[0];
        String address1 = rec.Address_Line_1__c;
        String address2 = rec.Address_Line_2__c;
        String city = rec.City__c;
        String state = rec.State__c;
        String zip5 = rec.ZipCode__c;
        
        String BaseURL = 'http://production.shippingapis.com/ShippingAPI.dll?API=Verify&XML=';
        String ReturnValue = '<AddressValidateRequest USERID="' + '686SOFTS6413' + '"><Address>';
        
        ReturnValue += '<Address1>' + address1 + '</Address1>';
        ReturnValue += '<Address2>' + address2 + '</Address2>';
        ReturnValue += '<City>' + city + '</City>';
        ReturnValue += '<State>' + state + '</State>';
        ReturnValue += '<Zip5>' + zip5 + '</Zip5>';
        ReturnValue += '<Zip4>' + ''+ '</Zip4>';        
        ReturnValue += '</Address></AddressValidateRequest>';
        
        system.debug(ReturnValue);
        ReturnValue = EncodingUtil.urlEncode(ReturnValue, 'UTF-8');
        
        ReturnValue = BaseURL + ReturnValue;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ReturnValue);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        DOM.Document doc = new DOM.Document();
        doc.load(response.getBody());
        DOM.XmlNode rootNode=doc.getRootElement();
        parseXML(rootNode);
        List<string> errorLst = new List<String>();
        if(String.isNotBlank(error)) {
            errorLst.add(error);
        } else {
             errorLst.add('Verification Success');
        }
        return errorLst;
        
    }
    
    public static void parseXML(DOM.XMLNode node) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            
        system.debug(node.getName());
            
            if(node.getName()=='Error'){
            }
            if(node.getName()=='Description'){
                error = node.getText();
            }
            
        }
        
        if(node.getName()!='Description'){
        for (Dom.XMLNode child: node.getChildElements()) {
            parseXML(child);
        }
        }
    }
    
}