({  
    submitCaseCreation: function (component, event, helper) {
	var that = this;
        this.callServer(component, "c.submitCase", function (result) {
            component.set("v.isSpinnerActive",true);
            var contactCaseNumber = JSON.parse(result);
            component.set("v.sCaseNumber", contactCaseNumber.CaseID);
            component.set("v.sContactId", contactCaseNumber.ContactID);
            var isAwsEnabled = $A.get("$Label.c.EnableAWSFileUpload");
            console.log('isAwsEnabled'+isAwsEnabled);
            var files =component.get("v.selectedFileList");
            var caseId = contactCaseNumber.CaseSFID;
            console.log('caseId'+caseId);
            if(isAwsEnabled == 'Yes')
            {
                if(contactCaseNumber.CaseID!=null || contactCaseNumber.CaseID!='')
                {
                    this.callawsservice(component,event,files,caseId);
                }
            }
            else{
                if (component.get("v.bIsPortalUser") === 'false') {
                    window.open(window.location.origin + '/lightning/r/Case/' + contactCaseNumber.CaseSFID + '/view?0.source=alohaHeader', '_self');
                }
                else if (result != null) {
                    that.fireAppEvent("e.c:X11_RI_StatusBarEvent", {"iStageIndentifier":4});
                }
            }
        },
        {
            sObjCase: component.get("v.objCase"),
            sFileLinks: JSON.stringify(component.get("v.selectedFileList")),
            sObjContact: JSON.stringify(component.get("v.objContact")),
            sCaseQuestionJSON: JSON.stringify(component.get("v.objCaseConfig"))
        });
    },

    bindScrollEvent: function () {
        const breadcrumWrapperElement = document.querySelector('.breadcrumb-wrap'),
            footer = document.querySelector('.footer'),
            footerRect = footer.getBoundingClientRect();
        if(footerRect.top <= (window.innerHeight || document.documentElement.clientHeight)) {
            breadcrumWrapperElement.classList.remove('sticky-breadcrumb');
        } 
        else {
            breadcrumWrapperElement.classList.add('sticky-breadcrumb');
        }
    },
    navigateToStage_Helper: function(cmp,event){
       var stage= event.currentTarget.dataset.id;
        this.fireAppEvent("e.c:X11_RI_StatusBarEvent", {"iStageIndentifier" : stage, "iAlreadySelected" : stage});
    },
    callawsservice : function(component,event,inputFile,recordId){
        sessionStorage.setItem("recordId", recordId);
        var amazonsetting = component.get("v.amazonsetting");
        
        var accesskey = amazonsetting.Access_Key__c;
        var secretkey = amazonsetting.Secret_Key__c;
        var region = amazonsetting.Region__c;
        var bucketname = amazonsetting.Bucket_Name__c;
        console.log('accesskey'+accesskey);
        console.log('secretkey'+secretkey);
        console.log('region'+region);
        console.log('In Helper'+JSON.stringify(amazonsetting));
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
        if(inputFile){
            console.log('inputFile '+JSON.stringify(inputFile) );
            
            
            var base64 = [];
            var blobs =[];
            for(var i =0;i<inputFile.length;i++)
            {
                
                var dataURI = inputFile[i].fileData;
                var byteString = atob(dataURI.split(',')[1]);
                
                var mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0];
                
                var byteNumbers = new Array(byteString.length);
                
                for (let i = 0; i < byteString.length; i++) {
                    byteNumbers[i] = byteString.charCodeAt(i);
                }
                var byteArray = new Uint8Array(byteNumbers);
                var blob = new Blob([byteArray],{type:mimeString});
                blobs.push(blob);
            }
            console.log('blobslength'+blobs.length);
            console.log('inputFilelength'+inputFile.length);
            
            if(blobs!=null && blobs.length === inputFile.length)
            {
                for(var i=0;i<inputFile.length;i++)
                {
                    var params = {
                        Key: inputFile[i].fileName,
                        Body: blobs[i]
                    }
                    bucket.upload(params).on('httpUploadProgress', function(evt) {
                        
                    }).send(function(err, data) {
                        console.log(err+ JSON.stringify(data));
                        if (!err) {
                            var fileURL = data.Location;
                            console.log('recordId '+sessionStorage.getItem("recordId"));
                            var action = component.get("c.UploadDoc");
                    action.setParams({
                        "claimId" : sessionStorage.getItem("recordId"),
                        "docURL" : fileURL
                    });
                    action.setCallback(this,function(response){
                        var state = response.getState();
                        console.log('satte '+state);
                        if(state === "SUCCESS"){
                            console.log(response);
                            if (component.get("v.bIsPortalUser") === 'false') {
                                window.open(window.location.origin + '/lightning/r/Case/' + sessionStorage.getItem("recordId") + '/view?0.source=alohaHeader', '_self');
                            }
                            else{
                                var appEvent = $A.get("e.c:X11_RI_StatusBarEvent");
                                appEvent.setParams({
                                    "iStageIndentifier" :4 });
                                appEvent.fire();
                                component.set("v.isSpinnerActive",false);  
                            }
                        }
                    });
                    $A.enqueueAction(action);
                        }
                        
                    });
                }
                
                
            }
            console.log('params '+JSON.stringify(params));
            
        }
        /*if(baseURL!=null && baseURL.length === inputFile.length)
        {
            console.log('baseURLbeforeevent '+baseURL);
            console.log('recordIdbeforeevent '+recordId);
            var awsEventParams = component.getEvent("AWSFileUploadEvent");
            awsEventParams.setParams({
                "claimId" : recordId,
                "baseURL" :  baseURL});
            awsEventParams.fire();  
            console.log('event fired'); 
        }*/
        //return false;
    }
})