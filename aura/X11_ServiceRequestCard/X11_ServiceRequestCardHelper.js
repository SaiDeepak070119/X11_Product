({
    updateSlideToDisplay : function(component) {
		var index = component.get('v.currentImageSlideIndex');
        var elements = document.querySelectorAll('.service-request-image');
        elements.forEach(element => {
        	element.style.display = 'none'; 
        });
        elements[index].style.display = 'block';
	},
    showImagePreview : function(component,event,awsImageNames){
        console.log('fileNames are'+awsImageNames);
    	var imageList = [];
        var amazonsetting = component.get("v.amazonsetting");
        var accesskey = amazonsetting.Access_Key__c;
        var secretkey = amazonsetting.Secret_Key__c;
        var region = amazonsetting.Region__c;
        var bucketname = amazonsetting.Bucket_Name__c;
        AWS.config.accessKeyId = accesskey;
        AWS.config.secretAccessKey = secretkey;
        AWS.config.region = region;
        var baseURL =[];
        var s3 = new AWS.S3();
        var bucket = new AWS.S3({
            params: {
                Bucket: bucketname
            }
        });
        for(var i=0;i<awsImageNames.length;i++)
        {
            let fileName = awsImageNames[i];
            let params = {Key : fileName};
            bucket.getObject(params,function(err,file){
                var contentType = fileName.split('.')[1];
                var str = file.Body.reduce(function(a,b){
                    return a+String.fromCharCode(b)},'');
                str = btoa(str).replace('/.{76}(?=.)/g','$&\n');
                var dataUrl = "data:image/"+contentType+";base64," +str;
                
                imageList.push({key:fileName,value:dataUrl});
                
                console.log('lst'+JSON.stringify(imageList));
                component.set("v.imageDataUrlList",imageList);
            });
            
        }
    }
})