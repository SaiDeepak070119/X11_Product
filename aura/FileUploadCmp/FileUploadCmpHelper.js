({
	getImagePrediction : function (component, event, helper) {
    	var imagesLst = component.get('v.uploadedFileData');
        if(imagesLst.length > 0){
            var imageArray = imagesLst[0].fileData.split("base64,");
            this.callServer(component, 'c.getPrediction', function(result){
                if(result && result !== 'normal'){
                    component.set('v.predictedCaseType', result);
                }
            },{
                imageString: imageArray[1]
            })
        }
    },
    handleFilesChange_helper : function (component, event, helper) {
        component.set('v.isLoading', true);
    	let filesList = (event.target.files) || (event.dataTransfer.files);
        const uploadedImages = component.get('v.uploadedFileData').length;
        if (uploadedImages + filesList.length > 5) {
            moreFilesError.classList.toggle('slds-hide');
            component.set('v.isLoading', false);
            return;
        }
        helper.readFileUploads(component, event, helper, filesList)
    },
    readFileUploads : function(component, event, helper, filesList){
        let promiseArr = [];

        for (let index = 0; index < filesList.length; index++) {
            promiseArr.push(new Promise((resolve, reject) => {
                helper.readFile(component, event, helper, filesList, index, resolve, reject);
            }));
        }
        
        Promise.all(promiseArr)
                .then((imageMetaObj) => {
                let oldUploadedFiles = component.get('v.uploadedFileData');
                component.set('v.uploadedFileData', null);
                
                let allUploadedFiles = [...oldUploadedFiles, ...imageMetaObj];
                console.log('fileinfo'+JSON.stringify(allUploadedFiles));
                //component.get('v.uploadedFileData').push(...imageMetaObj);
                component.set('v.uploadedFileData', allUploadedFiles);
                this.getImagePrediction(component, event, helper);
                const fileUploadEvent = component.getEvent("FileUploadEvent");
                fileUploadEvent.setParams({ "uploadedFileData": allUploadedFiles });
                            fileUploadEvent.fire();
            
            setTimeout(() => {
                component.set('v.isLoading', false);
            }, 4000);
            })
                .catch(error => {
                console.error(error.message)
                setTimeout(() => {
                component.set('v.isLoading', false);
            }, 100);
            });
	},
	readFile: function (component, event, helper, filesList, index, resolve, reject) {

        const file = filesList[index]
        /*if (!helper.isFileValid(component, file)) {
            component.set('v.isLoading', false);
            return;
        }*/

        let imageMetaObj = {};
        const reader = new FileReader();

        const ConvertDMSToDD = (degrees, minutes, seconds, direction) => {
            let dd = degrees + (minutes / 60) + (seconds / 3600);
            if (direction == "S" || direction == "W") {
                dd = dd * -1;
            }
            return dd;
        };

        EXIF.getData(file, function () {
            const myData = this;
            if (myData.exifdata.GPSLatitude) {
                const latDegree = myData.exifdata.GPSLatitude[0].numerator;
                const latMinute = myData.exifdata.GPSLatitude[1].numerator;
                const latSecond = myData.exifdata.GPSLatitude[2].numerator / myData.exifdata.GPSLatitude[2].denominator;
                const latDirection = myData.exifdata.GPSLatitudeRef;

                const latFinal = ConvertDMSToDD(latDegree, latMinute, latSecond, latDirection);

                // Calculate longitude decimal
                const lonDegree = myData.exifdata.GPSLongitude[0].numerator;
                const lonMinute = myData.exifdata.GPSLongitude[1].numerator;
                const lonSecond = myData.exifdata.GPSLongitude[2].numerator / myData.exifdata.GPSLongitude[2].denominator;
                const lonDirection = myData.exifdata.GPSLongitudeRef;

                const lonFinal = ConvertDMSToDD(lonDegree, lonMinute, lonSecond, lonDirection);

                imageMetaObj.position = { "lat": parseFloat(latFinal.toFixed(4)), "lng": parseFloat(lonFinal.toFixed(4)) };
            } else {
                imageMetaObj.position = null;
            }
        });


        reader.onload = (e) => {

            let img = document.createElement("IMG");
            img.height = "100";
            img.width = "100";
            img.src = e.target.result;

            let canvas = document.createElement('canvas');
            let ctx = canvas.getContext('2d');
            let image = document.createElement('img');

            image.onload = () => {
                const max_size = 600;
                let width = image.width;
                let height = image.height;
                let ratio = 0;
                if (parseInt(file.size) > 500000) {
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

                let tempFileType = file.name.toLowerCase().split('.');

                imageMetaObj.fileData = canvas.toDataURL("image/jpeg", 0.5);
                imageMetaObj.fileName = file.name;
                imageMetaObj.showImage = true;
                imageMetaObj.fileType = tempFileType[tempFileType.length - 1];

                resolve(imageMetaObj);

            };
            image.src = URL.createObjectURL(file);
        }
        reader.readAsDataURL(file);
    }
                    
})