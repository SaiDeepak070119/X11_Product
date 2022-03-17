public class X11_EinsteinPrediction_Controller {

    public static String getAccessToken(){
        try{
            String access_token;
            List<Document> documentLst = [Select Id,Body from Document WHERE DeveloperName = 'einstein_platform'];
            if(documentLst.size() > 0){
                String keyValue = documentLst[0].Body.toString();
                keyValue = keyValue.replace('-----BEGIN RSA PRIVATE KEY-----', '');
                keyValue = keyValue.replace('-----END RSA PRIVATE KEY-----', '');
                keyValue = keyValue.replace('\n', '');
                
                JWT jwt = new JWT('RS256');
                jwt.pkcs8 = keyValue; // Comment this if you are using jwt.cert
                jwt.iss = 'developer.force.com';
                jwt.sub = 'skorgaonkar@deloitte.com';
                jwt.aud = 'https://api.einstein.ai/v2/oauth2/token';
                jwt.exp = '3600';
                access_token = JWTBearerFlow.getAccessToken('https://api.einstein.ai/v2/oauth2/token', jwt);
            }
            return access_token;
        }catch(Exception e){
            System.debug(e.getMessage());
            return null;
        }
    }
    
    @AuraEnabled
    public static String getPrediction(String imageString){
        try{
            String modelIdValues = System.Label.Model_Id;
            if(!String.isBlank(modelIdValues)){
                List<String> modelIdLst = (modelIdValues.contains(';')) ? modelIdValues.split(';') : new List<String>{modelIdValues};
                    System.debug('modelIdLst' + modelIdLst);
                if(modelIdLst.size() > 0){
                    System.debug('modelIdLst' + modelIdLst);
                	String accessToken = getAccessToken();
                    System.debug('accessToken' + accessToken);
                    String predictionCaseType = '';
                    Integer i = 0;
                    for(String modelId: modelIdLst){
                        List<Vision.Prediction> lstPrediction = Vision.predictBlob(EncodingUtil.base64Decode(imageString),accessToken,modelId);
                        if(lstPrediction.size() > 0){
                            predictionCaseType = lstPrediction[0].label; 
                            i++;
                            System.debug('::-->'+i+' -- '+predictionCaseType);
                            if(i > 1){
                                return predictionCaseType;     
                            }
                        }
                    }
                     
                }
            }
            return JSON.serialize(new List<Vision.Prediction>());
        }catch(Exception e){
            System.debug(e.getMessage());
            return JSON.serialize(new List<Vision.Prediction>());
        }
    }
}