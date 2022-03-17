({
    doInit_Helper : function(component, event, helper){
        component.set('v.lcHost', window.location.hostname);
        window.addEventListener('message', function(event) {
            if(event.data.state == 'LOADED'){
                component.set('v.vfHost', event.data.vfHost);
                helper.sendToVF(component, {
                    locationOrigin: 'INIT',
                    mapData: component.get('v.mapData'),
                    mapOptionsCenter: component.get('v.mapOptionsCenter')
                });
                /*helper.sendToVF(component, {
                    mapData: component.get('v.mapData'),
                    mapOptionsCenter: component.get('v.mapOptionsCenter')
                });*/
                
                setTimeout(() => {
                    helper.getBrowserLocation(component, event);
                }, 4000);
            }
            else if(event.data.state == 'ADDRESSCHANGE'){
                helper.readValueFromVFPage(component, event);
            }
        }, false);
    },
    sendToVF : function(component, locationValues) {
        var message = {};
        
        /*if(component.get('v.selectedMapValues') != null) {
            var latval = component.get('v.selectedMapValues').latLong.lat;
            var longVal = component.get('v.selectedMapValues').latLong.lng;
            var mapOptionsCenter = {"lat":parseFloat(latval), "lng":parseFloat(longVal)};
            var mapData = Array();
            mapData.push({"lat":parseFloat(latval), "lng":parseFloat(longVal)})
        
            message = {
			            "loadGoogleMap" : true,
            			"mapData": mapData, 
            			"mapOptions": component.get('v.mapOptions'),  
                       	'mapOptionsCenter': mapOptionsCenter,
        		} ;
        }
        else {
            
        }*/
        
        const mapData = component.get('v.mapDateToPopulate');
        const LOCATION_ORIGIN = component.get('v.LOCATION_ORIGIN');
        const oldOrigin = (mapData && mapData.locationOrigin) ? LOCATION_ORIGIN[mapData.locationOrigin] : 0;
        const newOrigin = LOCATION_ORIGIN[locationValues.locationOrigin];
        
        if (mapData && newOrigin == 0) {
            component.set('v.mapData', [mapData.latLong]);
            component.set('v.mapOptionsCenter', mapData.latLong);
            locationOrigin = mapData.locationOrigin;
        }
        else if (newOrigin >= oldOrigin || newOrigin == 0) {
            component.set('v.mapData', locationValues.mapData || component.get('v.mapData'));
            component.set('v.mapOptionsCenter', locationValues.mapOptionsCenter || component.get('v.mapOptionsCenter'));
        }
        
        /*let mapData = locationValues.mapData ?  locationValues.mapData : component.get('v.mapData');
        let mapOptionCenter = locationValues.mapOptionsCenter ? locationValues.mapOptionsCenter : component.get('v.mapOptionsCenter');
        component.set('v.mapData', mapData);
        component.set('v.mapOptionsCenter', mapOptionCenter);*/
        message = {
            "loadGoogleMap" : true,
            "mapData": component.get('v.mapData'), 
            "mapOptions": component.get('v.mapOptions'),  
            'mapOptionsCenter': component.get('v.mapOptionsCenter'),
            "locationOrigin":locationValues.locationOrigin,
            "loadGoogleMap": true
        } ;
        this.sendMessage(component, message);
    },
    
    sendMessage: function(component, message){ 
        message.origin = window.location.hostname;
        var vfWindow = component.find("vfFrame").getElement().contentWindow;
        vfWindow.postMessage(message, component.get("v.vfHost"));
    },
    getBrowserLocation: function (component, event) {
        const userLocationSuccess = (location) => {
            const { latitude, longitude } = location.coords;
            const userLocation = { "lat": parseFloat(latitude), "lng": parseFloat(longitude) };
            // component.set('v.mapData', [userLocation]);
            // component.set('v.mapOptionsCenter', userLocation);
            this.sendToVF(component, {
                locationOrigin: 'BROWSER',
                mapData: [userLocation],
                mapOptionsCenter: userLocation
            });
        };
        const userLocationError = (error) => {
        };

        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(userLocationSuccess, userLocationError);
        }
    },
    readValueFromVFPage: function(component, event) {
        component.set("v.mapDataFromVFPage.address", event.data.address);
        component.set("v.mapDataFromVFPage.latLong", event.data.latLong);
        component.set("v.mapDataFromVFPage.postal", event.data.postal);
        component.set("v.mapDataFromVFPage.country", event.data.country);
        component.set("v.mapDataFromVFPage.cityName", event.data.cityName);
        component.set("v.mapDataFromVFPage.streetaddress", event.data.streetaddress);
        component.set("v.mapDataFromVFPage.streetNum", event.data.streetNum);
        component.set("v.mapDataFromVFPage.city", event.data.city);
        component.set("v.mapDataFromVFPage.stateVal", event.data.stateVal);
        component.set("v.mapDataFromVFPage.boundCheck", event.data.boundCheck);
        component.set("v.selectedMapValues", JSON.parse(JSON.stringify(event.data)))
        var childOption = component.getEvent("GoogleMapAddresChange");
        childOption.setParams({"mapDataToPass": component.get("v.mapDataFromVFPage")});
        childOption.fire();
	},
    getUploadedFileLocation: function (component, event) {
        const fileContent = event.getParam("fileContentToInsert").find((file) => file.position);
        if (fileContent) {
            //Send data to VF page to draw map
            this.sendToVF(component, {
                locationOrigin: 'IMAGE',
                mapData: [fileContent.position],
                mapOptionsCenter: fileContent.position
            });

        }
    }
})