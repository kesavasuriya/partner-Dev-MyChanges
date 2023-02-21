public with sharing class DataService {
    
    public static List<SObject>  performQueryOperation(List<String> fieldsToQuery, String objectName, String conditionExpression, Integer queryLimit) {  
    
        
        List<SObject> queriedSObjResult = new List<SObject>();

        if (String.isNotBlank(objectName) && fieldsToQuery != null && fieldsToQuery.size() > 0) {

            String query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM ' + objectName;

            if(String.isNotBlank(conditionExpression)) {
                
                query += ' WHERE ' ; 
                
                String conditionUpperCase = conditionExpression.toUpperCase();
            	Integer orderPosition = conditionUpperCase.lastIndexOf('ORDER BY');
                if(orderPosition > -1) {
                
                 	query += conditionExpression.substring(0, orderPosition) + ' WITH SECURITY_ENFORCED '+ conditionExpression.substring(orderPosition);    
                } else {
                    query += conditionExpression + ' WITH SECURITY_ENFORCED';
                }
            }
            query +=  ' LIMIT ' + queryLimit;
            queriedSObjResult = Database.query(query);
        } 
        return queriedSObjResult;
    }
}