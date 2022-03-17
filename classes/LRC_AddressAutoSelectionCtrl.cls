/**
 * Name : LRC_AddressAutoSelectionCtrl 
 * Description: This class will be used to provide the methods for callouts of Auto Address Completion
 */
public with sharing class LRC_AddressAutoSelectionCtrl {
    
    /*
     * Name : getAddressConfigurations 
     * Description: This method will be used to get address related Configurations
     */
    public static Map<String,String> getAddressConfigurations(){
        Map<String,String> mapAddressConfigurations = new Map<String,String>();
        try {
            List<LRC_AddressConfiguration__mdt> lstAddressConfigurations = [SELECT MasterLabel, DeveloperName, Key__c, Value__c FROM LRC_AddressConfiguration__mdt LIMIT 50000];
            for(LRC_AddressConfiguration__mdt adConfig : lstAddressConfigurations) {
                mapAddressConfigurations.put(adConfig.Key__c, adConfig.Value__c);
            }
            return mapAddressConfigurations;
        }
        catch(System.Exception e) {
            return mapAddressConfigurations;
        }
    }
    
    /*
     * Name : getAddressDetailsFromPlaceId 
     * Description: This method will be used to get address (street,city,country,zipcode,geolocation) 
     *              using the Place Id generated during address Selection
     */
    
    @AuraEnabled
    public static String getAddressDetailsFromPlaceId(String placeId, String selectedAddress) {
        Map<String,String> mapAddressConfigurations = getAddressConfigurations();
        String addressDetailsFromPlaceIdUrl = mapAddressConfigurations.get(LRC_Constants.GOOGLEADDRESSDETAILSFROMPLACEIDURL);
        String googleAPIKey = mapAddressConfigurations.get(LRC_Constants.GOOGLEAPIKEY);
        try {
            String url = addressDetailsFromPlaceIdUrl + '?placeid=' + String.escapeSingleQuotes(placeId) + '&key=' + googleAPIKey;
            String addressResult = sendHTTPRequest(url);

            Map<String, Object> mapAddressResults = (Map<String, Object>)JSON.deserializeUntyped(addressResult);
            if(mapAddressResults.get(LRC_Constants.RESULT) == null || mapAddressResults.get(LRC_Constants.RESULT) == '') {
                return null;
            }

            Map<String, Object> mapAddressComponents = (Map<String, Object>)mapAddressResults.get(LRC_Constants.RESULT);
            List<Object> lstAddressComponents = (List<Object>)mapAddressComponents.get(LRC_Constants.ADDRESSCOMPONENTS);
            if(lstAddressComponents.size() == 0) {
                return getAddressDetailsFromString(String.escapeSingleQuotes(selectedAddress));
            }

            Map<String,String> mapAddressValues = getMapAddressValues(lstAddressComponents);
            if(mapAddressValues.get(LRC_Constants.STREET)!= null && mapAddressValues.get(LRC_Constants.CITY)!= null
                && mapAddressValues.get(LRC_Constants.STATE)!= null && mapAddressValues.get(LRC_Constants.COUNTY)!= null
                && mapAddressValues.get(LRC_Constants.COUNTRY)!= null && mapAddressValues.get(LRC_Constants.POSTALCODE)!= null) {
                    return addressResult;
            }
            
            return getAddressDetailsFromString(String.escapeSingleQuotes(selectedAddress));
        }
        catch(System.Exception e) {
            X11_Utility.logError(e, 'X11_CustomLogin_Ctrl', 'logIntoCommunity'); 
            return null;
        }
    }

    private static Map<String,String> getMapAddressValues(List<Object> lstAddressComponents) {
        Map<String, String> mapAddressValues = new Map<String,String>();
        for(Object adObj : lstAddressComponents) {
            Map<String,object> mapAdCompRecords = (Map<String, Object>)adObj;
            List<Object> lstTypes = (List<Object>)mapAdCompRecords.get(LRC_Constants.TYPES);
            if(lstTypes.contains(LRC_Constants.ROUTE)) {
                mapAddressValues.put(LRC_Constants.STREET, String.valueOf(mapAdCompRecords.get(LRC_Constants.LONGNAME)));
            }
            if(lstTypes.contains(LRC_Constants.LOCALITY)) {
                mapAddressValues.put(LRC_Constants.CITY, String.valueOf(mapAdCompRecords.get(LRC_Constants.LONGNAME)));
            }
            if(lstTypes.contains(LRC_Constants.ADMINISTRATIVEAREALEVEL1)) {
                mapAddressValues.put(LRC_Constants.STATE, String.valueOf(mapAdCompRecords.get(LRC_Constants.LONGNAME)));
            }
            if(lstTypes.contains(LRC_Constants.ADMINISTRATIVEAREALEVEL2)) {
                mapAddressValues.put(LRC_Constants.COUNTY, String.valueOf(mapAdCompRecords.get(LRC_Constants.LONGNAME)));
            }
            if(lstTypes.contains(LRC_Constants.COUNTRY)) {
                mapAddressValues.put(LRC_Constants.COUNTRY,String.valueOf(mapAdCompRecords.get(LRC_Constants.LONGNAME))); 
            }
            if(lstTypes.contains(LRC_Constants.POSTALCODE)) {
                mapAddressValues.put(LRC_Constants.POSTALCODE, String.valueOf(mapAdCompRecords.get(LRC_Constants.LONGNAME))); 
            }
        }
        return mapAddressValues;
    }

    /*
     * Name : getAddressDetailsFromString
     * Description: This method will be used to get address (street,city,country,zipcode,geolocation) 
     *              using the address generated during address Selection
     */
    
    @AuraEnabled
    public static String getAddressDetailsFromString(String selectedAddress) {
        Map<String,String> mapAddressConfigurations = getAddressConfigurations();
        String addressDetailsUrl = mapAddressConfigurations.get(LRC_Constants.GOOGLEADDRESSDETAILSFROMPLACEIDURLOLDAPI);
        String googleAPIKey = mapAddressConfigurations.get(LRC_Constants.GOOGLEAPIKEY);

        try {
            String url = addressDetailsUrl + '?address='
                                    + EncodingUtil.urlEncode(String.escapeSingleQuotes(selectedAddress), LRC_Constants.UTF8)
                                    + '&key=' + googleAPIKey;
                    
            return sendHTTPRequest(url);
        }
        catch(System.Exception e) {
            X11_Utility.logError(e, 'X11_CustomLogin_Ctrl', 'logIntoCommunity');  
            return '';
        }
    }
    
    /*
     * Name : getAddressAutoComplete 
     * Description: This method will be used to get Search Results for auto Address text entered by user using GoogleMaps API
     */
    @AuraEnabled
    public static String getAddressAutoComplete(String input, String countryCode) {
        try {
            Map<String,String> mapAddressConfigurations = getAddressConfigurations();
            String addressAutoCompleteURL = mapAddressConfigurations.get(LRC_Constants.GOOGLEAUTOCOMPLETEURL);
            String googleAPIKey = mapAddressConfigurations.get(LRC_Constants.GOOGLEAPIKEY);

            String strAutoComplete = addressAutoCompleteURL + '?input='
                                        + EncodingUtil.urlEncode(String.escapeSingleQuotes(input), LRC_Constants.UTF8)
                                        + '&key=' + googleAPIKey;

            if(countryCode != LRC_Constants.NONE) {
                strAutoComplete = strAutoComplete + '&components=country:' + String.escapeSingleQuotes(countryCode);
            }
            
            return sendHTTPRequest(strAutoComplete);
        }
        catch(System.Exception e) {
            X11_Utility.logError(e, 'LRC_AddressAutoSelectionCtrl', 'getAddressAutoComplete'); 
            return '';
        }
    }
    
    /*
     * Name : sendHTTPRequest 
     * Description: This method will be used to provide the methods for callouts of Auto Address Completion
     */
    public static String sendHTTPRequest(String url) {
        HttpResponse response;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(String.escapeSingleQuotes(url));
        req.setMethod(LRC_Constants.GETREQUEST);
        try {
            Http http = new Http();
            if(!Test.isRunningTest()) {
                response = http.send(req);
            }
            else {
                response = new HttpResponse();
                response.setBody('{ "results" : [{ "address_components" : [ { "long_name" : "404", "short_name" : "404", "types" : [ "street_number" ] }, { "long_name" : "Frankfort Avenue", "short_name" : "Frankfort Ave", "types" : [ "route" ] }, { "long_name" : "Butchertown", "short_name" : "Butchertown", "types" : [ "neighborhood", "political" ] }, { "long_name" : "Louisville", "short_name" : "Louisville", "types" : [ "locality", "political" ] }, { "long_name" : "Jefferson County", "short_name" : "Jefferson County", "types" : [ "administrative_area_level_2", "political" ] }, { "long_name" : "Kentucky", "short_name" : "KY", "types" : [ "administrative_area_level_1", "political" ] }, { "long_name" : "United States", "short_name" : "US", "types" : [ "country", "political" ] }, { "long_name" : "40206", "short_name" : "40206", "types" : [ "postal_code" ] } ], "formatted_address" : "404 Frankfort Ave, Louisville, KY 40206, USA", "geometry" : { "location" : { "lat" : 38.2644825, "lng" : -85.72534570000001 }, "location_type" : "RANGE_INTERPOLATED", "viewport" : { "northeast" : { "lat" : 38.2658314802915, "lng" : -85.72399671970851 }, "southwest" : { "lat" : 38.2631335197085, "lng" : -85.72669468029152 } } }, "partial_match" : true, "place_id" : "", "types" : [ "street_address" ] },{ "geometry" : { "location" : {"lat" : 37.7787937,"lng" : -122.4216864} } }],"result" :  { "address_components" : [ { "long_name" : "404", "short_name" : "404", "types" : [ "street_number" ] }, { "long_name" : "Frankfort Avenue", "short_name" : "Frankfort Ave", "types" : [ "route" ] }, { "long_name" : "Butchertown", "short_name" : "Butchertown", "types" : [ "neighborhood", "political" ] }, { "long_name" : "Louisville", "short_name" : "Louisville", "types" : [ "locality", "political" ] }, { "long_name" : "Jefferson County", "short_name" : "Jefferson County", "types" : [ "administrative_area_level_2", "political" ] }, { "long_name" : "Kentucky", "short_name" : "KY", "types" : [ "administrative_area_level_1", "political" ] }, { "long_name" : "United States", "short_name" : "US", "types" : [ "country", "political" ] }, { "long_name" : "40206", "short_name" : "40206", "types" : [ "postal_code" ] } ], "formatted_address" : "404 Frankfort Ave, Louisville, KY 40206, USA", "geometry" : { "location" : { "lat" : 38.2644825, "lng" : -85.72534570000001 }, "location_type" : "RANGE_INTERPOLATED", "viewport" : { "northeast" : { "lat" : 38.2658314802915, "lng" : -85.72399671970851 }, "southwest" : { "lat" : 38.2631335197085, "lng" : -85.72669468029152 } } }, "partial_match" : true, "place_id" : "", "types" : [ "street_address" ] },"status" : "OK" }');
            }
        }
        catch(System.Exception e) {
            return e.getMessage();
        }
        return response.getBody();
    }
}