({
    setPagesToShow : function(component) {
        var currentPageNumber = component.get('v.currentPageNumber');
        var numberOfRecordsPerPage = component.get('v.numberOfRecordsPerPage');
        var serviceRequests = component.get('v.serviceRequests');
        var totalPages = component.get('v.totalPages');
        
        var minimumPageNumber = 1;
        if(totalPages - currentPageNumber >= 2) {
            minimumPageNumber = currentPageNumber - 2;
        }
        else if(totalPages - currentPageNumber === 1) {
            minimumPageNumber = currentPageNumber - 3;
        }
        else if(totalPages - currentPageNumber === 0) {
            minimumPageNumber = currentPageNumber - 4;
        }
        minimumPageNumber = (minimumPageNumber <= 0) ? 1 : minimumPageNumber;
        
        var pagesToShow = [];
        for(var i = minimumPageNumber; pagesToShow.length < 5 && i <= totalPages; i++) {
            pagesToShow.push(i);
        }
        component.set('v.pagesToShow', pagesToShow);
    },
    showImagePreview : function(component,event,caseToAwsImageNames,images){
        var caseToImageNames = caseToAwsImageNames;
    	var imageList = images;
        var totallength=caseToImageNames.length+imageList.length;
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
        for(var i=0;i<caseToImageNames.length;i++)
        {
            let fileName = caseToImageNames[i].value;
            let currentCaseNumber = caseToImageNames[i].key;
            let params = {Key : fileName};
            bucket.getObject(params,function(err,file){
                var contentType = fileName[i].split('.')[1];
                var str = file.Body.reduce(function(a,b){
                    return a+String.fromCharCode(b)},'');
                str = btoa(str).replace('/.{76}(?=.)/g','$&\n');
                var dataUrl = "data:image/"+contentType+";base64," +str;
                
                imageList.push({key:currentCaseNumber,value:dataUrl});
                if(imageList.length === totallength)
                {
                	component.set("v.imageDataUrlList",imageList);
                }
            });
            
        }
    }
})