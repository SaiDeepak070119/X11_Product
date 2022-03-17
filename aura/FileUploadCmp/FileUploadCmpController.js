({
    removeFile: function (component, event, helper) {
        var fileListContentTemp = component.get("v.uploadedFileData");
        var selectedIndex = event.currentTarget.dataset.record;
        fileListContentTemp.splice(selectedIndex, 1);
        component.set("v.uploadedFileData", fileListContentTemp);
    },

    handleFilesChange: function (component, event, helper) {
        helper.handleFilesChange_helper(component, event, helper);
        /*var filesList = (event.target.files) || (event.dataTransfer.files);
        var wrapperObj;
        var childOption;
        var obj = {};
        if (filesList.length > 5) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Upload up to 5 files.",
                "type": "error"
            });
            toastEvent.fire();
            return;
        }

        EXIF.getData(filesList[0], function() {
            obj.Latitude = EXIF.getTag(this, "GPSLatitude");
            obj.Longitude = EXIF.getTag(this, "GPSLongitude");
            obj.LatitudeRef = EXIF.getTag(this, "GPSLatitudeRef");
            obj.LongitudeRef = EXIF.getTag(this, "GPSLongitudeRef");
            
            if($A.util.isArray(obj.Latitude) && $A.util.isArray(obj.Longitude)) {
                var latitude = obj.Latitude[0] + (obj.Latitude[1] * 60 + obj.Latitude[2])/3600;
                var longitude = obj.Longitude[0] + (obj.Longitude[1] * 60 + obj.Longitude[2])/3600;
                if(obj.LatitudeRef === 'S') {
                    latitude *= -1;
                }
                if(obj.LongitudeRef === 'W') {
                    longitude *= -1;
                }
                var locationMapCenter = {"lat": latitude, "lng": longitude};
                component.set('v.locationMapCenter', locationMapCenter);
                component.set('v.isLocationIdentifiedFromImage', true);
            }
            else if(obj.Latitude && obj.Longitude) {
                var locationMapCenter = {"lat": obj.Latitude, "lng": obj.Longitude};
                component.set('v.locationMapCenter', locationMapCenter);
                component.set('v.isLocationIdentifiedFromImage', true);
            }    
        });
        
        var reader = new FileReader();
        function readFile(index) {
            if (index >= filesList.length) {
                return;
            }
            var file = filesList[index];
            if (parseInt(file.size) > 5242880) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Upload files less then 5 MB",
                    "type": "error"
                });
                toastEvent.fire();
                return;
            }
            
            reader.onload = function (e) {
                var img = document.createElement("IMG");
                img.height = "100";
                img.width = "100";
                img.src = e.target.result;

                var canvas = document.createElement('canvas');
                var ctx = canvas.getContext('2d');
                var image = document.createElement('img');

                image.onload = function () {
                    var max_size = 600;
                    var width = image.width;
                    var height = image.height;
                    var ratio = 0;
                    if (parseInt(file.size) > ("700000", 700000)) {
                        if ((width > height) && (width > max_size)) {
                            ratio = max_size / width;

                            height = height * ratio;
                            width = width * ratio;
                        } else if (height > max_size) {
                            ratio = max_size / height;
                            width = width * ratio;
                            height = height * ratio;
                        }
                    } else {
                        width = image.width;
                        height = image.height;
                    }

                    canvas.width = width;
                    canvas.height = height;

                    ctx.drawImage(image, 0, 0, width, height);

                    var dataUrl;
                    var actualFileName = file.name.toLowerCase();
                    if (actualFileName.includes('jpg') || actualFileName.includes('jpeg')) {
                        dataUrl = canvas.toDataURL("image/jpeg", 1.0);
                    } else if (actualFileName.includes('gif')) {
                        dataUrl = canvas.toDataURL("image/gif", 1.0);
                    } else if (actualFileName.includes('png')) {
                        dataUrl = canvas.toDataURL("image/png", 1.0);
                    }
                    wrapperObj = {};
                    wrapperObj.fileName = file.name;
                    var tempFileType = [];
                    if (actualFileName.includes('.')) {
                        tempFileType = actualFileName.split('.')
                    }

                    wrapperObj.fileType = tempFileType[tempFileType.length - 1];

                    wrapperObj.fileData = dataUrl;


                    if (actualFileName.includes('png') ||
                        actualFileName.includes('jpg') ||
                        actualFileName.includes('jpeg') ||
                        actualFileName.includes('gif')) {
                        wrapperObj.showImage = true;
                    } else {
                        wrapperObj.showImage = false;
                    }

                    component.get('v.uploadedFileData').push(wrapperObj);
                    component.set('v.uploadedFileData', component.get('v.uploadedFileData'));
                    helper.getImagePrediction(component, event, helper);
                };

                image.src = URL.createObjectURL(file);
                readFile(index + 1)
            }
            reader.readAsDataURL(file);
        }
        readFile(0);*/
    }
})