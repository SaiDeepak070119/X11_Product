public class JWTBearerFlow {

    public static String getAccessToken(String tokenEndpoint, JWT jwt) {
    
        String access_token = null;
        String body = 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=' + jwt.issue();
        HttpRequest req = new HttpRequest();                            
        req.setMethod(Einstein_GlobalConstants.REST_CONNECTION_TYPE_POST);
        req.setEndpoint(tokenEndpoint);
        req.setHeader(Einstein_GlobalConstants.CONTENT_TYPE, 'application/x-www-form-urlencoded');
        req.setBody(body);
        Http http = new Http();               
        HTTPResponse res = http.send(req);
        
        if ( res.getStatusCode() == 200 ) {
            System.JSONParser parser = System.JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == Einstein_GlobalConstants.ACCESS_TOKEN_TEXT)) {
                    parser.nextToken();
                    access_token = parser.getText();
                    break;
                }
            }
        }
        return access_token;
        
    }

}