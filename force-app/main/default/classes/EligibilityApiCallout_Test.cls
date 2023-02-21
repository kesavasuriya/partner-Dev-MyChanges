@isTest
public class EligibilityApiCallout_Test implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        // 
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{\"orderType\":\"courtorder\",\"finalStatus\":\"ELIGIBLEFORAREIMBURSEMENT\",\"courtStatus\":{\"eligibility\":\"EligibleReimbursable\",\"status\":\"PASS\",\"message\":1,\"remDtEarlierThnCtOrderDt\":\"Yes\"},\"homeRemoval\":{\"eligibility\":\"EligibleReimbursable\",\"status\":\"PASS\",\"message\":3,\"spRelClIdsameAsCtw\":\"Yes\"},\"demographics\":{\"eligibility\":\"EligibleReimbursable\",\"status\":\"PASS\",\"message\":5,\"usCorQA\":\"Yes\",\"ageDuringAFDCmonth\":16,\"childReceivingSSIOrSSADuringReviewPeriod\":\"Yes\",\"isTheAgencyTheRepresentativePayee\":\"Yes\",\"hasTheAgencyOptedToSuspendTheSSIPAymentAndClaimIVE\":\"Yes\"},\"deprivation\":{\"eligibility\":\"EligibleReimbursable\",\"status\":\"PASS\",\"message\":10,\"depParentalSupp\":\"Yes\",\"deprivationFactor\":\"Absence\"},\"familySizeAndSona\":{\"familySize\":3,\"sona\":517.0},\"income\":{\"eligibility\":\"EligibleReimbursable\",\"status\":\"PASS\",\"message\":16,\"totalAvailableIncome\":300.0},\"asset\":{\"eligibility\":\"EligibleReimbursable\",\"status\":\"PASS\",\"message\":18,\"assetValue\":250.0},\"placement\":{\"eligibility\":\"EligibleReimbursable\",\"status\":\"PASS\",\"message\":20,\"placementReimbursable\":\"Yes\",\"plcmntDtErlThnRemDtr\":\"No\"},\"removalType\":{\"eligibility\":\"EligibleReimbursable\",\"status\":\"PASS\",\"message\":24,\"type\":\"courtorder\"},\"ineligible\":0,\"nonReimburable\":0,\"eligibleReimbursable\":8}');
                    res.setStatusCode(400);
                    return res;
                    }
                    }